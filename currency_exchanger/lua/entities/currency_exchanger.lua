AddCSLuaFile()

ENT.Model 			= "models/props_c17/cashregister01a.mdl"
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Currency Exchanger"
ENT.Author			= "Piengineer"
ENT.Contact			= "http://steamcommunity.com/id/Piengineer12/"
ENT.Purpose			= "Change one currency to another! (may include additional fees)"
ENT.Instructions	= "Press 'Use' to open up the menu."
ENT.Category		= "Currency Exchanger"
ENT.Spawnable		= true
ENT.AdminOnly		= true

if SERVER then
	util.AddNetworkString("OpenCurrencyOptionMenu")
	util.AddNetworkString("OpenCurrencyExchangeMenu")
	util.AddNetworkString("RevalidModel")
end

local SetGetTypeText = [[Defines how the functions work:
0 : ply:CashFunction(cash)
1 : CashFunction(ply,cash)
2 : CashFunction(cash,ply)
3 : var:CashFunction(cash,ply)
4 : ply:CashFunction(var,cash)
5 : CashFunction(var,ply,cash)
6 : CashFunction(var,cash,ply)
7 : var:CashFunction(ply,cash)
8 : ply:CashFunction(cash)
9 : CashFunction(ply,var,cash)
10 : CashFunction(cash,var,ply)
11 : var.CashFunction(cash,ply)
12 : ply:CashFunction(cash,var)
13 : CashFunction(ply,cash,var)
14 : CashFunction(cash,ply,var)
15 : var.CashFunction(ply,cash)
16 : var.CashFunction]]

local currencylib = {
	--[[
	FIELDS:
	
	RequiredGlobalVariable : string
	CurrencyPrefix : string
	CurrencyPrefixVars : table
	CurrencySuffix : string
	CurrencySuffixVars : table
	SetGetType : number
	SetGetTypeOverride : table
	Getter : string
	GetterVar : string
	GetterClient : string
	GetterClientVar : string
	Canner : string
	CannerVar : string
	CannerClient : string
	CannerClientVar : string
	Setter : string
	SetterVar : string
	Adder : string
	AdderVar : string
	Subtracter : string
	SubtracterVar : string
	
	]]
	["DarkRP"]={
		RequiredGlobalVariable = "DarkRP",
		CurrencyPrefix = "%s",
		CurrencyPrefixVars = {"GAMEMODE.Config.currency"},
		SetGetType = 0,
		Canner = "canAfford",
		Adder = "addMoney",
	},
	["Pointshop"]={
		RequiredGlobalVariable = "PS",
		CurrencySuffix = " %s",
		CurrencySuffixVars = {"PS.Config.PointsName"},
		SetGetType = 0,
		Setter = "PS_SetPoints",
		Getter = "PS_GetPoints",
		Adder = "PS_GivePoints",
		Subtracter = "PS_TakePoints"
	},
	["Pointshop Bank"]={
		RequiredGlobalVariable = "PSBanks_StorePoints",
		CurrencySuffix = " %s",
		CurrencySuffixVars = {"PS.Config.PointsName"},
		SetGetType = 6,
		SetGetTypeOverride = {
			GetterClient = 4
		},
		Setter = "PSBanks_StorePoints",
		SetterVar = "PLAYER:SteamID()",
		Getter = "PSBanks_ReadPoints",
		GetterVar = "PLAYER:SteamID()",
		GetterClient = "GetNWInt",
		GetterClientVar = "PSBank"
	},
	["PropPrice"]={
		RequiredGlobalVariable = "PROPPRICE_ACTIVE",
		SetGetType = 0,
		Setter = "PP_SetCash",
		Getter = "PP_GetCash"
	},
	["Currency Addon"]={
		RequiredGlobalVariable = "playerManager",
		CurrencySuffix = " $",
		SetGetType = 3,
		SetGetTypeOverride={
			Getter = 16
		},
		Getter = "money",
		GetterVar = "playerManager.players[game.SinglePlayer() and \"STEAM_0:0:0\" or PLAYER:SteamID()]",
		Adder = "addMoney",
		AdderVar = "playerManager.players[game.SinglePlayer() and \"STEAM_0:0:0\" or PLAYER:SteamID()]",
		Subtracter = "decreaseMoney",
		SubtracterVar = "playerManager.players[game.SinglePlayer() and \"STEAM_0:0:0\" or PLAYER:SteamID()]",
	},
	["YourRP"]={
		RequiredGlobalVariable = "YRP",
		CurrencyPrefix = "%s",
		CurrencyPrefixVars = {"PLAYER:GetNWString(\"text_money_pre\")"},
		CurrencySuffix = "%s",
		CurrencySuffixVars = {"PLAYER:GetNWString(\"text_money_pos\")"},
		SetGetType = 0,
		Setter = "SetMoney",
		Getter = "YRPGetMoney",
		Canner = "canAfford",
		Adder = "addMoney"
	},
	["YourRP (Bank)"]={
		RequiredGlobalVariable = "YRP",
		CurrencyPrefix = "%s",
		CurrencyPrefixVars = {"PLAYER:GetNWString(\"text_money_pre\")"},
		CurrencySuffix = "%s",
		CurrencySuffixVars = {"PLAYER:GetNWString(\"text_money_pos\")"},
		SetGetType = 0,
		Setter = "SetMoneyBank",
		Getter = "YRPGetMoneyBank",
		Canner = "canAffordBank",
		Adder = "addMoneyBank"
	}
}
table.Merge(currencylib,util.JSONToTable(file.Read("currency_definitions.txt") or "") or {})

local function GetCurrencyProperty(name,prop,def)
	return currencylib[name] and currencylib[name][prop] or def
end

local currencyviewmem = {}
local PLAYER = FindMetaTable("Player")

local function GetCurrencyView(name,amount,def)
	if not currencyviewmem[name] then
		local slib = currencylib[name]
		local prefix,suffix = {},{}
		if not slib then return def end
		for k,v in pairs(slib.CurrencyPrefixVars or {}) do
			RunString("local PLAYER = Player("..LocalPlayer():UserID()..");TEMP_VAR = "..v)
			prefix[k] = TEMP_VAR
		end
		for k,v in pairs(slib.CurrencySuffixVars or {}) do
			RunString("local PLAYER = Player("..LocalPlayer():UserID()..");TEMP_VAR = "..v)
			suffix[k] = TEMP_VAR
		end
		if slib.CurrencyPrefix then
			prefix = string.format(slib.CurrencyPrefix,unpack(prefix))
		elseif slib.CurrencySuffix then
			prefix = ""
		else
			prefix = "$"
		end
		if slib.CurrencySuffix then
			suffix = string.format(slib.CurrencySuffix,unpack(suffix))
		else
			suffix = ""
		end
		currencyviewmem[name] = {prefix,suffix}
	end
	return currencyviewmem[name][1]..amount..currencyviewmem[name][2]
