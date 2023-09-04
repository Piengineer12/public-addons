# Setting Up ConVars Using CCVCCM
All var / command adding methods should return a class containing the variable / command.
This will minimize the use of GetConVar which needs to take in arguments involving addons, categories and whatnot.
```lua
-- this hook will run during Initialize if CCVCCM is present
-- the next methods in this group should run in this hook
hook.Add("CCVCCMRun", "uniqueIdentifier", function() --[[...]] end)

-- prefix for all ConVars / ConCommands that will be added by this addon
-- addon_name will be added as a root tab in CCVCCM if it doesn't exist
-- the second argument dictates what's displayed in CCVCCM as the addon name and ideally should only be done once
-- the third argument controls the icon
-- this will also pop any existing categories
CCVCCM:SetAddon("addon_name", "Addon Name", "icon16/star.png")

-- all ConVars / ConCommands inserted after this will be part of a category
-- internal names will be prefixed with _category_name (after the addon prefix) while
-- the second argument will be what's displayed in CCVCCM
-- if the third argument is true, CCVCCM will insert the category as a tab instead of a list of collapsible categories
-- the fourth argument controls the icon IF within a category that supports icons
-- both the second and third arguments should only be provided once
CCVCCM:PushCategory("category_name", "Category Name", true, "icon16/star.png")

-- all ConVars / ConCommands inserted after this will not be part of the previous category
-- raises an error if not in a category
-- if a number is provided, indicates the number of categories to pop
-- -1 will pop any existing categories
CCVCCM:PopCategory()

-- equivalent to CCVCCM:PopCategory() CCVCCM:PushCategory(...), but will not call CCVCCM:PopCategory() if not currently in a category
CCVCCM:NextCategory("category_name", "Category Name", true, "icon16/star.png")

-- adds a ConVar
-- overwrites if the full name is already registered in CCVCCM
CCVCCM:AddConVar("convar_name", {
    realm = "server", -- one of "client", "server" or "shared", default: server
        -- for consistency reasons, "shared" will automatically mark the CVar as replicated and only modifiable on the server's side
        -- if realm == "client" and userInfo ~= true, the server won't add the CVar on its end
        -- WARNING: if realm == "server", this still needs to be called SHARED to be added in the client's CCVCCM!
    name = "Display Name",
    help = "Description of ConVar",
    default = "default",
    manual = true,
    type = "string", -- one of "bool", "keybind", "int", "float", "string"
    choices = {{"Display Name 1", "value1"}, {"Display Name 2", "value2"}}, -- if specified, CCVCCM will show list of choices for this ConVar
    min = 1, -- only for int and float types
    max = 10, -- only for int and float types
    interval = 0.01, -- only for int and float types, sets the interval for CCVCCM
    logarithmic = true, -- only for int and float types, if specified, CCVCCM displays a logarithmic slider
        -- if min * max <= 0, raises an error
    clamp = true, -- only for int and float types, if specified, will force ConVar values to be limited to min and max
        -- default: false for float type, true for int type
    sep = " ", -- if specified, CCVCCM:GetConVarValue will return a table of the specified type
        -- only applicable for int, float and string types
    uiOnly = true, -- if true, this will not add a ConVar

    userInfo = true, -- only if realm == "client"
    notify = true,
    hide = "client server console log",
    flags = "cheat nosave sp control demo nodemo",
        -- cheat: implies nosave
        -- control: error if realm == "shared", userInfo == true or notify == true
        -- nodemo: error if demo is specified
})

-- adds a ConCommand
-- overwrites if the full name is already registered in CCVCCM
CCVCCM:AddConCommand("concommand_name", {
    -- the same fields as above, with some differences:
    -- default, manual, userInfo, notify are not valid keys
    type = "none", -- "none" is valid
    func = function(ply, cmd, args, argStr) --[[...]] end,
    autoComplete = function(cmd, argStr) --[[...]] end,
    hide = "console log",
    flags = "cheat sp demo nodemo"
})

-- adds a addon variable - this variable can't be modified in the console, but allows for very complex typing
-- overwrites if the full name is already registered in CCVCCM
CCVCCM:AddAddonVar("var_name", {
    realm = "server", -- one of "client", "server" or "shared", default: server
    name = "Display Name",
    help = "Description",
    default = "default",
    manual = true,
    typeInfo = {
        name = "Display Name", -- displayed as button text / type help text
        help = "Description", -- displayed as header text, only valid when type == nil
        type = "string", -- one of "bool", "keybind", "number", "string" or nil
        choices = {{"Display Name 1", "value1"}, {"Display Name 2", "value2"}}, -- only when type ~= nil
        min = 1, -- only when type == "number"
        max = 10, -- only when type == "number"
        interval = 0.01, -- only when type == "number"
        logarithmic = true, -- only when type == "number"
        {} -- if nested typeInfo tables are supplied, this will be presented as a list of types
        -- type = "keybind" is not implemented here
    },
    userInfo = true,
    notify = true,
    flags = "cheat nosave sp",
        -- cheat: implies nosave
})

-- adds an addon command
-- overwrites if the full name is already registered in CCVCCM
CCVCCM:AddAddonCommand("command_name", "default", {
    -- the same fields as above, with some differences:
    -- default, manual, userInfo, notify are not valid keys
    typeInfo = {}, -- an empty table can be specified
    func = function(ply, cmd, args) --[[...]] end,
    -- userInfo, notify are not valid keys
    flags = "cheat sp"
})
```

