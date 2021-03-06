--[[
Workshop:		https://steamcommunity.com/sharedfiles/filedetails/?id=1673039990
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/isawc
Donate:			https://ko-fi.com/randomtnt12

Links above are confirmed working as of 2021-03-05. All dates are in ISO 8601 format. 
]]

ISAWC = ISAWC or {}
ISAWC._VERSION = "2.5.0"
ISAWC._VERSIONDATE = "2021-03-05"

if SERVER then util.AddNetworkString("isawc_general") end

local color_dark_red_semitransparent = Color(127,0,0,63)
local color_dark_green_semitransparent = Color(0,127,0,63)
local color_aqua = Color(0,255,255)
local color_dark_blue_semitransparent = Color(0,0,127,63)
local color_white_semitransparent = Color(255,255,255,63)
local color_gray_semitransparent = Color(127,127,127,63)
local color_black_semiopaque = Color(0,0,0,191)
local color_black_semitransparent = Color(0,0,0,63)

ISAWC.DoNothing = function()end

ISAWC.dm3perHu = 0.00204838

ISAWC.Log = function(self,msg)
	MsgC(color_aqua,"[ISAWC] ",color_white,msg,"\n")
end

ISAWC.ConCommands = {}

ISAWC.AddConCommand = function(self, name, data)
	concommand.Add(name, data.exec, data.autocomplete, data.help_small or data.help)
	self.ConCommands[name] = data.help
end

ISAWC.ConAllowConstrained = CreateConVar("isawc_allow_constrained","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Allows constrained props to be picked up.\
This feature is in beta - use it at your own risk.")

ISAWC.ConDelay = CreateConVar("isawc_pickup_delay","0.5",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"How long should a player wait before picking up another prop.")

ISAWC.ConDragAndDropOntoContainer = CreateConVar("isawc_container_autointo","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If 1, objects that come in contact with a container are automatically put into it.\
If 2, containers will use StartTouch detection methods instead of Touch detection methods. Both methods have their own pros and cons.")

ISAWC.ConReal = CreateConVar("isawc_use_realistic_volumes","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets how realistic volumes should be calculated:\
0: Take the object's total volume only. Hollow spaces within the object are ignored.\
1: Calculate a box surrounding the object, then take the box's volume.\
2: Calculate a sphere surrounding the object, then take the sphere's volume.")