end

function PLAYER:InternalUniversalCurrencyFunction(name,func,amount,var)
	local curlib = currencylib[name]
	local funcvar = func.."Var"
	var = var~=nil and var or curlib[funcvar]
	TEMP_VAR = nil
	local err = RunString("local PLAYER = Player("..self:UserID()..");TEMP_VAR = "..tostring(var),"TEMP_VAR_PROCESS",false)
	--print(TEMP_VAR)
	if TEMP_VAR~=nil then
		var = TEMP_VAR
	end
	local typ = curlib.SetGetTypeOverride and curlib.SetGetTypeOverride[func] or curlib.SetGetType
	if typ==0x0 then
		return self[curlib[func]](self,amount)
	elseif typ==0x1 then
		return _G[curlib[func]](self,amount)
	elseif typ==0x2 then
		return _G[curlib[func]](amount,self)
	elseif typ==0x3 then
		return TEMP_VAR[curlib[func]](TEMP_VAR,amount,self)
	elseif typ==0x4 then
		return self[curlib[func]](self,var,amount)
	elseif typ==0x5 then
		return _G[curlib[func]](var,self,amount)
	elseif typ==0x6 then
		return _G[curlib[func]](var,amount,self)
	elseif typ==0x7 then
		return TEMP_VAR[curlib[func]](TEMP_VAR,self,amount)
	elseif typ==0x8 then
		return self[curlib[func]](self,amount)
	elseif typ==0x9 then
		return _G[curlib[func]](self,var,amount)
	elseif typ==0xA then
		return _G[curlib[func]](amount,var,self)
	elseif typ==0xB then
		return TEMP_VAR[curlib[func]](self,amount)
	elseif typ==0xC then
		return self[curlib[func]](self,amount,var)
	elseif typ==0xD then
		return _G[curlib[func]](self,amount,var)
	elseif typ==0xE then
		return _G[curlib[func]](amount,self,var)
	elseif typ==0xF then
		return TEMP_VAR[curlib[func]](amount,self)
	elseif typ==0x10 then
		return TEMP_VAR[curlib[func]]
	else return 0
	end
end

function PLAYER:UniversalCurrencyFunction(name,func,amount,var)
	if not isstring(name) then
		error("bad argument #1 to 'UniversalCurrencyFunction' (string expected, got "..type(name)..")")
	elseif not isstring(func) then
		error("bad argument #2 to 'UniversalCurrencyFunction' (string expected, got "..type(name)..")")
	end
	local libi = currencylib[name]
	if not libi then 
		error("bad argument #1 to 'UniversalCurrencyFunction' (string rejected, invalid currency name)")
	end
	if func == "Get" or func == "Getter" then
		if libi.GetterClient and CLIENT then
			return self:InternalUniversalCurrencyFunction(name,"GetterClient",amount,var)
		elseif libi.Getter then
			return self:InternalUniversalCurrencyFunction(name,"Getter",amount,var)
		end
		error("bad argument #2 to 'UniversalCurrencyFunction' (string rejected, function unavailable)")
	elseif func == "Can" or func == "Canner" then
		if libi.CannerClient and CLIENT then
			return self:InternalUniversalCurrencyFunction(name,"CannerClient",amount,var)
		elseif libi.Canner then
			return self:InternalUniversalCurrencyFunction(name,"Canner",amount,var)
		elseif libi.GetterClient and CLIENT then
			return self:InternalUniversalCurrencyFunction(name,"GetterClient",amount,var)>=amount
		elseif libi.Getter then
			return self:InternalUniversalCurrencyFunction(name,"Getter",amount,var)>=amount
		end
		error("bad argument #2 to 'UniversalCurrencyFunction' (string rejected, function unavailable)")
	elseif func == "Set" or func == "Setter" then
		if libi.Setter then
			return self:InternalUniversalCurrencyFunction(name,"Setter",amount,var)
		elseif libi.Getter then
			local curamt = self:UniversalCurrencyFunction(name,"Get",amount,var)
			if libi.Adder and (amount>=curamt or not libi.Subtracter) then
				return self:InternalUniversalCurrencyFunction(name,"Adder",amount-curamt,var)
			elseif libi.Subtracter then
				return self:InternalUniversalCurrencyFunction(name,"Subtracter",curamt-amount,var)
			end
		end
		error("bad argument #2 to 'UniversalCurrencyFunction' (string rejected, function unavailable)")
	elseif func == "Add" or func == "Adder" then
		if libi.Adder then
			return self:InternalUniversalCurrencyFunction(name,"Adder",amount,var)
		elseif libi.Setter and libi.Getter then
			local curamt = self:UniversalCurrencyFunction(name,"Get",amount,var)
			return self:InternalUniversalCurrencyFunction(name,"Setter",curamt+amount,var)
		elseif libi.Subtracter then
			return self:InternalUniversalCurrencyFunction(name,"Subtracter",-amount,var)
		end
		error("bad argument #2 to 'UniversalCurrencyFunction' (string rejected, function unavailable)")
	elseif func == "Sub" or func == "Subtracter" then
		if libi.Subtracter then
			return self:InternalUniversalCurrencyFunction(name,"Subtracter",amount,var)
		elseif libi.Setter and libi.Getter then
			local curamt = self:UniversalCurrencyFunction(name,"Get",amount,var)
			return self:InternalUniversalCurrencyFunction(name,"Setter",curamt-amount,var)
		elseif libi.Adder then
			return self:InternalUniversalCurrencyFunction(name,"Adder",-amount,var)
		end
		error("bad argument #2 to 'UniversalCurrencyFunction' (string rejected, function unavailable)")
	end
	error("bad argument #2 to 'UniversalCurrencyFunction' (string rejected, invalid function key)")
end

function ENT:SpawnFunction( ply, tr, class )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 30
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 90

	local ent = ents.Create(class)
	ent:SetPos(SpawnPos)
	ent:SetAngles(SpawnAng)
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Locked")
	self:NetworkVar("String",0,"SavedModel")
	self:NetworkVar("String",1,"CurrencyTemplate")
end

function ENT:Initialize()
	if self:GetSavedModel() ~= nil and util.IsValidModel(self:GetSavedModel()) then
		self:SetModel(self:GetSavedModel())
	else
		self:SetModel(self.Model)
	end
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
	end
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then phys:Wake() end
	local data = util.JSONToTable(file.Read("currency_exchanger.txt") or "") or {}
	self.Transactions = data[template]