# Using ConVars With CCVCCM
Unlike the above methods, these should only be called AFTER the CCVCCMRun hook is finished.
```lua
-- returns a CCVCCMPointer instance
-- a CCVCCMPointer already gets returned from the CCVCCM:Add* methods above
-- note that the CCVCCMPointer constructor is only accessible to CCVCCM
CCVCCM:Pointer("addon_name", {"category_name"}, "name")

-- returns the current var value
CCVCCMPointer:Get()

-- sets the var value and returns the previous value
CCVCCMPointer:Set("value")

-- sets the var value to the default value
CCVCCMPointer:Revert()

-- callback when the value is changed
CCVCCMPointer:AddChangeCallback("id", function(ptr, oldValue, newValue) end)

-- remove a callback
CCVCCMPointer:RemoveChangeCallback("id")

-- runs the command with the passed value
CCVCCMPointer:Run(value)

-- returns the value of var_name as a bool / number / string / table
-- depending on the type specified in CCVCCM:Add*Var
CCVCCM:GetVarValue("addon_name", {"categories"}, "var_name")

-- sets the value of a registered var
CCVCCM:SetVarValue("addon_name", {"categories"}, "var_name", "value")

-- reverts the value of a registered var
-- can also revert all ConVars and AddonVars of a specific addon or category
CCVCCM:RevertVarValue("addon_name", {"categories (optional)"}, "var_name (optional)")
```

# (Internal) API Data Handling
While the order of addons isn't too important to be saved, the order of categories and variables are.

Also, there needs to be a way such that "category_convar" and "convar" with category "category" mean the same thing,
while GetConVarValue needs to read the data table too.
```json
{ //#=1
    "<name>": {
        "name": "<>",
        "icon": "<>",
        "categories": "#=1",
        "categoriesOrder": ["<name>", "..."],
        "categoriesUseTab": true,
        "registered": {
            "<name>": {
                "type": "<>",
                "data": "{data}"
            }
        },
        "registeredOrder": ["<name>", "..."]
    }
}
```

# (Internal) Structure of Save Tables
```json
[
	{
		"displayName": "<string>",
		"icon": "<string>",
		"content": [
			{
				"type": "text",
				"displayName": "<string>"
			},
			{
				"type": "category",
				"displayName": "<string>",
				"content": []
			},
			{
				"type": "tabs",
				"tabs": [
					{
						"displayName": "<string>",
						"icon": "<string>",
						"content": []
					}
				]
			},
			{
				"type": "clientConVar / clientConCommand / serverConVar / serverConCommand",
				"internalName": "<string>",
				"displayName": "<string>",
                "manual": true,
				"dataType": "none / bool / choices / number / string / stringList",
				"arguments": "<string>",
				"choices": [
					["<string>", "<string>"],
					["<string>", "<string>"],
					["..."]
				],
				"minimum": "<number>",
				"maximum": "<number>",
				"interval": "<number>",
				"logarithmic": true
			},
			{
				"type": "complex",
				"internalName": "<string>",
				"realm": "client / server / shared",
				"dataType": "<dataType>(bool / choices / number / string) / [<dataType>, <dataType>, ...]",
			}
		]
	}
]
```

# (Internal) Structure required by ListInputUI
```json
{
    "header": "headerText",
    "names": ["columnName1", "columnName2", "..."],
    "types": [
        {
            "dataType": "DTYPE",
            "choices": [["key1", "value1"], ["key1", "value1"]],
            "min": 0,
            "max": 10,
            "interval": 0.01,
            "logarithmic": false,
            "header": "headerText",
            "names": ["columnName1", "columnName2", "..."],
            "types": [
                {
                    "dataType": "DTYPE",
                    "choices": [["key1", "value1"], ["key1", "value1"]],
                    "min": 0,
                    "max": 10,
                    "interval": 0.01,
                    "logarithmic": false,
                    "header": "headerText",
                    "names": ["columnName1", "columnName2", "..."],
                    "types": ["..."]
                }
            ]
        },
        {
            "dataType": "DTYPE",
            "choices": [["key1", "value1"], ["key1", "value1"]],
            "min": 0,
            "max": 10,
            "interval": 0.01,
            "logarithmic": false,
            "header": "headerText",
            "names": ["columnName1", "columnName2", "..."],
            "types": []
        },
        "..."
    ]
    //
}
```