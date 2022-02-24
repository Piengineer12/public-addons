--[[
Workshop:		https://steamcommunity.com/sharedfiles/filedetails/?id=1673039990
Profile Page:	https://steamcommunity.com/id/Piengineer12
GitHub Page:	https://github.com/Piengineer12/public-addons/tree/master/isawc
Donate:			https://ko-fi.com/piengineer12

Links above are confirmed working as of 2021-06-21. All dates are in ISO 8601 format. 
]]

local startLoadTime = SysTime()

ISAWC = ISAWC or {}
ISAWC._VERSION = "5.0.2"
ISAWC._VERSIONDATE = "2022-02-24"

if SERVER then util.AddNetworkString("isawc_general") end

local color_dark_red_semitransparent = Color(127,0,0,63)
local color_yellow = Color(255,255,0)
local color_dark_green_semitransparent = Color(0,127,0,63)
local color_aqua = Color(0,255,255)
local color_dark_blue_semitransparent = Color(0,0,127,63)
local color_white_semitransparent = Color(255,255,255,63)
local color_gray_semitransparent = Color(127,127,127,63)
local color_black_semiopaque = Color(0,0,0,191)
local color_black_semitransparent = Color(0,0,0,63)

ISAWC.MESSAGE_TYPES = {
	close_container		= 1,
	delete				= 2,
	delete_full			= 3,
	delete_full_l		= 4,
	delete_full_r		= 5,
	delete_l			= 6,
	delete_r			= 7,
	drop_all			= 8,
	drop_all_l			= 9,
	drop_all_r			= 10,
	empty_weapon		= 11,
	empty_weapon_l		= 12,
	empty_weapon_r		= 13,
	exporter			= 14,
	exporter_disconnect	= 15,
	inventory			= 16,
	inventory_l			= 17,
	inventory_r			= 18,
	moving_items		= 19,
	moving_items_l		= 20,
	moving_items_r		= 21,
	open_container		= 22,
	pickup				= 23,
	pickup_denied		= 24,
	send_maker_data		= 25,
	set_public			= 26,
	spawn				= 27,
	spawn_l				= 28,
	spawn_r				= 29,
	spawn_self			= 30,
	spawn_self_l		= 31,
	spawn_self_r		= 32,
	store_weapon		= 33,
	store_weapon_l		= 34,
	store_weapon_r		= 35,
	transfer_from		= 36,
	transfer_to			= 37,
}

ISAWC.DoNothing = function()end

ISAWC.dm3perHu = 0.00204838

ISAWC.Log = function(self,msg)
	MsgC(color_aqua,"[ISAWC] ",color_white,msg,"\n")
end

ISAWC:Log(string.format("Loading ISAWC by Piengineer12, version %s (%s)", ISAWC._VERSION, ISAWC._VERSIONDATE))

ISAWC.StringMatchParams = function(self,str,params)
	for k,v in pairs(params) do
		local findStr = string.PatternSafe(k)
		findStr = string.Replace(findStr, "%*", ".+")
		findStr = string.Replace(findStr, "%?", ".")
		if string.find(str, "^"..findStr.."$") then return v end
	end
	return false
end

ISAWC.FilterSequentialTable = function(self,tab,func)
	local filtered = {}
	for i,v in ipairs(tab) do
		if func(i,v) then
			table.insert(filtered, v)
		end
	end
	return filtered
end

ISAWC.FilterIsValid = function(k,v)
	return IsValid(v)
end

ISAWC.ConCommands = {}

ISAWC.AddConCommand = function(self, name, data)
	concommand.Add(name, data.exec, data.autocomplete, data.help_small or data.help)
	self.ConCommands[name] = data.help
end

ISAWC.ConAllowConstrained = CreateConVar("isawc_pickup_constrained","0",FCVAR_REPLICATED,
"Allows constrained props to be picked up.\
This feature is in beta - use it at your own risk.")

ISAWC.ConDelay = CreateConVar("isawc_pickup_delay","0.5",FCVAR_REPLICATED,
"How long should a player wait before picking up another prop.")

ISAWC.ConDragAndDropOntoContainer = CreateConVar("isawc_container_autointo","1",FCVAR_REPLICATED,
"If 1, objects that come in contact with a container are automatically put into it.\
If 2, containers will use StartTouch detection methods instead of Touch detection methods. (Dev note: broken?)\
If 3, containers will use PhysicsCollide detection methods instead of Touch detection methods.\
All three methods have their own pros and cons.")

ISAWC.ConReal = CreateConVar("isawc_use_realisticvolumes","0",FCVAR_REPLICATED,
"Sets how realistic volumes should be calculated:\
0: Take the object's total volume only. Hollow spaces within the object are ignored.\
1: Calculate a box surrounding the object, then take the box's volume.\
2: Calculate a sphere surrounding the object, then take the sphere's volume.")

ISAWC.ConMassMul = CreateConVar("isawc_player_massmul","0.2",FCVAR_REPLICATED,
"Sets the player inventory maximum mass multiplier.\
Note that the maximum inventory mass is affected by the player's playermodel.\
If this is 0, the mass limit will not be enforced.")

ISAWC.ConVolMul = CreateConVar("isawc_player_volumemul","0.8",FCVAR_REPLICATED,
"Sets the player inventory maximum volume multiplier.\
Note that the maximum inventory volume is affected by the player's playermodel.\
If this is 0, the volume limit will not be enforced.")

ISAWC.ConCount = CreateConVar("isawc_player_maxcount","10",FCVAR_REPLICATED,
"Sets the maximum number of items players are allowed to carry at once.\
If this is 0, 65536 items (the maximum the addon can handle properly) will be the limit.")

ISAWC.ConStackLimit = CreateConVar("isawc_player_stacklimit","1",FCVAR_REPLICATED,
"Sets how much items can occupy one unit of space in a player's inventory.\
See the \"isawc_stacklist\" ConCommand to set maximum stacks individually.")

ISAWC.ConMassMul2 = CreateConVar("isawc_container_massmul","1",FCVAR_REPLICATED,
"Sets the container inventory maximum mass multiplier.\
Note that the maximum inventory mass is affected by the container's model.\
If this is 0, the mass limit will not be enforced.")

ISAWC.ConVolMul2 = CreateConVar("isawc_container_volumemul","0.9",FCVAR_REPLICATED,
"Sets the container inventory maximum volume multiplier.\
Note that the maximum inventory volume is affected by the container's model.\
If this is 0, the volume limit will not be enforced.")

ISAWC.ConCount2 = CreateConVar("isawc_container_maxcount","100",FCVAR_REPLICATED,
"Sets the maximum number of items containers are allowed to carry at once.\
If this is 0, 65536 items (the maximum the addon can handle properly) will be the limit.")

ISAWC.ConStackLimit2 = CreateConVar("isawc_container_stacklimit","100",FCVAR_REPLICATED,
"Sets how much items can occupy one unit of space in a container's inventory.\
See the \"isawc_stacklist\" ConCommand to set maximum stacks individually.")

ISAWC.ConConstEnabled = CreateConVar("isawc_use_constants","0",FCVAR_REPLICATED,
"Causes all maximum mass and volume calculations to be based on constants instead of deriving it from the playermodel.\
Please note that carrying capacities of containers are still defined in their respective files (though you can change their properties by the right-click menu).\
Additionally, the ConVars \"isawc_container_massmul\" and \"isawc_container_volumemul\" will still be obeyed.")

ISAWC.ConConstMass = CreateConVar("isawc_player_massconstant","15",FCVAR_REPLICATED,
"Sets the maximum mass, in kg, that all players are allowed to carry at once when the isawc_use_constants ConVar is enabled.\
If this is 0, the mass limit will not be enforced.")

ISAWC.ConConstVol = CreateConVar("isawc_player_volumeconstant","100",FCVAR_REPLICATED,
"Sets the maximum volume, in dm³, that all players are allowed to carry at once when the isawc_use_constants ConVar is enabled.\
If this is 0, the volume limit will not be enforced.")

ISAWC.ConDistance = CreateConVar("isawc_pickup_maxdistance","128",FCVAR_REPLICATED,
"Sets the maximum pickup distance when grabbing or dropping objects.\
If this is 0, the distance limit will not be enforced.")

ISAWC.ConDoSave = CreateConVar("isawc_player_save","1",FCVAR_REPLICATED,
"Sets whether players' inventories are saved or not.\
1: Saves players' inventories periodically (see \"isawc_player_savedelay\") or when they disconnect or die.\
2: Saves players' inventories whenever their inventory is changed (may cause tremendous lag!)")

ISAWC.ConUndoIntoContain = CreateConVar("isawc_undo_into_container","1",FCVAR_REPLICATED,
"If set, undone spawn groups will be put back into the container it came from, instead of being deleted entirely.")

AccessorFunc(ISAWC,"SuppressUndo","SuppressUndo",FORCE_BOOL)
AccessorFunc(ISAWC,"SuppressUndoHeaders","SuppressUndoHeaders",FORCE_BOOL)
AccessorFunc(ISAWC,"SuppressNoPickup","SuppressNoPickup",FORCE_BOOL)

ISAWC.ConAltSave = CreateConVar("isawc_use_altsave","0",FCVAR_REPLICATED,
"If set, entities that are put into containers are stored and retrieved somewhere safe rather than being deleted and recreated.\
Enabling this option can fix many bugs relating to items not being stored properly, however it might cause other issues.\
This feature is in beta - use it at your own risk.")

ISAWC.ConDropOnDeath = CreateConVar("isawc_dropondeath_enabled","1",FCVAR_REPLICATED,
"If set, players drop a box containing their inventory on death.")

ISAWC.ConNonVPhysics = CreateConVar("isawc_pickup_nonvphysics","0",FCVAR_REPLICATED,
"If set, entities can be picked up even if they do not have VPhysics movement.\
Turning on this option is not recommended as players might pick up normally immovable props.")

ISAWC.CreateListConCommand = function(self, name, data)
	self:AddConCommand(name, {
		exec = function(ply,cmd,args)
			if IsValid(ply) and not ply:IsAdmin() then
				self:Log("Access denied.")
			else
				if next(args) then
					data.exe(args)
					self:SaveData()
				else
					self:Log(data.display.."{")
					for k,v in pairs(self[data.display_table]) do
						data.display_function(k,v)
					end
					self:Log("}")
					self:Log("")
					for i,v in ipairs(data.help) do
						self:Log(v)
					end
				end
			end
		end,
		help_small = data.help_small,
		help = data.purpose
	})
end

ISAWC.BWLists = ISAWC.BWLists or {}
ISAWC.CreateBWListPair = function(self, name, commandPrefix, displayName, data)
	self.BWLists[name] = self.BWLists[name] or {Blacklist = {}, Whitelist = {}}
	self.BWLists[name].DisplayName = displayName
	
	local blacklistConCommand = "isawc_"..commandPrefix.."blacklist"
	local blacklistDisplayName = displayName.." blacklist"
	local blacklistHelp = {
		"Use \""..blacklistConCommand.." <class1> <class2> ...\" to add/remove entity classes into/from the list.",
		"* and ? wildcards are supported.",
		"Use \""..blacklistConCommand.." *\" to clear the list.",
	}
	local blacklistExe = function(args, blacklistTable)
		for k,v in pairs(args) do
			v = v:lower()
			if v=="*" then
				table.Empty(blacklistTable)
				self:Log("Removed everything from the "..blacklistDisplayName..".")
			elseif blacklistTable[v] then
				blacklistTable[v] = nil
				self:Log("Removed \""..v.."\" from the "..blacklistDisplayName..".")
			else
				blacklistTable[v] = true
				self:Log("Added \""..v.."\" into the "..blacklistDisplayName..".")
			end
		end
	end
	self:AddConCommand(blacklistConCommand, {
		exec = function(ply,cmd,args)
			local blacklistTable = self.BWLists[name].Blacklist
			if IsValid(ply) and not ply:IsAdmin() then
				self:Log("Access denied.")
			else
				if next(args) then
					blacklistExe(args, blacklistTable)
					self:SaveData()
				else
					self:Log("The "..blacklistDisplayName.." is as follows: {")
					for k,v in pairs(blacklistTable) do
						self:Log("\t"..string.format('%q',k)..",")
					end
					self:Log("}")
					self:Log("")
					for i,v in ipairs(blacklistHelp) do
						self:Log(v)
					end
				end
			end
		end,
		help_small = "Usage: "..blacklistConCommand.." <class1> <class2> ...",
		help = "Adds or removes entity classes from the "..blacklistDisplayName..". "..data.blacklistDesc,
	})
	
	local whitelistConCommand = "isawc_"..commandPrefix.."whitelist"
	local whitelistDisplayName = displayName.." whitelist"
	local whitelistHelp = {
		"Use \""..whitelistConCommand.." <class1> <class2> ...\" to add/remove entity classes into/from the list.",
		"* and ? wildcards are supported.",
		"Use \""..whitelistConCommand.." *\" to clear the list.",
	}
	local whitelistExe = function(args, whitelistTable)
		for k,v in pairs(args) do
			v = v:lower()
			if v=="*" then
				table.Empty(whitelistTable)
				self:Log("Removed everything from the "..whitelistDisplayName..".")
			elseif whitelistTable[v] then
				whitelistTable[v] = nil
				self:Log("Removed \""..v.."\" from the "..whitelistDisplayName..".")
			else
				whitelistTable[v] = true
				self:Log("Added \""..v.."\" into the "..whitelistDisplayName..".")
			end
		end
	end
	local whitelistConVarName = "Con"..name.."WhitelistEnabled"
	local whitelistConVar = "isawc_"..commandPrefix.."whitelistenabled"
	self:AddConCommand(whitelistConCommand, {
		exec = function(ply,cmd,args)
			local whitelistTable = self.BWLists[name].Whitelist
			if IsValid(ply) and not ply:IsAdmin() then
				self:Log("Access denied.")
			else
				if next(args) then
					whitelistExe(args, whitelistTable)
					self:SaveData()
				else
					self:Log("The "..whitelistDisplayName.." is as follows: {")
					for k,v in pairs(whitelistTable) do
						self:Log("\t"..string.format('%q',k)..",")
					end
					self:Log("}")
					self:Log("")
					for i,v in ipairs(whitelistHelp) do
						self:Log(v)
					end
				end
			end
		end,
		help_small = "Usage: "..whitelistConCommand.." <class1> <class2> ...",
		help = "Adds or removes entity classes from the "..whitelistDisplayName..". See the ConVar \""..whitelistConVarName.."\" for more information.",
	})
	
	local whitelistConVarDesc = data.whitelistConVarDesc
	if not data.excludeWhitelistConCommandFromDesc then
		whitelistConVarDesc = whitelistConVarDesc.."\nSee the ConCommand \""..whitelistConCommand.."\" to manipulate the list."
	end
	self[whitelistConVarName] = CreateConVar(whitelistConVar, "0", FCVAR_REPLICATED, data.whitelistConVarDesc)
	self.BWLists[name].WhitelistConVar = self[whitelistConVarName]
end

ISAWC.SatisfiesBWLists = function(self, class, name)
	local lists = self.BWLists[name]
	if self:StringMatchParams(class, lists.Whitelist) then
		return true
	elseif self:StringMatchParams(class, lists.Blacklist) then
		return false
	else
		return not lists.WhitelistConVar:GetBool()
	end
end

ISAWC.SatisfiesWhitelist = function(self, class, name)
	local lists = self.BWLists[name]
	return self:StringMatchParams(class, lists.Whitelist)
end

ISAWC:CreateBWListPair("General", "", "pickup", {
	blacklistDesc = "Classes in the blacklist cannot be picked up.",
	whitelistConVarDesc = "If set, only entity classes that are in the whitelist can be picked up.\n\z
	Otherwise, entity classes that aren't in the blacklist or are in the whitelist can be picked up.\n\z
	Use the ConCommands \"isawc_blacklist\" and \"isawc_whitelist\" to manipulate the lists.\n\z
	Tip: Even if this is not set, non-solid and non-VPhysics entities can still be specified in the whitelist to make them able to be picked up,\n\z
	regardless of the other ConVars.",
	excludeWhitelistConCommandFromDesc = true
})

ISAWC:CreateBWListPair("Exporter", "exporter_", "exporter", {
	blacklistDesc = "Classes in the blacklist will not be exported by Inventory Exporters.",
	whitelistConVarDesc = "If set, only entity classes that are in the whitelist can be exported by Inventory Exporters."
})

ISAWC:CreateBWListPair("ContainerMagnet", "container_magnet_", "container magnetization", {
	blacklistDesc = "Classes in the blacklist will not be magnetized by containers.",
	whitelistConVarDesc = "If set, only entity classes that are in the whitelist can be magnetized by containers."
})

ISAWC:CreateBWListPair("ContainerMagnetContainer", "container_magnet_container", "container magnetization container", {
	blacklistDesc = "Classes in the blacklist will not be magnetic containers.",
	whitelistConVarDesc = "If set, only entity classes that are in the whitelist are magnetic containers."
})

ISAWC:CreateBWListPair("PlayerMagnet", "player_magnet_", "player magnetization", {
	blacklistDesc = "Classes in the blacklist will not be magnetized by players.",
	whitelistConVarDesc = "If set, only entity classes that are in the whitelist can be magnetized by players."
})