end

function ENT:Use(activator,ply)
	if IsValid(ply) and ply:IsPlayer() then
		if not self:GetLocked() and ply:IsAdmin() then
			net.Start("OpenCurrencyOptionMenu",true)
			net.WriteEntity(self)
			net.Send(ply)
		elseif self:GetLocked() then
			net.Start("OpenCurrencyOptionMenu",true)
			net.WriteEntity(self)
			net.WriteTable(self.Transactions)
			net.Send(ply)
		end
	end
end

function ENT:Draw()
	self.Entity:DrawModel()
end

-- Client UI

local modelname = ""
local heighty = 24
local color_black_translucent = Color(0,0,0,127)
local color_red = Color(255,0,0,255)
local color_yellow = Color(255,255,0,255)
local color_green = Color(0,255,0,255)
local color_aqua = Color(0,255,255,255)
local color_dark_yellow = Color(127,127,0,255)
local color_dark_green = Color(0,127,0,255)
local color_dark_blue = Color(0,0,127,255)
local color_dark_magenta = Color(127,0,127,255)
local color_semidark_yellow = Color(191,191,0,255)
local color_semidark_blue = Color(0,0,191,255)
local color_semidark_magenta = Color(191,0,191,255)
local nullfunc = function() end
local function CauseNotification(msg)
	notification.AddLegacy(msg,NOTIFY_ERROR,5)
	surface.PlaySound("buttons/button10.wav")
end

