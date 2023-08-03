# Setting up ConVars using CCVCCM
```lua
-- this hook will run during Initialize if CCVCCM is present
-- the next methods in this group *must* run in this hook
hook.Add("CCVCCMRun", "uniqueIdentifier", function() --[[...]] end)

-- prefix for all ConVars / ConCommands that will be added by this addon
-- addon_name will be added as a root tab in CCVCCM if it doesn't exist
-- the second argument dictates what's displayed in CCVCCM as the addon name
-- this will also pop any existing categories
CCVCCM:SetAddon("addon_name", "Addon Name")

-- adds a ConVar
CCVCCM:AddConVar("convar_name", "default", {
    realm = "server", -- one of "client", "server" or "shared", default: server
        -- for consistency reasons, "shared" will automatically mark the CVar as replicated and only modifiable on the server's side
        -- if realm == "client" and userInfo ~= true, the server won't add the CVar on its end
        -- WARNING: if realm == "server", this still needs to be called SHARED to be added in the client's CCVCCM!
    name = "Display Name",
    help = "Description of ConVar",
    type = "string", -- one of "bool", "int", "float", "string"
    choices = {{"Display Name 1", "value1"}, {"Display Name 2", "value2"}}, -- if specified, CCVCCM will show list of choices for this ConVar
    min = 1, -- only for int and float types
    max = 10, -- only for int and float types
    interval = 0.01, -- only for int and float types, sets the interval for CCVCCM
    logarithmic = true, -- only for int and float types, if specified, CCVCCM displays a logarithmic slider
        -- if min * max <= 0, raises an error
    clamp = true, -- only for int and float types, if specified, will make internal ConVar values limited to min and max
        -- default: false for float type, true for int type
    sep = " ", -- if specified, CCVCCM:GetConVarValue will return a table of the specified type
    confirm = true, -- if specified, this ConVar requires confirmation in CCVCCM before changes are applied
    userInfo = true, -- only if realm == "client"
    notify = true,
    hide = "client server console log",
    flags = "cheat nosave sp control demo nodemo",
        -- cheat: implies nosave
        -- control: error if realm == "shared", userInfo == true or notify == true
        -- nodemo: error if demo is specified
})

-- adds a ConCommand
CCVCCM:AddConCommand("concommand_name", "default", {
    -- the same fields as above, with some differences:
    type = "none", -- "none" is valid
    -- confirm, sharing, notify are not valid keys
    hide = true, -- hide from the console
    flags = "cheat sp demo nodemo"
})

-- adds a modifiable variable - this variable can't be modified in the console, but allows for very complex typing
CCVCCM:AddAddonVar("var_name", "default", {
    realm = "server", -- one of "client", "server" or "shared", default: server
    name = "Display Name",
    help = "Description",
    typeInfo = {
        type = "string",
        choices = {{"Display Name 1", "value1"}, {"Display Name 2", "value2"}},
        min = 1,
        max = 10,
        interval = 0.01,
        logarithmic = true,
        {} -- if typeInfo tables are supplied, this will instead be presented as a list of types
    },
    userInfo = true,
    notify = true,
    hide = "client server",
    flags = "cheat nosave sp control",
        -- cheat: implies nosave
        -- control: error if realm == "shared", userInfo == true or notify == true
    onModified = function(oldValue, newValue) end
})

-- all ConVars / ConCommands inserted after this will be part of a category
-- internal names will be prefixed with _category_name (after the addon prefix) while
-- the second argument will be what's displayed in CCVCCM
-- if the third argument is true, CCVCCM will insert the category as a tab instead of a list of collapsible categories
CCVCCM:PushCategory("category_name", "Category Name", true)

-- all ConVars / ConCommands inserted after this will not be part of the previous category
-- raises an error if not in a category
CCVCCM:PopCategory()

-- equivalent to CCVCCM:PopCategory() CCVCCM:PushCategory(...), but will not call CCVCCM:PopCategory() if not currently in a category
CCVCCM:NextCategory("category_name", "Category Name", true)
```

# Using ConVars with CCVCCM
Unlike the above methods, these should only be called AFTER the CCVCCMRun hook is finished.
```lua
-- returns the value of addon_name_category_name_convar as a bool / number / string / table
-- depending on the type specified in CCVCCM:AddConVar
CCVCCM:GetConVarValue("convar_name")

-- similar to CCVCCM:GetConVarValue
CCVCCM:GetAddonVar("var_name")
```