ISAWC:CreateBWListPair("DropOnDeath", "dropondeath_", "player death box", {
	blacklistDesc = "Classes in the blacklist will not be transferred to player death boxes if isawc_dropondeath_enabled is enabled.",
	whitelistConVarDesc = "If set, only entity classes that are in the whitelist can be transferred to player death boxes if isawc_dropondeath_enabled is enabled."
})

ISAWC.Stacklist = ISAWC.Stacklist or {}
ISAWC:CreateListConCommand("isawc_stacklist", {
	display = "The stacking list is as follows: ",
	display_table = "Stacklist",
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
					ISAWC.Stacklist = {}
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
	display_table = "Masslist",
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
			ISAWC.Masslist = {}
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
	display_table = "MassMultiList",
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
			ISAWC.MassMultiList = {}
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
	display_table = "Volumelist",
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
			ISAWC.Volumelist = {}
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
	display_table = "VolumeMultiList",
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
			ISAWC.VolumeMultiList = {}
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
	display_table = "Countlist",
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
			ISAWC.Countlist = {}
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
	display_table = "CountMultiList",
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
			ISAWC.CountMultiList = {}
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
	display_table = "Remaplist",
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
			ISAWC.Remaplist = {}
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

ISAWC.ConAllowDelete = CreateConVar("isawc_allow_delete","1",FCVAR_REPLICATED,
"Enables players to delete props that they've picked up.")

ISAWC.ConOverride = CreateConVar("isawc_pickup_force","1",FCVAR_REPLICATED,
"Ignores other potential return values from hooks it calls.\
Tick this option if you can't pick up items in other gamemodes.")

ISAWC.ConAlwaysPublic = CreateConVar("isawc_container_alwayspublic","0",FCVAR_REPLICATED,
"If set to 1, all containers are always openable by anyone.\
If set to 2, containers may be opened by another player in the same team.\
This overrides the \"always public\" option in the \"Edit Properties...\" menu.")
	
ISAWC.ConHideNotifsG = CreateConVar("isawc_hide_notificationsglobal","0",FCVAR_REPLICATED,
"Same as Hide All Notifications (isawc_hide_notifications) on client, but affects all clients on the server.\
Note that this does not prevent hint messages from popping up for clients.")

ISAWC.ConAllowPickupOnPhysgun = CreateConVar("isawc_pickup_physgunned","0",FCVAR_REPLICATED,
"If set, entities being picked up by the Physics Gun can still be picked up and put into any inventory.\
This feature is in beta - use it at your own risk.")

ISAWC.ConDistBefore = CreateConVar("isawc_spawn_bumpdist","4",FCVAR_REPLICATED,
"When an entity is taken out of a container via Spawn At Crosshair, it will be spawned this far away from any obstructions.\
This ignores Max Pickup Distance!")

ISAWC.ConSaveIntoFile = CreateConVar("isawc_container_save","0",FCVAR_REPLICATED,
"Causes containers to save/load their inventories into/from the database instead of its own entity table.\
This feature is in beta - use it at your own risk.\
WARNING: Make sure to Clear the Save Cache periodically!")

ISAWC.ConDropOnDeathContainer = CreateConVar("isawc_container_dropondeath","0",FCVAR_REPLICATED,
"If set, containers' inventories are dropped upon removal.\
This feature is in beta - use it at your own risk.")

ISAWC.ConAutoHealth = CreateConVar("isawc_container_healthmul","0",FCVAR_REPLICATED,
"If above 0, ALL containers spawned will have a limited amount of health depending on their volume multiplied by this ConVar.\
This feature is in beta - use it at your own risk.")

ISAWC.ConImporterAutoHealth = CreateConVar("isawc_importer_healthmul","0",FCVAR_REPLICATED,
"If above 0, ALL Inventory Importers spawned will have a limited amount of health depending on their volume multiplied by this ConVar.\
This feature is in beta - use it at your own risk.")

ISAWC.ConExporterAutoHealth = CreateConVar("isawc_exporter_healthmul","0",FCVAR_REPLICATED,
"If above 0, ALL Inventory Exporters will have a limited amount of health depending on their volume multiplied by this ConVar.\
This feature is in beta - use it at your own risk.")

ISAWC.ConSaveTable = CreateConVar("isawc_use_enginesavetables","0",FCVAR_REPLICATED,
"If set, entities will have their engine save tables stored as well.\
This feature is EXPERIMENTAL - use it at your own risk.")

ISAWC.ConPickupDenyLogs = CreateConVar("isawc_hide_pickuplogdenies","1",FCVAR_REPLICATED,
"If unset, when a player / container fails to pick up an item, a message is shown in console with the reason.")

ISAWC.ConContainerRegen = CreateConVar("isawc_container_regen","0",FCVAR_REPLICATED,
"Containers will regenerate this amount of health per second.\
Negative values are allowed.")

ISAWC.ConImporterRegen = CreateConVar("isawc_importer_regen","0",FCVAR_REPLICATED,
"Inventory Importers will regenerate this amount of health per second.\
Negative values are allowed.")

ISAWC.ConExporterRegen = CreateConVar("isawc_exporter_regen","0",FCVAR_REPLICATED,
"Inventory Exporters will regenerate this amount of health per second.\
Negative values are allowed.")

ISAWC.ConMassMul3 = CreateConVar("isawc_pickup_massmul","1",FCVAR_REPLICATED,
"Sets the mass multiplier for all picked up items.\
If you want to set the mass of individual items, see the isawc_masslist ConCommand.")

ISAWC.ConVolMul3 = CreateConVar("isawc_pickup_volumemul","1",FCVAR_REPLICATED,
"Sets the volume multiplier for all picked up items.\
If you want to set the volume of individual items, see the isawc_volumelist ConCommand.")

ISAWC.ConCount3 = CreateConVar("isawc_pickup_countmul","1",FCVAR_REPLICATED,
"Sets the amount multiplier for all picked up items.\
If you want to set the amount for individual items, see the isawc_countlist ConCommand.\
Note that decimal values are rounded down within inventories, which can lead to confusion.")

ISAWC.ConDeathRemoveDelay = CreateConVar("isawc_dropondeath_time","10",FCVAR_REPLICATED,
"Sets the amount of time to wait before removing the container players drop upon death, after being emptied.")

ISAWC.ConDropOnDeathAmount = CreateConVar("isawc_dropondeath_max","-1",FCVAR_REPLICATED,
"Sets the maximum number of the containers players drop upon death, per player. If another is created when the player is at its limit, the oldest one is removed.\
A value of -1 indicates no limit.")

ISAWC.ConSpawnDelay = CreateConVar("isawc_spawn_delay","1",FCVAR_REPLICATED,
"Sets the minimum delay between inventory item spawns by players.")

ISAWC.ConAdminOverride = CreateConVar("isawc_pickup_adminpower", "0", FCVAR_REPLICATED,
"Allows admins to pick up anything regardless of ConVars (except for players and the map, as those can crash the game).")

ISAWC.ConNoAmmo = CreateConVar("isawc_spawn_emptyweapons", "0", FCVAR_REPLICATED,
"If set, all weapons spawned from inventories will not have any ammo in their clip.")

ISAWC.ConAllowInterConnection = CreateConVar("isawc_allow_interownerconnections", "0", FCVAR_REPLICATED,
"If enabled, Inventory Importers and Exporters may be connected to a container owned by someone else.")

ISAWC.ConMinExportDelay = CreateConVar("isawc_exporter_mindelay", "0.05", FCVAR_REPLICATED,
"Minimum delay between items exported by Inventory Exporters.")

ISAWC.ConDoSaveDelay = CreateConVar("isawc_player_savedelay", "300", FCVAR_REPLICATED,
"Sets the delay between automatic saves for player inventories. No effect when Save Player Inventories (isawc_player_save) is disabled.\
Note that low values may severely impact performance!")

ISAWC.ConMagnet = CreateConVar("isawc_container_magnet_radius", "0", FCVAR_REPLICATED,
"Sets the range of containers to attract items. Note that the radius is multiplied with the size of the container - a range of 3 on a box will allow the box to pick up items 3 boxes away from it.\
A range of 0 disables this feature.")

ISAWC.ConDropOnDeathClass = CreateConVar("isawc_dropondeath_class", "isawc_container_cbbox_07", FCVAR_REPLICATED,
"Sets the classname of dropped containers on player deaths when the isawc_dropondeath_enabled ConVar is enabled. Useful for causing custom Lua containers to be dropped.\
If you just want to set the model, see the isawc_dropondeath_model ConVar.")

ISAWC.ConDropOnDeathModel = CreateConVar("isawc_dropondeath_model", "", FCVAR_REPLICATED,
"Overrides the model of dropped containers on player deaths when the isawc_dropondeath_enabled ConVar is enabled.\
Set the ConVar to \"\" to remove the model override.\
If you want to set the class, see the isawc_dropondeath_class ConVar.")

ISAWC.ConUseBindOverride = CreateConVar("isawc_pickup_bindoverride", "", FCVAR_REPLICATED,
"Sets the binding used to pick up items. This value overrides the value defined in the isawc_pickup_bind ConVar for all clients.\
Set the ConVar to \"\" to remove the override.")

ISAWC.ConDropAllAllowed = CreateConVar("isawc_dropall_enabled", "1", FCVAR_REPLICATED,
"Enables players to drop their entire inventory, or a container's inventory, into a small container for easy pickup. The container does not accept items.")

ISAWC.ConDropAllTime = CreateConVar("isawc_dropall_time", "10", FCVAR_REPLICATED,
"Sets the amount of time to wait before removing \"drop-all\" containers, after being emptied.")

ISAWC.ConDropAllLimit = CreateConVar("isawc_dropall_max", "-1", FCVAR_REPLICATED,
"Sets the maximum number of \"drop-all\" containers per player. If another is created when the player is at its limit, the oldest one is removed.\
A value of -1 indicates no limit.")

ISAWC.ConDropAllClass = CreateConVar("isawc_dropall_class", "isawc_container_cbbox_07", FCVAR_REPLICATED,
"Sets the classname of \"drop-all\" containers when the isawc_dropall_enabled ConVar is enabled. Useful for causing custom Lua containers to be dropped.\
If you just want to set the model, see the isawc_dropall_model ConVar.")

ISAWC.ConDropAllModel = CreateConVar("isawc_dropall_model", "", FCVAR_REPLICATED,
"Overrides the model of \"drop-all\" containers when the isawc_dropall_enabled ConVar is enabled.\
Set the ConVar to \"\" to remove the model override.\
If you want to set the class, see the isawc_dropall_class ConVar.")

ISAWC.ConPlayerPickupOnCollide = CreateConVar("isawc_player_autointo", "0", FCVAR_REPLICATED,
"If set, players will automatically pick up any entities they collide with, if able.")

ISAWC.ConPlayerMagnet = CreateConVar("isawc_player_magnet_radius", "0", FCVAR_REPLICATED,
"Sets the range of players to attract items. It is highly recommended to set isawc_player_autointo to 1 first!\
Note that the radius is multiplied with the size of the player - a range of 3 on a player with a dinosaur model will allow the player to pick up items 3 dinosaurs away from it.\
A range of 0 disables this feature.")

ISAWC.ConUseBindDelayOverride = CreateConVar("isawc_pickup_binddelayoverride", "0", FCVAR_REPLICATED,
"If non-zero, overwrites the value of the \"isawc_pickup_binddelay\" ConVar for all clients. See the mentioned ConVar for more information.")

ISAWC.ConUseCompression = CreateConVar("isawc_use_savecompression", "1", FCVAR_REPLICATED,
"Enables save data compression (LZMA+Base64). This saves disk space, but saving and loading becomes much slower.\
Compression is more effective if any players have many items in their inventories.\
Consider also modifying the \"isawc_player_save\" and \"isawc_player_savedelay\" ConVars so that saving does not occur too often.")

ISAWC.ConLockpickTime = CreateConVar("isawc_container_lockpicktime", "20", FCVAR_REPLICATED,
"DarkRP only. The amount of time it takes to lockpick a container, in seconds.\
Successfully lockpicking a container will disable the container's access restrictions, which can be manually enabled again in the GUI.\
If this is negative, all containers cannot be lockpicked.\
Note that the actual lockpicking time is multiplied with the container's Lock Multiplier.")

ISAWC.ConLockpickTimeBump = CreateConVar("isawc_container_lockpicktimedifference", "10", FCVAR_REPLICATED,
"DarkRP only. Randomly adds or subtracts the amount of time it takes to lockpick a container, in seconds.")

ISAWC.ConEditPropertiesPermissionLevel = CreateConVar("isawc_container_editpropertiespermissionlevel", "0", FCVAR_REPLICATED,
"Determines the admin level required to edit the container's properties.\
If 1, only admins can edit container properties.\
If 2, only superadmins can edit container properties.\
If 3, no one can edit container properties.\
Note that the Container Maker SWEP can still edit container properties even if this is set to 3.")

ISAWC.ConAllowHeldWeapons = CreateConVar("isawc_pickup_heldweapons", "1", FCVAR_REPLICATED,
"If enabled, players will be able to store their currently held weapons into their inventory and into containers.")

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

local lastSQLACResult = {}
local lastSQLACTime = 0
local function PlayerSQLAutoComplete(cmd, argStr)
	if lastSQLACTime+10 < RealTime() then
		lastSQLACTime = RealTime()+10
		lastSQLACResult = {}
		local results = ISAWC:SQL("SELECT \"steamID\" FROM \"isawc_player_data\";")
		if results then
			for k,v in pairs(results) do
				table.insert(lastSQLACResult, v.steamID)
			end
		end
	end
	
	local possibilities = {}
	local namesearch = argStr:Trim():lower()
	for k,v in pairs(lastSQLACResult) do
		if string.StartWith(v:lower(), namesearch) then
			table.insert(possibilities, cmd .. " " .. v)
		end
	end
	return possibilities
end

local clearcachemessage = "Clears inventories saved from Alternate Saving. Containers that aren't \z
presently in the map will have their contents wiped out."
if SERVER then
	ISAWC:AddConCommand("isawc_container_clearcache", {
		exec = function(ply,cmd,args)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			else
				ISAWC:SQL("BEGIN; DELETE FROM \"isawc_container_data\";")
				for k,v in pairs(ents.GetAll()) do
					if (IsValid(v) and v.Base=="isawc_container_base") then
						ISAWC:SaveContainerInventory(v)
					end
				end
				ISAWC:SQL("COMMIT;")
			end
		end,
		help = clearcachemessage
	})
	
	ISAWC:AddConCommand("isawc_delete", {
		exec = function(ply,cmd,args,argStr)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied. If you wish to delete your own items, and the server has enabled item delection, please use the option within the inventory GUI.")
			elseif argStr=="*" then
				for k,v in pairs(player.GetAll()) do
					v.ISAWC_Inventory = {}
					-- TODO: ISAWC_Inventory init problem?
				end
				ISAWC:Log("You have deleted everyone's inventory.")
			elseif next(args) then
				local success = false
				for k,v in pairs(player.GetAll()) do
					if v:Nick() == argStr then
						success = true
						v.ISAWC_Inventory = {}
						ISAWC:Log("You have deleted the inventory of " .. argStr .. ".")
						break
					end
				end
				if not success then
					ISAWC:Log("Can't find player \"" .. argStr .. "\".")
				end
			else
				ISAWC:Log("Usage: isawc_delete <player>")
			end
		end,
		autocomplete = BasicAutoComplete,
		help = "Deletes a player's inventory. The player must be currently active on the server. * may be used to delete ALL player inventories.",
		help_small = "Usage: isawc_delete <player>"
	})
	
	ISAWC:AddConCommand("isawc_delete_offline", {
		exec = function(ply,cmd,args,argStr)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			elseif argStr=="*" then
				ISAWC:SQL("DELETE FROM \"isawc_player_data\";")
				ISAWC:Log("You have deleted everyone's inventory.")
			elseif next(args) then
				local results = ISAWC:SQL("SELECT \"steamID\" FROM \"isawc_player_data\" WHERE \"steamID\" = %s;", argStr)
				if results then
					ISAWC:SQL("DELETE FROM \"isawc_player_data\" WHERE \"steamID\" = %s;", argStr)
					ISAWC:Log("You have deleted the inventory of " .. argStr .. ".")
				else
					ISAWC:Log("Can't find player with SteamID \"" .. argStr .. "\".")
				end
			else
				ISAWC:Log("Usage: isawc_delete_offline <player>")
			end
		end,
		autocomplete = PlayerSQLAutoComplete,
		help = "Deletes an offline player's inventory via their SteamID. Does not work well for online players.",
		help_small = "Usage: isawc_delete_offline <player>"
	})
	
	ISAWC:AddConCommand("isawc_reset_convars", {
		exec = function(ply,cmd,args,argStr)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			else
				for k,v in pairs(ISAWC) do
					if TypeID(v)==TYPE_CONVAR then
						v:Revert()
					end
				end
				ISAWC:Log("All ConVars reset!")
			end
		end,
		help = "Sets all ConVars to their default values."
	})
	
	ISAWC:AddConCommand("isawc_copy", {
		exec = function(ply,cmd,args,argStr)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			elseif next(args) then
				local success = false
				for k,v in pairs(player.GetAll()) do
					if v:Nick() == argStr then
						success = true
						if ply == v then
							ISAWC:Log("You can't copy your own inventory!")
						else
							ply.ISAWC_Inventory = {}
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
			else
				ISAWC:Log("Usage: isawc_copy <player>")
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
			elseif next(args) then
				local success = false
				for k,v in pairs(player.GetAll()) do
					if v:Nick() == argStr then
						success = true
						if ply == v then
							ISAWC:Log("You can't paste into your own inventory!")
						else
							v.ISAWC_Inventory = {}
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
			else
				ISAWC:Log("Usage: isawc_paste <player>")
			end
		end,
		autocomplete = BasicAutoComplete,
		help = "Pastes your inventory into another player's inventory.",
		help_small = "Usage: isawc_paste <player>"
	})
	
	ISAWC:AddConCommand("isawc_save_options", {
		exec = function(ply,cmd,args,argStr)
			if IsValid(ply) and not ply:IsAdmin() then
				ISAWC:Log("Access denied.")
			else
				ISAWC:SaveData()
			end
		end,
		help = "Saves all ISAWC ConVars and lists."
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
			if next(args) then
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
			else
				ISAWC:Log("The list of ConVars is as follows: {")
				for k,v in SortedPairs(ISAWC:GetConVarList()) do
					if v:GetString() == v:GetDefault() or tonumber(v:GetString()) == tonumber(v:GetDefault()) and tonumber(v:GetDefault()) then
						ISAWC:Log(string.format("\t%q = %s,",k,v:GetString()))
					else
						ISAWC:Log(string.format("\t%q = %s (default = %s),",k,v:GetString(),v:GetDefault()))
					end
				end
				ISAWC:Log("}")
				ISAWC:Log("The list of ConCommands is as follows: {")
				for k,v in SortedPairs(ISAWC.ConCommands) do
					ISAWC:Log(string.format("\t%q,",k))
				end
				ISAWC:Log("}")
				ISAWC:Log("Usage: isawc_help <command>")
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

	ISAWC.ConUseDelay = CreateClientConVar("isawc_pickup_binddelay","-2",true,false,
	"How long an item must be held with the Pickup Key before being picked up.\n\z
	A value of -1 disables this feature.\n\z
	A value of -2 will cause it to be the same as the \"isawc_pickup_delay\" ConVar.")

	ISAWC.ConUseBind = CreateClientConVar("isawc_pickup_bind","f",true,false,
	"Sets the binding used to pick up items.")

	ISAWC.ConInventoryBind = CreateClientConVar("isawc_player_bind","i",true,false,
	"If set, pressing this key will open the inventory.")

	ISAWC.ConInventoryBindHold = CreateClientConVar("isawc_player_bindhold","",true,false,
	"If set, holding this key will open the inventory. Releasing it will close it back.")
	
	ISAWC.ConHideNotifs = CreateClientConVar("isawc_hide_notifications","0",true,false,
	"Prevents those pop-up messages from... popping up.")
	
	ISAWC.ConHideHintNotifs = CreateClientConVar("isawc_hide_hintnotifications","0",true,false,
	"Prevents only the hint messages from popping up. Overridden by the \"isawc_hide_notifications\" ConVar.")
	
	ISAWC.ConHideNotifSound = CreateClientConVar("isawc_hide_notificationsound","0",true,false,
	"Stops the annoying buzzer sound from playing every time you fail to pick up an item.")

	ISAWC.ConPermaConnectorHUD = CreateClientConVar("isawc_always_showconnectorhud","0",true,false,
	"Shows links between containers and Inventory Exporters to other containers you own, even if the ISAWC MultiConnector SWEP is not equipped.")
	
	ISAWC.ConAllowSelflinks = CreateClientConVar("isawc_allow_selflinks","1",true,true,
	"Allows Inventory Importers and Inventory Exporters to put and pull items in and out of your inventory as long as you are linked to them via the ISAWC MultiConnector SWEP.")
	
	ISAWC.ConAllowPlayerMagnetization = CreateClientConVar("isawc_player_magnet_enabled","1",true,true,
	"If disabled, items will not be magnetized to you.")
	
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
	spawnmenu.AddToolMenuOption("ISAWC","server","isawc_pickup","Pickups","","",ISAWC.PopulateDFormPickup)
	spawnmenu.AddToolMenuOption("ISAWC","server","isawc_drop","Drops","","",ISAWC.PopulateDFormDrop)
	spawnmenu.AddToolMenuOption("ISAWC","server","isawc_player","Players","","",ISAWC.PopulateDFormPlayer)
	spawnmenu.AddToolMenuOption("ISAWC","server","isawc_container","Containers","","",ISAWC.PopulateDFormContainer)
	spawnmenu.AddToolMenuOption("ISAWC","server","isawc_importexport","Imports & Exports","","",ISAWC.PopulateDFormImportExport)
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
	DForm:NumSlider("Pickup Delay",ISAWC.ConUseDelay:GetName(),-1,10,2)
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
	DForm:CheckBox("Suppress Hint Notifications",ISAWC.ConHideHintNotifs:GetName())
	DForm:Help(" - "..ISAWC.ConHideHintNotifs:GetHelpText().."\n")
	DForm:CheckBox("Disable Notification Sound",ISAWC.ConHideNotifSound:GetName())
	DForm:Help(" - "..ISAWC.ConHideNotifSound:GetHelpText().."\n")
	DForm:CheckBox("Always Show Connections",ISAWC.ConPermaConnectorHUD:GetName())
	DForm:Help(" - "..ISAWC.ConPermaConnectorHUD:GetHelpText().."\n")
end

ISAWC.PopulateDFormGeneral = function(DForm)
	DForm:NumSlider("Mass Multiplier",ISAWC.ConMassMul3:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConMassMul3:GetHelpText().."\n")
	DForm:NumSlider("Volume Multiplier",ISAWC.ConVolMul3:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConVolMul3:GetHelpText().."\n")
	DForm:NumSlider("Amount Multiplier",ISAWC.ConCount3:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConCount3:GetHelpText().."\n")
	local combox = DForm:ComboBox("Volume Calculation",ISAWC.ConReal:GetName())
	combox:AddChoice("0 - Mesh Volume", 0)
	combox:AddChoice("1 - Outer Box", 1)
	combox:AddChoice("2 - Outer Sphere", 2)
	DForm:Help(" - "..ISAWC.ConReal:GetHelpText().."\n")
	DForm:CheckBox("Use Constants",ISAWC.ConConstEnabled:GetName())
	DForm:Help(" - "..ISAWC.ConConstEnabled:GetHelpText().."\n")
	DForm:CheckBox("Suppress All Notifications (Global)",ISAWC.ConHideNotifsG:GetName())
	DForm:Help(" - "..ISAWC.ConHideNotifsG:GetHelpText().."\n")
	DForm:CheckBox("Allow Item Deletion",ISAWC.ConAllowDelete:GetName())
	DForm:Help(" - "..ISAWC.ConAllowDelete:GetHelpText().."\n")
	DForm:CheckBox("Undo Puts Items Into Inventory",ISAWC.ConUndoIntoContain:GetName())
	DForm:Help(" - "..ISAWC.ConUndoIntoContain:GetHelpText().."\n")
	DForm:CheckBox("Use Alternate Storage Method",ISAWC.ConAltSave:GetName())
	DForm:Help(" - "..ISAWC.ConAltSave:GetHelpText().."\n")
	DForm:CheckBox("Use Save Data Compression",ISAWC.ConUseCompression:GetName())
	DForm:Help(" - "..ISAWC.ConUseCompression:GetHelpText().."\n")
	DForm:CheckBox("[EXPERIMENTAL] Save Engine Tables",ISAWC.ConSaveTable:GetName())
	DForm:Help(" - "..ISAWC.ConSaveTable:GetHelpText().."\n")
	local dangerbutton = DForm:Button("Set All To Default","isawc_reset_convars")
	dangerbutton:SetTextColor(Color(255,0,0))
end

ISAWC.PopulateDFormPickup = function(DForm)
	DForm:CheckBox("Override Hooks",ISAWC.ConOverride:GetName())
	DForm:Help(" - "..ISAWC.ConOverride:GetHelpText().."\n")
	DForm:CheckBox("Hide Pickup Fail Events",ISAWC.ConPickupDenyLogs:GetName())
	DForm:Help(" - "..ISAWC.ConPickupDenyLogs:GetHelpText().."\n")
	DForm:CheckBox("Allow Held Weapons",ISAWC.ConAllowHeldWeapons:GetName())
	DForm:Help(" - "..ISAWC.ConAllowHeldWeapons:GetHelpText().."\n")
	DForm:CheckBox("Allow Constrained Entities",ISAWC.ConAllowConstrained:GetName())
	DForm:Help(" - "..ISAWC.ConAllowConstrained:GetHelpText().."\n")
	DForm:CheckBox("Allow PhysGunned Entities",ISAWC.ConAllowPickupOnPhysgun:GetName())
	DForm:Help(" - "..ISAWC.ConAllowPickupOnPhysgun:GetHelpText().."\n")
	DForm:CheckBox("Allow Non-VPhysics Entities",ISAWC.ConNonVPhysics:GetName())
	DForm:Help(" - "..ISAWC.ConNonVPhysics:GetHelpText().."\n")
	DForm:TextEntry("Key Override",ISAWC.ConUseBindOverride:GetName())
	DForm:Help(" - "..ISAWC.ConUseBindOverride:GetHelpText().."\n")
	DForm:TextEntry("Key Delay Override",ISAWC.ConUseBindDelayOverride:GetName())
	DForm:Help(" - "..ISAWC.ConUseBindDelayOverride:GetHelpText().."\n")
	DForm:NumSlider("Pickup Delay",ISAWC.ConDelay:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConDelay:GetHelpText().."\n")
	DForm:NumSlider("Max Distance",ISAWC.ConDistance:GetName(),0,1024,0)
	DForm:Help(" - "..ISAWC.ConDistance:GetHelpText().."\n")
	DForm:CheckBox("Use Whitelist",ISAWC.ConGeneralWhitelistEnabled:GetName())
	DForm:Help(" - "..ISAWC.ConGeneralWhitelistEnabled:GetHelpText().."\n")
end

ISAWC.PopulateDFormDrop = function(DForm)
	DForm:NumSlider("Delay",ISAWC.ConSpawnDelay:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConSpawnDelay:GetHelpText().."\n")
	DForm:NumSlider("Distance from Obstructions",ISAWC.ConDistBefore:GetName(),0,128,0)
	DForm:Help(" - "..ISAWC.ConDistBefore:GetHelpText().."\n")
	DForm:CheckBox("Empty Weapon Clips",ISAWC.ConNoAmmo:GetName())
	DForm:Help(" - "..ISAWC.ConNoAmmo:GetHelpText().."\n")
	DForm:CheckBox("Allow Dropboxes",ISAWC.ConDropAllAllowed:GetName())
	DForm:Help(" - "..ISAWC.ConDropAllAllowed:GetHelpText().."\n")
	DForm:NumSlider("Dropbox Remove Time",ISAWC.ConDropAllTime:GetName(),0,100,1)
	DForm:Help(" - "..ISAWC.ConDropAllTime:GetHelpText().."\n")
	DForm:NumSlider("Max Dropboxes",ISAWC.ConDropAllLimit:GetName(),-1,100,0)
	DForm:Help(" - "..ISAWC.ConDropAllLimit:GetHelpText().."\n")
	DForm:TextEntry("Dropbox Class",ISAWC.ConDropAllClass:GetName())
	DForm:Help(" - "..ISAWC.ConDropAllClass:GetHelpText().."\n")
	DForm:TextEntry("Dropbox Model",ISAWC.ConDropAllModel:GetName())
	DForm:Help(" - "..ISAWC.ConDropAllModel:GetHelpText().."\n")
end

ISAWC.PopulateDFormPlayer = function(DForm)
	DForm:NumSlider("Mass Carrying Multiplier",ISAWC.ConMassMul:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConMassMul:GetHelpText().."\n")
	DForm:NumSlider("Volume Carrying Multiplier",ISAWC.ConVolMul:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConVolMul:GetHelpText().."\n")
	DForm:NumSlider("Max Items",ISAWC.ConCount:GetName(),0,1000,0)
	DForm:Help(" - "..ISAWC.ConCount:GetHelpText().."\n")
	--DForm:NumSlider("Max Items per Stack",ISAWC.ConStackLimit:GetName(),0,1000,0)
	--DForm:Help(" - "..ISAWC.ConStackLimit:GetHelpText().."\n")
	DForm:NumSlider("Constant Mass (kg)",ISAWC.ConConstMass:GetName(),0,1000,0)
	DForm:Help(" - "..ISAWC.ConConstMass:GetHelpText().."\n")
	DForm:NumSlider("Constant Volume (dm³)",ISAWC.ConConstVol:GetName(),0,1000,0)
	DForm:Help(" - "..ISAWC.ConConstVol:GetHelpText().."\n")
	DForm:CheckBox("Pickup on Touch",ISAWC.ConPlayerPickupOnCollide:GetName())
	DForm:Help(" - "..ISAWC.ConPlayerPickupOnCollide:GetHelpText().."\n")
	DForm:NumSlider("Magnet Range",ISAWC.ConPlayerMagnet:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConPlayerMagnet:GetHelpText().."\n")
	DForm:CheckBox("Admin Can Pickup Any",ISAWC.ConAdminOverride:GetName())
	DForm:Help(" - "..ISAWC.ConAdminOverride:GetHelpText().."\n")
	local combox = DForm:ComboBox("Save Inventories",ISAWC.ConDoSave:GetName())
	combox:AddChoice("0 - Don't", 0)
	combox:AddChoice("1 - Periodically", 1)
	combox:AddChoice("2 - Frequently", 2)
	DForm:Help(" - "..ISAWC.ConDoSave:GetHelpText().."\n")
	DForm:NumSlider("Periodic Saving Delay",ISAWC.ConDoSaveDelay:GetName(),1,600,0)
	DForm:Help(" - "..ISAWC.ConDoSaveDelay:GetHelpText().."\n")
	DForm:CheckBox("Drop Inventory On Death",ISAWC.ConDropOnDeath:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeath:GetHelpText().."\n")
	DForm:CheckBox("Use Death Drop Whitelist",ISAWC.ConDropOnDeathWhitelistEnabled:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeathWhitelistEnabled:GetHelpText().."\n")
	DForm:NumSlider("Death Drop Remove Time",ISAWC.ConDeathRemoveDelay:GetName(),0,100,1)
	DForm:Help(" - "..ISAWC.ConDeathRemoveDelay:GetHelpText().."\n")
	DForm:NumSlider("Max Death Drops",ISAWC.ConDropOnDeathAmount:GetName(),-1,100,0)
	DForm:Help(" - "..ISAWC.ConDropOnDeathAmount:GetHelpText().."\n")
	DForm:TextEntry("Death Drop Class",ISAWC.ConDropOnDeathClass:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeathClass:GetHelpText().."\n")
	DForm:TextEntry("Death Drop Model",ISAWC.ConDropOnDeathModel:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeathModel:GetHelpText().."\n")
end

ISAWC.PopulateDFormContainer = function(DForm)
	local combox = DForm:ComboBox("Properties Editing Permission Level",ISAWC.ConEditPropertiesPermissionLevel:GetName())
	combox:AddChoice("0 - Anyone", 0)
	combox:AddChoice("1 - Admins Only", 1)
	combox:AddChoice("2 - Superadmins Only", 2)
	combox:AddChoice("3 - No One", 3)
	DForm:Help(" - "..ISAWC.ConEditPropertiesPermissionLevel:GetHelpText().."\n")
	DForm:NumSlider("Mass Carrying Multiplier",ISAWC.ConMassMul2:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConMassMul2:GetHelpText().."\n")
	DForm:NumSlider("Volume Carrying Multiplier",ISAWC.ConVolMul2:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConVolMul2:GetHelpText().."\n")
	DForm:NumSlider("Max Items",ISAWC.ConCount2:GetName(),0,1000,0)
	DForm:Help(" - "..ISAWC.ConCount2:GetHelpText().."\n")
	--DForm:NumSlider("Max Items per Stack",ISAWC.ConStackLimit2:GetName(),0,1000,0)
	--DForm:Help(" - "..ISAWC.ConStackLimit2:GetHelpText().."\n")
	combox = DForm:ComboBox("Auto Pickup on Touch",ISAWC.ConDragAndDropOntoContainer:GetName())
	combox:AddChoice("0 - Don't", 0)
	combox:AddChoice("1 - Use Touch", 1)
	combox:AddChoice("2 - Use StartTouch", 2)
	combox:AddChoice("3 - Use PhysicsCollide", 3)
	DForm:Help(" - "..ISAWC.ConDragAndDropOntoContainer:GetHelpText().."\n")
	DForm:CheckBox("Always Openable By Everyone",ISAWC.ConAlwaysPublic:GetName())
	DForm:Help(" - "..ISAWC.ConAlwaysPublic:GetHelpText().."\n")
	DForm:NumSlider("Lockpick Time",ISAWC.ConLockpickTime:GetName(),0,100,1)
	DForm:Help(" - "..ISAWC.ConLockpickTime:GetHelpText().."\n")
	DForm:NumSlider("Lockpick Drift",ISAWC.ConLockpickTimeBump:GetName(),0,100,1)
	DForm:Help(" - "..ISAWC.ConLockpickTimeBump:GetHelpText().."\n")
	DForm:CheckBox("Drop Inventory On Remove",ISAWC.ConDropOnDeathContainer:GetName())
	DForm:Help(" - "..ISAWC.ConDropOnDeathContainer:GetHelpText().."\n")
	DForm:CheckBox("Use Database Saving",ISAWC.ConSaveIntoFile:GetName())
	DForm:Help(" - "..ISAWC.ConSaveIntoFile:GetHelpText().."\n")
	DForm:Button("Clear Database Cache (Admin Only)","isawc_container_clearcache")
	DForm:Help(" - "..clearcachemessage.."\n")
	DForm:NumSlider("Health Multiplier",ISAWC.ConAutoHealth:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConAutoHealth:GetHelpText().."\n")
	DForm:NumSlider("Health Regen",ISAWC.ConContainerRegen:GetName(),-100,100,1)
	DForm:Help(" - "..ISAWC.ConContainerRegen:GetHelpText().."\n")
	DForm:NumSlider("Magnet Range",ISAWC.ConMagnet:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConMagnet:GetHelpText().."\n")
	DForm:CheckBox("Use Magnet Whitelist",ISAWC.ConContainerMagnetWhitelistEnabled:GetName())
	DForm:Help(" - "..ISAWC.ConContainerMagnetWhitelistEnabled:GetHelpText().."\n")
	DForm:CheckBox("Use Container Magnet Whitelist",ISAWC.ConContainerMagnetContainerWhitelistEnabled:GetName())
	DForm:Help(" - "..ISAWC.ConContainerMagnetContainerWhitelistEnabled:GetHelpText().."\n")
end

ISAWC.PopulateDFormImportExport = function(DForm)
	DForm:CheckBox("Allow Public Connections",ISAWC.ConAllowInterConnection:GetName())
	DForm:Help(" - "..ISAWC.ConAllowInterConnection:GetHelpText().."\n")
	DForm:NumSlider("Importer Health Multiplier",ISAWC.ConImporterAutoHealth:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConImporterAutoHealth:GetHelpText().."\n")
	DForm:NumSlider("Importer Health Regen",ISAWC.ConImporterRegen:GetName(),-100,100,1)
	DForm:Help(" - "..ISAWC.ConImporterRegen:GetHelpText().."\n")
	DForm:NumSlider("Minimum Exporter Delay",ISAWC.ConMinExportDelay:GetName(),0.01,10,2)
	DForm:Help(" - "..ISAWC.ConMinExportDelay:GetHelpText().."\n")
	DForm:CheckBox("Use Exporter Whitelist",ISAWC.ConExporterWhitelistEnabled:GetName())
	DForm:Help(" - "..ISAWC.ConExporterWhitelistEnabled:GetHelpText().."\n")
	DForm:NumSlider("Exporter Health Multiplier",ISAWC.ConExporterAutoHealth:GetName(),0,10,2)
	DForm:Help(" - "..ISAWC.ConExporterAutoHealth:GetHelpText().."\n")
	DForm:NumSlider("Exporter Health Regen",ISAWC.ConExporterRegen:GetName(),-100,100,1)
	DForm:Help(" - "..ISAWC.ConExporterRegen:GetHelpText().."\n")
end

ISAWC.BuildClientVars = function(self)
	self.SW,self.SH,self.LP = ScrW(),ScrH(),LocalPlayer()
	self.FontH = draw.GetFontHeight("DermaDefault")
end

if CLIENT then
	ISAWC:BuildClientVars()
	local border = 4
	local border_w = 5
	local matSelect = Material("gui/sm_hover.png", "nocull")
	local matSelect2 = Material("gui/ps_hover.png", "nocull")
	ISAWC.DrawHoverBox = GWEN.CreateTextureBorder(border, border, 64-border*2, 64-border*2, border_w, border_w, border_w, border_w, matSelect)
	ISAWC.DrawSelectionBox = GWEN.CreateTextureBorder(border, border, 64-border*2, 64-border*2, border_w, border_w, border_w, border_w, matSelect2)
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

ISAWC.InstallSortFunctions = function(self,panel,InvPanel,delname,wepstorename,dropname,container,displayContainerOptions)
	local allowdel = self.ConAllowDelete:GetBool()
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
						v:SetSelected(not v:IsSelected())
					end
				end
			end
		end):SetIcon("icon16/shape_move_backwards.png")
		if ISAWC.ConAllowHeldWeapons:GetBool() then
			sOptions:AddOption("Store Held Weapon",function()
				ISAWC:StartNetMessage(wepstorename)
				if IsValid(container) then
					net.WriteEntity(container)
				end
				net.SendToServer()
			end):SetIcon("icon16/gun.png")
		end
		local sortOptions,sortOption = sOptions:AddSubMenu("Sort Items")
		sortOption:SetIcon("icon16/book.png")
		do
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
			sortOptions:AddOption("Sort Randomly",function()
				if IsValid(InvPanel) then
					local temptab,displ = {},0
					for i,v in ipairs(InvPanel:GetChildren()) do
						if v.MdlInfo then
							table.insert(temptab, v.ID)
						end
					end
					for k,v in RandomPairs(temptab) do
						displ = displ + 1
						InvPanel.IDOrder[displ]=v
					end
					InvPanel.WaitForSend = true
				end
			end):SetIcon("icon16/arrow_switch.png")
		end
		if displayContainerOptions then
			local containerOptions,containerOption = sOptions:AddSubMenu("Container Options")
			containerOption:SetIcon("icon16/brick_edit.png")
			if container:GetIsPublic() then
				containerOptions:AddOption("Enable Access Restriction",function()
					ISAWC:StartNetMessage("set_public")
					net.WriteBool(false)
					net.WriteEntity(container)
					net.SendToServer()
				end):SetIcon("icon16/lock_add.png")
			else
				containerOptions:AddOption("Disable Access Restriction",function()
					ISAWC:StartNetMessage("set_public")
					net.WriteBool(true)
					net.WriteEntity(container)
					net.SendToServer()
				end):SetIcon("icon16/lock_delete.png")
			end
		else
			local selfOptions,selfOption = sOptions:AddSubMenu("Self Options")
			selfOption:SetIcon("icon16/user_edit.png")
			if ISAWC.ConAllowSelflinks:GetBool() then
				selfOptions:AddCVar("Disallow Inventory Links", "isawc_allow_selflinks", "1", "0"):SetIcon("icon16/link_delete.png")
			else
				selfOptions:AddCVar("Allow Inventory Links", "isawc_allow_selflinks", "1", "0"):SetIcon("icon16/link_add.png")
			end
			if ISAWC.ConAllowPlayerMagnetization:GetBool() then
				selfOptions:AddCVar("Disable Magnetization", "isawc_player_magnet_enabled", "1", "0"):SetIcon("icon16/basket_delete.png")
			else
				selfOptions:AddCVar("Enable Magnetization", "isawc_player_magnet_enabled", "1", "0"):SetIcon("icon16/basket_add.png")
			end
			if ISAWC.ConHideHintNotifs:GetBool() then
				selfOptions:AddCVar("Enable Hint Messages", "isawc_hide_hintnotifications", "1", "0"):SetIcon("icon16/comment_add.png")
			else
				selfOptions:AddCVar("Disable Hint Messages", "isawc_hide_hintnotifications", "1", "0"):SetIcon("icon16/comment_delete.png")
			end
		end
		if ISAWC.ConDropAllAllowed:GetBool() then
			sOptions:AddOption("Drop All Items",function()
				ISAWC:StartNetMessage(dropname)
				if IsValid(container) then
					net.WriteEntity(container)
				end
				net.SendToServer()
			end):SetIcon("icon16/package_go.png")
		end
		if ISAWC.ConAllowDelete:GetBool() then
			local SubOptions,SubOption = sOptions:AddSubMenu("Delete All")
			Option = SubOptions:AddOption("Confirm Deletion",function()
				ISAWC:StartNetMessage(delname)
				if IsValid(container) then
					net.WriteEntity(container)
				end
				net.SendToServer()
			end)
			SubOption:SetIcon("icon16/bin.png")
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
	
	-- needed for items to be able to be dragged out of the inventory
	local worldPanel = vgui.GetWorldPanel()
	if not worldPanel.ISAWC_Receiver then
		worldPanel.ISAWC_Receiver = true
		worldPanel:Receiver("ISAWC.ItemMoveOut", function(this, panels, dropped)
			if dropped then
				panels[1]:SignalOutOfInventory(panels)
			end
		end)
	end
	
	ISAWC:BuildClientVars()
	Main:SetSize(ISAWC.SW/4,ISAWC.SH/2)
	Main:Center()
	Main:SetTitle(string.format("Inventory - %s (%s)", LocalPlayer():Nick(), tostring(LocalPlayer())))
	Main:SetSizable(true)
	Main:Receiver("ISAWC.ItemMoveOut", ISAWC.DoNothing) -- This is so that items don't accidentally get dropped into the world
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_semiopaque)
		draw.RoundedBox(8,0,0,w,24,color_black_semiopaque)
	end
	ISAWC.reliantwindow = Main
	
	local InvBase = Main:Add("DScrollPanel")
	InvBase:Dock(FILL)
	InvBase:SetSelectionCanvas(true)
	
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
	InvPanel:SetSelectionCanvas(true)
	InvPanel:MakeDroppable("ISAWC.ItemMove",false)
	InvPanel.IDOrder = {}
	function InvPanel:Think()
		if self.WaitForSend and not input.IsMouseDown(MOUSE_LEFT) then
			self.WaitForSend = false
			ISAWC:StartNetMessage("moving_items")
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
	function InvPanel:GetSelectedItems()
		local selectedPanels = {}
		for k,v in pairs(self:GetChildren()) do
			if v.ID and v:IsSelected() then
				table.insert(selectedPanels, v)
			end
		end
		return selectedPanels
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
					Item:SetSelectable(true)
					Item:Droppable("ISAWC.ItemMove")
					Item:Droppable("ISAWC.ItemMoveOut")
					Item.MdlInfo = info
					if info.Class ~= "prop_physics" and info.Class ~= "prop_ragdoll" then
						Item:SetTooltip(language.GetPhrase(info.Class))
					end
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
						-- Why is the magenta selection thing defined in PaintOver?! Thanks garry, now I need to redefine the default behaviour...
						-- ...though I will change it a little because creating a new color table every single frame is NOT optimal.
						self.OverlayColor = self.OverlayColor or Color(255,255,255,self.OverlayFade)
						if self.OverlayFade > 0 then
							self.OverlayColor.a = self.OverlayFade
							ISAWC.DrawHoverBox(0,0,w,h,self.OverlayColor)
						end
						if self:IsSelected() then
							ISAWC.DrawSelectionBox(0,0,w,h,color_white)
						end
					end
					function Item:SendSignal(msg)
						if Item.SendIDs then
							ISAWC:StartNetMessage(msg)
							net.WriteUInt(0,16)
							net.WriteUInt(#Item.SendIDs,16)
							for i,v in ipairs(Item.SendIDs) do
								net.WriteUInt(v,16)
							end
							net.SendToServer()
							Item.SendIDs = nil
						else
							ISAWC:StartNetMessage(msg)
							net.WriteUInt(i,16)
							net.SendToServer()
						end
					end
					function Item:AddSignal(id)
						Item.SendIDs = Item.SendIDs or {}
						table.insert(Item.SendIDs,id)
					end
					function Item:DoClick()
						self:SendSignal("spawn")
					end
					function Item:DoRightClick()
						local Options = DermaMenu(Item)
						local Option = nil
						if #InvPanel:GetSelectedItems() <= 0 or ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							Option = Options:AddOption("Use / Spawn At Self",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvPanel:GetSelectedItems(), "ID", true) do
										self:AddSignal(v2.ID)
									end
									self:SendSignal("spawn_self")
								end
							end)
							Option:SetIcon("icon16/arrow_in.png")
							Option = Options:AddOption("Spawn At Crosshair",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvPanel:GetSelectedItems(), "ID", true) do
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
									for k2,v2 in SortedPairsByMemberValue(InvPanel:GetSelectedItems(), "ID", true) do
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
									for k2,v2 in SortedPairsByMemberValue(InvPanel:GetSelectedItems(), "ID", true) do
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
					function Item:SignalOutOfInventory(items)
						if #items > 1 and ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							for k2,v2 in SortedPairsByMemberValue(items, "ID", true) do
								self:AddSignal(v2.ID)
							end
						end
						self:SendSignal("spawn")
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
	
	ISAWC:StartNetMessage("inventory")
	net.SendToServer()
	
	return Main
end

ISAWC.InvData2 = {0,0,0,0,0,0}
ISAWC.BuildOtherInventory = function(self,container,inv1,inv2,info1,info2)
	
	-- This is bascially ISAWC.BuildInventory but with some major differences.
	-- I'd deduplicate the codes if I had a lot of sanity to spare.
	local worldPanel = vgui.GetWorldPanel()
	if not worldPanel.ISAWC_Receiver then
		worldPanel.ISAWC_Receiver = true
		worldPanel:Receiver("ISAWC.ItemMoveOut", function(this, panels, dropped)
			if dropped then
				panels[1]:SignalOutOfInventory(panels)
			end
		end)
	end
	
	ISAWC:BuildClientVars()
	if IsValid(ISAWC.reliantwindow) then ISAWC.reliantwindow:Close() end
	local Main = vgui.Create("DFrame")
	Main:SetSize(ISAWC.SW/2,ISAWC.SH/2)
	Main:Center()
	Main:SetTitle(string.format("Inventories - %s (%s), %s (%s)", LocalPlayer():Nick(), tostring(LocalPlayer()), language.GetPhrase(container:GetClass()), tostring(container)))
	Main:SetSizable(true)
	Main:MakePopup()
	Main:SetKeyboardInputEnabled(false)
	Main:Receiver("ISAWC.ItemMoveContainer", ISAWC.DoNothing)
	Main:Receiver("ISAWC.ItemMoveContainer2", ISAWC.DoNothing)
	function Main:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_semiopaque)
		draw.RoundedBox(8,0,0,w,24,color_black_semiopaque)
	end
	function Main:OnRemove()
		ISAWC:StartNetMessage("close_container")
		net.WriteEntity(container)
		net.SendToServer()
	end
	function Main:Think()
		if not ISAWC.LP:Alive() then self:Close() end
		if not IsValid(container) then self:Close() return ISAWC:NoPickup("The container is missing!") end
		if ISAWC.LP:GetPos():Distance(container:GetPos())-container:BoundingRadius()>ISAWC.ConDistance:GetFloat() then self:Close() end
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
	InvBaseLeft:Receiver("ISAWC.ItemMoveContainer2",function(self,panels,dropped)
		if dropped then
			for k2,v2 in SortedPairsByMemberValue(panels, "ID", true) do
				if v2.IsInContainer then
					panels[1]:AddSignal(v2.ID)
				end
			end
			panels[1]:SendSignal("transfer_from")
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
	InvFittingLeft:SetSelectionCanvas(true)
	
	local InvLeft = InvFittingLeft:Add("DIconLayout")
	InvLeft:Dock(TOP)
	InvLeft:SetStretchHeight(true)
	InvLeft:SetStretchWidth(false)
	InvLeft:SetDnD(true)
	InvLeft:SetDropPos("46")
	InvLeft:SetUseLiveDrag(true)
	InvLeft:SetSelectionCanvas(true)
	InvLeft:MakeDroppable("ISAWC.ItemMoveContainer",false)
	InvLeft.IDOrder = {}
	function InvLeft:Think()
		if self.WaitForSend and not input.IsMouseDown(MOUSE_LEFT) then
			self.WaitForSend = false
			ISAWC:StartNetMessage("moving_items_l")
			net.WriteEntity(container)
			for i,v in ipairs(self.IDOrder) do
				net.WriteUInt(v,16)
			end
			net.SendToServer()
		end
	end
	function InvLeft:OnModified()
		for i,v in ipairs(self:GetChildren()) do
			self.IDOrder[i]=v.ID
		end
		self.WaitForSend = true
	end
	function InvLeft:GetSelectedItems()
		local selectedPanels = {}
		for k,v in pairs(self:GetChildren()) do
			if v.ID and v:IsSelected() then
				table.insert(selectedPanels, v)
			end
		end
		return selectedPanels
	end
	
	local SortLeft = InvBaseLeft:Add("DButton")
	SortLeft:Dock(BOTTOM)
	ISAWC:InstallSortFunctions(SortLeft,InvLeft,"delete_full_l","store_weapon_l","drop_all_l",container)
	
	local LoadingLeft = InvLeft:Add("DLabel")
	LoadingLeft:SetText(language.GetPhrase("gmod_loading_title"))
	LoadingLeft:SetFont("DermaLarge")
	LoadingLeft:SizeToContents()
	
	local InvBaseRight = Divider:Add("DPanel")
	function InvBaseRight:Paint(w,h)
		draw.RoundedBox(8,0,0,w,h,color_black_semitransparent)
		draw.SimpleText("Container's Inventory","Default",w/2,h/2,color_white_semitransparent,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	InvBaseRight:Receiver("ISAWC.ItemMoveContainer",function(self,panels,dropped,...)
		if dropped then
			for k2,v2 in SortedPairsByMemberValue(panels, "ID", true) do
				if not v2.IsInContainer then
					panels[1]:AddSignal(v2.ID)
				end
			end
			panels[1]:SendSignal("transfer_to")
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
	InvFittingRight:SetSelectionCanvas(true)
	
	local InvRight = InvFittingRight:Add("DIconLayout")
	InvRight:SetZPos(2)
	InvRight:Dock(TOP)
	InvRight:SetStretchHeight(true)
	InvRight:SetStretchWidth(false)
	InvRight:SetDnD(true)
	InvRight:SetDropPos("46")
	InvRight:SetUseLiveDrag(true)
	InvRight:SetSelectionCanvas(true)
	InvRight:MakeDroppable("ISAWC.ItemMoveContainer2",false)
	InvRight.IDOrder = {}
	function InvRight:Think()
		if self.WaitForSend and not input.IsMouseDown(MOUSE_LEFT) then
			self.WaitForSend = false
			ISAWC:StartNetMessage("moving_items_r")
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
	function InvRight:GetSelectedItems()
		local selectedPanels = {}
		for k,v in pairs(self:GetChildren()) do
			if v.ID and v:IsSelected() then
				table.insert(selectedPanels, v)
			end
		end
		return selectedPanels
	end
	
	local SortRight = InvBaseRight:Add("DButton")
	SortRight:Dock(BOTTOM)
	ISAWC:InstallSortFunctions(SortRight,InvRight,"delete_full_r","store_weapon_r","drop_all_r",container,true)
	
	local LoadingRight = InvRight:Add("DLabel")
	LoadingRight:SetText(language.GetPhrase("gmod_loading_title"))
	LoadingRight:SetFont("DermaLarge")
	LoadingRight:SizeToContents()
	
	function Main:ReceiveInventory(inv1,inv2)
		InvLeft:Clear()
		InvRight:Clear()
		if IsValid(container) then
			if (container:GetIsPublic() and not ISAWC.ConAlwaysPublic:GetBool()) ~= IsValid(InvFittingRight.UnlockedWarning) then
				if IsValid(InvFittingRight.UnlockedWarning) then
					InvFittingRight.UnlockedWarning:Remove()
				else
					local WarningText = InvFittingRight:Add("DLabel")
					WarningText:SetTextColor(color_yellow)
					WarningText:SetText("This container is currently unlocked and access restriction is not enforced.\nAccess restriction can be enabled in the Container Options menu below.")
					WarningText:SizeToContentsY()
					WarningText:SetZPos(1)
					WarningText:Dock(TOP)
					InvFittingRight.UnlockedWarning = WarningText
				end
			end
		else
			self:Close()
			return ISAWC:NoPickup("The container is missing!")
		end
		if next(inv1) then
			for i,v in ipairs(inv1) do
				--local enum,info = next(v)
				local info = v
				if (info and info.Class) then
					local Item = InvLeft:Add("SpawnIcon")
					Item:SetSize(64,64)
					Item:SetModel(info.Model,info.Skin,info.BodyGroups)
					Item:SetSelectable(true)
					Item:Droppable("ISAWC.ItemMoveContainer")
					Item:Droppable("ISAWC.ItemMoveOut")
					Item.MdlInfo = info
					if info.Class ~= "prop_physics" and info.Class ~= "prop_ragdoll" then
						Item:SetTooltip(language.GetPhrase(info.Class))
					end
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
						self.OverlayColor = self.OverlayColor or Color(255,255,255,self.OverlayFade)
						if self.OverlayFade > 0 then
							self.OverlayColor.a = self.OverlayFade
							ISAWC.DrawHoverBox(0,0,w,h,self.OverlayColor)
						end
						if self:IsSelected() then
							ISAWC.DrawSelectionBox(0,0,w,h,color_white)
						end
					end
					function Item:SendSignal(msg,msg2)
						if Item.SendIDs or Item.SendIDs2 then
							if Item.SendIDs then
								ISAWC:StartNetMessage(msg)
								net.WriteEntity(container)
								net.WriteUInt(0,16)
								net.WriteUInt(#Item.SendIDs,16)
								for i,v in ipairs(Item.SendIDs) do
									net.WriteUInt(v,16)
								end
								net.SendToServer()
							end
							if Item.SendIDs2 then
								ISAWC:StartNetMessage(msg2)
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
							ISAWC:StartNetMessage(msg2 or msg)
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
						self:SendSignal("transfer_to")
					end
					function Item:DoRightClick()
						local Options = DermaMenu(Item)
						local Option = Options:AddOption("Deposit",function()
							if IsValid(self) then
								for k2,v2 in SortedPairsByMemberValue(InvLeft:GetSelectedItems(), "ID", true) do
									if not v2.IsInContainer then
										self:AddSignal(v2.ID)
									end
								end
								self:SendSignal("transfer_to")
							end
						end)
						Option:SetIcon("icon16/arrow_right.png")
						if #InvLeft:GetSelectedItems() <= 0 or ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							Option = Options:AddOption("Use / Spawn At Self",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvLeft:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("spawn_self_r","spawn_self_l")
								end
							end)
							Option:SetIcon("icon16/arrow_in.png")
							Option = Options:AddOption("Spawn At Crosshair",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvLeft:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("spawn_r","spawn_l")
								end
							end)
							Option:SetIcon("icon16/pencil.png")
						end
						if info.Clip1 > 0 or info.Clip2 > 0 then
							Option = Options:AddOption("Empty Weapon Clips",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvLeft:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("empty_weapon_r","empty_weapon_l")
								end
							end)
							Option:SetIcon("icon16/basket_remove.png")
						end
						if ISAWC.ConAllowDelete:GetBool() then
							local SubOptions,SubOption = Options:AddSubMenu("Delete")
							Option = SubOptions:AddOption("Confirm Deletion",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvLeft:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("delete_r","delete_l")
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
					function Item:SignalOutOfInventory(items)
						if #items > 1 and ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							for k2,v2 in SortedPairsByMemberValue(items, "ID", true) do
								if v2.IsInContainer then
									self:AddSignal(v2.ID)
								else
									self:AddSignal2(v2.ID)
								end
							end
						end
						self:SendSignal("spawn_r","spawn_l")
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
					Item:SetSelectable(true)
					Item:Droppable("ISAWC.ItemMoveContainer2")
					Item:Droppable("ISAWC.ItemMoveOut")
					Item.MdlInfo = info
					if info.Class ~= "prop_physics" and info.Class ~= "prop_ragdoll" then
						Item:SetTooltip(language.GetPhrase(info.Class))
					end
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
						self.OverlayColor = self.OverlayColor or Color(255,255,255,self.OverlayFade)
						if self.OverlayFade > 0 then
							self.OverlayColor.a = self.OverlayFade
							ISAWC.DrawHoverBox(0,0,w,h,self.OverlayColor)
						end
						if self:IsSelected() then
							ISAWC.DrawSelectionBox(0,0,w,h,color_white)
						end
					end
					function Item:SendSignal(msg,msg2)
						if Item.SendIDs or Item.SendIDs2 then
							if Item.SendIDs then
								ISAWC:StartNetMessage(msg)
								net.WriteEntity(container)
								net.WriteUInt(0,16)
								net.WriteUInt(#Item.SendIDs,16)
								for i,v in ipairs(Item.SendIDs) do
									net.WriteUInt(v,16)
								end
								net.SendToServer()
							end
							if Item.SendIDs2 then
								ISAWC:StartNetMessage(msg2)
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
							ISAWC:StartNetMessage(msg)
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
						self:SendSignal("transfer_from")
					end
					function Item:DoRightClick()
						local Options = DermaMenu(Item)
						local Option = Options:AddOption("Withdraw",function()
							if IsValid(self) then
								for k2,v2 in SortedPairsByMemberValue(InvRight:GetSelectedItems(), "ID", true) do
									if v2.IsInContainer then
										self:AddSignal(v2.ID)
									end
								end
								self:SendSignal("transfer_from")
							end
						end)
						Option:SetIcon("icon16/arrow_left.png")
						if #InvRight:GetSelectedItems() <= 0 or ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							Option = Options:AddOption("Use / Spawn At Self",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvRight:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("spawn_self_r","spawn_self_l")
								end
							end)
							Option:SetIcon("icon16/arrow_in.png")
							Option = Options:AddOption("Spawn At Crosshair",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvRight:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("spawn_r","spawn_l")
								end
							end)
							Option:SetIcon("icon16/pencil.png")
						end
						if info.Clip1 > 0 or info.Clip2 > 0 then
							Option = Options:AddOption("Empty Weapon Clips",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvRight:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("empty_weapon_r","empty_weapon_l")
								end
							end)
							Option:SetIcon("icon16/basket_remove.png")
						end
						if ISAWC.ConAllowDelete:GetBool() then
							local SubOptions,SubOption = Options:AddSubMenu("Delete")
							Option = SubOptions:AddOption("Confirm Deletion",function()
								if IsValid(self) then
									for k2,v2 in SortedPairsByMemberValue(InvRight:GetSelectedItems(), "ID", true) do
										if v2.IsInContainer then
											self:AddSignal(v2.ID)
										else
											self:AddSignal2(v2.ID)
										end
									end
									self:SendSignal("delete_r","delete_l")
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
					function Item:SignalOutOfInventory(items)
						if #items > 1 and ISAWC.ConSpawnDelay:GetFloat() <= 0 then
							for k2,v2 in SortedPairsByMemberValue(items, "ID", true) do
								if v2.IsInContainer then
									self:AddSignal(v2.ID)
								else
									self:AddSignal2(v2.ID)
								end
							end
						end
						self:SendSignal("spawn_r","spawn_l")
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
	
	self:StartNetMessage("inventory_l")
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

ISAWC.WriteContainerInventory = function(self,ply,container)
	local inv = container:GetInventory(ply)
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
	net.WriteString(ent.Model or "models/error.mdl")
	net.WriteString(ent.EntityMods and ent.EntityMods.WireName and ent.EntityMods.WireName.name~="" and ent.EntityMods.WireName.name
	or ent.Name~="" and ent.Name or ent.name~="" and ent.name or ent.PrintName~="" and ent.PrintName~="Scripted Weapon" and ent.PrintName
	or ent.Class or "worldspawn")
	net.WriteUInt(ent.Skin or 0, 16)
	net.WriteString(bodyGroups)
	net.WriteInt(ent.SavedClip1 or -1, 32)
	net.WriteInt(ent.SavedClip2 or -1, 32)
	net.WriteInt(ent.SavedMaxClip1 or -1, 32)
	net.WriteInt(ent.SavedMaxClip2 or -1, 32)
end

ISAWC.GetClientStats = function(self,ply,user)
	local isPlayer = ply:IsPlayer()
	local cw,cv,cc = 0,0,0
	local mw,mv,mc = 0,0,isPlayer and self.ConCount:GetInt() or self.ConCount2:GetInt() * (ply.GetCountMul and ply:GetCountMul() or 1)
	local inv = IsValid(user) and ply:GetInventory(user) or ply.ISAWC_Inventory or {}
	for k,v in pairs(inv) do
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
			if (IsValid(v) and v.GetPhysicsObjectCount) then
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
	self:StartNetMessage("inventory")
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
	self:StartNetMessage("inventory_r")
	--[[local data1 = util.Compress(util.TableToJSON(self:WriteClientInventory(ply)))
	local data2 = util.Compress(util.TableToJSON(self:WriteClientInventory(container)))
	net.WriteUInt(#data1,32)
	net.WriteUInt(#data2,32)
	net.WriteData(data1,#data1)
	net.WriteData(data2,#data2)]]
	self:WriteClientInventory(ply)
	self:WriteContainerInventory(ply,container)
	local stats = self:GetClientStats(ply)
	for i=1,4 do
		net.WriteFloat(stats[i])
	end
	for i=5,6 do
		net.WriteUInt(stats[i],16)
	end
	stats = self:GetClientStats(container,ply)
	for i=1,4 do
		net.WriteFloat(stats[i])
	end
	for i=5,6 do
		net.WriteUInt(stats[i],16)
	end
	net.Send(ply)
	ISAWC:UpdateContainerInventories(container)
	ISAWC:SaveContainerInventory(container)
end

ISAWC.CalculateVolume = function(self,v1,v2)
	return math.abs((v2.x-v1.x)*(v2.y-v1.y)*(v2.z-v1.z))
end

ISAWC.NoPickup = function(self,msg,ply)
	if not self.ConPickupDenyLogs:GetBool() and SERVER then
		self:Log(tostring(ply)..': '..msg)
	end
	if not self:GetSuppressNoPickup() then
		if (SERVER and ply and ply:IsPlayer() and not self.ConHideNotifsG:GetBool()) then
			self:StartNetMessage("pickup_denied")
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
end

ISAWC.PushNotification = function(self,msg)
	if not self.ConHideNotifs:GetBool() then
		if not istable(msg) then
			msg = {msg}
		else
			msg = table.Reverse(msg)
		end
		for i,v in ipairs(msg) do
			notification.AddLegacy(v,NOTIFY_HINT,4+#v/10)
		end
		if not self.ConHideNotifSound:GetBool() then
			surface.PlaySound(string.format("ambient/water/drip%i.wav", math.random(4)))
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

ISAWC.SQL = function(self,query,...)
	local params = {...}
	for k,v in pairs(params) do
		params[k] = sql.SQLStr(v)
	end
	local result = false
	local queryString = next(params) and string.format(query, unpack(params)) or query
	--print(queryString)
	result = sql.Query(queryString)
	--print(result)
	--if istable(result) then
		--PrintTable(result)
	--end
	if result == false then
		local err = sql.LastError()
		if err then
			error(err, 2)
		end
	else return result
	end
end

ISAWC.SaveData = function(self)
	if next(self.LastLoadedData) then
		local data = {}
		data.Stacklist = self.Stacklist or {}
		data.Masslist = self.Masslist or {}
		data.Volumelist = self.Volumelist or {}
		data.Countlist = self.Countlist or {}
		data.Remaplist = self.Remaplist or {}
		data.MassMultiList = self.MassMultiList or {}
		data.VolumeMultiList = self.VolumeMultiList or {}
		data.CountMultiList = self.CountMultiList or {}
		
		data.BWLists = {}
		for k,v in pairs(self.BWLists) do
			data.BWLists[k] = {
				Blacklist = v.Blacklist,
				Whitelist = v.Whitelist
			}
		end
		
		for k,v in pairs(self) do
			if TypeID(v) == TYPE_CONVAR then
				data[k] = v:GetString()
			end
		end
		
		if self.ConUseCompression:GetBool() then
			file.Write("isawc_data.dat",util.Compress(util.TableToJSON(data)))
		else
			file.Write("isawc_data.dat",util.TableToJSON(data))
		end
	end
end

ISAWC.SaveInventory = function(self,ply)
	local steamid
	self:SQL([[CREATE TABLE IF NOT EXISTS "isawc_player_data" (
		"steamID" TEXT NOT NULL UNIQUE ON CONFLICT REPLACE,
		"data" TEXT NOT NULL
	);]])
	if isstring(ply) then
		steamid = ply
		ply = player.GetBySteamID(ply)
	end
	if istable(ply) then
		self:SQL("BEGIN;")
		for k,v in pairs(ply) do
			steamid = v:SteamID() or ""
			if steamid ~= "" and self.ConDoSave:GetInt() > 0 then
				local inv = v.ISAWC_Inventory
				if self:RemoveRecursions(inv) then
					self:Log("Warning! " .. v:Nick() .. " had an item with recursive tables! This may cause errors to occur!")
				end
				if (inv and next(inv)) then
					local data
					if self.ConUseCompression:GetBool() then
						data = util.Base64Encode(util.Compress(util.TableToJSON(inv)))
					else
						data = util.TableToJSON(inv)
					end
					self:SQL("INSERT INTO \"isawc_player_data\" (\"steamID\", \"data\") VALUES (%s, %s);", steamid, data)
				else
					self:SQL("DELETE FROM \"isawc_player_data\" WHERE \"steamID\" = %s;", steamid)
				end
			end
		end
		self:SQL("COMMIT;")
	elseif (isentity(ply) and ply:IsPlayer()) then
		steamid = steamid or ply:SteamID() or ""
		if steamid ~= "" and self.ConDoSave:GetInt() > 0 then
			local inv = ply.ISAWC_Inventory
			if self:RemoveRecursions(inv) then
				self:Log("Warning! " .. ply:Nick() .. " had an item with recursive tables! This may cause errors to occur!")
			end
			if (inv and next(inv)) then
				local data
				if self.ConUseCompression:GetBool() then
					data = util.Base64Encode(util.Compress(util.TableToJSON(inv)))
				else
					data = util.TableToJSON(inv)
				end
				self:SQL("INSERT INTO \"isawc_player_data\" (\"steamID\", \"data\") VALUES (%s, %s);", steamid, data)
			else
				self:SQL("DELETE FROM \"isawc_player_data\" WHERE \"steamID\" = %s;", steamid)
			end
		end
	end
end

ISAWC.SaveContainerInventory = function(self,container)
	container:SendInventoryUpdate()
	local inv = {ISAWC_Inventory = container.ISAWC_Inventory, ISAWC_PlayerLocalizedInventories = container.ISAWC_PlayerLocalizedInventories}
	if self.ConSaveIntoFile:GetBool() then
		if self:RemoveRecursions(inv) then
			self:Log("Warning! " .. tostring(container) .. " had an item with recursive tables! This may cause errors to occur!")
		end
		if container:GetFileID() == "" then
			self:Log("Warning! " .. tostring(container) .. " failed to save as no ID was associated with the container!")
		else
			self:SQL([[CREATE TABLE IF NOT EXISTS "isawc_container_data" (
				"containerID" TEXT NOT NULL UNIQUE ON CONFLICT REPLACE,
				"data" TEXT NOT NULL
			);]])
			local data = next(inv.ISAWC_Inventory)
			if not data and next(inv.ISAWC_PlayerLocalizedInventories) then
				for k,v in pairs(inv.ISAWC_PlayerLocalizedInventories) do
					if next(v) then data = true break end
				end
			end
			if data then
				if self.ConUseCompression:GetBool() then
					data = util.Base64Encode(util.Compress(util.TableToJSON(inv)))
				else
					data = util.TableToJSON(inv)
				end
				self:SQL("INSERT INTO \"isawc_container_data\" (\"containerID\", \"data\") VALUES (%s, %s);", container:GetFileID(), data)
			else
				self:SQL("DELETE FROM \"isawc_container_data\" WHERE \"containerID\" = %s;", container:GetFileID())
			end
		end
	end
end

ISAWC.UpdateContainerInventories = function(self,container)
	local endername = container:GetEnderInvName()
	if (endername or "")~="" then
		for k,v in pairs(ents.GetAll()) do
			if v~=container and (v.Base=="isawc_container_base" and v:GetEnderInvName()==endername) then
				v.ISAWC_Inventory = container.ISAWC_Inventory
				v.ISAWC_PlayerLocalizedInventories = container.ISAWC_PlayerLocalizedInventories
				v:SendInventoryUpdate()
				ISAWC:SaveContainerInventory(v)
			end
		end
	end
end

ISAWC.DropAll = function(self,container,ply)
	if self.ConDropAllAllowed:GetBool() then
		local briefcase = ents.Create(self.ConDropAllClass:GetString())
		local modelOverride = self.ConDropAllModel:GetString()
		if not (IsValid(briefcase) and briefcase.Base == "isawc_container_base") then
			SafeRemoveEntity(briefcase)
			self:Log("Failed to create invalid container class "..self.ConDropAllClass:GetString()..'!')
			self:Log("Failed to remove items owned by "..tostring(container).." as the dropped container was invalid!")
		elseif not (modelOverride == "" or util.IsValidModel(modelOverride)) then
			briefcase:Remove()
			self:Log("Failed to create invalid model "..modelOverride..'!')
			self:Log("Failed to remove items owned by "..tostring(container).." as the dropped container was invalid!")
		else
			briefcase:SetPos(ply:GetShootPos())
			briefcase:SetCreator(ply)
			if modelOverride ~= "" then
				briefcase.ContainerModel = modelOverride
			end
			briefcase:Spawn()
			briefcase:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			briefcase:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 200)
			briefcase.ISAWC_IsDeathDrop = true
			briefcase.ISAWC_IsDropAll = true
			
			local inv
			if container.Base == "isawc_container_base" then
				inv = container:GetInventory(ply)
			else
				inv = container.ISAWC_Inventory
			end
			for i=1,#inv do
				local dupe = inv[i]
				if dupe then
					table.insert(briefcase.ISAWC_Inventory,dupe)
				end
			end
			container:SetInventory({}, ply)
			
			ply.ISAWC_DropAllContainers = self:FilterSequentialTable(ply.ISAWC_DropAllContainers or {}, self.FilterIsValid)
			table.insert(ply.ISAWC_DropAllContainers, briefcase)
			if self.ConDropAllLimit:GetInt() > 0 then
				for i=1,#ply.ISAWC_DropAllContainers-self.ConDropAllLimit:GetInt() do
					ply.ISAWC_DropAllContainers[i]:Remove()
				end
			end
		end
	end
end

ISAWC.PerformCompatibilityLoad = function(self, data)
end

ISAWC.PlayerCollisionCallback = function(ply, data)
	if ISAWC.ConPlayerPickupOnCollide:GetBool() and IsValid(data.HitEntity) then
		ISAWC:PlayerCollisionPickup(ply, data.HitEntity)
	end
end

ISAWC.LastLoadedData = ISAWC.LastLoadedData or {}
ISAWC.Initialize = function()
	if table.IsEmpty(ISAWC.LastLoadedData) and SERVER then
		local data = util.JSONToTable(file.Read("isawc_data.dat") or "") or {}
		if table.IsEmpty(data) then
			data = util.JSONToTable(util.Decompress(file.Read("isawc_data.dat") or "") or "") or {}
		end
		ISAWC:PerformCompatibilityLoad(data)
		
		ISAWC.Stacklist = data.Stacklist or ISAWC.Stacklist
		ISAWC.Masslist = data.Masslist or ISAWC.Masslist
		ISAWC.Volumelist = data.Volumelist or ISAWC.Volumelist
		ISAWC.Countlist = data.Countlist or ISAWC.Countlist
		ISAWC.Remaplist = data.Remaplist or ISAWC.Remaplist
		ISAWC.MassMultiList = data.MassMultiList or ISAWC.MassMultiList
		ISAWC.VolumeMultiList = data.VolumeMultiList or ISAWC.VolumeMultiList
		ISAWC.CountMultiList = data.CountMultiList or ISAWC.CountMultiList
		for k,v in pairs(data.BWLists or {}) do
			ISAWC.BWLists[k].Blacklist = v.Blacklist
			ISAWC.BWLists[k].Whitelist = v.Whitelist
		end
		
		local replacements = 0
		for k,v in pairs(ISAWC) do
			if (TypeID(v) == TYPE_CONVAR and data[k] ~= v:GetString()) and data[k] then
				v:SetString(data[k])
				replacements = replacements + 1
			end
		end
		if replacements > 1 then
			ISAWC:Log(string.format("ConVar file loaded, %u ConVar values updated.", replacements))
		elseif replacements > 0 then
			ISAWC:Log("ConVar file loaded, 1 ConVar value updated.")
		end
		
		ISAWC.LastLoadedData = data
	end
end

ISAWC.PlayerSpawn = function(ply)
	timer.Simple(0.5,function()
		if IsValid(ply) then
			local steamID = ply:SteamID() or ""
			if (ply.ISAWC_Inventory and next(ply.ISAWC_Inventory)) then
				ISAWC.LastLoadedData[steamID] = nil
			elseif ISAWC.ConDoSave:GetInt() > 0 then
				if steamID ~= "" then
					local results = ISAWC:SQL("SELECT \"steamID\", \"data\" FROM \"isawc_player_data\" WHERE \"steamID\" = %s;", steamID)
					if (results and results[1]) then
						ply.ISAWC_Inventory = util.JSONToTable(results[1].data)
						if not ply.ISAWC_Inventory then
							ply.ISAWC_Inventory = util.JSONToTable(util.Decompress(results[1].data) or "")
							if not ply.ISAWC_Inventory then
								ply.ISAWC_Inventory = util.JSONToTable(util.Decompress(util.Base64Decode(results[1].data) or "") or "")
							end
						end
					end
				end
				if not (ply.ISAWC_Inventory and next(ply.ISAWC_Inventory)) and ISAWC.LastLoadedData[steamID] then
					ply.ISAWC_Inventory = ISAWC.LastLoadedData[steamID]
				end
			end
			if not ply.ISAWC_AttachedCollisionInterface then
				ply.ISAWC_AttachedCollisionInterface = ply:AddCallback("PhysicsCollide", ISAWC.PlayerCollisionCallback)
			end
			ISAWC:SendInventory(ply)
		end
	end)
end

ISAWC.PlayerDeath = function(ply)
	if (ply.ISAWC_Inventory and next(ply.ISAWC_Inventory) or next(ply:GetWeapons())) and ISAWC.ConDropOnDeath:GetBool() then
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
			ply.ISAWC_Inventory = ply.ISAWC_Inventory or {}
			briefcase:SetPos(ply:GetPos() + ply:OBBCenter())
			briefcase:SetCreator(ply)
			if modelOverride ~= "" then
				briefcase.ContainerModel = modelOverride
			end
			briefcase:Spawn()
			briefcase:SetMassMul(0)
			briefcase:SetVolumeMul(0)
			briefcase:SetCountMul(0)
			briefcase:SetIsPublic(true)
			for i=1,#ply.ISAWC_Inventory do
				local dupe = ply.ISAWC_Inventory[i]
				if dupe then
					table.insert(briefcase.ISAWC_Inventory,dupe)
					--ISAWC:SpawnDupe(dupe,true,true,i,ply)
				end
			end
			ISAWC:SetSuppressUndo(true)
			for k,v in pairs(ply:GetWeapons()) do
				if ISAWC:CanPickup(briefcase,v,true) and ISAWC:SatisfiesBWLists(v:GetClass(), "DropOnDeath") then
					ply:DropWeapon(v)
					if ISAWC:CanProperty(briefcase,v) then
						ISAWC:PropPickup(briefcase,v,ply)
					end
				end
			end
			ISAWC:SetSuppressUndo(false)
			if briefcase.ISAWC_Inventory[1] then
				briefcase.ISAWC_IsDeathDrop = true
				ply.ISAWC_DropOnDeathContainers = ISAWC:FilterSequentialTable(ply.ISAWC_DropOnDeathContainers or {}, ISAWC.FilterIsValid)
				
				table.insert(ply.ISAWC_DropOnDeathContainers, briefcase)
				
				if ISAWC.ConDropOnDeathAmount:GetInt() > 0 then
					for i=1,#ply.ISAWC_DropOnDeathContainers-ISAWC.ConDropOnDeathAmount:GetInt() do
						ply.ISAWC_DropOnDeathContainers[i]:Remove()
					end
				end
			else
				SafeRemoveEntity(briefcase)
			end
			ply.ISAWC_Inventory = {}
			ISAWC:SendInventory(ply)
			ISAWC:SaveInventory(ply)
		end
	end
end

ISAWC.PlayerDisconnect = function(data)
	if SERVER then
		ISAWC:SaveData()
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
	local cond3 = cond1 and ent:PlayerPermitted(ply)
	local legal = cond1 and cond2 and cond3
	
	if not legal then
		local vioCode = 0
		if cond1 then
			vioCode = 1
		end
		if cond2 then
			vioCode = bit.bor(vioCode, 2)
		end
		if cond3 then
			vioCode = bit.bor(vioCode, 4)
		end
		self:Log(string.format("Rejected %s's attempt to use container \"%s\"!", ply:Nick(), tostring(ent)))
		self:Log(string.format("Technical details: expected 7 passes, got only %u passes", vioCode))
	end
	return legal
end

ISAWC.EmptyWeaponClipsToPlayer = function(self,dupe,ply)
	local success = false
	for k,v in pairs(dupe.Entities) do
		if (v.SavedClip1 and v.SavedClip1 > 0) then
			ply:GiveAmmo(v.SavedClip1, v.SavedAmmoType1)
			v.SavedClip1 = 0
			success = true
		end
		if (v.SavedClip2 and v.SavedClip2 > 0) then
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

ISAWC.StoredInAltSaveProps = ISAWC.StoredInAltSaveProps or {}
ISAWC.SpawnDupe = function(self,dupe,isSpawn,sSpawn,invnum,ply)
	local canDel = self.ConAllowDelete:GetBool()
	local trace = util.QuickTrace(ply:EyePos(),isSpawn and ply:GetAimVector()*self.ConDistance:GetFloat() or vector_origin,ply)
	local spawnpos = trace.HitPos - Vector(0,0,dupe.Mins.z) + trace.HitNormal * self.ConDistBefore:GetFloat()
	local altSaveSpawnable = true
	for k,v in pairs(dupe.Entities) do
		local ent = Entity(k)
		if sSpawn then
			if not (IsValid(ent) and self.StoredInAltSaveProps[ent]) then
				altSaveSpawnable = false
			end
		elseif canDel then
			SafeRemoveEntity(ent)
		else
			table.insert(ply.ISAWC_Inventory,invnum,dupe)
			self:NoPickup("You can't delete inventory items!",ply)
		end
	end
	if self.ConAltSave:GetBool() and altSaveSpawnable then
		for k,v in pairs(dupe.Entities) do
			local ent = Entity(k)
			if self.ConSaveTable:GetBool() then
				for k,v in pairs(ent.ISAWC_SaveTable or {}) do
					ent:SetSaveValue(k,v)
				end
			end
			self.StoredInAltSaveProps[ent] = nil
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
	elseif sSpawn then
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
				newent:SetCreator(ply)
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
							self:NoPickup("Can't undo deleted entity!",ply)
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
	local trace = util.QuickTrace(ply:EyePos(),isSpawn and ply:GetAimVector()*self.ConDistance:GetFloat() or vector_origin,ply)
	local spawnpos = trace.HitPos - Vector(0,0,dupe.Mins.z) + trace.HitNormal * self.ConDistBefore:GetFloat()
	local altSaveSpawnable = true
	for k,v in pairs(dupe.Entities) do
		local ent = Entity(k)
		if sSpawn then
			if not (IsValid(ent) and self.StoredInAltSaveProps[ent]) then
				altSaveSpawnable = false
			end
		elseif canDel then
			SafeRemoveEntity(ent)
		else
			table.insert(container.ISAWC_Inventory,invnum,dupe)
			self:NoPickup("You can't delete inventory items!",ply)
		end
	end
	if self.ConAltSave:GetBool() and altSaveSpawnable then
		for k,v in pairs(dupe.Entities) do
			local ent = Entity(k)
			if self.ConSaveTable:GetBool() then
				for k,v in pairs(ent.ISAWC_SaveTable or {}) do
					ent:SetSaveValue(k,v)
				end
			end
			self.StoredInAltSaveProps[ent] = nil
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
	elseif sSpawn then
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
				newent:SetCreator(ply)
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
							self:NoPickup("Can't undo deleted entity!",ply)
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
	local altSaveSpawnable = true
	for k,v in pairs(dupe.Entities) do
		local ent = Entity(k)
		if not (IsValid(ent) and self.StoredInAltSaveProps[ent]) then
			altSaveSpawnable = false
		end
	end
	if self.ConAltSave:GetBool() and altSaveSpawnable then
		for k,v in pairs(dupe.Entities) do
			local ent = Entity(k)
			if self.ConSaveTable:GetBool() then
				for k,v in pairs(ent.ISAWC_SaveTable or {}) do
					ent:SetSaveValue(k,v)
				end
			end
			self.StoredInAltSaveProps[ent] = nil
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
	else
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
				newent:SetCreator(ply)
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

ISAWC.StartNetMessage = function(self,messageType,unreliable)
	net.Start("isawc_general", unreliable)
	local typeID = self.MESSAGE_TYPES[messageType]
	net.WriteUInt(typeID or 0, 8)
	if not typeID then
		self:Log("Warning! Message type \""..messageType.."\" is invalid!")
	end
end

ISAWC.IsMessageType = function(self,messageType,messageTypeString)
	return messageType == ISAWC.MESSAGE_TYPES[messageTypeString]
end

ISAWC.ReceiveMessage = function(self,length,ply,func)
	if SERVER and IsValid(ply) then
		ply.ISAWC_Inventory = ply.ISAWC_Inventory or {}
		if self:IsMessageType(func, "pickup") then
			local ent = net.ReadEntity()
			if self:CanProperty(ply,ent) then
				self:PropPickup(ply,ent)
			end
		elseif self:IsMessageType(func, "inventory") then
			self:SendInventory(ply)
		elseif self:IsMessageType(func, "inventory_l") then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				self:SendInventory2(ply,container)
			end
		elseif self:IsMessageType(func, "close_container") then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply,true) then
				container.ISAWC_Openers[ply] = nil
				if not IsValid(next(container.ISAWC_Openers)) then
					self:StartNetMessage("close_container")
					net.WriteEntity(container)
					net.SendPAS(container:GetPos())
				end
			end
		elseif self:IsMessageType(func, "moving_items") or self:IsMessageType(func, "moving_items_l") then
			local container
			if self:IsMessageType(func, "moving_items_l") then
				container = net.ReadEntity()
				if not self:IsLegalContainer(container,ply) then return end
			end
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
			if container then
				self:SendInventory2(ply,container)
			else
				self:SendInventory(ply)
			end
		elseif self:IsMessageType(func, "moving_items_r") then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				local constructtable = {}
				local inv = container:GetInventory(ply)
				for i=1,#inv do
					local desired = net.ReadUInt(16)
					if desired<1 then return end
					if desired>#inv then return end
					constructtable[desired] = i
				end
				if #constructtable~=#inv then return end
				for k,v in pairs(table.Copy(constructtable)) do
					constructtable[v] = inv[k]
				end
				container:SetInventory(constructtable,ply)
				self:SendInventory2(ply,container)
			end
		elseif self:IsMessageType(func, "transfer_to") then
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
							local data = self:GetClientStats(container,ply)
							if data[5]+dupe.TotalCount>data[6] then self:NoPickup("The container needs "..math.ceil(data[5]+dupe.TotalCount-data[6]).." more slot(s) before it can accept the item!",ply) break end
							if data[3]+dupe.TotalVolume>data[4] then self:NoPickup("The container needs "..math.Round((data[3]+dupe.TotalVolume-data[4])*self.dm3perHu,2).." dm³ more before it can accept the item!",ply) break end
							if data[1]+dupe.TotalMass>data[2] then self:NoPickup("The container needs "..math.Round(data[1]+dupe.TotalMass-data[2],2).." kg more before it can accept the item!",ply) break end
							table.insert(container:GetInventory(ply),dupe)
							table.remove(ply.ISAWC_Inventory,invnum)
						end
					else
						local dupe = ply.ISAWC_Inventory[invnum]
						if not dupe then return end
						local data = self:GetClientStats(container,ply)
						if data[5]+dupe.TotalCount>data[6] then return self:NoPickup("The container needs "..math.ceil(data[5]+dupe.TotalCount-data[6]).." more slot(s) before it can accept the item!",ply) end
						if data[3]+dupe.TotalVolume>data[4] then return self:NoPickup("The container needs "..math.Round((data[3]+dupe.TotalVolume-data[4])*self.dm3perHu,2).." dm³ more before it can accept the item!",ply) end
						if data[1]+dupe.TotalMass>data[2] then return self:NoPickup("The container needs "..math.Round(data[1]+dupe.TotalMass-data[2],2).." kg more before it can accept the item!",ply) end
						table.insert(container:GetInventory(ply),dupe)
						table.remove(ply.ISAWC_Inventory,invnum)
					end
					self:SendInventory2(ply,container)
				end
			end
		elseif self:IsMessageType(func, "transfer_from") then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				local invnum = net.ReadUInt(16)
				if invnum == 0 then
					for i=1,net.ReadUInt(16) do
						invnum = net.ReadUInt(16)
						local dupe = container:GetInventory(ply)[invnum]
						if not dupe then break end
						local data = self:GetClientStats(ply)
						if data[5]+dupe.TotalCount>data[6] then self:NoPickup("You need "..math.ceil(data[5]+dupe.TotalCount-data[6]).." more slot(s) to take that item!",ply) break end
						if data[3]+dupe.TotalVolume>data[4] then self:NoPickup("You need "..math.Round((data[3]+dupe.TotalVolume-data[4])*self.dm3perHu,2).." dm³ more to take that item!",ply) break end
						if data[1]+dupe.TotalMass>data[2] then self:NoPickup("You need "..math.Round(data[1]+dupe.TotalMass-data[2],2).." kg more to take that item!",ply) break end
						table.insert(ply.ISAWC_Inventory,dupe)
						table.remove(container:GetInventory(ply),invnum)
					end
				else
					local dupe = container:GetInventory(ply)[invnum]
					if not dupe then return end
					local data = self:GetClientStats(ply)
					if data[5]+dupe.TotalCount>data[6] then return self:NoPickup("You need "..math.ceil(data[5]+dupe.TotalCount-data[6]).." more slot(s) to take that item!",ply) end
					if data[3]+dupe.TotalVolume>data[4] then return self:NoPickup("You need "..math.Round((data[3]+dupe.TotalVolume-data[4])*self.dm3perHu,2).." dm³ more to take that item!",ply) end
					if data[1]+dupe.TotalMass>data[2] then return self:NoPickup("You need "..math.Round(data[1]+dupe.TotalMass-data[2],2).." kg more to take that item!",ply) end
					table.insert(ply.ISAWC_Inventory,dupe)
					table.remove(container:GetInventory(ply),invnum)
				end
				self:SendInventory2(ply,container)
			end
		elseif self:IsMessageType(func, "spawn") or self:IsMessageType(func, "spawn_self") or self:IsMessageType(func, "delete") then
			if self:CanDrop(ply) or self:IsMessageType(func, "delete") then
				local invnum = net.ReadUInt(16)
				if invnum == 0 then
					if self:CanMultiSpawn(ply) then
						self:SetSuppressUndoHeaders(true)
						undo.Create("Spawn From Inventory")
						for i=1,net.ReadUInt(16) do
							invnum = net.ReadUInt(16)
							local dupe = table.remove(ply.ISAWC_Inventory,invnum)
							if dupe then
								self:SpawnDupe(dupe,self:IsMessageType(func, "spawn"),not self:IsMessageType(func, "delete"),invnum,ply)
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
						self:SpawnDupe(dupe,self:IsMessageType(func, "spawn"),not self:IsMessageType(func, "delete"),invnum,ply)
					end
				end
				self:SendInventory(ply)
			end
		elseif self:IsMessageType(func, "spawn_l") or self:IsMessageType(func, "spawn_self_l") or self:IsMessageType(func, "delete_l") then
			if self:CanDrop(ply) or self:IsMessageType(func, "delete_l") then
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
									self:SpawnDupe(dupe,self:IsMessageType(func, "spawn_l"),not self:IsMessageType(func, "delete_l"),invnum,ply)
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
							self:SpawnDupe(dupe,self:IsMessageType(func, "spawn_l"),not self:IsMessageType(func, "delete_l"),invnum,ply)
						end
					end
					self:SendInventory2(ply,container)
				end
			end
		elseif self:IsMessageType(func, "spawn_r") or self:IsMessageType(func, "spawn_self_r") or self:IsMessageType(func, "delete_r") then
			if self:CanDrop(ply) or self:IsMessageType(func, "delete_r") then
				local container = net.ReadEntity()
				if self:IsLegalContainer(container,ply) then
					local invnum = net.ReadUInt(16)
					if invnum == 0 then
						if self:CanMultiSpawn(ply) then
							self:SetSuppressUndoHeaders(true)
							undo.Create("Spawn From Container")
							for i=1,net.ReadUInt(16) do
								invnum = net.ReadUInt(16)
								local dupe = table.remove(container:GetInventory(ply),invnum)
								if dupe then
									self:SpawnDupe2(dupe,self:IsMessageType(func, "spawn_r"),not self:IsMessageType(func, "delete_r"),invnum,ply,container)
								end
							end
							undo.SetCustomUndoText("Undone Spawn From Container",ply)
							undo.SetPlayer(ply)
							undo.Finish()
							self:SetSuppressUndoHeaders(false)
						end
					else
						local dupe = table.remove(container:GetInventory(ply),invnum)
						if dupe then
							self:SpawnDupe2(dupe,self:IsMessageType(func, "spawn_r"),not self:IsMessageType(func, "delete_r"),invnum,ply,container)
						end
					end
					self:SendInventory2(ply,container)
				end
			end
		elseif self:IsMessageType(func, "delete_full") or self:IsMessageType(func, "delete_full_l") then
			if self.ConAllowDelete:GetBool() then
				ply.ISAWC_Inventory = {}
			else
				self:NoPickup("You can't delete inventory items!",ply)
			end
			if self:IsMessageType(func, "delete_full") then
				self:SendInventory(ply)
			else
				local container = net.ReadEntity()
				if self:IsLegalContainer(container,ply) then
					self:SendInventory2(ply,container)
				end
			end
		elseif self:IsMessageType(func, "delete_full_r") then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				if self.ConAllowDelete:GetBool() then
					container:SetInventory({}, ply)
				else
					self:NoPickup("You can't delete inventory items!",ply)
				end
				self:SendInventory2(ply,container)
			end
		elseif self:IsMessageType(func, "drop_all") or self:IsMessageType(func, "drop_all_l") then
			if (ply.ISAWC_Inventory and next(ply.ISAWC_Inventory)) then
				self:DropAll(ply,ply)
				if self:IsMessageType(func, "drop_all") then
					self:SendInventory(ply)
				else
					local container = net.ReadEntity()
					if self:IsLegalContainer(container,ply) then
						self:SendInventory2(ply,container)
					end
				end
			end
		elseif self:IsMessageType(func, "drop_all_r") then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				if next(container:GetInventory(ply)) then
					self:DropAll(container,ply)
					self:SendInventory2(ply,container)
				end
			end
		elseif self:IsMessageType(func, "empty_weapon") then
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
		elseif self:IsMessageType(func, "empty_weapon_l") or self:IsMessageType(func, "empty_weapon_r") then
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				local invnum = net.ReadUInt(16)
				if invnum == 0 then
					for i=1,net.ReadUInt(16) do
						invnum = net.ReadUInt(16)
						local dupe = self:IsMessageType(func, "empty_weapon_l") and ply.ISAWC_Inventory[invnum] or container:GetInventory(ply)[invnum]
						if not dupe then return end
						self:EmptyWeaponClipsToPlayer(dupe, ply)
					end
				else
					local dupe = self:IsMessageType(func, "empty_weapon_l") and ply.ISAWC_Inventory[invnum] or container:GetInventory(ply)[invnum]
					if not dupe then return end
					self:EmptyWeaponClipsToPlayer(dupe, ply)
				end
				self:SendInventory2(ply,container)
			end
		elseif self:IsMessageType(func, "store_weapon") then
			if ISAWC.ConAllowHeldWeapons:GetBool() then
				local ent = ply:GetActiveWeapon()
				if IsValid(ent) then
					if self:CanPickup(ply,ent,true) then
						ply:DropWeapon(ent)
						if self:CanProperty(ply,ent) then
							self:PropPickup(ply,ent)
						end
					end
				else
					self:NoPickup("You don't have any weapons equipped!",ply)
				end
			else
				self:NoPickup("You can't put held weapons into containers!",ply)
			end
		elseif self:IsMessageType(func, "store_weapon_l") then
			if ISAWC.ConAllowHeldWeapons:GetBool() then
				local container = net.ReadEntity()
				if self:IsLegalContainer(container,ply) then
					local ent = ply:GetActiveWeapon()
					if IsValid(ent) then
						if self:CanPickup(ply,ent,true) then
							ply:DropWeapon(ent)
							if self:CanProperty(ply,ent) then
								self:PropPickup(ply,ent,container)
							end
						end
					else
						self:NoPickup("You don't have any weapons equipped!",ply)
					end
				end
			else
				self:NoPickup("You can't put held weapons into containers!",ply)
			end
		elseif self:IsMessageType(func, "store_weapon_r") then
			if ISAWC.ConAllowHeldWeapons:GetBool() then
				local container = net.ReadEntity()
				if self:IsLegalContainer(container,ply) then
					local ent = ply:GetActiveWeapon()
					if IsValid(ent) then
						if self:CanPickup(container,ent,true) then
							ply:DropWeapon(ent)
							if self:CanProperty(container,ent) then
								self:PropPickup(container,ent,ply)
							end
						end
					else
						self:NoPickup("You don't have any weapons equipped!",ply)
					end
				end
			else
				self:NoPickup("You can't put held weapons into containers!",ply)
			end
		elseif self:IsMessageType(func, "exporter") then
			local exporter = net.ReadEntity()
			if (IsValid(exporter) and exporter:GetClass()=="isawc_extractor" and exporter:GetOwnerAccountID() == (ply:AccountID() or 0) or ply:IsAdmin()) then
				exporter:SetActiFlags(net.ReadInt(32))
				exporter:SetSpawnDelay(net.ReadFloat())
				exporter:SetActiMass(net.ReadFloat())
				exporter:SetActiVolume(net.ReadFloat())
				exporter:SetActiCount(net.ReadFloat())
			end
		elseif self:IsMessageType(func, "exporter_disconnect") then
			local exporter = net.ReadEntity()
			if (IsValid(exporter) and exporter:GetClass()=="isawc_extractor" and exporter:GetOwnerAccountID() == (ply:AccountID() or 0) or ply:IsAdmin()) then
				exporter:ClearStorageEntities()
				exporter:SetCollisionGroup(COLLISION_GROUP_NONE)
				--exporter:UpdateWireOutputs()
			end
		elseif self:IsMessageType(func, "send_maker_data") then
			local weapon = ply:GetActiveWeapon()
			if (IsValid(weapon) and weapon:GetClass()=="weapon_isawc_maker") then
				local massMul, volumeMul, countMul, lockMul = net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat()
				local massConstant, volumeConstant = net.ReadFloat(), net.ReadFloat()
				local openSounds, closeSounds = net.ReadString(), net.ReadString()
				local additionalAccess = net.ReadString()
				--print(massMul, volumeMul, massConstant, volumeConstant, openSounds, closeSounds)
				weapon:SetMassMul(massMul)
				weapon:SetVolumeMul(volumeMul)
				weapon:SetCountMul(countMul)
				weapon:SetLockMul(lockMul)
				weapon:SetMassConstant(massConstant)
				weapon:SetVolumeConstant(volumeConstant)
				weapon:SetOpenSounds(openSounds)
				weapon:SetCloseSounds(closeSounds)
				weapon:SetAdditionalAccess(additionalAccess)
				weapon:EmitSound("buttons/button17.wav")
				ply:PrintMessage(HUD_PRINTTALK, "Properties set! They will take place the next time you transform a container.")
			end
		elseif self:IsMessageType(func, "set_public") then
			local isPublic = net.ReadBool()
			local container = net.ReadEntity()
			if self:IsLegalContainer(container,ply) then
				container:SetIsPublic(isPublic)
				self:SendInventory2(ply,container)
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
		if self:IsMessageType(func, "inventory") then
			if IsValid(self.reliantwindow) then
				if self.reliantwindow.IsDouble then
					self.reliantwindow:Close()
				else
					--[[local bytes = net.ReadUInt(32)
					self.reliantwindow:ReceiveInventory(util.JSONToTable(net.ReadData(bytes)))]]
					local data = {}
					for i=1,net.ReadUInt(16) do
						data[i] = {Model=net.ReadString(), Class=net.ReadString(), Skin=net.ReadUInt(16), BodyGroups=net.ReadString(),
						Clip1=net.ReadInt(32), Clip2=net.ReadInt(32), MaxClip1=net.ReadInt(32), MaxClip2=net.ReadInt(32)}
					end
					self.reliantwindow:ReceiveInventory(data)
					self.reliantwindow:ReceiveStats({net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadFloat(),net.ReadUInt(16),net.ReadUInt(16)})
				end
			end
		elseif self:IsMessageType(func, "pickup_denied") then
			self:NoPickup(net.ReadString(),ply)
		elseif self:IsMessageType(func, "inventory_l") then
			local container = net.ReadEntity()
			if IsValid(container) then
				self:BuildOtherInventory(container)
			end
		elseif self:IsMessageType(func, "open_container") then
			local container = net.ReadEntity()
			if IsValid(container) then
				container.FinishOpenAnimTime = CurTime() + (container.OpenAnimTime or 0)
				if container.ISAWC_Template then
					container.OpenSounds = string.Split(net.ReadString(),'|')
					container.CloseSounds = string.Split(net.ReadString(),'|')
				end
				if next(container.OpenSounds or {}) then
					container:EmitSound(container.OpenSounds[math.random(1,#container.OpenSounds)], 60)
				end
			end
		elseif self:IsMessageType(func, "close_container") then
			local container = net.ReadEntity()
			if IsValid(container) then
				container.FinishCloseAnimTime = CurTime() + (container.CloseAnimTime or 0)
				if next(container.CloseSounds or {}) then
					container:EmitSound(container.CloseSounds[math.random(1,#container.CloseSounds)], 60)
				end
			end
		elseif self:IsMessageType(func, "inventory_r") then
			if IsValid(self.reliantwindow) then
				if self.reliantwindow.IsDouble then
					--[[local bytes1,bytes2 = net.ReadUInt(32),net.ReadUInt(32)
					local data1 = util.JSONToTable(net.ReadData(bytes1))
					local data2 = util.JSONToTable(net.ReadData(bytes2))]]
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
			end
		elseif self:IsMessageType(func, "exporter") then
			local questionEnt = net.ReadEntity()
			if IsValid(questionEnt) then
				questionEnt:BuildConfigGUI()
			end
		elseif self:IsMessageType(func, "send_maker_data") then
			local weapon = net.ReadEntity()
			if IsValid(weapon) then
				weapon:OpenMakerMenu()
			end
		else
			self:Log("Received unrecognised message header \"" .. func .. "\" from server. Assuming data packet corrupted.")
		end
	end
end

net.Receive("isawc_general",function(length,ply)
	ISAWC:ReceiveMessage(length,ply,net.ReadUInt(8))
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

ISAWC.CanPickup = function(self,ply,ent,speculative)
	if not IsValid(ply) then return false end
	if not IsValid(ent) then self:NoPickup("You can't pick up a nonexistent entity!",ply) return false end
	if ent.ISAWC_BeingPhysgunned then self:NoPickup("You can't pick up an entity that is being carried by the Physics Gun!",ply) return false end
	if ply.ISAWC_IsDeathDrop then self:NoPickup("You can't pick up any entities!",ply) return false end
	if (tonumber(ent.NextPickup2) or 0) > CurTime() and (tonumber(ent.NextPickup2) or 0) <= CurTime() + 0.5 and SERVER then return false end
	if speculative then
		ent.NextPickup2 = CurTime() - math.random()
	else
		ent.NextPickup2 = CurTime() + 0.5
	end
	if ply.NextPickup2 == ent.NextPickup2 and not speculative then self:NoPickup("You can't pick up a container with the same NP time!",ply) return false end
	if (ply:IsPlayer() and ply:IsAdmin()) and self.ConAdminOverride:GetBool() and SERVER then
		local passeswlist = self:SatisfiesWhitelist(class, "General")
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
		local allowed = self:SatisfiesBWLists(class, "General")
		local passeswlist = self:SatisfiesWhitelist(class, "General")
		if not allowed then
			if self.ConGeneralWhitelistEnabled:GetBool() then	
				self:NoPickup("That entity isn't whitelisted for being picked up!", ply)
			else
				self:NoPickup("That entity is blacklisted from being picked up!", ply)
			end
			return false
		end
		if ent:IsPlayer() and not passeswlist then self:NoPickup("You can't pick up players!",ply) return false end
		if ent==game.GetWorld() and not passeswlist then self:NoPickup("You can't pick up worldspawn!",ply) return false end
		if not ply:IsPlayer() and (class=="isawc_importer" or class=="isawc_extractor" or class=="isawc_weighingscale") and not passeswlist then
			if class=="isawc_weighingscale" then
				self:NoPickup("You can't pick up Weighing Scales!",ply) return false
			elseif class=="isawc_importer" then
				if ent:GetFileID()=='' then
					self:NoPickup("You can't pick up unconnected Inventory Importers!",ply) return false
				elseif ent:GetContainer()==ply then
					self:NoPickup("You can't pick up Inventory Importers connected to you!",ply) return false
				end
			else
				if not ent:HasContainer() then
					self:NoPickup("You can't pick up unconnected Inventory Exporters!",ply) return false
				elseif ent:HasContainer(ply) then
					self:NoPickup("You can't pick up Inventory Exporters connected to you!",ply) return false
				end
			end
		end
		if SERVER then
			if not speculative then
				DropEntityIfHeld(ent)
			end
			if ply:GetPos():Distance(ent:GetPos())-ent:BoundingRadius()-ply:BoundingRadius()>self.ConDistance:GetFloat() and ply:IsPlayer() then self:NoPickup("You need to be closer to the object!",ply) return false end
			if not (ent:IsSolid() or ent:IsWeapon()) then self:NoPickup("You can't pick up non-solid entities!",ply) return false end
			if ent:GetMoveType()~=MOVETYPE_VPHYSICS and not self.ConNonVPhysics:GetBool() and not ent:IsWeapon() then self:NoPickup("You can't pick up non-VPhysics entities!",ply) return false end
			if constraint.HasConstraints(ent) and not self.ConAllowConstrained:GetBool() then self:NoPickup("You can't pick up constrained entities!",ply) return false end
			local TotalMass, TotalVolume, TotalCount = self:CalculateEntitySpace(ent)
			local data
			if ply:IsPlayer() then
				data = self:GetClientStats(ply)
			else
				local pickupPlayer = (
					IsValid(ent:GetPhysicsAttacker(5)) and ent:GetPhysicsAttacker(5)
					or IsValid(ent:GetOwner()) and ent:GetOwner()
					or IsValid(ent:GetCreator()) and ent:GetCreator()
					or player.GetByAccountID(ply:GetOwnerAccountID())
				)
				data = self:GetClientStats(ply,pickupPlayer)
			end
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
	if self.ConOverride:GetBool() or speculative then return true end
end

ISAWC.CanMultiSpawn = function(self,ply)
	if ISAWC.ConSpawnDelay:GetFloat() > 0 then self:NoPickup("You can't spawn multiple items at once!") return false end
	return true
end

ISAWC.OldCanProperty = function(ply,name,ent)
	if name=="isawc_pickup" then
		return ISAWC:CanPickup(ply,ent)
	elseif name=="editentity" and IsValid(ply) and (IsValid(ent) and ent.Base == "isawc_container_base") then
		local permissionValue = ISAWC.ConEditPropertiesPermissionLevel:GetInt()
		if permissionValue > 2 then return false
		elseif permissionValue > 1 and not ply:IsSuperAdmin() then return false
		elseif permissionValue > 0 and not ply:IsAdmin() then return false
		end
	end
end

ISAWC.CanDrop = function(self,ply)
	if (ply.NextDrop or 0) > CurTime() and (ply.NextDrop or 0) <= CurTime() + self.ConSpawnDelay:GetFloat() and ply:IsPlayer() and SERVER then self:NoPickup("You need to wait for "..string.format("%.1f",ply.NextDrop-CurTime()).." seconds before spawning another object!",ply) return false end
	ply.NextDrop = CurTime() + self.ConSpawnDelay:GetFloat()
	return true
end

ISAWC.PlayerCollisionPickup = function(self, ply, ent)
	self:SetSuppressNoPickup(true)
	if self:CanProperty(ply, ent) then
		self:PropPickup(ply, ent)
	end
	self:SetSuppressNoPickup(false)
end

ISAWC.PlayerMagnetize = function(self, ply, ent)
	if not IsValid(ent:GetParent()) and self:CanPickup(ply,ent,true) then
		ply.ISAWC_MagnetTraceResult = ply.ISAWC_MagnetTraceResult or {}
		local trace = util.TraceLine({
			start = ply:GetPos(),
			endpos = ent:GetPos(),
			filter = ply,
			mask = MASK_SOLID,
			output = ply.ISAWC_MagnetTraceResult
		})
		local result = ply.ISAWC_MagnetTraceResult
		if not result.Hit or result.HitNonWorld and result.Entity == ent then
			if IsValid(ent:GetPhysicsObject()) and ent:GetMoveType()==MOVETYPE_VPHYSICS then
				local dir = ply:GetPos()-ent:GetPos()
				local nDir = dir:GetNormalized()
				nDir:Mul(math.min(ply.MagnetScale*5e4*self.ConPlayerMagnet:GetFloat()/dir:LengthSqr(), 1000))
				ent:GetPhysicsObject():AddVelocity(nDir)
			else
				self:PlayerCollisionPickup(ply, ent)
			end
		end
	end
end

ISAWC.PermissionsObjectMetaIndex = {
	Initialize = function(self)
		self:SetPermittedUsernames({})
		self:SetPermittedTeams({})
		self:SetPermittedDarkRPCategories({})
		self:SetPermittedDarkRPCommands({})
		self:SetPermittedDarkRPDoorGroups({})
	end,
	
	AddPermittedUsername = function(self, username)
		self:GetPermittedUsernames()[username] = true
	end,
	
	AddPermittedTeam = function(self, team)
		self:GetPermittedTeams()[team] = true
	end,
	
	AddPermittedDarkRPCategory = function(self, category)
		self:GetPermittedDarkRPCategories()[category] = true
	end,
	
	AddPermittedDarkRPCommand = function(self, command)
		self:GetPermittedDarkRPCommands()[command] = true
	end,
	
	AddPermittedDarkRPDoorGroup = function(self, doorGroup)
		self:GetPermittedDarkRPDoorGroups()[doorGroup] = true
	end,
	
	PlayerPermitted = function(self, ply)
		local playerTeam = ply:Team()
		local notPermitted = not (self:GetPermittedUsernames()[ply:Nick()] or self:GetPermittedTeams()[playerTeam])
		
		if DarkRP and notPermitted then
			local jobInfo = ply:getJobTable()
			
			notPermitted = not (self:GetPermittedDarkRPCategories()[jobInfo.category] or self:GetPermittedDarkRPCommands()[jobInfo.command])
			
			if notPermitted then
				-- this is kinda dumb (O(n^2))
				for k,v in pairs(self:GetPermittedDarkRPDoorGroups()) do
					if table.HasValue(RPExtraTeamDoors[k] or {}, playerTeam) then
						notPermitted = false break
					end
				end
			end
		end
		
		return not notPermitted
	end
}

AccessorFunc(ISAWC.PermissionsObjectMetaIndex, "_permittedUsernames", "PermittedUsernames")
AccessorFunc(ISAWC.PermissionsObjectMetaIndex, "_permittedTeams", "PermittedTeams")
AccessorFunc(ISAWC.PermissionsObjectMetaIndex, "_permittedDarkRPCategories", "PermittedDarkRPCategories")
AccessorFunc(ISAWC.PermissionsObjectMetaIndex, "_permittedDarkRPCommands", "PermittedDarkRPCommands")
AccessorFunc(ISAWC.PermissionsObjectMetaIndex, "_permittedDarkRPDoorGroups", "PermittedDarkRPDoorGroups")

ISAWC.CreatePermissionsObject = function(self, oldTable)
	local permissionsObject = {}
	setmetatable(permissionsObject, {__index = self.PermissionsObjectMetaIndex})
	permissionsObject:Initialize()
	
	if oldTable then
		for k,v in pairs(oldTable) do
			permissionsObject[k] = v
		end
	end
	
	return permissionsObject
end

local invcooldown = 0
local nextsave = 0
local nextAltSaveCheck = 0
local clientTicks = 0
local allPlayers = player.GetAll()
for k,v in pairs(allPlayers) do
	if v.ISAWC_AttachedCollisionInterface then
		v:RemoveCallback("PhysicsCollide", v.ISAWC_AttachedCollisionInterface)
		v.ISAWC_AttachedCollisionInterface = v:AddCallback("PhysicsCollide", ISAWC.PlayerCollisionCallback)
	end
end
ISAWC.Tick = function()
	if SERVER then
		if nextsave < RealTime() and ISAWC.ConDoSave:GetInt() > 0 then
			nextsave = RealTime() + ISAWC.ConDoSaveDelay:GetFloat()
			ISAWC:SaveInventory(player.GetAll())
			ISAWC:Log("Player inventories saved!")
		end
		if ISAWC.ConPlayerMagnet:GetFloat() > 0 then
			ISAWC:SetSuppressNoPickup(true)
			for k,v in pairs(allPlayers) do
				if (IsValid(v) and tobool(v:GetInfo("isawc_player_magnet_enabled"))) then
					if not v.MagnetScale or (v.ISAWC_LastMagnetScaleCalc or 0) + 1 < CurTime() then
						v.ISAWC_LastMagnetScaleCalc = CurTime()
						v.MagnetScale = v:BoundingRadius()
					end
					for k2,v2 in pairs(ents.FindInSphere(v:LocalToWorld(v:OBBCenter()), ISAWC.ConPlayerMagnet:GetFloat()*v.MagnetScale)) do
						if v2 ~= v and ISAWC:SatisfiesBWLists(v2:GetClass(), "PlayerMagnet") then
							ISAWC:PlayerMagnetize(v, v2)
						end
					end
				end
			end
			ISAWC:SetSuppressNoPickup(false)
		end
		-- the following is needed to make sure the stashed props don't just walk off the map!
		if nextAltSaveCheck < RealTime() then
			nextAltSaveCheck = RealTime() + 2
			if table.IsEmpty(ISAWC.LastLoadedData) then -- Initialize failed to be called for some reason
				ISAWC:Initialize()
			end
			allPlayers = player.GetAll()
			for k,v in pairs(ISAWC.StoredInAltSaveProps) do
				if IsValid(k) and not k:IsPlayer() then
					k:SetPos(Vector(16000,16000,16000))
					k:SetNoDraw(true)
					k:SetNotSolid(true)
					k:SetMoveType(MOVETYPE_NONE)
				else
					ISAWC.StoredInAltSaveProps[k] = nil
				end
			end
		end
	end
	if CLIENT then
		local ply = LocalPlayer()
		local overrideKey = input.GetKeyCode(ISAWC.ConUseBindOverride:GetString())
		local useKey = overrideKey > 0 and overrideKey or input.GetKeyCode(ISAWC.ConUseBind:GetString())
		local invToggleKey = input.GetKeyCode(ISAWC.ConInventoryBind:GetString())
		local invHoldKey = input.GetKeyCode(ISAWC.ConInventoryBindHold:GetString())
		local noOtherUIs = not (gui.IsGameUIVisible() or gui.IsConsoleVisible() or IsValid(vgui.GetKeyboardFocus()))
		if input.IsKeyDown(useKey) and noOtherUIs then
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
					tracedata = {}
					local hitpos = traceresult.HitPos
					for k,v in pairs(ents.FindInSphere(hitpos,16)) do
						tracedata[v] = -v:GetPos():DistToSqr(hitpos)
					end
					probent = table.GetWinningKey(tracedata)
				else
					probent = traceresult.Entity
				end
			end
			local ent = probent or NULL
			if IsValid(ent) and not (ent:IsWeapon() and ent:GetOwner() == ply) then
				if (ent.ISAWC_ResetUseTime or 0) < CurTime() then
					ent.ISAWC_UseStreak = 0
				end
				ent.ISAWC_UseStreak = ent.ISAWC_UseStreak + 1
				ent.ISAWC_ResetUseTime = CurTime() + 0.1
				local effectiveUseDelay = ISAWC.ConUseBindDelayOverride:GetFloat() ~= 0 and ISAWC.ConUseBindDelayOverride:GetFloat() or ISAWC.ConUseDelay:GetFloat()
				effectiveUseDelay = effectiveUseDelay == -2 and ISAWC.ConDelay:GetFloat() or effectiveUseDelay
				if ent.ISAWC_UseStreak >= effectiveUseDelay/engine.TickInterval() and effectiveUseDelay>=0 then
					ent.ISAWC_UseStreak = 0
					if ISAWC:CanProperty(ply,ent) then
						ISAWC:StartNetMessage("pickup")
						net.WriteEntity(ent)
						net.SendToServer()
					end
				end
			end
		elseif input.IsKeyDown(invToggleKey) and noOtherUIs and invcooldown < RealTime() then
			invcooldown = RealTime() + 1
			if not (ply:GetActiveWeapon().CW20Weapon and ply:GetActiveWeapon().dt.State == CW_CUSTOMIZE and CW_CUSTOMIZE) then
				if IsValid(ISAWC.reliantwindow) then
					ISAWC.reliantwindow:Close()
				else
					ISAWC.reliantwindow = ISAWC:BuildInventory()
				end
			end
		elseif input.IsKeyDown(invHoldKey) and not (IsValid(ISAWC.TempWindow) and ISAWC.TempWindow:IsVisible()) then
			if IsValid(ISAWC.TempWindow) then
				ISAWC.TempWindow:Show()
				ISAWC.TempWindow:RequestFocus()
			else
				ISAWC.TempWindow = ISAWC:BuildInventory()
			end
		elseif not input.IsKeyDown(invHoldKey) and (IsValid(ISAWC.TempWindow) and ISAWC.TempWindow:IsVisible()) then
			ISAWC.TempWindow:Hide()
			ISAWC.TempWindow:KillFocus()
		end
		if clientTicks < 2400 and not ISAWC.ConHideHintNotifs:GetBool() then
			clientTicks = clientTicks + 1
			if clientTicks == 600 then
				ISAWC:PushNotification(
					string.format(
						"[ISAWC] Hold %s to pick up items.",
						string.upper(language.GetPhrase(input.GetKeyName(useKey) or "none"))
					)
				)
			elseif clientTicks == 800 then
				ISAWC:PushNotification(
					string.format(
						"Press %s or hold %s to open your inventory.",
						string.upper(language.GetPhrase(input.GetKeyName(invToggleKey) or "none")),
						string.upper(language.GetPhrase(input.GetKeyName(invHoldKey) or "none"))
					)
				)
			elseif clientTicks == 1000 then
				ISAWC:PushNotification({"You can also open your inventory in the CONTEXT MENU,", "as well as right-click items from there to pick them up."})
			elseif clientTicks == 1400 then
				ISAWC:PushNotification({"You can change the keys under General Client options in the", "\"ISAWC\" section at the top-right of the SPAWN MENU."})
			elseif clientTicks == 1800 then
				ISAWC:PushNotification({"Alternatively, you can change the ConVars \"isawc_pickup_bind\",", "\"isawc_player_bind\" and \"isawc_player_bindhold\"."})
			elseif clientTicks == 2200 then
				ISAWC:PushNotification("Please note that the server can override your set binds.")
			elseif clientTicks == 2400 then
				ISAWC:PushNotification({"You can turn these hint messages off in the Client options,", "or set \"isawc_hide_hintnotifications\" to 1."})
			end
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
	local inv
	if ply.Base == "isawc_container_base" then
		inv = ply:GetInventory(container)
	else
		inv = ply.ISAWC_Inventory
	end
	if not inv then
		inv = ply.ISAWC_Inventory or {}
		self:Log(string.format("%s grabbed %s without having an inventory!", tostring(ply), tostring(ent)))
	end
	local tpos = ent:GetPos()
	tpos.z = tpos.z+ent:OBBMins().z
	for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
		v.ISAWC_SaveTable = v:GetSaveTable()
		if not duplicator.FindEntityClass(ent:GetClass()) then
			duplicator.RegisterEntityClass(ent:GetClass(),function(ply, data)
				local ent = ents.Create(data.Class)
				if IsValid(ent) then
					duplicator.DoGeneric(ent, data)
					ent:SetCreator(ply)
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
			self.StoredInAltSaveProps[v] = true
		else
			-- clear out inventories to prevent item duplication
			if v.ISAWC_Inventory then
				v.ISAWC_Inventory = {}
			end
			v:Fire("Kill")
		end
	end
	table.insert(inv,dupe)
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
	MenuLabel = "[ISAWC] Pick Up",
	MenuIcon = "icon16/basket_put.png",
	Order = 46,
	Filter = function(self,ent)
		return ISAWC:CanProperty(LocalPlayer(),ent)
	end,
	Action = function(self,ent,trace)
		ISAWC:StartNetMessage("pickup")
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
hook.Add("Initialize","ISAWC",ISAWC.Initialize)
hook.Add("PhysgunPickup","ISAWC",ISAWC.PhysgunPickup)
hook.Add("PhysgunDrop","ISAWC",ISAWC.PhysgunDrop)
hook.Add("PlayerSpawn","ISAWC",ISAWC.PlayerSpawn)
hook.Add("PlayerDeath","ISAWC",ISAWC.PlayerDeath)
hook.Add("player_disconnect","ISAWC",ISAWC.PlayerDisconnect)
hook.Add("ShutDown","ISAWC",ISAWC.PlayerDisconnect)
hook.Add("CanProperty","ISAWC",ISAWC.OldCanProperty)
hook.Add("Tick","ISAWC",ISAWC.Tick)

list.Set("DesktopWindows","Open Inventory",ISAWC.DesktopTable)

if SERVER then
	ISAWC:Log(string.format("All server code successfully initialized in %.2f ms!", (SysTime()-startLoadTime)*1e3))
end
if CLIENT then
	ISAWC:Log(string.format("All client code successfully initialized in %.2f ms!", (SysTime()-startLoadTime)*1e3))
end