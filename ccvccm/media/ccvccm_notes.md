# Setting Up ConVars Using CCVCCM
```lua
-- this hook will run during Initialize if CCVCCM is present
-- at this point CCVCCM will be fully initialized and you can add ConVars
hook.Add("CCVCCMRun", "uniqueIdentifier", function() --[[...]] end)

-- prefix for all ConVars / ConCommands that will be added by this addon
-- this will also pop all declared categories
-- addon_name will be added as a root tab in CCVCCM if it doesn't exist
-- the second argument is optional and dictates the addon's nice name, this argument only needs to be passed once anytime
-- the third argument is optional and controls the addon icon displayed in CCVCCM, this argument only needs to be passed once anytime
CCVCCM:SetAddon("addon_name", "Addon Name", "icon16/star.png")

-- all ConVars / ConCommands inserted after this will be part of a category
-- internal names will be prefixed with _category_name (after the addon prefix) while
-- the second argument is optional and dictates the category's nice name
-- the third argument is optional, a true value will make CCVCCM insert the category as a tab instead of a collapsible category
-- if tabs are used, the fourth argument controls the icon
CCVCCM:PushCategory("category_name", "Category Name", true, "icon16/star.png")

-- all ConVars / ConCommands inserted after this will not be part of the previous category
-- raises an error if not in a category
-- if a number is provided, indicates the number of categories to pop
-- -1 will pop all existing categories
CCVCCM:PopCategory()

-- equivalent to CCVCCM:PopCategory() CCVCCM:PushCategory(...), but will not call CCVCCM:PopCategory() if not currently in a category
CCVCCM:NextCategory("category_name", "Category Name", true, "icon16/star.png")

-- adds a ConVar
-- overwrites if the full name is already registered in CCVCCM
CCVCCM:AddConVar("convar_name", {
    realm = "server", -- one of "client", "server" or "shared", default: server
        -- for consistency reasons, "shared" will automatically mark the CVar as replicated and only modifiable on the server's side
        -- WARNING: even if realm == "server", this still needs to be called SHARED to be added in the client's CCVCCM!
    name = "Display Name", -- default: full name of ConVar
    fullName = "addon_categories_name", -- changes how this is referred to by CCVCCM:GetVarValue() and the like
        -- will not affect CCVCCM:RevertByAddonAndCategory() behaviour
    help = "Description of ConVar", -- optional
    default = "default", -- MUST be provided
    manual = true, -- optional
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
    generate = true, -- if true, this will generate a ConVar in addition to the ConVar being added to CCVCCM

    userInfo = true, -- only if realm == "client"
    notify = true, -- optional
    hide = "client server console log", -- optional
    flags = "cheat nosave sp control demo nodemo", -- optional
})

-- adds a ConCommand
-- overwrites if the full name is already registered in CCVCCM
CCVCCM:AddConCommand("concommand_name", {
    -- the same fields as above, with some differences:
    -- default, manual, userInfo, notify are not valid keys
    type = "none", -- "none" is valid
    func = function(ply, cmd, args, argStr) --[[...]] end, -- required
    autoComplete = function(cmd, argStr) --[[...]] end, -- optional
    hide = "console log", -- optional
    flags = "cheat sp demo nodemo" -- optional
})

-- adds a addon variable - this variable can't be modified in the console, but allows for very complex typing
-- overwrites if the full name is already registered in CCVCCM
CCVCCM:AddAddonVar("var_name", {
    realm = "server", -- one of "client", "server" or "shared", default: server
    name = "Display Name", -- default: full name of AddonVar
    fullName = "addon_categories_name", -- changes how this is referred to by CCVCCM:GetVarValue() and the like
    help = "Description", -- optional
    default = "default", -- MUST be provided
    manual = true, -- optional
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
    userInfo = true, -- only if realm == "client"
    notify = true, -- optional
    flags = "cheat nosave sp", -- optional
    func = function(arg, fullName, ply) --[[...]] end, -- runs every time a value is set
        -- ply is only defined serverside for client addonvars with userInfo = true
})

-- adds an addon command
-- overwrites if the full name is already registered in CCVCCM
CCVCCM:AddAddonCommand("command_name", "default", {
    -- the same fields as above, with some differences:
    -- default, manual, userInfo, notify are not valid keys
    func = function(ply, arg, fullName) --[[...]] end, -- required
    typeInfo = {}, -- an empty table can be specified
    -- userInfo, notify are not valid keys
    flags = "cheat sp" -- optional
})
```

# Using ConVars With CCVCCM
Unlike the above methods, these should only be called AFTER the CCVCCMRun hook is finished.
```lua
-- returns a CCVCCMPointer instance
-- a CCVCCMPointer already gets returned from the CCVCCM:Add* methods above
-- note that the CCVCCMPointer constructor itself is private
CCVCCM:Pointer("addon_categories_name")

-- returns the current var value
CCVCCMPointer:Get(ply)

-- sets the var value
CCVCCMPointer:Set(value)

-- sets the var value to the default value
CCVCCMPointer:Revert()

-- runs the command with the passed value
CCVCCMPointer:Run(value, ply)

-- returns the value of var_name as a bool / number / string / table
-- depending on the type specified in CCVCCM:Add*Var
CCVCCM:GetVarValue("addon_categories_name")

-- sets the value of a registered var
CCVCCM:SetVarValue("addon_categories_name", "value")

-- reverts the value of a registered var
CCVCCM:RevertVarValue("addon_categories_name")

-- reverts all ConVars and AddonVars of a specific addon (and optionally category)
CCVCCM:RevertByAddonAndCategory("addon", "[category1]", "[category2]")
```