ISAWC.ConMassMul = CreateConVar("isawc_player_massmul","0.2",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the player inventory maximum mass multiplier.\
Note that the maximum inventory mass is affected by the player's playermodel.\
If this is 0, the mass limit will not be enforced.")

ISAWC.ConVolMul = CreateConVar("isawc_player_volumemul","0.8",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the player inventory maximum volume multiplier.\
Note that the maximum inventory volume is affected by the player's playermodel.\
If this is 0, the volume limit will not be enforced.")

ISAWC.ConCount = CreateConVar("isawc_player_maxcount","10",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the maximum number of items players are allowed to carry at once.\
If this is 0, 65536 items (the maximum the addon can handle properly) will be the limit.")

ISAWC.ConStackLimit = CreateConVar("isawc_player_stacklimit","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets how much items can occupy one unit of space in a player's inventory.\
See the \"isawc_stacklist\" ConCommand to set maximum stacks individually.")

ISAWC.ConMassMul2 = CreateConVar("isawc_container_massmul","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the container inventory maximum mass multiplier.\
Note that the maximum inventory mass is affected by the container's model.\
If this is 0, the mass limit will not be enforced.")

ISAWC.ConVolMul2 = CreateConVar("isawc_container_volumemul","0.9",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the container inventory maximum volume multiplier.\
Note that the maximum inventory volume is affected by the container's model.\
If this is 0, the volume limit will not be enforced.")

ISAWC.ConCount2 = CreateConVar("isawc_container_maxcount","100",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the maximum number of items containers are allowed to carry at once.\
If this is 0, 65536 items (the maximum the addon can handle properly) will be the limit.")

ISAWC.ConStackLimit2 = CreateConVar("isawc_container_stacklimit","100",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets how much items can occupy one unit of space in a container's inventory.\
See the \"isawc_stacklist\" ConCommand to set maximum stacks individually.")

ISAWC.ConConstEnabled = CreateConVar("isawc_use_constants","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Causes all maximum mass and volume calculations to be based on constants instead of deriving it from the playermodel.\
Please note that carrying capacities of containers are still defined in their respective files (though you can change their properties by the right-click menu).\
Additionally, the ConVars \"isawc_container_massmul\" and \"isawc_container_volumemul\" will still be obeyed.")

ISAWC.ConConstMass = CreateConVar("isawc_player_constant_mass","15",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the maximum mass, in kg, that all players are allowed to carry at once.\
If this is 0, the mass limit will not be enforced.")

ISAWC.ConConstVol = CreateConVar("isawc_player_constant_volume","100",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the maximum volume, in dm³, that all players are allowed to carry at once.\
If this is 0, the volume limit will not be enforced.")

ISAWC.ConDistance = CreateConVar("isawc_pickup_maxdistance","128",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the maximum pickup distance when grabbing or dropping objects.\
If this is 0, the distance limit will not be enforced.")

ISAWC.ConDoSave = CreateConVar("isawc_player_save","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets whether players' inventories are saved or not.\
1: Saves players' inventories periodically (see \"isawc_player_savedelay\") or when they disconnect or die.\
2: Saves players' inventories whenever their inventory is changed (may caused tremendous lag!)")

ISAWC.ConUndoIntoContain = CreateConVar("isawc_undo_into_container","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, undone spawn groups will be put back into the container it came from, instead of being deleted entirely.")

AccessorFunc(ISAWC,"SuppressUndo","SuppressUndo",FORCE_BOOL)
AccessorFunc(ISAWC,"SuppressUndoHeaders","SuppressUndoHeaders",FORCE_BOOL)

ISAWC.ConAltSave = CreateConVar("isawc_use_altsave","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, entities that are put into containers are stored and retrieved somewhere safe rather than being deleted and recreated.\
This feature is in beta - use it at your own risk.")

ISAWC.ConDropOnDeath = CreateConVar("isawc_player_dropondeath","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, players drop a box containing their inventory on death.")

ISAWC.ConVPhysicsOnly = CreateConVar("isawc_use_strictvphysics","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, only entities with MOVETYPE_VPHYSICS can be picked up (anything that is a prop, basically).\
Turning off this option is not recommended as players might pick up normally immovable props.")

ISAWC.CreateListConCommand = function(self, name, data)
	ISAWC:AddConCommand(name, {
		exec = function(ply,cmd,args)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			else
				if #args==0 then
					ISAWC:Log(data.display..'{')
					for k,v in pairs(data.display_table) do
						data.display_function(k,v)
					end
					ISAWC:Log("}")
					ISAWC:Log("")
					for i,v in ipairs(data.help) do
						ISAWC:Log(v)
					end
				else
					data.exe(args)
					if ISAWC.ConDoSave:GetInt() > 1 then
						ISAWC:SaveInventory(ply)
					end
				end
			end
		end,
		help_small = data.help_small,
		help = data.purpose
	})
end

ISAWC.Blacklist = ISAWC.Blacklist or {}
ISAWC:CreateListConCommand("isawc_blacklist", {
	display = "The blacklist is as follows: ",
	display_table = ISAWC.Blacklist,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format('%q',k)..",")
	end,
	purpose = "Adds or removes entity classes from the blacklist. Classes in the blacklist cannot be picked up.",
	help = {
		"Use \"isawc_blacklist <class1> <class2> ...\" to add/remove entity classes into/from the list.",
		"* and ? wildcards are supported.",
		"Use \"isawc_blacklist *\" to clear the list.",
	},
	help_small = "Usage: isawc_blacklist <class1> <class2> ...",
	exe = function(args)
		for k,v in pairs(args) do
			v = v:lower()
			if v=="*" then
				table.Empty(ISAWC.Blacklist)
				ISAWC:Log("Removed everything from the blacklist.") break
			elseif ISAWC.Blacklist[v] then
				ISAWC.Blacklist[v] = nil
				ISAWC:Log("Removed \""..v.."\" from the blacklist.")
			else
				ISAWC.Blacklist[v] = true
				ISAWC:Log("Added \""..v.."\" into the blacklist.")
			end
		end
	end
})

ISAWC.BlackContainerMagnetList = ISAWC.BlackContainerMagnetList or {}
ISAWC:CreateListConCommand("isawc_container_magnetcontainerblacklist", {
	display = "The container magnetization container blacklist is as follows: ",
	display_table = ISAWC.BlackContainerMagnetList,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format('%q',k)..",")
	end,
	purpose = "Adds or removes entity classes from the container magnetization container blacklist. Classes in the blacklist will not be magnetic containers.",
	help = {
		"Use \"isawc_container_magnetcontainerblacklist <class1> <class2> ...\" to add/remove entity classes into/from the list.",
		"* and ? wildcards are supported.",
		"Use \"isawc_container_magnetcontainerblacklist *\" to clear the list.",
	},
	help_small = "Usage: isawc_container_magnetcontainerblacklist <class1> <class2> ...",
	exe = function(args)
		for k,v in pairs(args) do
			v = v:lower()
			if v=="*" then
				table.Empty(ISAWC.BlackContainerMagnetList)
				ISAWC:Log("Removed everything from the container magnetization container blacklist.") break
			elseif ISAWC.BlackContainerMagnetList[v] then
				ISAWC.BlackContainerMagnetList[v] = nil
				ISAWC:Log("Removed \""..v.."\" from the container magnetization container blacklist.")
			else
				ISAWC.BlackContainerMagnetList[v] = true
				ISAWC:Log("Added \""..v.."\" into the container magnetization container blacklist.")
			end
		end
	end
})

ISAWC.ConUseWhitelist = CreateConVar("isawc_use_whitelist","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, only entity classes that are in the whitelist can be picked up.\
Otherwise, entity classes that aren't in the blacklist or are in the whitelist can be picked up.\
Use the ConCommands \"isawc_blacklist\" and \"isawc_whitelist\" to manipulate the lists.\
Tip: Even if this is not set, non-solid and non-VPhysics entities can still be specified in the whitelist to make them able to be picked up,\
regardless of the other ConVars.")

ISAWC.ConUseExportWhitelist = CreateConVar("isawc_use_exportwhitelist","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, only entity classes that are in the whitelist can be exported by Inventory Exporters.\
See the ConCommand \"isawc_export_whitelist\" to manipulate the list.")

ISAWC.ConUseMagnetWhitelist = CreateConVar("isawc_use_magnetwhitelist","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, only entity classes that are in the whitelist can be magnetized by containers.\
See the ConCommand \"isawc_container_magnetwhitelist\" to manipulate the list.")

ISAWC.Whitelist = ISAWC.Whitelist or {}
ISAWC:CreateListConCommand("isawc_whitelist", {
	display = "The whitelist is as follows: ",
	display_table = ISAWC.Whitelist,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format('%q',k)..",")
	end,
	purpose = "Adds or removes entity classes from the whitelist. See the ConVar \"isawc_use_whitelist\" for more information.",
	help = {
		"Use \"isawc_whitelist <class1> <class2> ...\" to add/remove an entity class into/from the list.",
		"* and ? wildcards are supported.",
		"Use \"isawc_whitelist *\" to clear the list.",
		"Tip: Non-solid and Non-VPhysics entities can be specified here to make them able to be picked up regardless of the other ConVars."
	},
	help_small = "Usage: isawc_whitelist <class1> <class2> ...",
	exe = function(args)
		for k,v in pairs(args) do
			v = v:lower()
			if v=="*" then
				table.Empty(ISAWC.Whitelist)
				ISAWC:Log("Removed everything from the whitelist.") break
			elseif ISAWC.Whitelist[v] then
				ISAWC.Whitelist[v] = nil
				ISAWC:Log("Removed \""..v.."\" from the whitelist.")
			else
				ISAWC.Whitelist[v] = true
				ISAWC:Log("Added \""..v.."\" into the whitelist.")
			end
		end
	end
})

ISAWC.WhiteExtractList = ISAWC.WhiteExtractList or {}
ISAWC:CreateListConCommand("isawc_export_whitelist", {
	display = "The Inventory Exporter whitelist is as follows: ",
	display_table = ISAWC.WhiteExtractList,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format('%q',k)..",")
	end,
	purpose = "Adds or removes entity classes from the Inventory Exporter whitelist. See the ConVar \"isawc_use_exportwhitelist\" for more information.",
	help = {
		"Use \"isawc_export_whitelist <class1> <class2> ...\" to add/remove an entity class into/from the list.",
		"* and ? wildcards are supported.",
		"Use \"isawc_export_whitelist *\" to clear the list.",
	},
	help_small = "Usage: isawc_export_whitelist <class1> <class2> ...",
	exe = function(args)
		for k,v in pairs(args) do
			v = v:lower()
			if v=="*" then
				table.Empty(ISAWC.WhiteExtractList)
				ISAWC:Log("Removed everything from the Inventory Exporter whitelist.") break
			elseif ISAWC.WhiteExtractList[v] then
				ISAWC.WhiteExtractList[v] = nil
				ISAWC:Log("Removed \""..v.."\" from the Inventory Exporter whitelist.")
			else
				ISAWC.WhiteExtractList[v] = true
				ISAWC:Log("Added \""..v.."\" into the Inventory Exporter whitelist.")
			end
		end
	end
})

ISAWC.WhiteMagnetList = ISAWC.WhiteMagnetList or {}
ISAWC:CreateListConCommand("isawc_container_magnetwhitelist", {
	display = "The container magnetization whitelist is as follows: ",
	display_table = ISAWC.WhiteMagnetList,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format('%q',k)..",")
	end,
	purpose = "Adds or removes entity classes from the container magnetization whitelist. See the ConVar \"isawc_container_magnetwhitelist\" for more information.",
	help = {
		"Use \"isawc_container_magnetwhitelist <class1> <class2> ...\" to add/remove an entity class into/from the list.",
		"* and ? wildcards are supported.",
		"Use \"isawc_container_magnetwhitelist *\" to clear the list."
	},
	help_small = "Usage: isawc_container_magnetwhitelist <class1> <class2> ...",
	exe = function(args)
		for k,v in pairs(args) do
			v = v:lower()
			if v=="*" then
				table.Empty(ISAWC.WhiteMagnetList)
				ISAWC:Log("Removed everything from the container magnetization whitelist.") break
			elseif ISAWC.WhiteMagnetList[v] then
				ISAWC.WhiteMagnetList[v] = nil
				ISAWC:Log("Removed \""..v.."\" from the container magnetization whitelist.")
			else
				ISAWC.WhiteMagnetList[v] = true
				ISAWC:Log("Added \""..v.."\" into the container magnetization whitelist.")
			end
		end
	end
})

ISAWC.Stacklist = ISAWC.Stacklist or {}
ISAWC:CreateListConCommand("isawc_stacklist", {
	display = "The stacking list is as follows: ",
	display_table = ISAWC.Stacklist,
	display_function = function(k,v)
		ISAWC:Log(string.format("\t%s={player=%u,container=%u}",k,v[1],v[2]))
	end,
	purpose = "Adds or removes entity classes from the stack list. The stack list currently does nothing.",
	help = {
		"Use \"isawc_stacklist <class> <playerStackAmt> <containerStackAmt>\" to add an entity class into the list. \z
		A StackAmt of 0 means that the maximum stacking amount is unlimited. \z
		If any StackAmt is -1, it will be removed from the list instead.",
		"* and ? wildcards are supported.",
		"Use \"isawc_stacklist *\" to clear the list."
	},
	help_small = "Usage: isawc_whitelist <class1> <class2> ...",
	exe = function(args)
		local builttabs = {}
		local curName = ""
		for i,v in ipairs(args) do
			if i%3==1 then -- every 1st
				v = v:lower()
				if v=="*" then
					table.Empty(ISAWC.Stacklist)
					ISAWC:Log("Removed everything from the stack list.") break
				end
				curName = v
				builttabs[curName] = {}
			elseif i%3==2 then -- every 2nd
				builttabs[curName][1] = tonumber(v)
			else -- every 3rd
				builttabs[curName][2] = tonumber(v)
			end
		end
		for k,v in pairs(builttabs) do
			if v[1] then
				v[2] = v[2] or v[1]
				if v[1] < 0 or v[2] < 0 then
					ISAWC.Stacklist[k] = nil
					ISAWC:Log("Removed \""..k.."\" from the stack list.")
				else
					ISAWC.Stacklist[k] = v
					ISAWC:Log("Added \""..k.."\" into the stack list.")
				end
			else
				ISAWC:Log("Usage: isawc_stacklist <class> <playerStackAmt> <containerStackAmt>") break
			end
		end
	end
})

ISAWC.Masslist = ISAWC.Masslist or {}
ISAWC:CreateListConCommand("isawc_masslist", {
	display = "The custom mass list is as follows: ",
	display_table = ISAWC.Masslist,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format("%q=%g",k,v)..",")
	end,
	purpose = "Adds or removes entity classes or models from the mass list. Can be used to change the amount of mass needed to store an entity.",
	help = {
		"Use \"isawc_masslist <model/class1> <kg1> <model/class2> <kg2> ...\" to update or add a model into the list. \z
		If mass is -1, it will be removed from the list instead.",
		"* and ? wildcards are supported.",
		"Use \"isawc_masslist *\" to clear the list.",
		"Note that the \"isawc_pickup_massmul\" ConVar still affects the picked up entities."
	},
	help_small = "Usage: isawc_masslist <model/class1> <kg1> <model/class2> <kg2> ...",
	exe = function(args)
		if args[1]=="*" then
			table.Empty(ISAWC.Masslist)
			ISAWC:Log("Removed everything from the custom mass list.")
		elseif #args%2~=0 then
			ISAWC:Log("Usage: isawc_masslist <model/class1> <kg1> <model/class2> <kg2> ...")
		else
			for i,v in ipairs(args) do
				if i%2==1 then
					v = v:lower()
					local mass = tonumber(args[i+1])
					if (not mass or mass < 0) then
						ISAWC.Masslist[v] = nil
						ISAWC:Log("Removed \""..v.."\" from the custom mass list.")
					elseif ISAWC.Masslist[v] then
						ISAWC.Masslist[v] = mass
						ISAWC:Log("Updated \""..v.."\" in the custom mass list.")
					else
						ISAWC.Masslist[v] = mass
						ISAWC:Log("Added \""..v.."\" into the custom mass list.")
					end
				end
			end
		end
	end
})

ISAWC.MassMultiList = ISAWC.MassMultiList or {}
ISAWC:CreateListConCommand("isawc_player_usergroupmassmullist", {
	display = "The usergroup mass multiplier list is as follows: ",
	display_table = ISAWC.MassMultiList,
	display_function = function(k,v)
		if v == 0 then v = math.huge end
		ISAWC:Log("\t"..string.format("%q=%g",k,v)..",")
	end,
	purpose = "Adds or removes usergroups from the usergroup mass multiplier list. Can be used to change the maximum amount of mass a certain usergroup is allowed to carry.",
	help = {
		"Use \"isawc_player_usergroupmassmullist <usergroup1> <mul1> <usergroup2> <mul2> ...\" to update or add a usergroup into the list. \z
		If mul is 0, the usergroup can carry an infinite amount of mass. If mul is -1, the usergroup will be removed from the list instead.",
		"* and ? wildcards are supported.",
		"Use \"isawc_player_usergroupmassmullist *\" to clear the list.",
		"Note that the \"isawc_player_massmul\" ConVar still affects all players' maximum carrying mass."
	},
	help_small = "Usage: isawc_player_usergroupmassmullist <usergroup1> <mul1> <usergroup2> <mul2> ...",
	exe = function(args)
		if args[1]=="*" then
			table.Empty(ISAWC.MassMultiList)
			ISAWC:Log("Removed everything from the usergroup mass multiplier list.")
		elseif #args%2~=0 then
			ISAWC:Log("Usage: isawc_player_usergroupmassmullist <usergroup1> <mul1> <usergroup2> <mul2> ...")
		else
			for i,v in ipairs(args) do
				if i%2==1 then
					v = v:lower()
					local mass = tonumber(args[i+1])
					if (not mass or mass < 0) then
						ISAWC.MassMultiList[v] = nil
						ISAWC:Log("Removed \""..v.."\" from the usergroup mass multiplier list.")
					elseif ISAWC.MassMultiList[v] then
						ISAWC.MassMultiList[v] = mass
						ISAWC:Log("Updated \""..v.."\" in the usergroup mass multiplier list.")
					else
						ISAWC.MassMultiList[v] = mass
						ISAWC:Log("Added \""..v.."\" into the usergroup mass multiplier list.")
					end
				end
			end
		end
	end
})

ISAWC.Volumelist = ISAWC.Volumelist or {}
ISAWC:CreateListConCommand("isawc_volumelist", {
	display = "The custom volume list is as follows: ",
	display_table = ISAWC.Volumelist,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format("%q=%g",k,v)..",")
	end,
	purpose = "Adds or removes entity classes or models from the volume list. Can be used to change the amount of volume needed to store an entity.",
	help = {
		"Use \"isawc_volumelist <model/class1> <vol1> <model/class2> <vol2> ...\" to update or add a model into the list. \z
		If volume is -1, it will be removed from the list instead.",
		"* and ? wildcards are supported.",
		"Use \"isawc_volumelist *\" to clear the list.",
		"Note that the \"isawc_pickup_volumemul\" ConVar still affects the picked up entities."
	},
	help_small = "Usage: isawc_volumelist <model/class1> <vol1> <model/class2> <vol2> ...",
	exe = function(args)
		if args[1]=="*" then
			table.Empty(ISAWC.Volumelist)
			ISAWC:Log("Removed everything from the custom volume list.")
		elseif #args%2~=0 then
			ISAWC:Log("Usage: isawc_volumelist <model/class1> <vol1> <model/class2> <vol2> ...")
		else
			for i,v in ipairs(args) do
				if i%2==1 then
					v = v:lower()
					local volume = tonumber(args[i+1])
					if (not volume or volume < 0) then
						ISAWC.Volumelist[v] = nil
						ISAWC:Log("Removed \""..v.."\" from the custom volume list.")
					elseif ISAWC.Volumelist[v] then
						ISAWC.Volumelist[v] = volume
						ISAWC:Log("Updated \""..v.."\" in the custom volume list.")
					else
						ISAWC.Volumelist[v] = volume
						ISAWC:Log("Added \""..v.."\" into the custom volume list.")
					end
				end
			end
		end
	end
})

ISAWC.VolumeMultiList = ISAWC.VolumeMultiList or {}
ISAWC:CreateListConCommand("isawc_player_usergroupvolumemullist", {
	display = "The usergroup volume multiplier list is as follows: ",
	display_table = ISAWC.VolumeMultiList,
	display_function = function(k,v)
		if v == 0 then v = math.huge end
		ISAWC:Log("\t"..string.format("%q=%g",k,v)..",")
	end,
	purpose = "Adds or removes usergroups from the usergroup volume multiplier list. Can be used to change the maximum amount of volume a certain usergroup is allowed to carry.",
	help = {
		"Use \"isawc_player_usergroupvolumemullist <usergroup1> <mul1> <usergroup2> <mul2> ...\" to update or add a usergroup into the list. \z
		If mul is 0, the usergroup can carry an infinite amount of volume. If mul is -1, the usergroup will be removed from the list instead.",
		"* and ? wildcards are supported.",
		"Use \"isawc_player_usergroupvolumemullist *\" to clear the list.",
		"Note that the \"isawc_player_volumemul\" ConVar still affects all players' maximum carrying volume."
	},
	help_small = "Usage: isawc_player_usergroupvolumemullist <usergroup1> <mul1> <usergroup2> <mul2> ...",
	exe = function(args)
		if args[1]=="*" then
			table.Empty(ISAWC.VolumeMultiList)
			ISAWC:Log("Removed everything from the usergroup volume multiplier list.")
		elseif #args%2~=0 then
			ISAWC:Log("Usage: isawc_player_usergroupvolumemullist <usergroup1> <mul1> <usergroup2> <mul2> ...")
		else
			for i,v in ipairs(args) do
				if i%2==1 then
					v = v:lower()
					local volume = tonumber(args[i+1])
					if (not volume or volume < 0) then
						ISAWC.VolumeMultiList[v] = nil
						ISAWC:Log("Removed \""..v.."\" from the usergroup volume multiplier list.")
					elseif ISAWC.VolumeMultiList[v] then
						ISAWC.VolumeMultiList[v] = volume
						ISAWC:Log("Updated \""..v.."\" in the usergroup volume multiplier list.")
					else
						ISAWC.VolumeMultiList[v] = volume
						ISAWC:Log("Added \""..v.."\" into the usergroup volume multiplier list.")
					end
				end
			end
		end
	end
})

ISAWC.Countlist = ISAWC.Countlist or {}
ISAWC:CreateListConCommand("isawc_countlist", {
	display = "The custom count list is as follows: ",
	display_table = ISAWC.Countlist,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format("%q=%u",k,v)..",")
	end,
	purpose = "Adds or removes entity classes or models from the custom count list. Can be used to change the amount of slots needed to store an entity.",
	help = {
		"Use \"isawc_countlist <model/class1> <count1> <model/class2> <count2> ...\" to update or add a class into the list. \z
		If amount is -1, it will be removed from the list instead.",
		"* and ? wildcards are supported.",
		"Use \"isawc_countlist *\" to clear the list.",
		"Note that the \"isawc_pickup_countmul\" ConVar still affects the picked up entities."
	},
	help_small = "Usage: isawc_countlist <model/class1> <count1> <model/class2> <count2> ...",
	exe = function(args)
		if args[1]=="*" then
			table.Empty(ISAWC.Countlist)
			ISAWC:Log("Removed everything from the custom amount list.")
		elseif #args%2~=0 then
			ISAWC:Log("Usage: isawc_countlist <model/class1> <count1> <model/class2> <count2> ...")
		else
			for i,v in ipairs(args) do
				if i%2==1 then
					v = v:lower()
					local amount = tonumber(args[i+1])
					if (not amount or amount < 0) then
						ISAWC.Countlist[v] = nil
						ISAWC:Log("Removed \""..v.."\" from the custom amount list.")
					elseif ISAWC.Countlist[v] then
						ISAWC.Countlist[v] = amount
						ISAWC:Log("Updated \""..v.."\" in the custom amount list.")
					else
						ISAWC.Countlist[v] = amount
						ISAWC:Log("Added \""..v.."\" into the custom amount list.")
					end
				end
			end
		end
	end
})

ISAWC.CountMultiList = ISAWC.CountMultiList or {}
ISAWC:CreateListConCommand("isawc_player_usergroupcountmullist", {
	display = "The usergroup count multiplier list is as follows: ",
	display_table = ISAWC.CountMultiList,
	display_function = function(k,v)
		if v == 0 then v = math.huge end
		ISAWC:Log("\t"..string.format("%q=%g",k,v)..",")
	end,
	purpose = "Adds or removes usergroups from the usergroup count multiplier list. Can be used to change the maximum amount of items a certain usergroup is allowed to carry.",
	help = {
		"Use \"isawc_player_usergroupcountmullist <usergroup1> <mul1> <usergroup2> <mul2> ...\" to update or add a usergroup into the list. \z
		If mul is 0, the usergroup can carry 65536 items. If mul is -1, the usergroup will be removed from the list instead.",
		"* and ? wildcards are supported.",
		"Use \"isawc_player_usergroupcountmullist *\" to clear the list.",
		"Note that the \"isawc_player_maxcount\" ConVar still affects all players' maximum carried items."
	},
	help_small = "Usage: isawc_player_usergroupcountmullist <usergroup1> <mul1> <usergroup2> <mul2> ...",
	exe = function(args)
		if args[1]=="*" then
			table.Empty(ISAWC.CountMultiList)
			ISAWC:Log("Removed everything from the usergroup count multiplier list.")
		elseif #args%2~=0 then
			ISAWC:Log("Usage: isawc_player_usergroupcountmullist <usergroup1> <mul1> <usergroup2> <mul2> ...")
		else
			for i,v in ipairs(args) do
				if i%2==1 then
					v = v:lower()
					local count = tonumber(args[i+1])
					if (not count or count < 0) then
						ISAWC.CountMultiList[v] = nil
						ISAWC:Log("Removed \""..v.."\" from the usergroup count multiplier list.")
					elseif ISAWC.CountMultiList[v] then
						ISAWC.CountMultiList[v] = count
						ISAWC:Log("Updated \""..v.."\" in the usergroup count multiplier list.")
					else
						ISAWC.CountMultiList[v] = count
						ISAWC:Log("Added \""..v.."\" into the usergroup count multiplier list.")
					end
				end
			end
		end
	end
})

ISAWC.Remaplist = ISAWC.Remaplist or {}
ISAWC:CreateListConCommand("isawc_remaplist", {
	display = "The class remapping list is as follows: ",
	display_table = ISAWC.Remaplist,
	display_function = function(k,v)
		ISAWC:Log("\t"..string.format("%q=%q",k,v)..",")
	end,
	purpose = "Adds or removes entity classes from the class remap list. Can be used to change the class a certain entity becomes when stored.",
	help = {
		"Use \"isawc_remaplist <oldClass1> <newClass1> <oldClass2> <newClass2> ...\" to update or add a class into the list. \z
		If newClass is *, it will be removed from the list instead.",
		"* and ? wildcards are supported.",
		"Use \"isawc_remaplist *\" to clear the list."
	},
	help_small = "Usage: isawc_remaplist <oldClass1> <newClass1> <oldClass2> <newClass2> ...",
	exe = function(args)
		if args[1]=="*" then
			table.Empty(ISAWC.Remaplist)
			ISAWC:Log("Removed everything from the class remap list.")
		elseif #args%2~=0 then
			ISAWC:Log("Usage: isawc_remaplist <oldClass1> <newClass1> <oldClass2> <newClass2> ...")
		else
			for i,v in ipairs(args) do
				if i%2==1 then
					v = v:lower()
					local newMap = args[i+1]
					if newMap == "*" then
						ISAWC.Remaplist[v] = nil
						ISAWC:Log("Removed \""..v.."\" from the class remap list.")
					elseif ISAWC.Remaplist[v] then
						ISAWC.Remaplist[v] = newMap
						ISAWC:Log("Updated \""..v.."\" in the class remap list.")
					else
						ISAWC.Remaplist[v] = newMap
						ISAWC:Log("Added \""..v.."\" into the class remap list.")
					end
				end
			end
		end
	end
})

ISAWC.ConAllowDelete = CreateConVar("isawc_allow_delete","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Enables players to delete props that they've picked up.")

ISAWC.ConOverride = CreateConVar("isawc_use_forcepickup","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Ignores other potential return values from hooks it calls.\
Tick this option if you can't pick up items in other gamemodes.")

ISAWC.ConAlwaysPublic = CreateConVar("isawc_container_alwayspublic","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set to 1, all containers are always openable by anyone.\
If set to 2, containers may be opened by another player in the same team.\
This overrides the \"always public\" option in the \"Edit Properties...\" menu.")
	
ISAWC.ConHideNotifsG = CreateConVar("isawc_hide_notifications_global","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Same as Hide All Notifications (isawc_hide_notifications) on client, but affects the whole server.\
Does nothing on client - use the mentioned ConVar instead.")

ISAWC.ConAllowPickupOnPhysgun = CreateConVar("isawc_allow_pickupwhilephysgunned","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, entities being picked up by the Physics Gun can still be picked up and put into any inventory.\
This feature is in beta - use it at your own risk.")

ISAWC.ConDistBefore = CreateConVar("isawc_spawnbeforedist","4",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"When an entity is taken out of a container via Spawn At Crosshair, it will be spawned this far away from any obstructions.\
This ignores Max Pickup Distance!")

ISAWC.ConSaveIntoFile = CreateConVar("isawc_container_save","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Causes containers to save/load their inventories into/from files instead of its own entity table.\
This feature is in beta - use it at your own risk.\
WARNING: Make sure to Clear the Save Cache periodically!")

ISAWC.ConDropOnDeathContainer = CreateConVar("isawc_container_dropondeath","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, containers' inventories are dropped upon removal.\
This feature is in beta - use it at your own risk.")

ISAWC.ConAutoHealth = CreateConVar("isawc_container_healthmul","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If above 0, ALL containers spawned will have a limited amount of health depending on their volume multiplied by this ConVar.\
This feature is in beta - use it at your own risk.")

ISAWC.ConSaveTable = CreateConVar("isawc_use_enginesavetables","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, entities will have their engine save tables stored as well.\
This feature is EXPERIMENTAL - use it at your own risk.")

ISAWC.ConPickupDenyLogs = CreateConVar("isawc_hide_pickuplogdenies","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If unset, when a player / container fails to pick up an item, a message is shown in console with the reason.")

ISAWC.ConContainerRegen = CreateConVar("isawc_container_regen","0",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Containers will regenerate this amount of health per second.\
Negative values are allowed.")

ISAWC.ConMassMul3 = CreateConVar("isawc_pickup_massmul","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the mass multiplier for all picked up items.\
If you want to set the mass of individual items, see the isawc_masslist ConCommand.")

ISAWC.ConVolMul3 = CreateConVar("isawc_pickup_volumemul","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the volume multiplier for all picked up items.\
If you want to set the volume of individual items, see the isawc_volumelist ConCommand.")

ISAWC.ConCount3 = CreateConVar("isawc_pickup_countmul","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the amount multiplier for all picked up items.\
If you want to set the amount for individual items, see the isawc_countlist ConCommand.\
Note that decimal values are rounded down within inventories, which can lead to confusion.")

ISAWC.ConDeathRemoveDelay = CreateConVar("isawc_player_deathdroptime","10",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the amount of time to wait before removing the box players drop upon death, after being emptied.")

ISAWC.ConSpawnDelay = CreateConVar("isawc_spawn_delay","1",FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the minimum delay between inventory item spawns by players.")

ISAWC.ConAdminOverride = CreateConVar("isawc_allow_adminpickupanything", "0", FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Allows admins to pick up anything regardless of ConVars (except for players and the map, as those can crash the game).")

ISAWC.ConNoAmmo = CreateConVar("isawc_empty_weapons", "0", FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set, all weapons spawned from inventories will not have any ammo in their clip.")

ISAWC.ConAllowInterConnection = CreateConVar("isawc_allow_interownerconnections", "0", FCVAR_ARCHIVE+FCVAR_REPLICATED,
"If set to 1, Inventory Importers, Exporters and Viewers may be connected to a container owned by someone else.\
If set to 2, connections are only allowed to containers owned by the same team.")

ISAWC.ConMinExportDelay = CreateConVar("isawc_export_mindelay", "0.05", FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Minimum delay between items exported by Inventory Exporters.")

ISAWC.ConDoSaveDelay = CreateConVar("isawc_player_savedelay", "300", FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the delay between automatic saves for player inventories. No effect when Save Player Inventories (isawc_player_save) is disabled.\
Note that low values may severely impact performance!")

ISAWC.ConMagnet = CreateConVar("isawc_container_magnetradius", "0", FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the range of containers to instantly pick up an item. Note that the radius is multiplied with the size of the container - a range of 3 on a box will allow the box to pick up items 3 boxes away from it.\
A range of 0 disables this feature.")

ISAWC.ConDropOnDeathClass = CreateConVar("isawc_player_dropondeathclass", "isawc_container_cbbox_07", FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Sets the classname of dropped containers on player deaths when the isawc_player_dropondeath ConVar is enabled. Useful for causing custom Lua containers to be dropped.\
Note that invalid classes will cause the addon to default back to isawc_container_cbbox_07 - a small box.\
If you just want to set the model, see the isawc_player_dropondeathmodel ConVar.")

ISAWC.ConDropOnDeathModel = CreateConVar("isawc_player_dropondeathmodel", "", FCVAR_ARCHIVE+FCVAR_REPLICATED,
"Overrides the model of dropped containers on player deaths when the isawc_player_dropondeath ConVar is enabled.\
Set the ConVar to \"\" to remove the model override.\
If you want to set the class, see the isawc_player_dropondeathclass ConVar.")

local function BasicAutoComplete(cmd, argStr)
	local possibilities = {}
	local namesearch = argStr:Trim():lower()
	for k,v in pairs(player.GetAll()) do
		if string.StartWith(v:Nick():lower(), namesearch) then
			table.insert(possibilities, cmd .. " " .. v:Nick())
		end
	end
	return possibilities
end

local clearcachemessage = "Clears inventories saved from Alternate Saving. Containers that aren't presently in the map will have their contents wiped out."
if SERVER then
	ISAWC:AddConCommand("isawc_container_clearcache", {
		exec = function(ply,cmd,args)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			else
				for k,v in pairs(file.Find("isawc_containers/*.dat","DATA")) do
					file.Delete("isawc_containers/"..v)
				end
				for k,v in pairs(ents.GetAll()) do
					if (IsValid(v) and v.Base=="isawc_container_base") then
						ISAWC:SaveContainerInventory(v)
					end
				end
			end
		end,
		help = clearcachemessage
	})
	
	ISAWC:AddConCommand("isawc_reset_convars", {
		exec = function(ply,cmd,args,argStr)
			for k,v in pairs(ISAWC) do
				if TypeID(v)==TYPE_CONVAR then
					v:Revert()
				end
			end
		end,
		help = "Sets all ConVars to their default values."
	})
	
	ISAWC:AddConCommand("isawc_copy", {
		exec = function(ply,cmd,args,argStr)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			else
				if #args==0 then
					ISAWC:Log("Usage: isawc_copy <player>")
				else
					local success = false
					for k,v in pairs(player.GetAll()) do
						if v:Nick() == argStr then
							success = true
							if ply == v then
								ISAWC:Log("You can't copy your own inventory!")
							else
								table.Empty(ply.ISAWC_Inventory)
								for i2,v2 in ipairs(v.ISAWC_Inventory) do
									table.insert(ply.ISAWC_Inventory, v2)
								end
								ISAWC:Log("You have copied the inventory of " .. argStr .. " into your inventory.")
							end
							break
						end
					end
					if not success then
						ISAWC:Log("Can't find player \"" .. argStr .. "\".")
					end
				end
			end
		end,
		autocomplete = BasicAutoComplete,
		help = "Copies a player's inventory into your inventory.",
		help_small = "Usage: isawc_copy <player>"
	})
	
	ISAWC:AddConCommand("isawc_paste", {
		exec = function(ply,cmd,args,argStr)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			else
				if #args==0 then
					ISAWC:Log("Usage: isawc_paste <player>")
				else
					local success = false
					for k,v in pairs(player.GetAll()) do
						if v:Nick() == argStr then
							success = true
							if ply == v then
								ISAWC:Log("You can't paste into your own inventory!")
							else
								table.Empty(v.ISAWC_Inventory)
								for i2,v2 in ipairs(ply.ISAWC_Inventory) do
									table.insert(v.ISAWC_Inventory, v2)
								end
								ISAWC:Log("You have pasted your inventory into the inventory of " .. argStr .. ".")
							end
							break
						end
					end
					if not success then
						ISAWC:Log("Can't find player \"" .. argStr .. "\".")
					end
				end
			end
		end,
		autocomplete = BasicAutoComplete,
		help = "Pastes your inventory into another player's inventory.",
		help_small = "Usage: isawc_paste <player>"
	})
end

ISAWC.CachedConVars = nil
ISAWC.GetConVarList = function()
	if not ISAWC.CachedConVars then
		ISAWC.CachedConVars = {}
		for k,v in pairs(ISAWC) do
			if TypeID(v) == TYPE_CONVAR then
				ISAWC.CachedConVars[v:GetName()] = v
			end
		end
	end
	return ISAWC.CachedConVars
end

ISAWC:AddConCommand("isawc_help", {
	exec = function(ply,cmd,args,argStr)
		if not ply:IsAdmin() and ply.ISAWC_HelpCooldown > RealTime() then
			ISAWC:NoPickup(string.format("You need to wait for %.2f seconds before calling this command again!", ply.ISAWC_HelpCooldown - RealTime()), ply)
		else
			ply.ISAWC_HelpCooldown = RealTime() + 10
			if #args==0 then
				ISAWC:Log("The list of ConVars is as follows: {")
				for k,v in SortedPairs(ISAWC:GetConVarList()) do
					ISAWC:Log(string.format("\t%q = %s,",k,v:GetString()))
				end
				ISAWC:Log("}")
				ISAWC:Log("The list of ConCommands is as follows: {")
				for k,v in SortedPairs(ISAWC.ConCommands) do
					ISAWC:Log(string.format("\t%q,",k))
				end
				ISAWC:Log("}")
				ISAWC:Log("Usage: isawc_help <command>")
			else
				argStr = string.Trim(argStr)
				local success = false
				for k,v in SortedPairs(ISAWC:GetConVarList()) do
					if argStr == k then
						ISAWC:Log(string.format("%s (Console Variable, Current = %s, Default = %s)", k, v:GetString(), v:GetDefault()))
						ISAWC:Log(v:GetHelpText())
						success = true
						break
					end
				end
				if not success then
					for k,v in SortedPairs(ISAWC.ConCommands) do
						if argStr == k then
							ISAWC:Log(argStr.." (Console Command)")
							ISAWC:Log(v)
							success = true
							break
						end
					end
				end
				if not success then
					ISAWC:Log("The ConVar / ConCommand \""..argStr.."\" does not exist within ISAWC.")
				end
			end
		end
	end,
	autocomplete = function(cmd, argStr)
		argStr = string.Trim(argStr)
		local possibilities = {}
		for k,v in SortedPairs(ISAWC:GetConVarList()) do
			if string.StartWith(k, argStr) then
				table.insert(possibilities, cmd .. ' ' .. k)
			end
		end
		for k,v in SortedPairs(ISAWC.ConCommands) do
			if string.StartWith(k, argStr) then
				table.insert(possibilities, cmd .. ' ' .. k)
			end
		end
		return possibilities
	end,
	help = "Shows a list of ISAWC ConVars and ConCommands, or a help topic about one of them.",
	help_small = "Usage: isawc_help <command>"
})

if CLIENT then

	ISAWC.ConUseDelay = CreateClientConVar("isawc_use_delay","0",true,false,
	"How long an item must be held with the Pickup Key before being picked up.\n\z
	A value of -1 disables this feature.")

	ISAWC.ConUseBind = CreateClientConVar("isawc_use_bind","",true,false,
	"Sets the binding used to pick up items.")

	ISAWC.ConInventoryBind = CreateClientConVar("isawc_player_bind","",true,false,
	"If set, pressing this key will open the inventory.")

	ISAWC.ConInventoryBindHold = CreateClientConVar("isawc_player_bind_hold","",true,false,
	"If set, holding this key will open the inventory. Releasing it will close it back.")
	
	ISAWC.ConHideNotifs = CreateClientConVar("isawc_hide_notifications","0",true,false,
	"Prevents those pop-up messages from... popping up.")
	
	ISAWC.ConHideNotifSound = CreateClientConVar("isawc_hide_notificationsound","0",true,false,
	"Stops the annoying buzzer sound from playing every time you fail to pick up an item.")

	ISAWC.ConPermaConnectorHUD = CreateClientConVar("isawc_always_showconnectorhud","0",true,false,
	"Shows links between containers and Inventory Exporters to other containers you own, even if the ISAWC MultiConnector SWEP is not equipped.")
	
	local inventoryOpenTable = {
		exec = function(ply,cmd,args)
			if IsValid(ISAWC.TempWindow2) then
				ISAWC.TempWindow2:Close()
			else
				ISAWC.TempWindow2 = ISAWC:BuildInventory()
			end
		end,
		help = "Opens the inventory."
	}
	
	ISAWC:AddConCommand("isawc_activate_inventory_menu", inventoryOpenTable)
	ISAWC:AddConCommand("isawc_inventory", inventoryOpenTable)
	
	ISAWC:AddConCommand("+isawc_inventory", {
		exec = function(ply,cmd,args)
			if IsValid(ISAWC.TempWindow2) then
				ISAWC.TempWindow2:Show()
				ISAWC.TempWindow2:RequestFocus()
			else
				ISAWC.TempWindow2 = ISAWC:BuildInventory()
			end
		end,
		help = "Opens the inventory."
	})
	
	ISAWC:AddConCommand("-isawc_inventory", {
		exec = function(ply,cmd,args)
			if IsValid(ISAWC.TempWindow2) then
				ISAWC.TempWindow2:Hide()
				ISAWC.TempWindow2:KillFocus()
			end
		end,
		help = "Closes the inventory."
	})

end

ISAWC.AddToolMenuTabs = function()
	spawnmenu.AddToolTab("ISAWC")
end

ISAWC.AddToolMenuCategories = function()
	spawnmenu.AddToolCategory("ISAWC","client","Client")
	spawnmenu.AddToolCategory("ISAWC","server","Server")
end

ISAWC.PopulateToolMenu = function()
	spawnmenu.AddToolMenuOption("ISAWC","client","isawc_client","General","","",ISAWC.PopulateDFormClient)
	spawnmenu.AddToolMenuOption("ISAWC","server","isawc_general","General","","",ISAWC.PopulateDFormGeneral)
	spawnmenu.AddToolMenuOption("ISAWC","server","isawc_multipliers","Scaling","","",ISAWC.PopulateDFormMultipliers)
	spawnmenu.AddToolMenuOption("ISAWC","server","isawc_others","Various Others","","",ISAWC.PopulateDFormOthers)
end

ISAWC.PopulateDFormClient = function(DForm)
	DForm:Help("") --whitespace
	DForm:ControlHelp("Clientside Settings")
	
	local DLabel = Label("Pickup Key (RMB to clear)")
	DLabel:SetDark(true)
	local Binder = vgui.Create("DBinder")
	Binder:SetValue(input.GetKeyCode(ISAWC.ConUseBind:GetString()))
	function Binder:OnChange(key)
		ISAWC.ConUseBind:SetString(input.GetKeyName(key) or "")
	end
	DForm:AddItem(DLabel,Binder)
	Binder:Dock(RIGHT)
	DLabel:SizeToContentsX()
	DForm:Help(" - "..ISAWC.ConUseBind:GetHelpText().."\n")
	DForm:NumSlider("Pickup Delay",ISAWC.ConUseDelay:GetName(),-1,10,3)
	DForm:Help(" - "..ISAWC.ConUseDelay:GetHelpText().."\n")
	
	--[[DLabel = Label("Inventory Key (RMB to clear)")
	DLabel:SetDark(true)
	Binder = vgui.Create("DBinder")
	Binder:SetValue(input.GetKeyCode(ISAWC.ConInventoryBind:GetString()))
	function Binder:OnChange(key)
		ISAWC.ConInventoryBind:SetString(input.GetKeyName(key) or "")
	end
	DForm:AddItem(DLabel,Binder)
	Binder:Dock(RIGHT)
	DLabel:SizeToContentsX()
	DForm:Help(" - "..ISAWC.ConInventoryBind:GetHelpText().."\n")]]
	DForm:Help("Tip: Use the client console commands \"isawc_activate_inventory_menu\" or \"+isawc_inventory\" to open the inventory menu.")
	DForm:Help("Bind a key with \"bind <key> isawc_activate_inventory_menu\" (toggle version) or \"bind <key> +isawc_inventory\" (hold version).\n")
	DForm:CheckBox("Suppress All Notifications",ISAWC.ConHideNotifs:GetName())
	DForm:Help(" - "..ISAWC.ConHideNotifs:GetHelpText().."\n")
	DForm:CheckBox("Disable Notification Sound",ISAWC.ConHideNotifSound:GetName())
	DForm:Help(" - "..ISAWC.ConHideNotifSound:GetHelpText().."\n")
	DForm:CheckBox("Always Show Connections",ISAWC.ConPermaConnectorHUD:GetName())
	DForm:Help(" - "..ISAWC.ConPermaConnectorHUD:GetHelpText().."\n")
end

ISAWC.PopulateDFormGeneral = function(DForm)
	DForm:Help("") --whitespace
	DForm:ControlHelp("General Settings")
	local combox = DForm:ComboBox("Use Realistic Volumes",ISAWC.ConReal:GetName())
	combox:AddChoice("0 - Don't", 0)
	combox:AddChoice("1 - Outer Box", 1)
	combox:AddChoice("2 - Outer Sphere", 2)
	DForm:Help(" - "..ISAWC.ConReal:GetHelpText().."\n")
	DForm:CheckBox("Allow Item Deletion",ISAWC.ConAllowDelete:GetName())
	DForm:Help(" - "..ISAWC.ConAllowDelete:GetHelpText().."\n")
	DForm:CheckBox("Allow Constrained Entities",ISAWC.ConAllowConstrained:GetName())
	DForm:Help(" - "..ISAWC.ConAllowConstrained:GetHelpText().."\n")
	DForm:CheckBox("Allow PhysGunned Entities",ISAWC.ConAllowPickupOnPhysgun:GetName())
	DForm:Help(" - "..ISAWC.ConAllowPickupOnPhysgun:GetHelpText().."\n")
	DForm:CheckBox("Undo Puts Items Into Inventory",ISAWC.ConUndoIntoContain:GetName())
	DForm:Help(" - "..ISAWC.ConUndoIntoContain:GetHelpText().."\n")
	DForm:CheckBox("Empty Weapon Clips",ISAWC.ConNoAmmo:GetName())
	DForm:Help(" - "..ISAWC.ConNoAmmo:GetHelpText().."\n")
	DForm:NumSlider("Allow UP'd Inventory Connections",ISAWC.ConAllowInterConnection:GetName(),0,2,0)
	DForm:Help(" - "..ISAWC.ConAllowInterConnection:GetHelpText().."\n")
	DForm:NumSlider("Minimum Export Delay",ISAWC.ConMinExportDelay:GetName(),0.01,10,2)
	DForm:Help(" - "..ISAWC.ConMinExportDelay:GetHelpText().."\n")
	DForm:CheckBox("Use Alternate Storing Method",ISAWC.ConAltSave:GetName())
	DForm:Help(" - "..ISAWC.ConAltSave:GetHelpText().."\n")
	DForm:CheckBox("[EXPERIMENTAL] Save Engine Tables",ISAWC.ConSaveTable:GetName())
	DForm:Help(" - "..ISAWC.ConSaveTable:GetHelpText().."\n")
	DForm:CheckBox("Use Item Whitelist",ISAWC.ConUseWhitelist:GetName())
	DForm:Help(" - "..ISAWC.ConUseWhitelist:GetHelpText().."\n")
	DForm:CheckBox("Use Inventory Exporter Whitelist",ISAWC.ConUseExportWhitelist:GetName())
	DForm:Help(" - "..ISAWC.ConUseExportWhitelist:GetHelpText().."\n")
	DForm:CheckBox("Strictly VPhysics Props",ISAWC.ConVPhysicsOnly:GetName())
	DForm:Help(" - "..ISAWC.ConVPhysicsOnly:GetHelpText().."\n")
	DForm:CheckBox("Suppress All Notifications (Global)",ISAWC.ConHideNotifsG:GetName())
	DForm:Help(" - "..ISAWC.ConHideNotifsG:GetHelpText().."\n")
	DForm:CheckBox("Override Hooks",ISAWC.ConOverride:GetName())
	DForm:Help(" - "..ISAWC.ConOverride:GetHelpText().."\n")
	DForm:CheckBox("Hide Pickup Fail Events",ISAWC.ConPickupDenyLogs:GetName())
	DForm:Help(" - "..ISAWC.ConPickupDenyLogs:GetHelpText().."\n")
end

ISAWC.PopulateDFormMultipliers = function(DForm)
	DForm:Help("") --whitespace
	DForm:ControlHelp("Pickup Multipliers")
	DForm:NumSlider("Mass Multiplier",ISAWC.ConMassMul3:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConMassMul3:GetHelpText().."\n")
	DForm:NumSlider("Volume Multiplier",ISAWC.ConVolMul3:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConVolMul3:GetHelpText().."\n")
	DForm:NumSlider("Amount Multiplier",ISAWC.ConCount3:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConCount3:GetHelpText().."\n")
	
	DForm:Help("") --whitespace
	DForm:ControlHelp("Player Multipliers")
	DForm:NumSlider("Mass Carrying Multiplier",ISAWC.ConMassMul:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConMassMul:GetHelpText().."\n")
	DForm:NumSlider("Volume Carrying Multiplier",ISAWC.ConVolMul:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConVolMul:GetHelpText().."\n")
	DForm:NumSlider("Max Items",ISAWC.ConCount:GetName(),0,1024,0)
	DForm:Help(" - "..ISAWC.ConCount:GetHelpText().."\n")
	--DForm:NumSlider("Max Items per Stack",ISAWC.ConStackLimit:GetName(),0,1024,0)
	--DForm:Help(" - "..ISAWC.ConStackLimit:GetHelpText().."\n")
	
	DForm:Help("") --whitespace
	DForm:ControlHelp("Containers' Multipliers")
	DForm:NumSlider("Mass Carrying Multiplier",ISAWC.ConMassMul2:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConMassMul2:GetHelpText().."\n")
	DForm:NumSlider("Volume Carrying Multiplier",ISAWC.ConVolMul2:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConVolMul2:GetHelpText().."\n")
	DForm:NumSlider("Max Items",ISAWC.ConCount2:GetName(),0,1024,0)
	DForm:Help(" - "..ISAWC.ConCount2:GetHelpText().."\n")
	--DForm:NumSlider("Max Items per Stack",ISAWC.ConStackLimit2:GetName(),0,1024,0)
	--DForm:Help(" - "..ISAWC.ConStackLimit2:GetHelpText().."\n")
	
	DForm:Help("") --whitespace
	DForm:ControlHelp("Constants")
	DForm:CheckBox("Use Constants",ISAWC.ConConstEnabled:GetName())
	DForm:Help(" - "..ISAWC.ConConstEnabled:GetHelpText().."\n")
	DForm:NumSlider("Player Max Mass (kg)",ISAWC.ConConstMass:GetName(),0,1024,1)
	DForm:Help(" - "..ISAWC.ConConstMass:GetHelpText().."\n")
	DForm:NumSlider("Player Max Volume (dm³)",ISAWC.ConConstVol:GetName(),0,1024,1)
	DForm:Help(" - "..ISAWC.ConConstVol:GetHelpText().."\n")
end

ISAWC.PopulateDFormOthers = function(DForm)
	DForm:Help("") --whitespace
	DForm:ControlHelp("Player Options")
	DForm:NumSlider("Pickup Delay",ISAWC.ConDelay:GetName(),0,100,2)
	DForm:Help(" - "..ISAWC.ConDelay:GetHelpText().."\n")
	DForm:NumSlider("Drop Delay",ISAWC.ConSpawnDelay:GetName(),0,100,2)
	DForm:Help(" - "..ISAWC.ConSpawnDelay:GetHelpText().."\n")
	DForm:NumSlider("Max Pickup Distance",ISAWC.ConDistance:GetName(),0,1024,1)
	DForm:Help(" - "..ISAWC.ConDistance:GetHelpText().."\n")
	DForm:NumSlider("Distance from Obstructions",ISAWC.ConDistBefore:GetName(),0,1024,1)
	DForm:Help(" - "..ISAWC.ConDistBefore:GetHelpText().."\n")
	DForm:CheckBox("Drop Inventory On Death",ISAWC.ConDropOnDeath:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeath:GetHelpText().."\n")
	DForm:TextEntry("Class of Dropped Container",ISAWC.ConDropOnDeathClass:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeathClass:GetHelpText().."\n")
	DForm:TextEntry("Model of Dropped Container",ISAWC.ConDropOnDeathModel:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeathModel:GetHelpText().."\n")
	local combox = DForm:ComboBox("Save Player Inventories",ISAWC.ConDoSave:GetName())
	combox:AddChoice("0 - Don't", 0)
	combox:AddChoice("1 - Occasionally", 1)
	combox:AddChoice("2 - Frequently", 2)
	DForm:Help(" - "..ISAWC.ConDoSave:GetHelpText().."\n")
	DForm:NumSlider("Auto Save Delay",ISAWC.ConDoSaveDelay:GetName(),1,600,0)
	DForm:Help(" - "..ISAWC.ConDoSaveDelay:GetHelpText().."\n")
	DForm:CheckBox("Admin Can Pickup Any",ISAWC.ConAdminOverride:GetName())
	DForm:Help(" - "..ISAWC.ConAdminOverride:GetHelpText().."\n")
	
	DForm:Help("") --whitespace
	DForm:ControlHelp("Container Options")
	local combox = DForm:ComboBox("Hyperactive Containers",ISAWC.ConDragAndDropOntoContainer:GetName())
	combox:AddChoice("0 - Don't", 0)
	combox:AddChoice("1 - Use Touch", 1)
	combox:AddChoice("2 - Use StartTouch", 2)
	DForm:Help(" - "..ISAWC.ConDragAndDropOntoContainer:GetHelpText().."\n")
	DForm:NumSlider("Always Openable By Everyone",ISAWC.ConAlwaysPublic:GetName(),0,2,0)
	DForm:Help(" - "..ISAWC.ConAlwaysPublic:GetHelpText().."\n")
	DForm:NumSlider("Magnet Range",ISAWC.ConMagnet:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConMagnet:GetHelpText().."\n")
	DForm:CheckBox("Use Magnet Whitelist",ISAWC.ConUseMagnetWhitelist:GetName())
	DForm:Help(" - "..ISAWC.ConUseMagnetWhitelist:GetHelpText().."\n")
	DForm:CheckBox("Drop Inventory On Remove",ISAWC.ConDropOnDeathContainer:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeathContainer:GetHelpText().."\n")
	DForm:NumSlider("Health Multiplier",ISAWC.ConAutoHealth:GetName(),0,10,3)
	DForm:Help(" - "..ISAWC.ConAutoHealth:GetHelpText().."\n")
	DForm:NumSlider("Health Regen",ISAWC.ConContainerRegen:GetName(),-100,100,2)
	DForm:Help(" - "..ISAWC.ConContainerRegen:GetHelpText().."\n")
	DForm:CheckBox("Use Alternate Saving",ISAWC.ConSaveIntoFile:GetName())
	DForm:Help(" - "..ISAWC.ConSaveIntoFile:GetHelpText().."\n")
	DForm:Button("Clear Save Cache (Admin Only)","isawc_container_clearcache")
	DForm:Help(" - "..clearcachemessage.."\n")
	
	DForm:Help("") --whitespace
	DForm:ControlHelp("Miscellaneous")
	local dangerbutton = DForm:Button("Set All To Default","isawc_reset_convars")
	dangerbutton:SetTextColor(Color(255,0,0))
end

ISAWC.BuildClientVars = function(self)
	self.SW,self.SH,self.LP = ScrW(),ScrH(),LocalPlayer()
	self.FontH = draw.GetFontHeight("DermaDefault")
end

if CLIENT then
	ISAWC:BuildClientVars()
	local border = 4
	local border_w = 5
	local matSelect = Material("gui/ps_hover.png", "nocull")
	ISAWC.DrawSelectionBox = GWEN.CreateTextureBorder(border, border, 64-border*2, 64-border*2, border_w, border_w, border_w, border_w, matSelect)
end

ISAWC.GetPercentageColor = function(self,percent)
	return HSVToColor(math.Clamp(math.Remap(percent,0,1,180,0),0,180),1,1)
end

ISAWC.DrawInfos = function(self,invinfo,w,h)
	local cw,mw,cv,mv,cc,mc = unpack(invinfo)
	if mc == 0 then mc = 65536 end
	local pw,pv,pc = cw/mw,cv/mv,cc/mc
	draw.RoundedBox(4,0,h-self.FontH*3,w,self.FontH,color_black_semiopaque)
	draw.RoundedBox(4,0,h-self.FontH*2,w,self.FontH,color_black_semiopaque)
	draw.RoundedBox(4,0,h-self.FontH,w,self.FontH,color_black_semiopaque)
	if pw>=0 then
		draw.RoundedBox(4,0,h-self.FontH*3,w*math.min(pw,1),self.FontH,color_dark_red_semitransparent)
		draw.SimpleTextOutlined(string.format("    Mass: %.2f kg/%.2f kg (%i%%)",cw,mw,pw*100),"DermaDefault",0,h-self.FontH*2.5,self:GetPercentageColor(pw),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER,1,color_black_semitransparent)
	end
	if pv>=0 then
		draw.RoundedBox(4,0,h-self.FontH*2,w*math.min(pv,1),self.FontH,color_dark_green_semitransparent)
		draw.SimpleTextOutlined(string.format("    Volume: %.2f dm³/%.2f dm³ (%i%%)",cv*self.dm3perHu,mv*self.dm3perHu,pv*100),"DermaDefault",0,h-self.FontH*1.5,self:GetPercentageColor(pv),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER,1,color_black_semitransparent)
	end
	if pc>=0 then
		draw.RoundedBox(4,0,h-self.FontH,w*math.min(pc,1),self.FontH,color_dark_blue_semitransparent)
		draw.SimpleTextOutlined(string.format("    Number of Items: %u/%u (%i%%)",cc,mc,pc*100),"DermaDefault",0,h-self.FontH*0.5,self:GetPercentageColor(pc),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER,1,color_black_semitransparent)
	end
end

ISAWC.InstallSortFunctions = function(self,panel,InvPanel,delname,wepstorename,dropname,container)
	local allowdel = ISAWC.ConAllowDelete:GetBool()
	panel:SetText(allowdel and "    Options / Delete All" or "    Options")
	panel:SetTextColor(color_white)
	panel:SetContentAlignment(4)
	function panel:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,self.Depressed and color_aqua or self:IsHovered() and color_white_semitransparent or color_gray_semitransparent)
	end
	function panel:DoClick()
		local sOptions = DermaMenu(panel)
		sOptions:AddOption("Invert Selection",function()
			if IsValid(InvPanel) then
				for i,v in ipairs(InvPanel:GetChildren()) do
					if v.ID then
						ISAWC.reliantwindow:AddToSelection(v)
					end
				end
			end
		end):SetIcon("icon16/shape_move_backwards.png")
		sOptions:AddOption("Store Held Weapon",function()
			net.Start("isawc_general")
			net.WriteString(wepstorename)
			if IsValid(container) then
				net.WriteEntity(container)
			end
			net.SendToServer()
		end):SetIcon("icon16/gun.png")
		local sortOptions,sortOption = sOptions:AddSubMenu("Sort Items")
		sortOption:SetIcon("icon16/book.png")
		sortOptions:AddOption("Sort By Class (Ascending)",function()
			if IsValid(InvPanel) then
				local temptab,displ = {},0
				for i,v in ipairs(InvPanel:GetChildren()) do
					if v.MdlInfo then
						temptab[v.ID] = v.MdlInfo.Class .. '_' .. v.MdlInfo.Model .. '_' .. v.MdlInfo.Skin
					end
				end
				for k,v in SortedPairsByValue(temptab) do
					displ = displ + 1
					InvPanel.IDOrder[displ]=k
				end
				InvPanel.WaitForSend = true
			end
		end):SetIcon("icon16/textfield_add.png")
		sortOptions:AddOption("Sort By Class (Descending)",function()
			if IsValid(InvPanel) then
				local temptab,displ = {},0
				for i,v in ipairs(InvPanel:GetChildren()) do
					if v.MdlInfo then
						temptab[v.ID] = v.MdlInfo.Class .. '_' .. v.MdlInfo.Model .. '_' .. v.MdlInfo.Skin
					end
				end
				for k,v in SortedPairsByValue(temptab,true) do
					displ = displ + 1
					InvPanel.IDOrder[displ]=k
				end
				InvPanel.WaitForSend = true
			end
		end):SetIcon("icon16/textfield_delete.png")
		sortOptions:AddOption("Sort By Model (Ascending)",function()
			if IsValid(InvPanel) then
				local temptab,displ = {},0
				for i,v in ipairs(InvPanel:GetChildren()) do
					if v.MdlInfo then
						temptab[v.ID] = v.MdlInfo.Model .. '_' .. v.MdlInfo.Skin .. v.MdlInfo.Class
					end
				end
				for k,v in SortedPairsByValue(temptab) do
					displ = displ + 1
					InvPanel.IDOrder[displ]=k
				end
				InvPanel.WaitForSend = true
			end
		end):SetIcon("icon16/brick_add.png")
		sortOptions:AddOption("Sort By Model (Descending)",function()
			if IsValid(InvPanel) then
				local temptab,displ = {},0
				for i,v in ipairs(InvPanel:GetChildren()) do
					if v.MdlInfo then
						temptab[v.ID] = v.MdlInfo.Model .. '_' .. v.MdlInfo.Skin .. v.MdlInfo.Class
					end
				end
				for k,v in SortedPairsByValue(temptab,true) do
					displ = displ + 1
					InvPanel.IDOrder[displ]=k
				end
				InvPanel.WaitForSend = true
			end
		end):SetIcon("icon16/brick_delete.png")
		sOptions:AddOption("Drop All Items",function()
			net.Start("isawc_general")
			net.WriteString(dropname)
			if IsValid(container) then
				net.WriteEntity(container)
			end
			net.SendToServer()
		end):SetIcon("icon16/package_go.png")
		if ISAWC.ConAllowDelete:GetBool() then
			local SubOptions,SubOption = sOptions:AddSubMenu("Delete All")
			Option = SubOptions:AddOption("Confirm Deletion",function()
				net.Start("isawc_general")
				net.WriteString(delname)
				if IsValid(container) then
					net.WriteEntity(container)
				end
				net.SendToServer()
			end)
			SubOption:SetIcon("icon16/delete.png")
			Option:SetIcon("icon16/accept.png")
		end
		sOptions:Open()
	end
	panel.DoRightClick = panel.DoClick
end

ISAWC.InvData = {0,0,0,0,0,0}
ISAWC.BuildInventory = function(iconPanel,Main)
	
	if IsValid(ISAWC.reliantwindow) then ISAWC.reliantwindow:Close() end
	if not IsValid(Main) then Main = vgui.Create("DFrame") Main:MakePopup() Main:SetKeyboardInputEnabled(false) end
	ISAWC:BuildClientVars()
	Main:SetSize(ISAWC.SW/4,ISAWC.SH/2)
	Main:Center()
	Main:SetTitle("Inventory")
	Main:SetSizable(true)
	Main.SelectedItems = {}
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_semiopaque)
		draw.RoundedBox(8,0,0,w,24,color_black_semiopaque)
	end
	function Main:AddToSelection(item)
		self.SelectedItems = self.SelectedItems or {}
		if self.SelectedItems[item] then
			self.SelectedItems[item] = nil
			item.Selected = nil
		else
			self.SelectedItems[item] = true
			item.Selected = true
		end
	end
	function Main:GetSelectedItems()
		if table.IsEmpty(self.SelectedItems) then
			return {}
		else
			local temptable = table.GetKeys(self.SelectedItems)
			local keysforremoval = {}
			for k,v in pairs(temptable) do
				if not v.ID then temptable[k] = nil end
			end
			return temptable
		end
	end
	ISAWC.reliantwindow = Main
	
	local InvBase = Main:Add("DScrollPanel")
	InvBase:Dock(FILL)
	
	local InfoPanel = Main:Add("DPanel")
	InfoPanel:SetHeight(ISAWC.FontH*3)
	InfoPanel:Dock(BOTTOM)
	function InfoPanel:Paint(w,h)
		ISAWC:DrawInfos(ISAWC.InvData,w,h)
	end
	
	local InvPanel = InvBase:Add("DIconLayout")
	InvPanel:Dock(TOP)
	InvPanel:SetStretchHeight(true)
	InvPanel:SetStretchWidth(false)
	InvPanel:SetDnD(true)
	InvPanel:SetDropPos("46")
	InvPanel:SetUseLiveDrag(true)
	InvPanel:MakeDroppable("ISAWC.ItemMove",false)
	InvPanel.IDOrder = {}
	function InvPanel:Think()
		if self.WaitForSend and not input.IsMouseDown(MOUSE_LEFT) then
			self.WaitForSend = false
			net.Start("isawc_general")
			net.WriteString("moving_items")
			for i,v in ipairs(self.IDOrder) do
				net.WriteUInt(v,16)
			end
			net.SendToServer()
		end
	end
	function InvPanel:OnModified()
		for i,v in ipairs(self:GetChildren()) do
			self.IDOrder[i]=v.ID
		end
		self.WaitForSend = true
	end
	
	local SortOptions = Main:Add("DButton")
	SortOptions:Dock(BOTTOM)
	ISAWC:InstallSortFunctions(SortOptions,InvPanel,"delete_full","store_weapon","drop_all")
	
	local LoadingPanel = InvPanel:Add("DLabel")
	LoadingPanel:SetText(language.GetPhrase("gmod_loading_title"))
	LoadingPanel:SetFont("DermaLarge")
	LoadingPanel:SizeToContents()
	
	function Main:ReceiveStats(data)
		ISAWC.InvData = data
	end
	
	function Main:ReceiveInventory(inv)
		InvPanel:Clear()
		if next(inv) then
			for i,v in ipairs(inv) do
				--local enum,info = next(v)
				local info = v
				if (info and info.Class) then
					local Item = InvPanel:Add("SpawnIcon")
					Item:SetSize(64,64)
					Item:SetModel(info.Model,info.Skin,info.BodyGroups)
					Item.MdlInfo = info
					Item:Droppable("ISAWC.ItemMove")
					if info.Class ~= "prop_physics" and info.Class ~= "prop_ragdoll" then
						Item:SetTooltip(language.GetPhrase(info.Class))
					end
					Item.OldPaintOver = Item.PaintOver
					function Item:PaintOver(w,h)
						local hasClip1 = false
						if info.Clip1 > 0 or info.MaxClip1 > 0 then
							hasClip1 = true
							if info.MaxClip1 > 0 then
								draw.SimpleTextOutlined(string.format("%i/%i", info.Clip1, info.MaxClip1), "DermaDefault", w-1, 1, ISAWC:GetPercentageColor(1-info.Clip1/info.MaxClip1), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							else
								draw.SimpleTextOutlined(string.format("%i", info.Clip1), "DermaDefault", w-1, 1, info.Clip1 > 0 and color_aqua or color_red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							end
						end
						if info.Clip2 > 0 or info.MaxClip2 > 0 then
							if info.MaxClip2 > 0 then
								draw.SimpleTextOutlined(string.format("%i/%i", info.Clip2, info.MaxClip2), "DermaDefault", w-1, hasClip1 and 14 or 1, ISAWC:GetPercentageColor(1-info.Clip2/info.MaxClip2), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							else
								draw.SimpleTextOutlined(string.format("%i", info.Clip2), "DermaDefault", w-1, hasClip1 and 14 or 1, info.Clip2 > 0 and color_aqua or color_red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							end
						end
						if self.Selected then
							ISAWC.DrawSelectionBox(0,0,w,h,color_white)
						end
						self:OldPaintOver(w,h)
					end
					function Item:SendSignal(msg)
						if Item.SendIDs then
							net.Start("isawc_general")
							net.WriteString(msg)
							net.WriteUInt(0,16)
							net.WriteUInt(#Item.SendIDs,16)
							for i,v in ipairs(Item.SendIDs) do
								net.WriteUInt(v,16)
							end
							net.SendToServer()
							Item.SendIDs = nil
						else
							net.Start("isawc_general")
							net.WriteString(msg)
							net.WriteUInt(i,16)
							net.SendToServer()
						end
					end
					function Item:AddSignal(id)
						Item.SendIDs = Item.SendIDs or {}
						table.insert(Item.SendIDs,id)
					end
					function Item:DoClick()
						if input.IsShiftDown() then
							Main:AddToSelection(self)
						else
							self:SendSignal("spawn")
						end
					end
					function Item:DoRightClick()
						local Options = DermaMenu(Item)
						local Option = nil
						if #Main:GetSelectedItems() <= 0 or ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							Option = Options:AddOption("Use / Spawn At Self",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										self:AddSignal(v2.ID)
									end
									self:SendSignal("spawn_self")
								end
							end)
							Option:SetIcon("icon16/arrow_in.png")
							Option = Options:AddOption("Spawn At Crosshair",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										self:AddSignal(v2.ID)
									end
									self:SendSignal("spawn")
								end
							end)
							Option:SetIcon("icon16/pencil.png")
						end
						if info.Clip1 > 0 or info.Clip2 > 0 then
							Option = Options:AddOption("Empty Weapon Clips",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										self:AddSignal(v2.ID)
									end
									self:SendSignal("empty")
								end
							end)
							Option:SetIcon("icon16/basket_remove.png")
						end
						if ISAWC.ConAllowDelete:GetBool() then
							local SubOptions,SubOption = Options:AddSubMenu("Delete")
							Option = SubOptions:AddOption("Confirm Deletion",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										self:AddSignal(v2.ID)
									end
									self:SendSignal("delete")
								end
							end)
							SubOption:SetIcon("icon16/delete.png")
							Option:SetIcon("icon16/accept.png")
						end
						Options:AddSpacer()
						Option = Options:AddOption("Edit Icon",function()
							if IsValid(self) then
								local IconEditor = vgui.Create("IconEditor")
								IconEditor:SetSize(ISAWC.SW/2,ISAWC.SH/2)
								IconEditor:SetIcon(Item)
								IconEditor:Refresh()
								IconEditor:Center()
								IconEditor:SetSizable(true)
								IconEditor:MakePopup()
							end
						end)
						Option:SetIcon("icon16/wrench.png")
						Options:Open()
					end
					Item.ID = i
				end
			end
		else
			LoadingPanel = InvPanel:Add("DLabel")
			LoadingPanel:SetText(language.GetPhrase("addons.none"))
			LoadingPanel:SetFont("DermaLarge")
			LoadingPanel:SizeToContents()
		end
	end
	
	net.Start("isawc_general")
	net.WriteString("inv")
	net.SendToServer()
	
	return Main
end

ISAWC.InvData2 = {0,0,0,0,0,0}
ISAWC.BuildOtherInventory = function(self,container,inv1,inv2,info1,info2)

	ISAWC:BuildClientVars()
	if IsValid(ISAWC.reliantwindow) then ISAWC.reliantwindow:Close() end
	local Main = vgui.Create("DFrame")
	Main:SetSize(ISAWC.SW/2,ISAWC.SH/2)
	Main:Center()
	Main:SetTitle("Inventories")
	Main:SetSizable(true)
	Main:MakePopup()
	Main:SetKeyboardInputEnabled(false)
	Main.SelectedItems = {}
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_semiopaque)
		draw.RoundedBox(8,0,0,w,24,color_black_semiopaque)
	end
	function Main:OnRemove()
		net.Start("isawc_general")
		net.WriteString("container_close")
		net.WriteEntity(container)
		net.SendToServer()
	end
	function Main:Think()
		if not LocalPlayer():Alive() then self:Close() end
		if not IsValid(container) then self:Close() return ISAWC:NoPickup("The container is missing!") end
		if LocalPlayer():GetPos():Distance(container:GetPos())-container:BoundingRadius()>ISAWC.ConDistance:GetFloat() then self:Close() end
	end
	function Main:AddToSelection(item)
		self.SelectedItems = self.SelectedItems or {}
		if self.SelectedItems[item] then
			self.SelectedItems[item] = nil
			item.Selected = nil
		else
			self.SelectedItems[item] = true
			item.Selected = true
		end
	end
	function Main:GetSelectedItems()
		if table.IsEmpty(self.SelectedItems) then
			return {}
		else
			local temptable = table.GetKeys(self.SelectedItems)
			local keysforremoval = {}
			for k,v in pairs(temptable) do
				if not v.ID then temptable[k] = nil end
			end
			return temptable
		end
	end
	Main.IsDouble = true
	ISAWC.reliantwindow = Main
	
	local Divider = Main:Add("DHorizontalDivider")
	Divider:Dock(FILL)
	Divider:SetDividerWidth(4)
	Divider:SetLeftWidth(ISAWC.SW/4-6)
	
	local InvBaseLeft = Divider:Add("DPanel")
	function InvBaseLeft:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_semitransparent)
		draw.SimpleText("Your Inventory","Default",w/2,h/2,color_white_semitransparent,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	InvBaseLeft:Receiver("ISAWC.ItemMoveContainer2",function(self,tab,dropped,...)
		if dropped then
			for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
				if v2.IsInContainer then
					tab[1]:AddSignal(v2.ID)
				end
			end
			tab[1]:SendSignal("transfer_from")
		end
	end)
	Divider:SetLeft(InvBaseLeft)
	
	local InfoLeft = InvBaseLeft:Add("DPanel")
	InfoLeft:SetHeight(ISAWC.FontH*3)
	InfoLeft:Dock(BOTTOM)
	function InfoLeft:Paint(w,h)
		ISAWC:DrawInfos(ISAWC.InvData,w,h)
	end
	
	local InvFittingLeft = InvBaseLeft:Add("DScrollPanel")
	InvFittingLeft:Dock(FILL)
	
	local InvLeft = InvFittingLeft:Add("DIconLayout")
	InvLeft:Dock(TOP)
	InvLeft:SetStretchHeight(true)
	InvLeft:SetStretchWidth(false)
	InvLeft:MakeDroppable("ISAWC.ItemMoveContainer",false)
	InvLeft.IDOrder = {}
	function InvLeft:Think()
		if self.WaitForSend and not input.IsMouseDown(MOUSE_LEFT) then
			self.WaitForSend = false
			net.Start("isawc_general")
			net.WriteString("moving_items_container")
			for i,v in ipairs(self.IDOrder) do
				net.WriteUInt(v,16)
			end
			net.WriteEntity(container)
			net.SendToServer()
		end
	end
	function InvLeft:OnModified()
		for i,v in ipairs(self:GetChildren()) do
			self.IDOrder[i]=v.ID
		end
		self.WaitForSend = true
	end
	
	local SortLeft = InvBaseLeft:Add("DButton")
	SortLeft:Dock(BOTTOM)
	ISAWC:InstallSortFunctions(SortLeft,InvLeft,"delete_in_container_full","store_weapon_in_container","drop_all_in_container",container)
	
	local LoadingLeft = InvLeft:Add("DLabel")
	LoadingLeft:SetText(language.GetPhrase("gmod_loading_title"))
	LoadingLeft:SetFont("DermaLarge")
	LoadingLeft:SizeToContents()
	
	local InvBaseRight = Divider:Add("DPanel")
	function InvBaseRight:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_semitransparent)
		draw.SimpleText("Container's Inventory","Default",w/2,h/2,color_white_semitransparent,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	InvBaseRight:Receiver("ISAWC.ItemMoveContainer",function(self,tab,dropped,...)
		if dropped then
			for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
				if not v2.IsInContainer then
					tab[1]:AddSignal(v2.ID)
				end
			end
			tab[1]:SendSignal("transfer_to")
		end
	end)
	Divider:SetRight(InvBaseRight)
	
	local InfoRight = InvBaseRight:Add("DPanel")
	InfoRight:SetHeight(ISAWC.FontH*3)
	InfoRight:Dock(BOTTOM)
	function InfoRight:Paint(w,h)
		ISAWC:DrawInfos(ISAWC.InvData2,w,h)
	end
	
	local InvFittingRight = InvBaseRight:Add("DScrollPanel")
	InvFittingRight:Dock(FILL)
	
	local InvRight = InvFittingRight:Add("DIconLayout")
	InvRight:Dock(TOP)
	InvRight:SetStretchHeight(true)
	InvRight:SetStretchWidth(false)
	InvRight:MakeDroppable("ISAWC.ItemMoveContainer2",false)
	InvRight.IDOrder = {}
	function InvRight:Think()
		if self.WaitForSend and not input.IsMouseDown(MOUSE_LEFT) then
			self.WaitForSend = false
			net.Start("isawc_general")
			net.WriteString("moving_items_container2")
			net.WriteEntity(container)
			for i,v in ipairs(self.IDOrder) do
				net.WriteUInt(v,16)
			end
			net.SendToServer()
		end
	end
	function InvRight:OnModified()
		for i,v in ipairs(self:GetChildren()) do
			self.IDOrder[i]=v.ID
		end
		self.WaitForSend = true
	end
	
	local SortRight = InvBaseRight:Add("DButton")
	SortRight:Dock(BOTTOM)
	ISAWC:InstallSortFunctions(SortRight,InvRight,"delete_in_container_full2","store_weapon_in_container2","drop_all_in_container2",container)
	
	local LoadingRight = InvRight:Add("DLabel")
	LoadingRight:SetText(language.GetPhrase("gmod_loading_title"))
	LoadingRight:SetFont("DermaLarge")
	LoadingRight:SizeToContents()
	
	function Main:ReceiveInventory(inv1,inv2)
		InvLeft:Clear()
		InvRight:Clear()
		if next(inv1) then
			for i,v in ipairs(inv1) do
				--local enum,info = next(v)
				local info = v
				if (info and info.Class) then
					local Item = InvLeft:Add("SpawnIcon")
					Item:SetSize(64,64)
					Item:SetModel(info.Model,info.Skin,info.BodyGroups)
					Item:Droppable("ISAWC.ItemMoveContainer")
					Item.MdlInfo = info
					if info.Class ~= "prop_physics" and info.Class ~= "prop_ragdoll" then
						Item:SetTooltip(language.GetPhrase(info.Class))
					end
					Item.OldPaintOver = Item.PaintOver
					function Item:PaintOver(w,h)
						local hasClip1 = false
						if info.Clip1 > 0 or info.MaxClip1 > 0 then
							hasClip1 = true
							if info.MaxClip1 > 0 then
								draw.SimpleTextOutlined(string.format("%i/%i", info.Clip1, info.MaxClip1), "DermaDefault", w-1, 1, ISAWC:GetPercentageColor(1-info.Clip1/info.MaxClip1), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							else
								draw.SimpleTextOutlined(string.format("%i", info.Clip1), "DermaDefault", w-1, 1, info.Clip1 > 0 and color_aqua or color_red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							end
						end
						if info.Clip2 > 0 or info.MaxClip2 > 0 then
							if info.MaxClip2 > 0 then
								draw.SimpleTextOutlined(string.format("%i/%i", info.Clip2, info.MaxClip2), "DermaDefault", w-1, hasClip1 and 14 or 1, ISAWC:GetPercentageColor(1-info.Clip2/info.MaxClip2), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							else
								draw.SimpleTextOutlined(string.format("%i", info.Clip2), "DermaDefault", w-1, hasClip1 and 14 or 1, info.Clip2 > 0 and color_aqua or color_red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							end
						end
						if self.Selected then
							ISAWC.DrawSelectionBox(0,0,w,h,color_white)
						end
						self:OldPaintOver(w,h)
					end
					function Item:SendSignal(msg,msg2)
						if Item.SendIDs or Item.SendIDs2 then
							if Item.SendIDs then
								net.Start("isawc_general")
								net.WriteString(msg)
								net.WriteEntity(container)
								net.WriteUInt(0,16)
								net.WriteUInt(#Item.SendIDs,16)
								for i,v in ipairs(Item.SendIDs) do
									net.WriteUInt(v,16)
								end
								net.SendToServer()
							end
							if Item.SendIDs2 then
								net.Start("isawc_general")
								net.WriteString(msg2)
								net.WriteEntity(container)
								net.WriteUInt(0,16)
								net.WriteUInt(#Item.SendIDs2,16)
								for i,v in ipairs(Item.SendIDs2) do
									net.WriteUInt(v,16)
								end
								net.SendToServer()
							end
							Item.SendIDs = nil
							Item.SendIDs2 = nil
						else
							net.Start("isawc_general")
							net.WriteString(msg2 or msg)
							net.WriteEntity(container)
							net.WriteUInt(i,16)
							net.SendToServer()
						end
					end
					function Item:AddSignal(id)
						Item.SendIDs = Item.SendIDs or {}
						table.insert(Item.SendIDs,id)
					end
					function Item:AddSignal2(id)
						Item.SendIDs2 = Item.SendIDs2 or {}
						table.insert(Item.SendIDs2,id)
					end
					function Item:DoClick()
						if input.IsShiftDown() then
							Main:AddToSelection(self)
						else
							self:SendSignal("transfer_to")
						end
					end
					function Item:DoRightClick()
						local Options = DermaMenu(Item)
						local Option = Options:AddOption("Deposit",function()
							if IsValid(self) then
								for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
									if not v2.IsInContainer then
										self:AddSignal(v2.ID)
									end
								end
								self:SendSignal("transfer_to")
							end
						end)
						Option:SetIcon("icon16/arrow_right.png")
						if #Main:GetSelectedItems() <= 0 or ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							Option = Options:AddOption("Use / Spawn At Self",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("spawn_self_in_container2","spawn_self_in_container")
								end
							end)
							Option:SetIcon("icon16/arrow_in.png")
							Option = Options:AddOption("Spawn At Crosshair",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("spawn_in_container2","spawn_in_container")
								end
							end)
							Option:SetIcon("icon16/pencil.png")
						end
						if info.Clip1 > 0 or info.Clip2 > 0 then
							Option = Options:AddOption("Empty Weapon Clips",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("empty_in_container2","empty_in_container")
								end
							end)
							Option:SetIcon("icon16/basket_remove.png")
						end
						if ISAWC.ConAllowDelete:GetBool() then
							local SubOptions,SubOption = Options:AddSubMenu("Delete")
							Option = SubOptions:AddOption("Confirm Deletion",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("delete_in_container2","delete_in_container")
								end
							end)
							SubOption:SetIcon("icon16/delete.png")
							Option:SetIcon("icon16/accept.png")
						end
						Options:AddSpacer()
						Option = Options:AddOption("Edit Icon",function()
							if IsValid(self) then
								local IconEditor = vgui.Create("IconEditor")
								IconEditor:SetSize(ISAWC.SW/2,ISAWC.SH/2)
								IconEditor:SetIcon(self)
								IconEditor:Refresh()
								IconEditor:Center()
								IconEditor:SetSizable(true)
								IconEditor:MakePopup()
							end
						end)
						Option:SetIcon("icon16/wrench.png")
						Options:Open()
					end
					Item.ID = i
				end
			end
		else
			LoadingLeft = InvLeft:Add("DLabel")
			LoadingLeft:SetText(language.GetPhrase("addons.none"))
			LoadingLeft:SetFont("DermaLarge")
			LoadingLeft:SizeToContents()
		end
		if next(inv2) then
			for i,v in ipairs(inv2) do
				--local enum,info = next(v)
				local info = v
				if (info and info.Class) then
					local Item = InvRight:Add("SpawnIcon")
					Item:SetSize(64,64)
					Item:SetModel(info.Model,info.Skin,info.BodyGroups)
					Item:Droppable("ISAWC.ItemMoveContainer2")
					Item.MdlInfo = info
					if info.Class ~= "prop_physics" and info.Class ~= "prop_ragdoll" then
						Item:SetTooltip(language.GetPhrase(info.Class))
					end
					Item.OldPaintOver = Item.PaintOver
					function Item:PaintOver(w,h)
						local hasClip1 = false
						if info.Clip1 > 0 or info.MaxClip1 > 0 then
							hasClip1 = true
							if info.MaxClip1 > 0 then
								draw.SimpleTextOutlined(string.format("%i/%i", info.Clip1, info.MaxClip1), "DermaDefault", w-1, 1, ISAWC:GetPercentageColor(1-info.Clip1/info.MaxClip1), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							else
								draw.SimpleTextOutlined(string.format("%i", info.Clip1), "DermaDefault", w-1, 1, info.Clip1 > 0 and color_aqua or color_red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							end
						end
						if info.Clip2 > 0 or info.MaxClip2 > 0 then
							if info.MaxClip2 > 0 then
								draw.SimpleTextOutlined(string.format("%i/%i", info.Clip2, info.MaxClip2), "DermaDefault", w-1, hasClip1 and 14 or 1, ISAWC:GetPercentageColor(1-info.Clip2/info.MaxClip2), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							else
								draw.SimpleTextOutlined(string.format("%i", info.Clip2), "DermaDefault", w-1, hasClip1 and 14 or 1, info.Clip2 > 0 and color_aqua or color_red, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black_semitransparent)
							end
						end
						if self.Selected then
							ISAWC.DrawSelectionBox(0,0,w,h,color_white)
						end
						self:OldPaintOver(w,h)
					end
					function Item:SendSignal(msg,msg2)
						if Item.SendIDs or Item.SendIDs2 then
							if Item.SendIDs then
								net.Start("isawc_general")
								net.WriteString(msg)
								net.WriteEntity(container)
								net.WriteUInt(0,16)
								net.WriteUInt(#Item.SendIDs,16)
								for i,v in ipairs(Item.SendIDs) do
									net.WriteUInt(v,16)
								end
								net.SendToServer()
							end
							if Item.SendIDs2 then
								net.Start("isawc_general")
								net.WriteString(msg2)
								net.WriteEntity(container)
								net.WriteUInt(0,16)
								net.WriteUInt(#Item.SendIDs2,16)
								for i,v in ipairs(Item.SendIDs2) do
									net.WriteUInt(v,16)
								end
								net.SendToServer()
							end
							Item.SendIDs = nil
							Item.SendIDs2 = nil
						else
							net.Start("isawc_general")
							net.WriteString(msg)
							net.WriteEntity(container)
							net.WriteUInt(i,16)
							net.SendToServer()
						end
					end
					function Item:AddSignal(id)
						Item.SendIDs = Item.SendIDs or {}
						table.insert(Item.SendIDs,id)
					end
					function Item:AddSignal2(id)
						Item.SendIDs2 = Item.SendIDs2 or {}
						table.insert(Item.SendIDs2,id)
					end
					function Item:DoClick()
						if input.IsShiftDown() then
							Main:AddToSelection(self)
						else
							self:SendSignal("transfer_from")
						end
					end
					function Item:DoRightClick()
						local Options = DermaMenu(Item)
						local Option = Options:AddOption("Withdraw",function()
							if IsValid(self) then
								for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
									if v2.IsInContainer then
										self:AddSignal(v2.ID)
									end
								end
								self:SendSignal("transfer_from")
							end
						end)
						Option:SetIcon("icon16/arrow_left.png")
						if #Main:GetSelectedItems() <= 0 or ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							Option = Options:AddOption("Use / Spawn At Self",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("spawn_self_in_container2","spawn_self_in_container")
								end
							end)
							Option:SetIcon("icon16/arrow_in.png")
							Option = Options:AddOption("Spawn At Crosshair",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("spawn_in_container2","spawn_in_container")
								end
							end)
							Option:SetIcon("icon16/pencil.png")
						end
						if info.Clip1 > 0 or info.Clip2 > 0 then
							Option = Options:AddOption("Empty Weapon Clips",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("empty_in_container2","empty_in_container")
								end
							end)
							Option:SetIcon("icon16/basket_remove.png")
						end
						if ISAWC.ConAllowDelete:GetBool() then
							local SubOptions,SubOption = Options:AddSubMenu("Delete")
							Option = SubOptions:AddOption("Confirm Deletion",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(Main:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("delete_in_container2","delete_in_container")
								end
							end)
							SubOption:SetIcon("icon16/delete.png")
							Option:SetIcon("icon16/accept.png")
						end
						Options:AddSpacer()
						Option = Options:AddOption("Edit Icon",function()
							if IsValid(self) then
								local IconEditor = vgui.Create("IconEditor")
								IconEditor:SetSize(ISAWC.SW/2,ISAWC.SH/2)
								IconEditor:SetIcon(self)
								IconEditor:Refresh()
								IconEditor:Center()
								IconEditor:SetSizable(true)
								IconEditor:MakePopup()
							end
						end)
						Option:SetIcon("icon16/wrench.png")
						Options:Open()
					end
					Item.ID = i
					Item.IsInContainer = true
				end
			end
		else
			LoadingRight = InvRight:Add("DLabel")
			LoadingRight:SetText(language.GetPhrase("addons.none"))
			LoadingRight:SetFont("DermaLarge")
			LoadingRight:SizeToContents()
		end
	end
	
	function Main:ReceiveStats(data1,data2)
		ISAWC.InvData = data1
		ISAWC.InvData2 = data2
	end
	
	net.Start("isawc_general")
	net.WriteString("inv_container")
	net.WriteEntity(container)
	net.SendToServer()
	
end

ISAWC.WriteClientInventory = function(self,ply)
	local inv = ply.ISAWC_Inventory or {}
	net.WriteUInt(#inv, 16)
	for i,v in ipairs(inv) do
		if next(v.Entities or {}) then
			self:WriteModelFromDupeTable(v)
		end
	end
end

ISAWC.WriteModelFromDupeTable = function(self,dupe)
	local ent = dupe.Entities[next(dupe.Entities)]
	local bodyGroups = "000000000"
	for k,v in pairs(ent.BodyG or {}) do
		bodyGroups = string.SetChar(bodyGroups,k,v)
	end
	net.WriteString(ent.Model)
	net.WriteString(ent.EntityMods and ent.EntityMods.WireName and ent.EntityMods.WireName.name~="" and ent.EntityMods.WireName.name
	or ent.Name~="" and ent.Name or ent.name~="" and ent.name or ent.PrintName~="" and ent.PrintName~="Scripted Weapon" and ent.PrintName
	or ent.Class)
	net.WriteUInt(ent.Skin or 0, 16)
	net.WriteString(bodyGroups)
	net.WriteInt(ent.SavedClip1 or -1, 32)
	net.WriteInt(ent.SavedClip2 or -1, 32)
	net.WriteInt(ent.SavedMaxClip1 or -1, 32)
	net.WriteInt(ent.SavedMaxClip2 or -1, 32)
end

ISAWC.GetClientStats = function(self,ply)
	local isPlayer = ply:IsPlayer()
	local cw,cv,cc = 0,0,0
	local mw,mv,mc = 0,0,isPlayer and self.ConCount:GetInt() or self.ConCount2:GetInt()
	for k,v in pairs(ply.ISAWC_Inventory or {}) do
		local aw,av,ac = self:GetStatsFromDupeTable(v)
		if aw > 0 then
			cw = cw + aw
		else
			mw = mw - aw
		end
		if av > 0 then
			cv = cv + av
		else
			mv = mv - av
		end
		if ac > 0 then
			cc = cc + ac
		else
			mc = mc - ac
		end
	end
	if self.ConConstEnabled:GetBool() then
		if isPlayer then
			mw = self.ConConstMass:GetFloat()
			mv = self.ConConstVol:GetFloat()/self.dm3perHu
		else
			mw = ply.ContainerConstants.Mass * self.ConMassMul2:GetFloat() * (ply.GetMassMul and ply:GetMassMul() or 1)
			mv = ply.ContainerConstants.Volume/self.dm3perHu * self.ConVolMul2:GetFloat() * (ply.GetVolumeMul and ply:GetVolumeMul() or 1)
		end
	else
		for k,v in pairs({ply,ply:GetChildren()}) do
			if IsValid(v) then
				for i=1,v:GetPhysicsObjectCount() do
					local physobj = v:GetPhysicsObjectNum(i-1)
					if IsValid(physobj) then
						mw = mw + physobj:GetMass()
						mv = mv + physobj:GetVolume()
					end
				end
			end
		end
		if mw <= 0 then
			mw = 100
		end
		if mv <= 0 then
			mv = 100
		end
		if isPlayer then
			mw = mw * self.ConMassMul:GetFloat()
			mv = mv * self.ConVolMul:GetFloat()
		else
			mw = mw * self.ConMassMul2:GetFloat() * (ply.GetMassMul and ply:GetMassMul() or 1) * (ply.ContainerMassMul or 1)
			mv = mv * self.ConVolMul2:GetFloat() * (ply.GetVolumeMul and ply:GetVolumeMul() or 1) * (ply.ContainerVolumeMul or 1)
		end
	end
	if isPlayer then
		mw = mw * (self:StringMatchParams(ply:GetUserGroup(), ISAWC.MassMultiList) or 1)
		mv = mv * (self:StringMatchParams(ply:GetUserGroup(), ISAWC.VolumeMultiList) or 1)
		mc = mc * (self:StringMatchParams(ply:GetUserGroup(), ISAWC.CountMultiList) or 1)
	end
	if mw <= 0 then mw = math.huge end
	if mv <= 0 then mv = math.huge end
	if mc <= 0 then mc = 65536 end
	return {cw,mw,cv,mv,cc,mc}
end

ISAWC.GetStatsFromDupeTable = function(self,dupe)
	return tonumber(dupe.TotalMass) or 0,tonumber(dupe.TotalVolume) or 0,tonumber(dupe.TotalCount) or 1
end

ISAWC.SendInventory = function(self,ply)
	net.Start("isawc_general")
	net.WriteString("inv")
	--[[local data = util.Compress(util.TableToJSON(self:GetClientInventory(ply)))
	net.WriteUInt(#data,32)
	net.WriteData(data,#data)]]
	
	self:WriteClientInventory(ply)
	
	local stats = self:GetClientStats(ply)
	for i=1,4 do
		net.WriteFloat(stats[i])
	end
	for i=5,6 do
		net.WriteUInt(stats[i],16)
	end
	net.Send(ply)
end

ISAWC.SendInventory2 = function(self,ply,container)
	if not IsValid(container) then return end
	net.Start("isawc_general")
	net.WriteString("inv2")
	--[[local data1 = util.Compress(util.TableToJSON(self:WriteClientInventory(ply)))
	local data2 = util.Compress(util.TableToJSON(self:WriteClientInventory(container)))
	net.WriteUInt(#data1,32)
	net.WriteUInt(#data2,32)
	net.WriteData(data1,#data1)
	net.WriteData(data2,#data2)]]
	self:WriteClientInventory(ply)
	self:WriteClientInventory(container)
	local stats = self:GetClientStats(ply)
	for i=1,4 do
		net.WriteFloat(stats[i])
	end
	for i=5,6 do
		net.WriteUInt(stats[i],16)
	end
	stats = self:GetClientStats(container)
	for i=1,4 do
		net.WriteFloat(stats[i])
	end
	for i=5,6 do
		net.WriteUInt(stats[i],16)
	end
	net.Send(ply)
	ISAWC:SaveContainerInventory(container)
end

ISAWC.CalculateVolume = function(self,v1,v2)
	return math.abs((v2.x-v1.x)*(v2.y-v1.y)*(v2.z-v1.z))
end

ISAWC.NoPickup = function(self,msg,ply)
	if not self.ConPickupDenyLogs:GetBool() and SERVER then
		self:Log(tostring(ply)..': '..msg)
	end
	if (SERVER and ply:IsPlayer() and not self.ConHideNotifsG:GetBool()) then
		net.Start("isawc_general")
		net.WriteString("no_pickup")
		net.WriteString(msg)
		net.Send(ply)
	end
	if (CLIENT and not self.ConHideNotifs:GetBool()) then
		notification.AddLegacy(msg,NOTIFY_ERROR,2+#msg/20)
		if not self.ConHideNotifSound:GetBool() then
			surface.PlaySound("buttons/button10.wav")
		end
	end
end

ISAWC.RemoveRecursions = function(self,tab,done)
	if not istable(tab) then return false end
	
	if not done then
		done = {}
	elseif done[tab] then
		done[tab] = done[tab] + 1
	else
		done[tab] = 0
	end
	
	local recursive = false
	for k,v in pairs(tab) do
		if istable(v) then
			if (done[tab] or 0) > 8 then
				tab[k] = nil
				recursive = true
			else
				recursive = recursive or self:RemoveRecursions(v,done)
			end
		end
	end
	done[tab] = nil
	
	return recursive
end

ISAWC.SaveInventory = function(self,ply)
	local data = util.JSONToTable(util.Decompress(file.Read("isawc_data.dat") or "")) or {}
	local steamid
	data.Blacklist = self.Blacklist or {}
	data.BlackContainerMagnetList = self.BlackContainerMagnetList or {}
	data.Whitelist = self.Whitelist or {}
	data.WhiteExtractList = self.WhiteExtractList or {}
	data.WhiteMagnetList = self.WhiteMagnetList or {}
	data.Stacklist = self.Stacklist or {}
	data.Masslist = self.Masslist or {}
	data.Volumelist = self.Volumelist or {}
	data.Countlist = self.Countlist or {}
	data.Remaplist = self.Remaplist or {}
	data.MassMultiList = self.MassMultiList or {}
	data.VolumeMultiList = self.VolumeMultiList or {}
	data.CountMultiList = self.CountMultiList or {}
	if isstring(ply) then
		steamid = ply
		ply = player.GetBySteamID(ply)
	end
	if (IsValid(ply) and ply:IsPlayer()) then
		steamid = steamid or ply:SteamID()
		if steamid then
			if self.ConDoSave:GetInt() > 0 then
				if not isstring(ply) and self:RemoveRecursions(ply.ISAWC_Inventory) then
					self:Log("Warning! " .. (isstring(ply) and ply or ply:Nick()) .. " had an item with recursive tables! This may cause errors to occur!")
				end
				data[steamid] = ply.ISAWC_Inventory or {}
			else
				data[steamid] = nil
			end
		end
	elseif istable(ply) then
		for k,v in pairs(ply) do
			steamid = v:SteamID()
			if steamid then
				if self.ConDoSave:GetInt() > 0 then
					if self:RemoveRecursions(v.ISAWC_Inventory) then
						self:Log("Warning! " .. v:Nick() .. " had an item with recursive tables! This may cause errors to occur!")
					end
					data[steamid] = v.ISAWC_Inventory or {}
				else
					data[steamid] = nil
				end
			end
		end
	end
	file.Write("isawc_data.dat",util.Compress(util.TableToJSON(data)))
end

ISAWC.SaveContainerInventory = function(self,container)
	container:SendInventoryUpdate()
	local endername = container:GetEnderInvName()
	if (endername or "")~="" then
		for k,v in pairs(ents.GetAll()) do
			if (IsValid(v) and v.Base=="isawc_container_base" and v:GetEnderInvName()==endername) then
				v.ISAWC_Inventory = container.ISAWC_Inventory
				v:SendInventoryUpdate()
			end
		end
	end
	if self:RemoveRecursions(container.ISAWC_Inventory) then
		self:Log("Warning! " .. tostring(container) .. " had an item with recursive tables! This may cause errors to occur!")
	end
	if self.ConSaveIntoFile:GetBool() then
		local data = container.ISAWC_Inventory
		if not file.IsDir("isawc_containers","DATA") then
			file.CreateDir("isawc_containers")
		end
		file.Write("isawc_containers/"..container:GetFileID()..".dat",util.Compress(util.TableToJSON(data)))
	end
end

ISAWC.LastLoadedData = {}
ISAWC.PlayerSpawn = function(ply)
	timer.Simple(0.5,function()
		if not next(ISAWC.LastLoadedData) then
			local data = util.JSONToTable(util.Decompress(file.Read("isawc_data.dat") or "")) or {}
			ISAWC.Blacklist = data.Blacklist or ISAWC.Blacklist
			ISAWC.BlackContainerMagnetList = data.BlackContainerMagnetList or ISAWC.BlackContainerMagnetList
			ISAWC.Whitelist = data.Whitelist or ISAWC.Whitelist
			ISAWC.WhiteExtractList = data.WhiteExtractList or ISAWC.WhiteExtractList
			ISAWC.WhiteMagnetList = data.WhiteMagnetList or ISAWC.WhiteMagnetList
			ISAWC.Stacklist = data.Stacklist or ISAWC.Stacklist
			ISAWC.Masslist = data.Masslist or ISAWC.Masslist
			ISAWC.Volumelist = data.Volumelist or ISAWC.Volumelist
			ISAWC.Countlist = data.Countlist or ISAWC.Countlist
			ISAWC.Remaplist = data.Remaplist or ISAWC.Remaplist
			ISAWC.MassMultiList = data.MassMultiList or ISAWC.MassMultiList
			ISAWC.VolumeMultiList = data.VolumeMultiList or ISAWC.VolumeMultiList
			ISAWC.CountMultiList = data.CountMultiList or ISAWC.CountMultiList
			ISAWC.LastLoadedData = data
		end
		if IsValid(ply) then
			if (ply.ISAWC_Inventory and next(ply.ISAWC_Inventory)) then
				ISAWC.LastLoadedData[ply:SteamID() or ""] = nil
			else
				if ISAWC.LastLoadedData[ply:SteamID()] and ISAWC.ConDoSave:GetInt() > 0 then
					ply.ISAWC_Inventory = ISAWC.LastLoadedData[ply:SteamID()]
				end
			end
			ISAWC:SendInventory(ply)
		end
	end)
end

ISAWC.PlayerDeath = function(ply)
	if (ply.ISAWC_Inventory and next(ply.ISAWC_Inventory)) and ISAWC.ConDropOnDeath:GetBool() then
		local briefcase = ents.Create(ISAWC.ConDropOnDeathClass:GetString())
		local modelOverride = ISAWC.ConDropOnDeathModel:GetString()
		if not (IsValid(briefcase) and briefcase.Base == "isawc_container_base") then
			SafeRemoveEntity(briefcase)
			ISAWC:Log("Failed to create invalid container class "..ISAWC.ConDropOnDeathClass:GetString()..'!')
			ISAWC:Log("Failed to remove items owned by "..ply:Nick().." as the dropped container was invalid!")
		elseif not (modelOverride == "" or util.IsValidModel(modelOverride)) then
			briefcase:Remove()
			ISAWC:Log("Failed to create invalid model "..modelOverride..'!')
			ISAWC:Log("Failed to remove items owned by "..ply:Nick().." as the dropped container was invalid!")
		else
			briefcase:SetPos(ply:GetPos() + ply:OBBCenter())
			if modelOverride ~= "" then
				briefcase.ContainerModel = modelOverride
			end
			briefcase:Spawn()
			briefcase.ISAWC_IsDeathDrop = true
			ISAWC:SetSuppressUndo(true)
			for i=1,#ply.ISAWC_Inventory do
				local dupe = ply.ISAWC_Inventory[i]
				if dupe then
					table.insert(briefcase.ISAWC_Inventory,dupe)
					--ISAWC:SpawnDupe(dupe,true,true,i,ply)
				end
			end
			ISAWC:SetSuppressUndo(false)
			table.Empty(ply.ISAWC_Inventory)
			ISAWC:SendInventory(ply)
			ISAWC:SaveInventory(ply)
		end
	end
end

ISAWC.PlayerDisconnect = function(data)
	if SERVER then
		if data then
			ISAWC:SaveInventory(data.networkid)
		else
			ISAWC:SaveInventory(player.GetAll())
		end
	end
end

if SERVER then
	for k,v in pairs(player.GetAll()) do
		ISAWC:SendInventory(v)
	end
end

ISAWC.IsLegalContainer = function(self,ent,ply,ignoreDist)
	local cond1 = IsValid(ent) and ent.Base=="isawc_container_base" and ply:Alive()
	local cond2 = ignoreDist or ply:GetPos():Distance(ent:GetPos())-ent:BoundingRadius()<=ISAWC.ConDistance:GetFloat()
	local cond3 = ent:GetOwnerAccountID()==(ply:AccountID() or 0) or ent:GetIsPublic() or ISAWC.ConAlwaysPublic:GetInt() == 1 or ISAWC.ConAlwaysPublic:GetInt() >= 2 and ply:Team() == ent:GetPlayerTeam()
	local legal = cond1 and cond2 and cond3
	
	if not legal then
		local vioCode = 0
		if not cond1 then
			vioCode = 1
		end
		if not cond2 then
			vioCode = bit.bor(vioCode, 2)
		end
		if not cond3 then
			vioCode = bit.bor(vioCode, 4)
		end
		self:Log(string.format("Rejected %s's attempt to use container %s (challenge expected 0, got %u)", ply:Nick(), tostring(ent), vioCode))
	end
	return legal
end

ISAWC.EmptyWeaponClipsToPlayer = function(self,dupe,ply)
	local success = false
	for k,v in pairs(dupe.Entities) do
		if v.SavedClip1 > 0 then
			ply:GiveAmmo(v.SavedClip1, v.SavedAmmoType1)
			v.SavedClip1 = 0
			success = true
		end
		if v.SavedClip2 > 0 then
			ply:GiveAmmo(v.SavedClip2, v.SavedAmmoType2)
			v.SavedClip2 = 0
			success = true
		end
	end
	if not success then
		self:NoPickup("The weapon has no ammo!", ply)
	end
end

ISAWC.RecursiveToNumbering = function(self,tab,done)
	if tab==nil then return
	elseif not done then
		done = {}
	elseif done[tab] then return
	end
	done[tab] = true
	for k,v in pairs(isentity(tab) and tab:GetTable() or tab) do
		if isstring(v) and tonumber(v) then
			tab[k] = tonumber(v)
		elseif istable(v) then
			self:RecursiveToNumbering(v,done)
		end
	end
end

ISAWC.SpawnDupe = function(self,dupe,isSpawn,sSpawn,invnum,ply)
	local canDel = self.ConAllowDelete:GetBool()
	local trace = util.QuickTrace(ply:GetShootPos(),isSpawn and ply:EyeAngles():Forward()*self.ConDistance:GetFloat() or vector_origin,ply)
	local spawnpos = trace.HitPos - Vector(0,0,dupe.Mins.z) + trace.HitNormal * self.ConDistBefore:GetFloat()
	for k,v in pairs(dupe.Entities) do
		local ent = Entity(k)
		if not sSpawn then
			if canDel then
				SafeRemoveEntity(ent)
			else
				table.insert(ply.ISAWC_Inventory,invnum,dupe)
				self:NoPickup("You can't delete inventory items!",ply)
			end
		elseif IsValid(ent) and self.ConAltSave:GetBool() then
			if self.ConSaveTable:GetBool() then
				for k,v in pairs(ent.ISAWC_SaveTable or {}) do
					ent:SetSaveValue(k,v)
				end
			end
			ent:SetNoDraw(ent.ISAWC_OldNoDraw or false)
			ent:SetNotSolid(not ent.ISAWC_OldSolid or false)
			ent:SetMoveType(ent.ISAWC_OldMoveType or MOVETYPE_VPHYSICS)
			ent:PhysWake()
			timer.Simple(0,function()
				if IsValid(ent) then
					ent:SetAngles((ent.ISAWC_OldAngles or angle_zero)+ply:GetAngles())
					ent:SetPos((ent.ISAWC_OldPos or vector_origin)+spawnpos)
				end
			end)
		end
	end
	if sSpawn and not self.ConAltSave:GetBool() then
		duplicator.SetLocalPos(spawnpos)
		duplicator.SetLocalAng(Angle(0,ply:EyeAngles().y,0))
		local entTab,conTab = duplicator.Paste(ply,dupe.Entities,dupe.Constraints)
		duplicator.SetLocalPos(vector_origin)
		duplicator.SetLocalAng(angle_zero)
		for k,v in pairs(entTab) do
			self:RecursiveToNumbering(v)
			v:SetCreator(ply)
			if self.ConSaveTable:GetBool() then
				for k2,v2 in pairs(v.ISAWC_SaveTable or {}) do
					v:SetSaveValue(k2,v2)
				end
			end
			if v:IsWeapon() then
				local newent = ents.Create(v:GetClass())
				newent:SetPos(v:GetPos())
				newent:SetAngles(v:GetAngles())
				entTab[k] = newent
				newent:Spawn()
				newent:SetClip1(self.ConNoAmmo:GetBool() and 0 or v.SavedClip1 or v:Clip1())
				newent:SetClip2(self.ConNoAmmo:GetBool() and 0 or v.SavedClip2 or v:Clip2())
				v:Remove()
			end
			v.Entity = v
			if not isSpawn then
				v:Use(ply)
			end
			v.NextPickup2 = CurTime() + 0.5
		end
		if not self:GetSuppressUndo() then
			if not self:GetSuppressUndoHeaders() then
				undo.Create("Spawn From Inventory")
			end
			for k,v in pairs(table.Add(entTab,conTab)) do
				undo.AddEntity(v)
			end
			if self.ConUndoIntoContain:GetBool() then
				undo.AddFunction(function(undoInfo)
					if IsValid(ply) then
						if IsTableOfEntitiesValid(entTab) then
							table.insert(ply.ISAWC_Inventory,dupe)
						else
							self:NoPickup("Error: Can't undo deleted entity!",ply)
						end
					end
				end)
			end
			if not self:GetSuppressUndoHeaders() then
				undo.SetCustomUndoText("Undone Spawn From Inventory")
				undo.SetPlayer(ply)
				undo.Finish()
			end
		end
	end
end

ISAWC.SpawnDupe2 = function(self,dupe,isSpawn,sSpawn,invnum,ply,container)
	local canDel = self.ConAllowDelete:GetBool()
	local trace = util.QuickTrace(ply:GetShootPos(),isSpawn and ply:EyeAngles():Forward()*self.ConDistance:GetFloat() or vector_origin,ply)
	local spawnpos = trace.HitPos - Vector(0,0,dupe.Mins.z) + trace.HitNormal * self.ConDistBefore:GetFloat()
	for k,v in pairs(dupe.Entities) do
		local ent = Entity(k)
		if not sSpawn then
			if canDel then
				SafeRemoveEntity(ent)
			else
				if IsValid(container) then
					table.insert(container.ISAWC_Inventory,invnum,dupe)
				end
				self:NoPickup("You can't delete inventory items!",ply)
			end
		elseif IsValid(ent) and self.ConAltSave:GetBool() then
			if self.ConSaveTable:GetBool() then
				for k,v in pairs(ent.ISAWC_SaveTable or {}) do
					ent:SetSaveValue(k,v)
				end
			end
			ent:SetNoDraw(ent.ISAWC_OldNoDraw or false)
			ent:SetNotSolid(not ent.ISAWC_OldSolid or false)
			ent:SetMoveType(ent.ISAWC_OldMoveType or MOVETYPE_VPHYSICS)
			ent:PhysWake()
			timer.Simple(0,function()
				if IsValid(ent) then
					ent:SetAngles((ent.ISAWC_OldAngles or angle_zero)+ply:GetAngles())
					ent:SetPos((ent.ISAWC_OldPos or vector_origin)+spawnpos)
				end
			end)
		end
	end
	if sSpawn and not self.ConAltSave:GetBool() then
		duplicator.SetLocalPos(spawnpos)
		duplicator.SetLocalAng(Angle(0,ply:EyeAngles().y,0))
		local entTab,conTab = duplicator.Paste(ply,dupe.Entities,dupe.Constraints)
		duplicator.SetLocalPos(vector_origin)
		duplicator.SetLocalAng(angle_zero)
		for k,v in pairs(entTab) do
			self:RecursiveToNumbering(v)
			v:SetCreator(ply)
			if self.ConSaveTable:GetBool() then
				for k2,v2 in pairs(v.ISAWC_SaveTable or {}) do
					v:SetSaveValue(k2,v2)
				end
			end
			if v:IsWeapon() then
				local newent = ents.Create(v:GetClass())
				newent:SetPos(v:GetPos())
				newent:SetAngles(v:GetAngles())
				entTab[k] = newent
				newent:Spawn()
				newent:SetClip1(self.ConNoAmmo:GetBool() and 0 or v.SavedClip1 or v:Clip1())
				newent:SetClip2(self.ConNoAmmo:GetBool() and 0 or v.SavedClip2 or v:Clip2())
				v:Remove()
			end
			v.Entity = v
			if not isSpawn then
				v:Use(ply)
			end
			v.NextPickup2 = CurTime() + 0.5
		end
		if not self:GetSuppressUndo() then
			if not self:GetSuppressUndoHeaders() then
				undo.Create("Spawn From Container")
			end
			for k,v in pairs(table.Add(entTab,conTab)) do
				undo.AddEntity(v)
			end
			if self.ConUndoIntoContain:GetBool() then
				undo.AddFunction(function(undoInfo)
					if IsValid(container) then
						if IsTableOfEntitiesValid(entTab) then
							table.insert(container.ISAWC_Inventory,dupe)
						else
							self:NoPickup("Error: Can't undo deleted entity!",ply)
						end
					end
				end)
			end
			if not self:GetSuppressUndoHeaders() then
				undo.SetCustomUndoText("Undone Spawn From Container",ply)
				undo.SetPlayer(ply)
				undo.Finish()
			end
		end
	end
end

ISAWC.SpawnDupeWeak = function(self,dupe,spawnpos,spawnangles,ply)
	for k,v in pairs(dupe.Entities) do
		local ent = Entity(k)
		if IsValid(ent) and self.ConAltSave:GetBool() then
			if self.ConSaveTable:GetBool() then
				for k,v in pairs(ent.ISAWC_SaveTable or {}) do
					ent:SetSaveValue(k,v)
				end
			end
			ent:SetNoDraw(ent.ISAWC_OldNoDraw or false)
			ent:SetNotSolid(not ent.ISAWC_OldSolid or false)
			ent:SetMoveType(ent.ISAWC_OldMoveType or MOVETYPE_VPHYSICS)
			ent:PhysWake()
			timer.Simple(0,function()
				if IsValid(ent) then
					ent:SetAngles((ent.ISAWC_OldAngles or angle_zero)+spawnangles)
					ent:SetPos((ent.ISAWC_OldPos or vector_origin)+spawnpos)
				end
			end)
		end
	end
	if not self.ConAltSave:GetBool() then
		duplicator.SetLocalPos(spawnpos)
		duplicator.SetLocalAng(Angle(0,spawnangles.y,0))
		local entTab,conTab = duplicator.Paste(ply,dupe.Entities,dupe.Constraints)
		duplicator.SetLocalPos(vector_origin)
		duplicator.SetLocalAng(angle_zero)
		for k,v in pairs(entTab) do
			self:RecursiveToNumbering(v)
			v:SetCreator(ply)
			if self.ConSaveTable:GetBool() then
				for k2,v2 in pairs(v.ISAWC_SaveTable or {}) do
					v:SetSaveValue(k2,v2)
				end
			end
			if v:IsWeapon() then
				local newent = ents.Create(v:GetClass())
				newent:SetPos(v:GetPos())
				newent:SetAngles(v:GetAngles())
				entTab[k] = newent
				newent:Spawn()
				newent:SetClip1(self.ConNoAmmo:GetBool() and 0 or v.SavedClip1 or v:Clip1())
				newent:SetClip2(self.ConNoAmmo:GetBool() and 0 or v.SavedClip2 or v:Clip2())
				v:Remove()
			end
			v.Entity = v
			v.NextPickup2 = CurTime() + 0.5
		end
	end
end

ISAWC.ReceiveMessage = function(self,length,ply,func)
	if SERVER and IsValid(ply) then
		if func == "pickup" then
			local ent = net.ReadEntity()
			if self:CanProperty(ply,ent) then
				self:PropPickup(ply,ent)
			end
		elseif func == "inv" then
			self:SendInventory(ply)
		elseif func == "moving_items" or func == "moving_items_container" then
			local constructtable = {}
			for i=1,#ply.ISAWC_Inventory do
				local desired = net.ReadUInt(16)
				if desired<1 then return end
				if desired>#ply.ISAWC_Inventory then return end
				constructtable[desired] = i
			end
			if #constructtable~=#ply.ISAWC_Inventory then return end
			for k,v in pairs(table.Copy(constructtable)) do
				constructtable[v] = ply.ISAWC_Inventory[k]
			end
			ply.ISAWC_Inventory = constructtable
			if func == "moving_items" then
				self:SendInventory(ply)
			else
				local container = net.ReadEntity()
				if self:IsLegalContainer(container,ply) then
					self:SendInventory2(ply,container)
				end
			end
		elseif func == "moving_items_container2" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				local constructtable = {}
				for i=1,#container.ISAWC_Inventory do
					local desired = net.ReadUInt(16)
					if desired<1 then return end
					if desired>#container.ISAWC_Inventory then return end
					constructtable[desired] = i
				end
				if #constructtable~=#container.ISAWC_Inventory then return end
				for k,v in pairs(table.Copy(constructtable)) do
					constructtable[v] = container.ISAWC_Inventory[k]
				end
				container.ISAWC_Inventory = constructtable
				self:SendInventory2(ply,container)
			end
		elseif func == "spawn" or func == "spawn_self" or func == "delete" then
			if self:CanDrop(ply) or func == "delete" then
				local invnum = net.ReadUInt(16)
				if invnum == 0 then
					if self:CanMultiSpawn(ply) then
						self:SetSuppressUndoHeaders(true)
						undo.Create("Spawn From Inventory")
						for i=1,net.ReadUInt(16) do
							invnum = net.ReadUInt(16)
							local dupe = table.remove(ply.ISAWC_Inventory,invnum)
							if dupe then
								self:SpawnDupe(dupe,func=="spawn",func~="delete",invnum,ply)
							end
						end
						undo.SetCustomUndoText("Undone Spawn From Inventory")
						undo.SetPlayer(ply)
						undo.Finish()
						self:SetSuppressUndoHeaders(false)
					end
				else
					local dupe = table.remove(ply.ISAWC_Inventory,invnum)
					if dupe then
						self:SpawnDupe(dupe,func=="spawn",func~="delete",invnum,ply)
					end
				end
				self:SendInventory(ply)
			end
		elseif func == "delete_full" or func == "delete_in_container_full" then
			if self.ConAllowDelete:GetBool() then
				table.Empty(ply.ISAWC_Inventory)
			else
				self:NoPickup("You can't delete inventory items!",ply)
			end
			if func == "delete_full" then
				self:SendInventory(ply)
			else
				local container = net.ReadEntity()
				if self:IsLegalContainer(container,ply) then
					self:SendInventory2(ply,container)
				end
			end
		elseif func == "drop_all" or func == "drop_all_in_container" then
			if (ply.ISAWC_Inventory and next(ply.ISAWC_Inventory)) then
				local briefcase = ents.Create("isawc_container_cbbox_07")
				briefcase:SetPos(ply:GetShootPos())
				briefcase:Spawn()
				briefcase:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				briefcase:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 200)
				briefcase.ISAWC_IsDeathDrop = true
				self:SetSuppressUndo(true)
				for i=1,#ply.ISAWC_Inventory do
					local dupe = ply.ISAWC_Inventory[i]
					if dupe then
						table.insert(briefcase.ISAWC_Inventory,dupe)
						--self:SpawnDupe(dupe,true,true,i,ply)
					end
				end
				self:SetSuppressUndo(false)
				table.Empty(ply.ISAWC_Inventory)
				if func == "drop_all" then
					self:SendInventory(ply)
				else
					local container = net.ReadEntity()
					if self:IsLegalContainer(container,ply) then
						self:SendInventory2(ply,container)
					end
				end
			end
		elseif func == "inv_container" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				self:SendInventory2(ply,container)
			end
		elseif func == "spawn_in_container" or func == "spawn_self_in_container" or func == "delete_in_container" then
			if self:CanDrop(ply) or func == "delete_in_container" then
				local container = net.ReadEntity()
				if self:IsLegalContainer(container,ply) then
					local invnum = net.ReadUInt(16)
					if invnum == 0 then
						if self:CanMultiSpawn(ply) then
							self:SetSuppressUndoHeaders(true)
							undo.Create("Spawn From Inventory")
							for i=1,net.ReadUInt(16) do
								invnum = net.ReadUInt(16)
								local dupe = table.remove(ply.ISAWC_Inventory,invnum)
								if dupe then
									self:SpawnDupe(dupe,func=="spawn_in_container",func~="delete_in_container",invnum,ply)
								end
							end
							undo.SetCustomUndoText("Undone Spawn From Inventory")
							undo.SetPlayer(ply)
							undo.Finish()
							self:SetSuppressUndoHeaders(false)
						end
					else
						local dupe = table.remove(ply.ISAWC_Inventory,invnum)
						if dupe then
							self:SpawnDupe(dupe,func=="spawn_in_container",func~="delete_in_container",invnum,ply)
						end
					end
					self:SendInventory2(ply,container)
				end
			end
		elseif func == "spawn_in_container2" or func == "spawn_self_in_container2" or func == "delete_in_container2" then
			if self:CanDrop(ply) or func == "delete_in_container2" then
				local container = net.ReadEntity()
				if self:IsLegalContainer(container,ply) then
					local invnum = net.ReadUInt(16)
					if invnum == 0 then
						if self:CanMultiSpawn(ply) then
							self:SetSuppressUndoHeaders(true)
							undo.Create("Spawn From Container")
							for i=1,net.ReadUInt(16) do
								invnum = net.ReadUInt(16)
								local dupe = table.remove(container.ISAWC_Inventory,invnum)
								if dupe then
									self:SpawnDupe2(dupe,func=="spawn_in_container2",func~="delete_in_container2",invnum,ply,container)
								end
							end
							undo.SetCustomUndoText("Undone Spawn From Container",ply)
							undo.SetPlayer(ply)
							undo.Finish()
							self:SetSuppressUndoHeaders(false)
						end
					else
						local dupe = table.remove(container.ISAWC_Inventory,invnum)
						if dupe then
							self:SpawnDupe2(dupe,func=="spawn_in_container2",func~="delete_in_container2",invnum,ply,container)
						end
					end
					self:SendInventory2(ply,container)
				end
			end
		elseif func == "drop_all_in_container2" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				if (container.ISAWC_Inventory and next(container.ISAWC_Inventory)) then
					local briefcase = ents.Create("isawc_container_cbbox_07")
					briefcase:SetPos(ply:GetShootPos())
					briefcase:Spawn()
					briefcase:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 200)
					briefcase.ISAWC_IsDeathDrop = true
					self:SetSuppressUndo(true)
					for i=1,#container.ISAWC_Inventory do
						local dupe = container.ISAWC_Inventory[i]
						if dupe then
							table.insert(briefcase.ISAWC_Inventory,dupe)
							--self:SpawnDupe(dupe,true,true,i,ply)
						end
					end
					self:SetSuppressUndo(false)
					table.Empty(container.ISAWC_Inventory)
					self:SendInventory2(ply,container)
				end
			end
		elseif func == "delete_in_container_full2" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				if self.ConAllowDelete:GetBool() then
					table.Empty(container.ISAWC_Inventory)
				else
					self:NoPickup("You can't delete inventory items!",ply)
				end
				self:SendInventory2(ply,container)
			end
		elseif func == "transfer_to" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				if container.ISAWC_IsDeathDrop then
					self:NoPickup("The container doesn't accept items!",ply)
				else
					local invnum = net.ReadUInt(16)
					if invnum == 0 then
						for i=1,net.ReadUInt(16) do
							invnum = net.ReadUInt(16)
							local dupe = ply.ISAWC_Inventory[invnum]
							if not dupe then break end
							local data = self:GetClientStats(container)
							if data[5]+dupe.TotalCount>data[6] then self:NoPickup("The container needs "..math.ceil(data[5]+dupe.TotalCount-data[6]).." more slot(s) before it can accept the item!",ply) break end
							if data[3]+dupe.TotalVolume>data[4] then self:NoPickup("The container needs "..math.Round((data[3]+dupe.TotalVolume-data[4])*self.dm3perHu,2).." dm³ more before it can accept the item!",ply) break end
							if data[1]+dupe.TotalMass>data[2] then self:NoPickup("The container needs "..math.Round(data[1]+dupe.TotalMass-data[2],2).." kg more before it can accept the item!",ply) break end
							table.insert(container.ISAWC_Inventory,dupe)
							table.remove(ply.ISAWC_Inventory,invnum)
						end
					else
						local dupe = ply.ISAWC_Inventory[invnum]
						if not dupe then return end
						local data = self:GetClientStats(container)
						if data[5]+dupe.TotalCount>data[6] then return self:NoPickup("The container needs "..math.ceil(data[5]+dupe.TotalCount-data[6]).." more slot(s) before it can accept the item!",ply) end
						if data[3]+dupe.TotalVolume>data[4] then return self:NoPickup("The container needs "..math.Round((data[3]+dupe.TotalVolume-data[4])*self.dm3perHu,2).." dm³ more before it can accept the item!",ply) end
						if data[1]+dupe.TotalMass>data[2] then return self:NoPickup("The container needs "..math.Round(data[1]+dupe.TotalMass-data[2],2).." kg more before it can accept the item!",ply) end
						table.insert(container.ISAWC_Inventory,dupe)
						table.remove(ply.ISAWC_Inventory,invnum)
					end
					self:SendInventory2(ply,container)
				end
			end
		elseif func == "transfer_from" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				local invnum = net.ReadUInt(16)
				if invnum == 0 then
					for i=1,net.ReadUInt(16) do
						invnum = net.ReadUInt(16)
						local dupe = container.ISAWC_Inventory[invnum]
						if not dupe then break end
						local data = self:GetClientStats(ply)
						if data[5]+dupe.TotalCount>data[6] then self:NoPickup("You need "..math.ceil(data[5]+dupe.TotalCount-data[6]).." more slot(s) to take that item!",ply) break end
						if data[3]+dupe.TotalVolume>data[4] then self:NoPickup("You need "..math.Round((data[3]+dupe.TotalVolume-data[4])*self.dm3perHu,2).." dm³ more to take that item!",ply) break end
						if data[1]+dupe.TotalMass>data[2] then self:NoPickup("You need "..math.Round(data[1]+dupe.TotalMass-data[2],2).." kg more to take that item!",ply) break end
						table.insert(ply.ISAWC_Inventory,dupe)
						table.remove(container.ISAWC_Inventory,invnum)
					end
				else
					local dupe = container.ISAWC_Inventory[invnum]
					if not dupe then return end
					local data = self:GetClientStats(ply)
					if data[5]+dupe.TotalCount>data[6] then return self:NoPickup("You need "..math.ceil(data[5]+dupe.TotalCount-data[6]).." more slot(s) to take that item!",ply) end
					if data[3]+dupe.TotalVolume>data[4] then return self:NoPickup("You need "..math.Round((data[3]+dupe.TotalVolume-data[4])*self.dm3perHu,2).." dm³ more to take that item!",ply) end
					if data[1]+dupe.TotalMass>data[2] then return self:NoPickup("You need "..math.Round(data[1]+dupe.TotalMass-data[2],2).." kg more to take that item!",ply) end
					table.insert(ply.ISAWC_Inventory,dupe)
					table.remove(container.ISAWC_Inventory,invnum)
				end
				if container.ISAWC_IsDeathDrop and #container.ISAWC_Inventory <= 0 then
					timer.Simple(self.ConDeathRemoveDelay:GetFloat()-6, function()
						if IsValid(container) then
							container:SetRenderMode(RENDERMODE_GLOW)
							container:SetRenderFX(kRenderFxFadeSlow)
							timer.Simple(6,function()
								SafeRemoveEntity(container)
							end)
						end
					end)
				end
				self:SendInventory2(ply,container)
			end
		elseif func == "empty" then
			local invnum = net.ReadUInt(16)
			if invnum == 0 then
				for i=1,net.ReadUInt(16) do
					invnum = net.ReadUInt(16)
					local dupe = ply.ISAWC_Inventory[invnum]
					if not dupe then return end
					self:EmptyWeaponClipsToPlayer(dupe, ply)
				end
			else
				local dupe = ply.ISAWC_Inventory[invnum]
				if not dupe then return end
				self:EmptyWeaponClipsToPlayer(dupe, ply)
			end
			self:SendInventory(ply)
		elseif func == "empty_in_container" or func == "empty_in_container2" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				local invnum = net.ReadUInt(16)
				if invnum == 0 then
					for i=1,net.ReadUInt(16) do
						invnum = net.ReadUInt(16)
						local dupe = func == "empty_in_container" and ply.ISAWC_Inventory[invnum] or container.ISAWC_Inventory[invnum]
						if not dupe then return end
						self:EmptyWeaponClipsToPlayer(dupe, ply)
					end
				else
					local dupe = func == "empty_in_container" and ply.ISAWC_Inventory[invnum] or container.ISAWC_Inventory[invnum]
					if not dupe then return end
					self:EmptyWeaponClipsToPlayer(dupe, ply)
				end
				self:SendInventory2(ply,container)
			end
		elseif func == "store_weapon" then
			local ent = ply:GetActiveWeapon()
			if IsValid(ent) then
				if self:CanProperty(ply,ent) then
					ply:DropWeapon(ent)
					ent.NextPickup2 = 0
					ply.NextPickup = 0
					if self:CanProperty(ply,ent) then
						self:PropPickup(ply,ent)
					end
				end
			else
				self:NoPickup("You don't have any weapons equipped!",ply)
			end
		elseif func == "store_weapon_in_container" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				local ent = ply:GetActiveWeapon()
				if IsValid(ent) then
					if self:CanProperty(ply,ent) then
						ply:DropWeapon(ent)
						ent.NextPickup2 = 0
						ply.NextPickup = 0
						if self:CanProperty(ply,ent) then
							self:PropPickup(ply,ent,container)
						end
					end
				else
					self:NoPickup("You don't have any weapons equipped!",ply)
				end
			end
		elseif func == "store_weapon_in_container2" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				local ent = ply:GetActiveWeapon()
				if IsValid(ent) then
					if self:CanProperty(container,ent) then
						ply:DropWeapon(ent)
						ent.NextPickup2 = 0
						ply.NextPickup = 0
						if self:CanProperty(container,ent) then
							self:PropPickup(container,ent,ply)
						end
					end
				else
					self:NoPickup("You don't have any weapons equipped!",ply)
				end
			end
		elseif func == "container_close" then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply,true) then
				container.ISAWC_Openers[ply] = nil
				if not IsValid(next(container.ISAWC_Openers)) then
					net.Start("isawc_general")
					net.WriteString("container_close")
					net.WriteEntity(container)
					net.SendPAS(container:GetPos())
				end
			end
		elseif func == "exporter" then
			local exporter = net.ReadEntity()
			if IsValid(exporter) and exporter:GetClass()=="isawc_extractor" and (exporter:GetOwnerAccountID() == (ply:AccountID() or 0) or ply:IsAdmin()) then
				exporter:SetActiFlags(net.ReadInt(32))
				exporter:SetSpawnDelay(net.ReadFloat())
				exporter:SetActiMass(net.ReadFloat())
				exporter:SetActiVolume(net.ReadFloat())
				exporter:SetActiCount(net.ReadFloat())
			end
		elseif func == "exporter_disconnect" then
			local exporter = net.ReadEntity()
			if IsValid(exporter) and exporter:GetClass()=="isawc_extractor" and (exporter:GetOwnerAccountID() == (ply:AccountID() or 0) or ply:IsAdmin()) then
				exporter:ClearStorageEntities()
				exporter:SetCollisionGroup(COLLISION_GROUP_NONE)
				--exporter:UpdateWireOutputs()
			end
		else
			self:Log("Received unrecognised message header \"" .. func .. "\" from " .. ply:Nick() .. ". Assuming data packet corrupted.")
			return
		end
		if self.ConDoSave:GetInt() > 1 then
			self:SaveInventory(ply)
		end
	end
	if CLIENT then
		if func == "inv" and IsValid(self.reliantwindow) then
			if self.reliantwindow.IsDouble then
				self.reliantwindow:Close()
			else
				--[[local bytes = net.ReadUInt(32)
				self.reliantwindow:ReceiveInventory(util.JSONToTable(util.Decompress(net.ReadData(bytes))))]]
				local data = {}
				for i=1,net.ReadUInt(16) do
					data[i] = {Model=net.ReadString(), Class=net.ReadString(), Skin=net.ReadUInt(16), BodyGroups=net.ReadString(),
					Clip1=net.ReadInt(32), Clip2=net.ReadInt(32), MaxClip1=net.ReadInt(32), MaxClip2=net.ReadInt(32)}
				end
				self.reliantwindow:ReceiveInventory(data)
				self.reliantwindow:ReceiveStats({net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadUInt(16),net.ReadUInt(16)})
			end
		elseif func == "no_pickup" then
			self:NoPickup(net.ReadString(),ply)
		elseif func == "inv_container" then
			local container = net.ReadEntity()
			if IsValid(container) then
				self:BuildOtherInventory(container)
			end
		elseif func == "container_open" then
			local container = net.ReadEntity()
			if IsValid(container) then
				container.FinishOpenAnimTime = CurTime() + (container.OpenAnimTime or 0)
				if next(container.OpenSounds or {}) then
					surface.PlaySound(container.OpenSounds[math.random(1,#container.OpenSounds)])
				end
			end
		elseif func == "container_close" then
			local container = net.ReadEntity()
			if IsValid(container) then
				container.FinishCloseAnimTime = CurTime() + (container.CloseAnimTime or 0)
				if next(container.CloseSounds or {}) then
					surface.PlaySound(container.CloseSounds[math.random(1,#container.CloseSounds)])
				end
			end
		elseif func == "inv2" and IsValid(self.reliantwindow) then
			if self.reliantwindow.IsDouble then
				--[[local bytes1,bytes2 = net.ReadUInt(32),net.ReadUInt(32)
				local data1 = util.JSONToTable(util.Decompress(net.ReadData(bytes1)))
				local data2 = util.JSONToTable(util.Decompress(net.ReadData(bytes2)))]]
				local nt1, nt2 = {}, {}
				for i=1,net.ReadUInt(16) do
					nt1[i] = {Model=net.ReadString(), Class=net.ReadString(), Skin=net.ReadUInt(16), BodyGroups=net.ReadString(),
					Clip1=net.ReadInt(32), Clip2=net.ReadInt(32), MaxClip1=net.ReadInt(32), MaxClip2=net.ReadInt(32)}
				end
				for i=1,net.ReadUInt(16) do
					nt2[i] = {Model=net.ReadString(), Class=net.ReadString(), Skin=net.ReadUInt(16), BodyGroups=net.ReadString(),
					Clip1=net.ReadInt(32), Clip2=net.ReadInt(32), MaxClip1=net.ReadInt(32), MaxClip2=net.ReadInt(32)}
				end
				self.reliantwindow:ReceiveInventory(nt1,nt2)
				self.reliantwindow:ReceiveStats({net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadUInt(16),net.ReadUInt(16)},{net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadUInt(16),net.ReadUInt(16)})
			else
				self.reliantwindow:Close()
			end
		elseif func == "exporter" then
			local questionEnt = net.ReadEntity()
			if IsValid(questionEnt) then
				questionEnt:BuildConfigGUI()
			end
		end
	end
end

net.Receive("isawc_general",function(length,ply)
	ISAWC:ReceiveMessage(length,ply,net.ReadString())
end)

ISAWC.CalculateEntitySpace = function(self,ent)
	local TotalMass,TotalVolume,TotalCount = 0,0,0
	for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
		local model = (v:GetModel() or ""):lower()
		local class = v:GetClass():lower()
		local list_count, list_mass, list_volume
		list_mass = self:StringMatchParams(model, ISAWC.Masslist) or self:StringMatchParams(class, ISAWC.Masslist)
		list_volume = self:StringMatchParams(model, ISAWC.Volumelist) or self:StringMatchParams(class, ISAWC.Volumelist)
		list_count = self:StringMatchParams(model, ISAWC.Countlist) or self:StringMatchParams(class, ISAWC.Countlist) or 1
		if list_mass then
			list_mass = list_mass * (v.BackpackMassMul and -v.BackpackMassMul*v:GetMassMul() or 1)
		end
		if list_volume then
			list_volume = list_volume * (v.BackpackVolumeMul and -v.BackpackVolumeMul*v:GetVolumeMul() or 1)
		end
		for i=0,v:GetPhysicsObjectCount()-1 do
			local physobj = v:GetPhysicsObjectNum(i)
			if IsValid(physobj) then
				local physsim = ISAWC.ConConstEnabled:GetBool() and v.BackpackConstants or {}
				if not list_mass then
					TotalMass = TotalMass + (physsim.Mass or physobj:GetMass() * -(v.BackpackMassMul and v.BackpackMassMul*v:GetMassMul() or -1))
				end
				if not list_volume and self.ConReal:GetInt()<=0 then
					TotalVolume = TotalVolume + (physsim.Volume or (physobj:GetVolume() or v:BoundingRadius()^3*math.pi*4/3) * -(v.BackpackVolumeMul and v.BackpackVolumeMul*v:GetVolumeMul() or -1))
				end
			end
		end
		if list_mass then
			TotalMass = TotalMass + list_mass
		end
		if list_volume then
			TotalVolume = TotalVolume + list_volume
		elseif self.ConReal:GetInt()==1 then
			TotalVolume = TotalVolume + self:CalculateVolume(v:GetCollisionBounds()) * -(v.BackpackVolumeMul and v.BackpackVolumeMul*v:GetVolumeMul() or -1)
		elseif self.ConReal:GetInt()>=2 then
			TotalVolume = TotalVolume + v:BoundingRadius()^3*math.pi*4/3 * -(v.BackpackVolumeMul and v.BackpackVolumeMul*v:GetVolumeMul() or -1)
		end
		TotalCount = TotalCount + list_count * -(v.BackpackCountMul and v.BackpackCountMul*v:GetCountMul() or -1)
		if v.ISAWC_Inventory then
			for k2,v2 in pairs(v.ISAWC_Inventory) do
				TotalMass = TotalMass + v2.TotalMass
				TotalCount = TotalCount + v2.TotalCount
			end
		end
	end
	TotalCount = TotalCount * ISAWC.ConCount3:GetFloat()
	TotalMass = TotalMass * ISAWC.ConMassMul3:GetFloat()
	TotalVolume = TotalVolume * ISAWC.ConVolMul3:GetFloat()
	return TotalMass,TotalVolume,TotalCount
end

ISAWC.CanProperty = function(self,ply,ent)
	if GAMEMODE.IsSandboxDerived and not ISAWC.ConOverride:GetBool() then
		return hook.Run("CanProperty",ply,"isawc_pickup",ent)
	else
		return self:CanPickup(ply,ent)
	end
end

ISAWC.StringMatchParams = function(self,str,params)
	for k,v in pairs(params) do
		local findStr = string.PatternSafe(k)
		findStr = string.Replace(findStr, "%*", ".+")
		findStr = string.Replace(findStr, "%?", ".")
		if string.find(str, "^"..findStr.."$") then return v end
	end
	return false
end

ISAWC.CanPickup = function(self,ply,ent,speculative)
	if not (IsValid(ply) and IsValid(ent)) then return false end
	if ent.ISAWC_BeingPhysgunned or ply.ISAWC_IsDeathDrop then return false end
	if (tonumber(ent.NextPickup2) or 0) > CurTime() and (tonumber(ent.NextPickup2) or 0) <= CurTime() + 0.5 and SERVER then return false end
	if speculative then
		ent.NextPickup2 = CurTime() - math.random()
	else
		ent.NextPickup2 = CurTime() + 0.5
	end
	if ply.NextPickup2 == ent.NextPickup2 and not speculative then self:NoPickup("You can't pick up a container with the same NP time!",ply) return false end
	if (ply:IsPlayer() and ply:IsAdmin()) and self.ConAdminOverride:GetBool() and SERVER then
		local passeswlist = self.Whitelist[class]
		if ent:IsPlayer() and not passeswlist then self:NoPickup("You can't pick up players!",ply) return false end
		if ent==game.GetWorld() and not passeswlist then self:NoPickup("You can't pick up worldspawn!",ply) return false end
		if not speculative then
			DropEntityIfHeld(ent)
		end
	else
		if (ply.NextPickup or 0) > CurTime() and (ply.NextPickup or 0) <= CurTime() + self.ConDelay:GetFloat() and ply:IsPlayer() and SERVER then self:NoPickup("You need to wait for "..string.format("%.1f",ply.NextPickup-CurTime()).." seconds before picking up another object!",ply) return false end
		if speculative then
			ply.NextPickup = CurTime()
		else
			ply.NextPickup = CurTime() + self.ConDelay:GetFloat()
		end
		local class = ent:GetClass():lower()
		local passesblist = self:StringMatchParams(class, self.Blacklist)
		local passeswlist = self:StringMatchParams(class, self.Whitelist)
		if passesblist and not passeswlist then self:NoPickup("That entity is blacklisted from being picked up!",ply) return false end
		if ent:IsPlayer() and not passeswlist then self:NoPickup("You can't pick up players!",ply) return false end
		if ent==game.GetWorld() and not passeswlist then self:NoPickup("You can't pick up worldspawn!",ply) return false end
		if not ply:IsPlayer() and (class=="isawc_phantomface" or class=="isawc_extractor" or class=="isawc_weighingscale") and not passeswlist then
			if class=="isawc_weighingscale" then
				self:NoPickup("You can't pick up Weighing Scales!",ply) return false
			elseif class=="isawc_phantomface" then
				if ent:GetFileID()=='' then
					self:NoPickup("You can't pick up unconnected Inventory Importers!",ply) return false
				elseif ent:GetContainer()==ply then
					self:NoPickup("You can't pick up Inventory Importers connected to you!",ply) return false
				end
			elseif class=="isawc_extractor" then
				if not ent:HasContainer() then
					self:NoPickup("You can't pick up unconnected Inventory Exporters!",ply) return false
				elseif ent:HasContainer(ply) then
					self:NoPickup("You can't pick up Inventory Exporters connected to you!",ply) return false
				end
			end
		end
		if SERVER then
			if self.ConUseWhitelist:GetBool() and not passeswlist then self:NoPickup("That entity isn't whitelisted from being picked up!",ply) return false end
			if not speculative then
				DropEntityIfHeld(ent)
			end
			if ply:GetPos():Distance(ent:GetPos())-ent:BoundingRadius()-ply:BoundingRadius()>self.ConDistance:GetFloat() and ply:IsPlayer() then self:NoPickup("You need to be closer to the object!",ply) return false end
			if not (ent:IsSolid() or passeswlist or ent:IsWeapon()) then self:NoPickup("You can't pick up non-solid entities!",ply) return false end
			if ent:GetMoveType()~=MOVETYPE_VPHYSICS and self.ConVPhysicsOnly:GetBool() and not (passeswlist or ent:IsWeapon()) then self:NoPickup("You can't pick up non-VPhysics entities!",ply) return false end
			if constraint.HasConstraints(ent) and not self.ConAllowConstrained:GetBool() then self:NoPickup("You can't pick up constrained entities!",ply) return false end
			local TotalMass, TotalVolume, TotalCount = self:CalculateEntitySpace(ent)
			local data = self:GetClientStats(ply)
			if data[5]+TotalCount>data[6] then
				ply.ISAWC_ExportFullTimestamp = CurTime()
				self:NoPickup("You need "..math.ceil(data[5]+TotalCount-data[6]).." more slot(s) to pick this up!",ply) return false
			end
			if data[3]+TotalVolume>data[4] then
				ply.ISAWC_ExportFullTimestamp = CurTime()
				self:NoPickup("You need "..math.Round((data[3]+TotalVolume-data[4])*self.dm3perHu,2).." dm³ more to pick this up!",ply) return false
			end
			if data[1]+TotalMass>data[2] then
				ply.ISAWC_ExportFullTimestamp = CurTime()
				self:NoPickup("You need "..math.Round(data[1]+TotalMass-data[2],2).." kg more to pick this up!",ply) return false
			end
		end
	end
	if self.ConOverride:GetBool() then return true end
end

ISAWC.CanMultiSpawn = function(self,ply)
	if ISAWC.ConSpawnDelay:GetFloat() > 0 then self:NoPickup("You can't spawn multiple items at once!") return false end
	return true
end

ISAWC.OldCanProperty = function(ply,name,ent)
	if name=="isawc_pickup" then
		return ISAWC:CanPickup(ply,ent)
	end
end

ISAWC.CanDrop = function(self,ply)
	if (ply.NextDrop or 0) > CurTime() and (ply.NextDrop or 0) <= CurTime() + self.ConSpawnDelay:GetFloat() and ply:IsPlayer() and SERVER then self:NoPickup("You need to wait for "..string.format("%.1f",ply.NextDrop-CurTime()).." seconds before spawning another object!",ply) return false end
	ply.NextDrop = CurTime() + self.ConSpawnDelay:GetFloat()
	return true
end

local invcooldown = 0
local nextsave = 0
ISAWC.Tick = function()
	if SERVER then
		if nextsave < RealTime() then
			nextsave = RealTime() + ISAWC.ConDoSaveDelay:GetFloat()
			ISAWC:SaveInventory(player.GetAll())
		end
	end
	if CLIENT then
		local ply = LocalPlayer()
		if input.IsKeyDown(input.GetKeyCode(ISAWC.ConUseBind:GetString())) and not IsValid(vgui.GetKeyboardFocus()) then
			local probent = ply:GetEyeTrace().Entity
			if not IsValid(probent) then
				local tracedata = {
					start = ply:GetShootPos(),
					endpos = ply:GetAimVector()*32768,
					filter = ply,
					mask = MASK_ALL
				}
				local traceresult = util.TraceLine(tracedata)
				if traceresult.HitWorld then
					table.Empty(tracedata)
					local hitpos = traceresult.HitPos
					for k,v in pairs(ents.FindInSphere(hitpos,16)) do
						tracedata[v] = -v:GetPos():DistToSqr(hitpos)
					end
					probent = table.GetWinningKey(tracedata)
				else
					probent = traceresult.Entity
				end
			end
			local ent = hook.Run("FindUseEntity",ply,probent) or probent
			if IsValid(ent) then
				if (ent.ISAWC_ResetUseTime or 0) < CurTime() then
					ent.ISAWC_UseStreak = 0
				end
				ent.ISAWC_UseStreak = ent.ISAWC_UseStreak + 1
				ent.ISAWC_ResetUseTime = CurTime() + 0.1
				if ent.ISAWC_UseStreak >= ISAWC.ConUseDelay:GetFloat()/engine.TickInterval() and ISAWC.ConUseDelay:GetFloat()>=0 then
					ent.ISAWC_UseStreak = 0
					if ISAWC:CanProperty(ply,ent) then
						net.Start("isawc_general")
						net.WriteString("pickup")
						net.WriteEntity(ent)
						net.SendToServer()
					end
				end
			end
		elseif input.IsKeyDown(input.GetKeyCode(ISAWC.ConInventoryBind:GetString())) and not IsValid(vgui.GetKeyboardFocus()) and invcooldown < RealTime() then
			invcooldown = RealTime() + 1
			if not (ply:GetActiveWeapon().CW20Weapon and ply:GetActiveWeapon().dt.State == CW_CUSTOMIZE and CW_CUSTOMIZE) then
				if IsValid(ISAWC.reliantwindow) then
					ISAWC.reliantwindow:Close()
				else
					ISAWC.reliantwindow = ISAWC:BuildInventory()
				end
			end
		elseif input.IsKeyDown(input.GetKeyCode(ISAWC.ConInventoryBindHold:GetString())) and not (IsValid(ISAWC.TempWindow) and ISAWC.TempWindow:IsVisible()) then
			if IsValid(ISAWC.TempWindow) then
				ISAWC.TempWindow:Show()
				ISAWC.TempWindow:RequestFocus()
			else
				ISAWC.TempWindow = ISAWC:BuildInventory()
			end
		elseif not input.IsKeyDown(input.GetKeyCode(ISAWC.ConInventoryBindHold:GetString())) and (IsValid(ISAWC.TempWindow) and ISAWC.TempWindow:IsVisible()) then
			ISAWC.TempWindow:Hide()
			ISAWC.TempWindow:KillFocus()
		end
	end
end

ISAWC.VoidTableEntities = function(self,tab,done)
	if tab==nil then return
	elseif not done then
		done = {}
	elseif done[tab] then return
	end
	done[tab] = true
	for k,v in pairs(tab) do
		if isentity(v) and IsValid(v) then
			tab[k] = nil
		elseif istable(v) then
			self:VoidTableEntities(v,done)
		end
	end
end

ISAWC.PropPickup = function(self,ply,ent,container)
	ply.ISAWC_Inventory = ply.ISAWC_Inventory or {}
	local tpos = ent:GetPos()
	tpos.z = tpos.z+ent:OBBMins().z
	for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
		v.ISAWC_SaveTable = v:GetSaveTable()
		if not duplicator.FindEntityClass(ent:GetClass()) then
			duplicator.RegisterEntityClass(ent:GetClass(),function(ply, data)
				local ent = ents.Create(data.Class)
				if IsValid(ent) then
					duplicator.DoGeneric(ent, data)
					ent:Spawn()
					ent:Activate()
					duplicator.DoGenericPhysics(ent, ply, data)
					table.Merge(ent:GetTable(), data)
					return ent
				end
			end,"Data")
		end
		if v:IsWeapon() then
			v.SavedClip1 = v:Clip1()
			v.SavedClip2 = v:Clip2()
			v.SavedMaxClip1 = v:GetMaxClip1()
			v.SavedMaxClip2 = v:GetMaxClip2()
			v.SavedAmmoType1 = v:GetPrimaryAmmoType()
			v.SavedAmmoType2 = v:GetSecondaryAmmoType()
		end
		local newClass = self:StringMatchParams(v:GetClass(), ISAWC.Remaplist)
		if newClass then
			v:SetKeyValue("classname", newClass)
		end
	end
	duplicator.SetLocalPos(tpos)
	duplicator.SetLocalAng(Angle(0,ply:EyeAngles().y,0))
	local dupe = duplicator.Copy(ent)
	duplicator.SetLocalPos(vector_origin)
	duplicator.SetLocalAng(angle_zero)
	dupe.TotalMass, dupe.TotalVolume, dupe.TotalCount = self:CalculateEntitySpace(ent)
	for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
		if ISAWC.ConAltSave:GetBool() then
			v.ISAWC_OldPos,v.ISAWC_OldAngles,v.ISAWC_OldNoDraw,v.ISAWC_OldSolid,v.ISAWC_OldMoveType = v:GetPos()-tpos,v:GetAngles()-ply:GetAngles(),v:GetNoDraw(),v:IsSolid(),v:GetMoveType()
			v:SetPos(Vector(16000,16000,16000))
			v:SetNoDraw(true)
			v:SetNotSolid(true)
			v:SetMoveType(MOVETYPE_NONE)
		else
			v:Fire("Kill")
		end
	end
	table.insert(ply.ISAWC_Inventory,dupe)
	if ply:IsPlayer() then
		if IsValid(container) then
			self:SendInventory2(ply,container)
		else
			self:SendInventory(ply)
		end
	elseif (IsValid(container) and container:IsPlayer()) then
		self:SendInventory2(container,ply)
	end
end

ISAWC.PhysgunPickup = function(ply,ent)
	if not ISAWC.ConAllowPickupOnPhysgun:GetBool() then
		ent.ISAWC_BeingPhysgunned = true
	end
end

ISAWC.PhysgunDrop = function(ply,ent)
	ent.ISAWC_BeingPhysgunned = nil
end

ISAWC.PropertyTable = {
	MenuLabel = "Pick Up",
	MenuIcon = "icon16/basket_put.png",
	Order = 46,
	Filter = function(self,ent)
		return ISAWC:CanProperty(LocalPlayer(),ent)
	end,
	Action = function(self,ent,trace)
		net.Start("isawc_general")
		net.WriteString("pickup")
		net.WriteEntity(ent)
		net.SendToServer()
	end,
	MenuOpen = function(self,option,ent,trace)
		if ent.Base == "isawc_backpack_base" then
			option.PaintOver = function(self,w,h)
				surface.SetDrawColor(0,255,0,63)
				surface.DrawRect(0,0,w,h)
			end
		end
	end
}

ISAWC.DesktopTable = {
	title = "Open Inventory",
	icon = "entities/weapon_satchel.png",
	init = function(...)
		if IsValid(ISAWC.reliantwindow) then
			ISAWC.reliantwindow:Close()
		else
			ISAWC.reliantwindow = ISAWC.BuildInventory(...)
		end
	end
}

gameevent.Listen("player_disconnect")
properties.Add("isawc_pickup",ISAWC.PropertyTable)
hook.Add("AddToolMenuTabs","ISAWC",ISAWC.AddToolMenuTabs)
hook.Add("AddToolMenuCategories","ISAWC",ISAWC.AddToolMenuCategories)
hook.Add("PopulateToolMenu","ISAWC",ISAWC.PopulateToolMenu)
hook.Add("PhysgunPickup","ISAWC",ISAWC.PhysgunPickup)
hook.Add("PhysgunDrop","ISAWC",ISAWC.PhysgunDrop)
hook.Add("PlayerSpawn","ISAWC",ISAWC.PlayerSpawn)
hook.Add("PlayerDeath","ISAWC",ISAWC.PlayerDeath)
hook.Add("player_disconnect","ISAWC",ISAWC.PlayerDisconnect)
hook.Add("ShutDown","ISAWC",ISAWC.PlayerDisconnect)
hook.Add("CanProperty","ISAWC",ISAWC.OldCanProperty)
hook.Add("Tick","ISAWC",ISAWC.Tick)

list.Set("DesktopWindows","Open Inventory",ISAWC.DesktopTable)