net.Receive("OpenCurrencyOptionMenu",function(length,ply)
	local exchanger = net.ReadEntity()
	if CLIENT then
		if not IsValid(exchanger) then return CauseNotification("Exchanger is nonexistent!") end
		if exchanger:GetLocked() then
			
			exchanger.Transactions = net.ReadTable()
			local purchases = {}
			local Main = vgui.Create("DFrame")
			Main:SetSize(ScrW()/2,ScrH()/2)
			Main:Center()
			Main:SetTitle("Currency Exchanger")
			Main:SetDraggable(true)
			Main:SetSizable(false)
			Main:ShowCloseButton(false)
			Main:MakePopup()
			function Main:Paint(w,h)
				draw.RoundedBox(4,0,0,w,h,color_dark_yellow)
				if Main:IsActive() then draw.RoundedBox(4,0,0,w,heighty,color_semidark_yellow) end
			end
			
			local CloseButton = vgui.Create("DButton",Main)
			CloseButton:SetPos(ScrW()/2-heighty,0)
			CloseButton:SetSize(heighty,heighty)
			CloseButton:SetFont("Marlett")
			CloseButton:SetTextColor(color_white)
			CloseButton:SetText("r")
			function CloseButton:DoClick()
				Main:Close()
			end
			CloseButton.Paint = nullfunc
			
			local TellBulk = vgui.Create("DLabel",Main)
			TellBulk:SetText("Hold 'Shift' to purchase x10, 'Ctrl' to purchase x100 and 'Alt' to purchase x10000. Combinations are also allowed (e.g. 'Ctrl'+'Shift' to purchase x1000).")
			TellBulk:SetTextColor(color_white)
			TellBulk:Dock(TOP)
			TellBulk:SetWrap(true)
			
			if LocalPlayer():IsAdmin() then
				local Resetter = vgui.Create("DButton",Main)
				Resetter:Dock(BOTTOM)
				Resetter:SetText("(Admin) Unlock Currency Exchanger")
				Resetter:SetTextColor(color_red)
				function Resetter:DoClick()
					net.Start("OpenCurrencyOptionMenu")
					net.WriteEntity(exchanger)
					net.WriteTable({unlockExchanger=true})
					net.SendToServer()
					Main:Close()
				end
			end
			
			local Checkout = vgui.Create("DButton",Main)
			Checkout:Dock(BOTTOM)
			Checkout:SetText("Proceed to Checkout")
			Checkout:SetTextColor(color_dark_green)
			function Checkout:DoClick()
				
				local ChecPanel = vgui.Create("DFrame")
				ChecPanel:SetSize(ScrW()/3,ScrH()/3)
				ChecPanel:Center()
				ChecPanel:SetTitle("Checkout")
				ChecPanel:SetDraggable(true)
				ChecPanel:SetSizable(false)
				ChecPanel:ShowCloseButton(false)
				ChecPanel:MakePopup()
				local tcost = {}
				function ChecPanel:Paint(w,h)
					if not IsValid(exchanger) then
						if IsValid(Main) then Main:Close() end
						ChecPanel:Close()
						return CauseNotification("Exchanger is nonexistent!")
					end
					table.Empty(tcost)
					local y_di = heighty+26
					draw.RoundedBox(4,0,0,w,h,color_dark_blue)
					if ChecPanel:IsActive() then draw.RoundedBox(4,0,0,w,heighty,color_semidark_blue) end
					draw.SimpleText("These transactions will cost you:","DermaDefault",w/2,heighty+5,color_white,TEXT_ALIGN_CENTER)
					for k,v in pairs(purchases) do
						if v>0 then
							tcost[exchanger.Transactions[k][1]] = (tcost[exchanger.Transactions[k][1]] or 0)+exchanger.Transactions[k][2]*v
						end
					end
					self.IsAffordable = true
					for k,v in pairs(tcost) do
						local canAfford = LocalPlayer():UniversalCurrencyFunction(k,"Can",v)
						if not canAfford then
							self.IsAffordable = nil
						end
						draw.SimpleText(GetCurrencyView(k,v,"<invalid>").." ("..k..")","DermaDefault",w/2,y_di,canAfford and color_green or color_red,TEXT_ALIGN_CENTER)
						y_di = y_di + 13
					end
					y_di = y_di + 13
					draw.SimpleText("Are you sure you want to perform the exchange?","DermaDefault",w/2,y_di,color_yellow,TEXT_ALIGN_CENTER)
				end
				
				local CloseCPanel = vgui.Create("DButton",ChecPanel)
				CloseCPanel:SetPos(ScrW()/3-heighty,0)
				CloseCPanel:SetSize(heighty,heighty)
				CloseCPanel:SetFont("Marlett")
				CloseCPanel:SetTextColor(color_white)
				CloseCPanel:SetText("r")
				function CloseCPanel:DoClick()
					ChecPanel:Close()
				end
				CloseCPanel.Paint = nullfunc
			
				local ConfirmCPanel = vgui.Create("DButton",ChecPanel)
				ConfirmCPanel:Dock(BOTTOM)
				ConfirmCPanel:SetText("Exchange!")
				ConfirmCPanel:SetTextColor(color_dark_green)
				function ConfirmCPanel:DoClick()
					if not ChecPanel.IsAffordable then return CauseNotification("Not enough money!") end
					ChecPanel:Close()
					if not IsValid(exchanger) then
						if IsValid(Main) then Main:Close() end
						return CauseNotification("Exchanger is nonexistent!")
					end
					if not exchanger:GetLocked() then
						if IsValid(Main) then Main:Close() end
						return CauseNotification("Exchanger is unlocked!")
					end
					net.Start("OpenCurrencyOptionMenu")
					net.WriteEntity(exchanger)
					net.WriteTable(purchases)
					net.SendToServer()
					chat.AddText(color_aqua,"Transaction successful!")
				end
				
			end
			
			local CurrencyTableList = vgui.Create("DScrollPanel",Main)
			CurrencyTableList:Dock(FILL)
			CurrencyTableList:DockPadding(5,5,5,5)
			CurrencyTableList:Clear()
			for k,v in ipairs(exchanger.Transactions) do
				
				local Transaction = vgui.Create("DPanel",CurrencyTableList)
				Transaction:DockMargin(0,0,0,5)
				Transaction:SetSize(-1,64)
				Transaction:Dock(TOP)
				Transaction:SetText("")
				function Transaction:Paint(w,h)
					draw.RoundedBox(4,0,0,w,h,color_black_translucent)
					draw.SimpleText("Buying: "..GetCurrencyView(v[1],v[2],"<invalid>").." ("..v[1]..")","DermaLarge")
					draw.SimpleText("Selling: "..GetCurrencyView(v[3],v[4],"<invalid>").." ("..v[3]..")","DermaLarge",0,h,color_green,TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
					if (purchases[k] and purchases[k]>0) then
						draw.SimpleText("Amount Purchased: "..purchases[k],"DermaDefault",w-32,h/2,color_yellow,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
					end
				end
				
				local RightPanel = vgui.Create("DPanel",Transaction)
				RightPanel:SetSize(32,-1)
				RightPanel:Dock(RIGHT)
				RightPanel.Paint = nullfunc
				
				function Transaction:ProcessKeys()
					return ((input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)) and 10 or 1)*
					((input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)) and 100 or 1)*
					((input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)) and 10000 or 1)
				end
				
				local PlusButton = vgui.Create("DImageButton",RightPanel)
				PlusButton:SetSize(32,32)
				PlusButton:Dock(TOP)
				PlusButton:SetImage("icon16/cart_put.png")
				function PlusButton:DoClick()
					local amt = Transaction:ProcessKeys()
					purchases[k] = (purchases[k] or 0) + amt
				end
				PlusButton:SetTooltip("Add to Cart")
				
				local MinusButton = vgui.Create("DImageButton",RightPanel)
				MinusButton:SetSize(32,32)
				MinusButton:Dock(BOTTOM)
				MinusButton:SetImage("icon16/cart_remove.png")
				function MinusButton:DoClick()
					local amt = Transaction:ProcessKeys()
					purchases[k] = math.max((purchases[k] or 0) - amt,0)
				end
				MinusButton:SetTooltip("Remove from Cart")
				
			end
			
		else
			
			exchanger.Transactions = exchanger.Transactions or {}
			local template,CurrencyTableList = exchanger:GetCurrencyTemplate()
			
			local Main = vgui.Create("DFrame")
			Main:SetSize(ScrW()/2,ScrH()/2)
			Main:Center()
			Main:SetTitle("Edit Currency Exchanger")
			Main:SetDraggable(true)
			Main:SetSizable(false)
			Main:ShowCloseButton(false)
			Main:MakePopup()
			function Main:Paint(w,h)
				draw.RoundedBox(4,0,0,w,h,color_dark_yellow)
				if Main:IsActive() then draw.RoundedBox(4,0,0,w,heighty,color_semidark_yellow) end
			end
			
			local CloseButton = vgui.Create("DButton",Main)
			CloseButton:SetPos(ScrW()/2-heighty,0)
			CloseButton:SetSize(heighty,heighty)
			CloseButton:SetFont("Marlett")
			CloseButton:SetTextColor(color_white)
			CloseButton:SetText("r")
			function CloseButton:DoClick()
				Main:Close()
			end
			CloseButton.Paint = nullfunc
			
			local ConfirmButton = vgui.Create("DButton",Main)
			ConfirmButton:Dock(BOTTOM)
			ConfirmButton:SetText("Save Template and Commit Changes")
			ConfirmButton:SetTextColor(color_dark_green)
			function ConfirmButton:DoClick()
				if #template==0 and not Main.hasWarned then
					Main.hasWarned = true
					notification.AddLegacy("You have not specified a unique name!",NOTIFY_GENERIC,10)
					notification.AddLegacy("If you continue, the transactions will not be saved between sessions!",NOTIFY_GENERIC,10)
					surface.PlaySound("ambient/water/drip"..math.random(1,4)..".wav")
					return true
				end
				Main:Close()
				if not IsValid(exchanger) then return CauseNotification("Exchanger is nonexistent!") end
				if not util.IsValidModel(modelname) and modelname~="" then return CauseNotification("Invalid model!") end
				net.Start("OpenCurrencyOptionMenu")
				net.WriteEntity(exchanger)
				net.WriteString(modelname)
				net.WriteString(template)
				net.WriteTable(exchanger.Transactions)
				net.SendToServer()
			end
			
			local AddButton = vgui.Create("DButton",Main)
			AddButton:Dock(BOTTOM)
			AddButton:SetText("Add New Transaction")
			AddButton:SetTextColor(color_dark_blue)
			function AddButton:DoClick(...)
			
				local system1,value1,system2,value2,one_way,index = ...
				
				local TransactionPanel = vgui.Create("DFrame")
				TransactionPanel:SetSize(ScrW()/3,ScrH()/3)
				TransactionPanel:Center()
				TransactionPanel:SetTitle(index and "Edit Transaction" or "Add New Transaction")
				TransactionPanel:SetDraggable(true)
				TransactionPanel:SetSizable(false)
				TransactionPanel:ShowCloseButton(false)
				TransactionPanel:MakePopup()
				function TransactionPanel:Paint(w,h)
					draw.RoundedBox(4,0,0,w,h,color_dark_blue)
					if TransactionPanel:IsActive() then draw.RoundedBox(4,0,0,w,heighty,color_semidark_blue) end
				end
				
				local CloseTPanel = vgui.Create("DButton",TransactionPanel)
				CloseTPanel:SetPos(ScrW()/3-heighty,0)
				CloseTPanel:SetSize(heighty,heighty)
				CloseTPanel:SetFont("Marlett")
				CloseTPanel:SetTextColor(color_white)
				CloseTPanel:SetText("r")
				function CloseTPanel:DoClick()
					TransactionPanel:Close()
				end
				CloseTPanel.Paint = nullfunc
			
				local ConfirmTPanel = vgui.Create("DButton",TransactionPanel)
				ConfirmTPanel:Dock(BOTTOM)
				ConfirmTPanel:SetText(index and "Edit Transaction" or "Add Transaction")
				ConfirmTPanel:SetTextColor(color_dark_green)
				function ConfirmTPanel:DoClick()
					if not system1 then return CauseNotification("Invalid Input Currency!") end
					if not system2 then return CauseNotification("Invalid Output Currency!") end
					if not value1 then return CauseNotification("Invalid Input Value!") end
					if not value2 then return CauseNotification("Invalid Output Value!") end
					TransactionPanel:Close()
					if not IsValid(exchanger) then
						if IsValid(Main) then Main:Close() end
						return CauseNotification("Exchanger is nonexistent!")
					end
					if index then
						table.remove(exchanger.Transactions,index)
						table.insert(exchanger.Transactions,index,{system1,value1,system2,value2})
					else
						table.insert(exchanger.Transactions,{system1,value1,system2,value2})
						if not one_way then
							table.insert(exchanger.Transactions,{system2,value2,system1,value1})
						end
					end
					if IsValid(CurrencyTableList) then
						CurrencyTableList:RebuildTransactions()
					end
				end
				
				local AddCPanel = vgui.Create("DButton",TransactionPanel)
				AddCPanel:Dock(BOTTOM)
				AddCPanel:SetText("Define a different currency system...")
				AddCPanel:SetTextColor(color_dark_blue)
				function AddCPanel:DoClick()
				
					local tableOfEntries = {}
					
					local MainCPanel = vgui.Create("DFrame")
					MainCPanel:SetSize(ScrW()/4,ScrH()/4)
					MainCPanel:Center()
					MainCPanel:SetTitle("Define Currency System")
					MainCPanel:SetDraggable(true)
					MainCPanel:SetSizable(false)
					MainCPanel:ShowCloseButton(false)
					MainCPanel:MakePopup()
					function MainCPanel:Paint(w,h)
						draw.RoundedBox(4,0,0,w,h,color_dark_magenta)
						if MainCPanel:IsActive() then draw.RoundedBox(4,0,0,w,heighty,color_semidark_magenta) end
					end
				
					local CloseCPanel = vgui.Create("DButton",MainCPanel)
					CloseCPanel:SetPos(ScrW()/4-heighty,0)
					CloseCPanel:SetSize(heighty,heighty)
					CloseCPanel:SetFont("Marlett")
					CloseCPanel:SetTextColor(color_white)
					CloseCPanel:SetText("r")
					function CloseCPanel:DoClick()
						MainCPanel:Close()
					end
					CloseCPanel.Paint = nullfunc
					
					local ScrollPanel = vgui.Create("DScrollPanel",MainCPanel)
					ScrollPanel:Dock(FILL)
					function ScrollPanel:AddHelpText(msg)
						local HelpPanel = vgui.Create("DLabel",ScrollPanel)
						HelpPanel:SetText(msg)
						HelpPanel:SetTextColor(color_white)
						HelpPanel:SetWrap(true)
						HelpPanel:SetAutoStretchVertical(true)
						HelpPanel:Dock(TOP)
					end
					function ScrollPanel:AddBlank()
						local BlankPanel = vgui.Create("DPanel",ScrollPanel)
						BlankPanel:SetSize(-1,13)
						BlankPanel:Dock(TOP)
						function BlankPanel:Paint(w,h)
							surface.SetDrawColor(color_black_translucent)
							surface.DrawRect(0,0,w,h)
						end
						function BlankPanel:NetworkToServer()
							net.WriteString(self:GetValue())
						end
					end
					function ScrollPanel:AddEntry(name)
						local Entry = vgui.Create("DTextEntry",ScrollPanel)
						Entry:Dock(TOP)
						Entry.TableKey = name
						table.insert(tableOfEntries,Entry)
					end
				
					ScrollPanel:AddHelpText("Currency Name (MANDATORY)")
					ScrollPanel:AddEntry("CurrencyName")
					ScrollPanel:AddHelpText("This must be the name of the currency system.")
					ScrollPanel:AddBlank()
				
					ScrollPanel:AddHelpText("Required Global Variable")
					ScrollPanel:AddEntry("RequiredGlobalVariable")
					ScrollPanel:AddHelpText("This variable must not return false nor nil for the currency to be detectable by the Currency Exchanger.")
					ScrollPanel:AddBlank()
				
					ScrollPanel:AddHelpText("Currency Prefix")
					ScrollPanel:AddEntry("CurrencyPrefix")
					ScrollPanel:AddHelpText("Appears before the currency value. Used in string.format(<this argument>,...)")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Currency Prefix Variables")
					ScrollPanel:AddEntry("CurrencyPrefixVars")
					ScrollPanel:AddHelpText("Arguments for string.format(Currency Prefix,<these arguments>). The PLAYER variable will refer to the local player. Semicolon (;) delimited.")
					ScrollPanel:AddBlank()
				
					ScrollPanel:AddHelpText("Currency Suffix")
					ScrollPanel:AddEntry("CurrencySuffix")
					ScrollPanel:AddHelpText("Appears after the currency value. Used in string.format(<this argument>,...)")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Currency Suffix Variables")
					ScrollPanel:AddEntry("CurrencySuffixVars")
					ScrollPanel:AddHelpText("Arguments for string.format(Currency Suffix,<these arguments>). The PLAYER variable will refer to the local player. Semicolon (;) delimited.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("SetGet Type (MANDATORY)")
					local Entry = vgui.Create("DNumberWang",ScrollPanel)
					Entry:SetMinMax(0,16)
					Entry:Dock(TOP)
					function Entry:NetworkToServer()
						net.WriteUInt(self:GetValue(),8)
					end
					Entry.TableKey = "SetGetType"
					table.insert(tableOfEntries,Entry)
					ScrollPanel:AddHelpText(SetGetTypeText)
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("SetGet Type Override")
					ScrollPanel:AddEntry("SetGetTypeOverride")
					ScrollPanel:AddHelpText("If some operations have a different SetGet Type, define them here. Format:\nGetter=n,GetterClient=n,Canner=n,CannerClient=n,Setter=n,Adder=n,Subtracter=n\n(n is a number from 0-15)")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Getter Function (MANDATORY if Canner is undefined)")
					ScrollPanel:AddEntry("Getter")
					ScrollPanel:AddHelpText("Name of the function to get the amount of a player's cash.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Getter Function Variable")
					ScrollPanel:AddEntry("GetterVar")
					ScrollPanel:AddHelpText("Variable to pass to var, as seen in SetGet Type. The PLAYER variable is available here (e.g. PLAYER:SteamID()).")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Client Getter Function")
					ScrollPanel:AddEntry("GetterClient")
					ScrollPanel:AddHelpText("If the function is different client-side, define it here.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Client Getter Function Variable")
					ScrollPanel:AddEntry("GetterClientVar")
					ScrollPanel:AddHelpText("If the variable is different client-side, define it here. The PLAYER variable is available here.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Canner Function (MANDATORY if Getter is undefined)")
					ScrollPanel:AddEntry("Canner")
					ScrollPanel:AddHelpText("Name of the function to see if the player can afford the transaction.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Canner Function Variable")
					ScrollPanel:AddEntry("CannerVar")
					ScrollPanel:AddHelpText("Variable to pass to var, as seen in SetGet Type. The PLAYER variable is available here.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Client Canner Function")
					ScrollPanel:AddEntry("CannerClient")
					ScrollPanel:AddHelpText("If the function is different client-side, define it here.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Client Canner Function Variable")
					ScrollPanel:AddEntry("CannerClientVar")
					ScrollPanel:AddHelpText("If the variable is different client-side, define it here. The PLAYER variable is available here.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Setter Function (Requires Getter Function)")
					ScrollPanel:AddEntry("Setter")
					ScrollPanel:AddHelpText("Name of the function to set player's cash.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Setter Function Variable")
					ScrollPanel:AddEntry("SetterVar")
					ScrollPanel:AddHelpText("Variable to pass to var, as seen in SetGet Type. The PLAYER variable is available here.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Adder Function (MANDATORY if Subtracter, Setter and Getter is undefined)")
					ScrollPanel:AddEntry("Adder")
					ScrollPanel:AddHelpText("Name of the function to add player's cash.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Adder Function Variable")
					ScrollPanel:AddEntry("AdderVar")
					ScrollPanel:AddHelpText("Variable to pass to var, as seen in SetGet Type. The PLAYER variable is available here.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Subtracter Function (MANDATORY if Adder, Setter and Getter is undefined)")
					ScrollPanel:AddEntry("Subtracter")
					ScrollPanel:AddHelpText("Name of the function to set player's cash.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("Subtracter Function Variable")
					ScrollPanel:AddEntry("SubtracterVar")
					ScrollPanel:AddHelpText("Variable to pass to var, as seen in SetGet Type. The PLAYER variable is available here.")
					ScrollPanel:AddBlank()
					
					ScrollPanel:AddHelpText("This system will be saved in currency_definitions.txt in the data/ folder.")
			
					local ConfirmCPanel = vgui.Create("DButton",ScrollPanel)
					ConfirmCPanel:Dock(TOP)
					ConfirmCPanel:SetText("Add Currency Definition")
					ConfirmCPanel:SetTextColor(color_dark_green)
					function ConfirmCPanel:DoClick()
						MainCPanel:Close()
						if IsValid(TransactionPanel) then
							TransactionPanel:Close()
						end
						local curtable = {}
						for k,v in pairs(tableOfEntries) do
							if v:GetValue()~="" then
								curtable[v.TableKey] = v:GetValue()
							end
						end
						if not curtable.RequiredGlobalVariable then curtable.RequiredGlobalVariable = "true" end
						if curtable.CurrencyPrefixVars then
							curtable.CurrencyPrefixVars = string.Explode(";",curtable.CurrencyPrefixVars)
						end
						if curtable.CurrencySuffixVars then
							curtable.CurrencySuffixVars = string.Explode(";",curtable.CurrencySuffixVars)
						end
						if curtable.SetGetTypeOverride then
							RunString("TEMP_VAR = {"..curtable.SetGetTypeOverride.."}")
							curtable.SetGetTypeOverride = TEMP_VAR
						end
						local data = util.JSONToTable(file.Read("currency_definitions.txt") or "") or {}
						data[curtable.CurrencyName] = curtable
						file.Write("currency_definitions.txt",util.TableToJSON(data,true))
						currencylib[curtable.CurrencyName] = curtable
						net.Start("OpenCurrencyOptionMenu")
						net.WriteEntity(exchanger)
						net.WriteString("::ADD_CURRENCY")
						net.WriteTable(curtable)
						net.SendToServer()
					end
					
				end
				
				local FirstCurrency = vgui.Create("DComboBox",TransactionPanel)
				FirstCurrency:Dock(TOP)
				FirstCurrency:SetValue("Choose a currency system...")
				for k,v in pairs(currencylib) do
					RunString("TEMP_VAR = nil;TEMP_VAR = "..tostring(v.RequiredGlobalVariable))
					if TEMP_VAR then
						FirstCurrency:AddChoice(k)
					end
				end
				if system1 then
					FirstCurrency:SetValue(system1)
				end
				function FirstCurrency:OnSelect(index,value,data)
					system1 = value
				end
				
				local FirstValue = vgui.Create("DTextEntry",TransactionPanel)
				FirstValue:Dock(TOP)
				FirstValue:SetPlaceholderText("Insert currency system value...")
				FirstValue:SetNumeric(true)
				if value1 then
					FirstValue:SetValue(value1)
				end
				function FirstValue:OnChange()
					value1 = tonumber(self:GetValue())
				end
				
				local ToText = vgui.Create("DLabel",TransactionPanel)
				ToText:SetFont("DermaDefaultBold")
				ToText:SetText("- to -")
				ToText:SetTextColor(color_white)
				ToText:Dock(TOP)
				ToText:SetContentAlignment(8)
				
				local SecondCurrency = vgui.Create("DComboBox",TransactionPanel)
				SecondCurrency:Dock(TOP)
				SecondCurrency:SetValue("Choose a currency system...")
				for k,v in pairs(currencylib) do
					TEMP_VAR = nil
					RunString("TEMP_VAR = "..tostring(v.RequiredGlobalVariable))
					if TEMP_VAR then
						SecondCurrency:AddChoice(k)
					end
				end
				if system2 then
					SecondCurrency:SetValue(system2)
				end
				function SecondCurrency:OnSelect(index,value,data)
					system2 = value
				end
				
				local SecondValue = vgui.Create("DTextEntry",TransactionPanel)
				SecondValue:Dock(TOP)
				SecondValue:SetPlaceholderText("Insert currency system value...")
				SecondValue:SetNumeric(true)
				if value2 then
					SecondValue:SetValue(value2)
				end
				function SecondValue:OnChange()
					value2 = tonumber(self:GetValue())
				end
				
				local ToText = vgui.Create("DLabel",TransactionPanel)
				ToText:SetSize(-1,40)
				ToText:SetText("Note: It is better to use a value ratio (e.g. 5:12) as the player can purchase in bulk.\nThe currency systems shown are based on your currently mounted add-ons.")
				ToText:SetTextColor(color_white)
				ToText:Dock(TOP)
				ToText:SetContentAlignment(8)
				
				local DecimalText = vgui.Create("DLabel",TransactionPanel)
				DecimalText:SetText("Using decimal points in the fields is risky as not all currency systems support decimal points.")
				DecimalText:SetTextColor(color_red)
				DecimalText:Dock(TOP)
				DecimalText:SetContentAlignment(8)
				
				if not index then
					local DualWay = vgui.Create("DCheckBoxLabel",TransactionPanel)
					DualWay:SetText("One-Way (you can use this to create a charging fee system)")
					DualWay:SetTextColor(color_white)
					DualWay:Dock(TOP)
					DualWay:SetContentAlignment(8)
					function DualWay:OnChange(val)
						one_way = val
					end
				end
			end
			
			local UpperRibbon = vgui.Create("DPanel",Main)
			UpperRibbon:SetSize(32,32)
			UpperRibbon:DockMargin(0,0,0,5)
			UpperRibbon:DockPadding(0,0,0,0)
			UpperRibbon:Dock(TOP)
			UpperRibbon.Paint = nullfunc
			
			local SaveTemplate = vgui.Create("DImageButton",UpperRibbon)
			SaveTemplate:SetSize(32,32)
			SaveTemplate:Dock(RIGHT)
			SaveTemplate:SetImage("icon16/disk.png")
			SaveTemplate:SetTooltip("#GameUI_Save")
			function SaveTemplate:DoClick()
				if template=="" then return CauseNotification("Invalid template name!") end
				net.Start("OpenCurrencyOptionMenu")
				net.WriteEntity(exchanger)
				net.WriteString("::SAVE_TRANSACTIONS")
				net.WriteString(template)
				net.WriteTable(exchanger.Transactions)
				net.SendToServer()
				local data = util.JSONToTable(file.Read("currency_exchanger.txt") or "") or {}
				data[template] = exchanger.Transactions
				file.Write("currency_exchanger.txt",util.TableToJSON(data,true))
				chat.AddText(color_aqua,"Transactions saved!")
			end
			
			local LoadTemplate = vgui.Create("DImageButton",UpperRibbon)
			LoadTemplate:SetSize(32,32)
			LoadTemplate:Dock(RIGHT)
			LoadTemplate:SetImage("icon16/folder_page.png")
			LoadTemplate:SetTooltip("#GameUI_Load")
			function LoadTemplate:DoClick()
				if template=="" then return CauseNotification("Invalid template name!") end
				Main:Close()
				net.Start("OpenCurrencyOptionMenu")
				net.WriteEntity(exchanger)
				net.WriteString("::LOAD_TRANSACTIONS")
				net.WriteString(template)
				net.SendToServer()
				local data = util.JSONToTable(file.Read("currency_exchanger.txt") or "") or {}
				exchanger.Transactions = data[template]
				chat.AddText(color_aqua,"Transactions loaded!")
			end
			
			local TemplateEntry = vgui.Create("DTextEntry",UpperRibbon)
			TemplateEntry:SetSize(-1,32)
			TemplateEntry:SetFont("DermaLarge")
			TemplateEntry:SetPlaceholderText("Enter a name (must be unique)")
			TemplateEntry:Dock(FILL)
			TemplateEntry:SetValue(template)
			function TemplateEntry:OnChange()
				template = self:GetValue()
			end
			
			local TemplateText = vgui.Create("DLabel",Main)
			TemplateText:SetFont("DermaDefaultBold")
			TemplateText:SetText("(Currency Exchangers with the same name will have their transactions replaced with these transactions even between maps.)")
			TemplateText:SetTextColor(color_white)
			TemplateText:SetWrap(true)
			TemplateText:SetAutoStretchVertical(true)
			TemplateText:Dock(TOP)
			
			local LowerRibbon = vgui.Create("DPanel",Main)
			LowerRibbon:SetSize(32,32)
			LowerRibbon:DockMargin(0,5,0,0)
			LowerRibbon:DockPadding(0,0,0,0)
			LowerRibbon:Dock(BOTTOM)
			LowerRibbon.Paint = nullfunc
			
			local VerifyModelInd = vgui.Create("DImage",LowerRibbon)
			VerifyModelInd:SetSize(32,32)
			VerifyModelInd:Dock(LEFT)
			VerifyModelInd:SetImage("icon16/tick.png")
			
			local ModelEntry
			local ResetModel = vgui.Create("DImageButton",LowerRibbon)
			ResetModel:SetSize(32,32)
			ResetModel:Dock(RIGHT)
			ResetModel:SetImage("icon16/arrow_refresh.png")
			ResetModel:SetTooltip("Reset")
			function ResetModel:DoClick()
				ModelEntry:SetValue("models/props_c17/cashregister01a.mdl")
				modelname = "models/props_c17/cashregister01a.mdl"
				VerifyModelInd:SetImage("icon16/tick.png")
			end
			
			local VerifyModel = vgui.Create("DImageButton",LowerRibbon)
			VerifyModel:SetSize(32,32)
			VerifyModel:Dock(RIGHT)
			VerifyModel:SetImage("icon16/script_edit.png")
			VerifyModel:SetTooltip("Recheck Model Validity")
			function VerifyModel:DoClick()
				net.Start("RevalidModel",true)
					net.WriteString(modelname)
				net.SendToServer()
				timer.Simple(0.3,function()
					if IsValid(VerifyModelInd) then
						if util.IsValidModel(modelname) or modelname == "" then
							VerifyModelInd:SetImage("icon16/tick.png")
						else
							VerifyModelInd:SetImage("icon16/cross.png")
						end
					end
				end)
			end
			
			ModelEntry = vgui.Create("DTextEntry",LowerRibbon)
			ModelEntry:SetSize(-1,32)
			ModelEntry:SetFont("DermaLarge")
			ModelEntry:SetPlaceholderText("Enter model name (leave blank to not change)")
			ModelEntry:Dock(FILL)
			if #modelname>0 then
				ModelEntry:SetValue(modelname)
				if util.IsValidModel(modelname) then
					VerifyModelInd:SetImage("icon16/tick.png")
				else
					VerifyModelInd:SetImage("icon16/cross.png")
				end
			end
			function ModelEntry:OnChange()
				modelname = self:GetValue()
				if util.IsValidModel(modelname) or #modelname==0 then
					VerifyModelInd:SetImage("icon16/tick.png")
				else
					VerifyModelInd:SetImage("icon16/cross.png")
				end
			end
			
			CurrencyTableList = vgui.Create("DScrollPanel",Main)
			CurrencyTableList:Dock(FILL)
			CurrencyTableList:DockPadding(5,5,5,5)
			function CurrencyTableList:RebuildTransactions()
				self:Clear()
				if not IsValid(exchanger) then Main:Close() return CauseNotification("Exchanger is nonexistent!") end
				for k,v in ipairs(exchanger.Transactions) do
					
					local Transaction = vgui.Create("DButton",self)
					Transaction:DockMargin(0,0,0,5)
					Transaction:SetSize(-1,64)
					Transaction:SetFont("DermaLarge")
					Transaction:Dock(TOP)
					Transaction:SetContentAlignment(7)
					Transaction:SetText("Input: "..GetCurrencyView(v[1],v[2],"<invalid>").." ("..v[1]..")\nOutput: "..GetCurrencyView(v[3],v[4],"<invalid>").." ("..v[3]..")")
					function Transaction:DoClick()
						AddButton:DoClick(v[1],v[2],v[3],v[4],nil,k)
					end
					Transaction:SetTooltip("Edit")
					
					local DeleteTransaction = vgui.Create("DImageButton",Transaction)
					DeleteTransaction:SetSize(32,32)
					DeleteTransaction:DockMargin(16,16,16,16)
					DeleteTransaction:Dock(RIGHT)
					DeleteTransaction:SetImage("icon16/delete.png")
					DeleteTransaction:SetTooltip("#GameUI_Delete")
					function DeleteTransaction:DoClick()
						table.remove(exchanger.Transactions,k)
						CurrencyTableList:RebuildTransactions() -- "self" refers to something else here!
					end
					
					local RightPanel = vgui.Create("DPanel",Transaction)
					RightPanel:SetSize(32,-1)
					RightPanel:Dock(RIGHT)
					RightPanel.Paint = nullfunc
					
					local UpButton = vgui.Create("DImageButton",RightPanel)
					UpButton:SetSize(32,32)
					UpButton:Dock(TOP)
					UpButton:SetImage("icon16/arrow_up.png")
					if k>1 then
						function UpButton:DoClick()
							table.insert(exchanger.Transactions,k-1,table.remove(exchanger.Transactions,k))
							CurrencyTableList:RebuildTransactions()
						end
					end
					UpButton:SetTooltip("Move Up")
					local DownButton = vgui.Create("DImageButton",RightPanel)
					DownButton:SetSize(32,32)
					DownButton:Dock(BOTTOM)
					DownButton:SetImage("icon16/arrow_down.png")
					if k<#exchanger.Transactions then
						function DownButton:DoClick()
							table.insert(exchanger.Transactions,k+1,table.remove(exchanger.Transactions,k))
							CurrencyTableList:RebuildTransactions()
						end
					end
					DownButton:SetTooltip("Move Down")
				end
			end
			CurrencyTableList:RebuildTransactions()
			
			if #exchanger.Transactions==0 then
				local WillyText = vgui.Create("DLabel",CurrencyTableList)
				WillyText:SetFont("DermaDefaultBold")
				WillyText:SetText("There's nothing here at the moment.\nClick on the Add New Transaction button to add a transaction.")
				WillyText:SetTextColor(color_red)
				WillyText:SizeToContentsY()
				WillyText:Dock(TOP)
			end
			
		end
	elseif (IsValid(exchanger) and exchanger:GetLocked()) then
		local purchases = net.ReadTable()
		local cTransactions = {}
		if purchases.unlockExchanger and ply:IsAdmin() then
			return exchanger:SetLocked(false)
		end
		for k,v in pairs(purchases) do
			table.insert(cTransactions,{exchanger.Transactions[k][1],exchanger.Transactions[k][2]*v,exchanger.Transactions[k][3],exchanger.Transactions[k][4]*v})
		end
		for k,v in pairs(cTransactions) do
			if not ply:UniversalCurrencyFunction(v[1],"Can",v[2]) then return end
			ply:UniversalCurrencyFunction(v[1],"Sub",v[2])
			ply:UniversalCurrencyFunction(v[3],"Add",v[4])
		end
	elseif ply:IsAdmin() then
		if not IsValid(exchanger) then return end
		local model = net.ReadString()
		if model=="::ADD_CURRENCY" then
			local curtable = net.ReadTable()
			currencylib[curtable.CurrencyName] = curtable
			local data = util.JSONToTable(file.Read("currency_definitions.txt") or "") or {}
			data[curtable.CurrencyName] = curtable
			return file.Write("currency_definitions.txt",util.TableToJSON(data,true))
		elseif model=="::SAVE_TRANSACTIONS" then
			local template = net.ReadString()
			local data = util.JSONToTable(file.Read("currency_exchanger.txt") or "") or {}
			data[template] = net.ReadTable()
			return file.Write("currency_exchanger.txt",util.TableToJSON(data,true))
		elseif model=="::LOAD_TRANSACTIONS" then
			local template = net.ReadString()
			local data = util.JSONToTable(file.Read("currency_exchanger.txt") or "") or {}
			exchanger.Transactions = data[template]
			return exchanger:SetCurrencyTemplate(template)
		elseif not util.IsValidModel(model) and model~="" then return end
		local template = net.ReadString()
		exchanger.Transactions = net.ReadTable()
		if model~="" then
			exchanger:SetModel(model)
			exchanger:SetSavedModel(model)
			exchanger:PhysicsInit(SOLID_VPHYSICS)
			exchanger:PhysWake()
		end
		exchanger:SetLocked(true)
		if #template>0 then
			exchanger:SetCurrencyTemplate(template)
			local data = util.JSONToTable(file.Read("currency_exchanger.txt") or "") or {}
			data[template] = exchanger.Transactions
			file.Write("currency_exchanger.txt",util.TableToJSON(data,true))
		end
	end
end)

net.Receive("RevalidModel",function(bits,sender)
	if not sender:IsPlayer() or not SERVER then return end
	util.PrecacheModel(net.ReadString())
end)