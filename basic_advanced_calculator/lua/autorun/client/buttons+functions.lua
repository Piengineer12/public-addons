-- Have you ever wanted to see why the buttons and functions are separate?

local xe = 11

-- Functions

local function CalcIndex(x,y)
	return (x+y*xe)+1
end

local function ToggleAC()
	if AdvCalc.ForceInsert and not AdvCalc.ForceInsertOverride then
		AdvCalc.ForceInsert = false
	elseif not AdvCalc.ForceInsert and not AdvCalc.ForceInsertOverride then
		AdvCalc.ForceInsert = true
	end
end

local FunctionList =
[[
	local pi = math.pi
	
	local e = math.exp(1)
	
	local Ans = AdvCalc.Ans
	
	local A = AdvCalc.A
	local B = AdvCalc.B
	local C = AdvCalc.C
	local D = AdvCalc.D
	local E = AdvCalc.E
	local F = AdvCalc.F
	local G = AdvCalc.G
	local H = AdvCalc.H
	local I = AdvCalc.I
	local J = AdvCalc.J
	local K = AdvCalc.K
	local L = AdvCalc.L
	local M = AdvCalc.M
	local N = AdvCalc.N
	local O = AdvCalc.O
	local P = AdvCalc.P
	local Q = AdvCalc.Q
	local R = AdvCalc.R
	local S = AdvCalc.S
	local T = AdvCalc.T
	local U = AdvCalc.U
	local V = AdvCalc.V
	local W = AdvCalc.W
	local X = AdvCalc.X
	local Y = AdvCalc.Y
	local Z = AdvCalc.Z
	
	local nan = math.asin(2)

	local function sqrt(num)
		return math.sqrt(num)
	end

	local function cubrt(num)
		return math.pow(num,1/3)
	end

	local function root(x,y)
		return math.pow(y,1/x)
	end

	local function Round(num,y)
		return math.Round(num,y or 0)
	end

	local function log(x,y)
		if y then
			return math.log(y,x)
		else
			return math.log(x,10)
		end
	end

	local function log10(num)
		return math.log10(num)
	end

	local function ln(num)
		return math.log(num)
	end

	local function sin(num)
		if AdvCalc.AngleMode == "degrees" then
			return math.sin(math.rad(num))
		elseif AdvCalc.AngleMode == "radians" then
			return math.sin(num)
		elseif AdvCalc.AngleMode == "gradians" then
			return math.sin(math.rad(num*9/10))
		end
	end

	local function cos(num)
		if AdvCalc.AngleMode == "degrees" then
			return math.cos(math.rad(num))
		elseif AdvCalc.AngleMode == "radians" then
			return math.cos(num)
		elseif AdvCalc.AngleMode == "gradians" then
			return math.cos(math.rad(num*9/10))
		end
	end

	local function tan(num)
		if AdvCalc.AngleMode == "degrees" then
			return math.tan(math.rad(num))
		elseif AdvCalc.AngleMode == "radians" then
			return math.tan(num)
		elseif AdvCalc.AngleMode == "gradians" then
			return math.tan(math.rad(num*9/10))
		end
	end

	local function asin(num)
		if AdvCalc.AngleMode == "degrees" then
			return math.deg(math.asin(num))
		elseif AdvCalc.AngleMode == "radians" then
			return math.asin(num)
		elseif AdvCalc.AngleMode == "gradians" then
			return math.deg(math.asin(num))*9/10
		end
	end

	local function acos(num)
		if AdvCalc.AngleMode == "degrees" then
			return math.deg(math.acos(num))
		elseif AdvCalc.AngleMode == "radians" then
			return math.acos(num)
		elseif AdvCalc.AngleMode == "gradians" then
			return math.deg(math.acos(num))*9/10
		end
	end

	local function atan(num)
		if AdvCalc.AngleMode == "degrees" then
			return math.deg(math.atan(num))
		elseif AdvCalc.AngleMode == "radians" then
			return math.atan(num)
		elseif AdvCalc.AngleMode == "gradians" then
			return math.deg(math.atan(num))*9/10
		end
	end

	local function sinh(num)
		return math.sinh(num)
	end

	local function cosh(num)
		return math.cosh(num)
	end

	local function tanh(num)
		return math.tanh(num)
	end
	
	local function Floor(num)
		return math.floor(num)
	end
	
	local function Ceil(num)
		return math.ceil(num)
	end
	
	local function SimpsonsRule(func,a,b,n)
	
		if not isfunction(func) then
			func = function(x)
				return x
			end
		end
		a = a or 0
		b = b or math.huge
		n = n and n > 0 and n or 6
		if n > 2147383647 then n = 2147383647 end
	
		-- Wikipedia couldn't help too much, had to refer to another website...
		-- The other website's content was under the GNU Free Documentation License 1.2 ( http://www.gnu.org/licenses/fdl-1.2.html ),
		-- ...so you probably know where I got this:

		local h = (b - a) / n
		local sum1 = func(a + h/2)
		local sum2 = 0

		for i=1,n-1 do
			sum1 = sum1 + func(a + h * i + h/2)
			sum2 = sum2 + func(a + h * i)
		end

		return (h / 6) * (func(a) + func(b) + 4*sum1 + 2*sum2)
		
	end
	
	local function Integral(var,str,a,b,n)
		if not isstring(var) then return nan end
		local dreamer = RunString("AdvCalc.IntegralFunc = function("..var..") return "..str.." end","Shover",false)
		if dreamer then return dreamer end
		return SimpsonsRule(AdvCalc.IntegralFunc,a,b,n)
	end
	
	
	local function fact(num)
		local iter = math.ceil(num)
		local ansf = 1
		if iter ~= num or num < 1 then return SimpsonsRule(function(x) return x^num*math.exp(-x) end,0,1000,6000) end
		if iter == math.huge then return math.huge end
		for i=1,iter do
			ansf = ansf * i
		end
		return ansf
	end
	
	local function Abs(...)
		local _1 = {...}
		local squareds = {}
		local sum = 0
		for k,v in pairs(_1) do
			if isnumber(v) then
				table.insert(squareds,v^2)
			elseif isvector(v) then
				table.insert(squareds,v:LengthSqr())
			end
		end
		for k,v in pairs(squareds) do
			sum = sum + v
		end
		return math.sqrt(sum)
	end
	
	local function Rand(...)
		return math.random(...)
	end
	
	local function Pol(a,b)
		return math.Distance(0,a,b,0)
	end
	
	local function Rec(a,b)
		return a*math.cos(AdvCalc.AngleMode == "degrees" and math.rad(b) or AdvCalc.AngleMode == "radians" and b or math.rad(b*9/10))
	end
	
	local function STORE_INTO(var)
		AdvCalc.VarTarg = var
	end
	
	local function Length(str)
		if isnumber(str) then
			return string.len(tostring(str))
		elseif isstring(str) or istable(str) then
			return table.Count(str)
		elseif isvector(str) then
			return str:Length()
		else
			return nan
		end
	end
	
	local function Lower(str)
		return string.lower(str)
	end
	
	local function Upper(str)
		return string.upper(str)
	end
	
	local function Cross(x,y)
		if isnumber(x) or isnumber(y) then
			return x*y
		elseif isvector(x) and isvector(y) then
			local Ans = x:Cross(y)
			return Ans
		else
			return nan
		end
	end
	
	local function Dot(x,y)
		if isnumber(x) or isnumber(y) then
			return x*y
		elseif isvector(x) and isvector(y) then
			local Ans = x:Dot(y)
			return Ans
		else
			return nan
		end
	end
	
	local function Normalize(vec)
		return vec:GetNormalized()
	end
	
	local function Permutations(n,r)
		return fact(n) / fact(n-r)
	end
	
	local function Combinations(n,r)
		return fact(n) / fact(r) / fact(n-r)
	end
	
	local function Graph(var,str,minv,maxv)
		if not isstring(var) then return math.asin(2) end
		local dreamer = RunString("AdvCalc.GraphFunc = function("..var..") return "..str.." end","Shover",false)
		if dreamer then return dreamer end
		minv = minv or -10
		maxv = maxv or 10
		if minv > maxv then
			minv,maxv = maxv,minv
		elseif minv == maxv then
			minv = minv - 0.0000001
			maxv = maxv + 0.0000001
		end
		AdvCalcDrawGraph(minv,maxv,AdvCalc.GraphFunc,str)
		return nil
	end
]]

local function AdvCalcFunc()
	local brackets = 0
	for _1 in string.gmatch(table.concat(AdvCalc.typed),"%(") do
		brackets = brackets + 1
	end
	for _1 in string.gmatch(table.concat(AdvCalc.typed),"%)") do
		brackets = brackets - 1
	end
	local extra = 0
	if string.find(table.concat(AdvCalc.typed),"->\"",1,false) then
		extra = 1
	else
		extra = 0
	end
	if table.concat(AdvCalc.typed) == "" then AdvCalc.func = "Ans" end
	local processor = table.concat(AdvCalc.typed) ~= "" and table.concat(AdvCalc.typed) or "AdvCalc.Ans"
	processor = string.Replace(processor,"->\"",";STORE_INTO(\"")
	processor = FunctionList.."AdvCalc.Ans = "..processor..(AdvCalc.ForceInsert and brackets > 0 and string.rep(")",brackets) or "")..(extra > 0 and string.rep(")",extra) or "")..AdvCalc.Posttyped
	local msg = RunString(processor,"Calc",false)
	AdvCalc.AnsDisp = tostring(AdvCalc.Ans)
	if ismatrix(AdvCalc.Ans) then
		AdvCalc.AnsDisp = util.TableToJSON(AdvCalc.Ans:ToTable())
	elseif istable(AdvCalc.Ans) then
		AdvCalc.AnsDisp = util.TableToJSON(AdvCalc.Ans)
	end
	if msg then
		AdvCalc.func = msg
		AdvCalc.AnsDisp = "Syntax Error"
	end
	if AdvCalc.Ans == math.huge or AdvCalc.Ans == -math.huge or AdvCalc.AnsDisp == "nan" then
		AdvCalc.AnsDisp = "Math Error"
	end
	if AdvCalc.VarTarg then
		local msg2 = RunString((#AdvCalc.VarTarg <= 1 and "AdvCalc." or "")..AdvCalc.VarTarg.."=AdvCalc.Ans","STORE_INTO",false)
		if msg2 then chat.AddText(Color(255,0,0),msg2) end
		AdvCalc.VarTarg = nil
	end
	AdvCalc.inspos = #AdvCalc.typed + 1
	AdvCalc.History[#AdvCalc.History+1] = AdvCalc.typed
	AdvCalc.Historyi = #AdvCalc.History + 1
end

-- Nightmarish Buttons

CButtonTable = 
{
	[CalcIndex(6,2)] = 
	{
		Text = "1",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(7,2)] = 
	{
		Text = "2",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(8,2)] = 
	{
		Text = "3",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(6,3)] = 
	{
		Text = "4",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(7,3)] = 
	{
		Text = "5",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(8,3)] = 
	{
		Text = "6",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(6,4)] = 
	{
		Text = "7",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(7,4)] = 
	{
		Text = "8",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(8,4)] = 
	{
		Text = "9",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(6,5)] = 
	{
		Text = "0",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(7,5)] = 
	{
		Text = ".",
		ButtonType = "number",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(8,5)] = 
	{
		Text = "EXP",
		FuncText = "*10^",
		ButtonType = "pad if null",
		DispColor = 2,
		TextColor = 16
	},
	[CalcIndex(7,1)] = 
	{
		Text = "C",
		DispColor = 10,
		RunFunction = function()
			if AdvCalc.Posttyped ~= "" then
				AdvCalc.Posttyped = ""
			elseif CheckAdvCSyntax("%d") then
				local sec = 0
				while CheckAdvCSyntax("%d") do
					AdvCalc.inspos = AdvCalc.inspos - 1
					table.remove(AdvCalc.typed,AdvCalc.inspos)
					sec = sec + 1
					if sec > 1000 then ErrorNoHalt("'While' loop unterminated"); break end
				end
			elseif CheckAdvCSyntax("%a") then
				local sec = 0
				while CheckAdvCSyntax("%a") do
					AdvCalc.inspos = AdvCalc.inspos - 1
					table.remove(AdvCalc.typed,AdvCalc.inspos)
					sec = sec + 1
					if sec > 1000 then ErrorNoHalt("'While' loop unterminated"); break end
				end
			elseif CheckAdvCSyntax("\"") then
				AdvCalc.inspos = AdvCalc.inspos - 1
				table.remove(AdvCalc.typed,AdvCalc.inspos)
				ToggleAC()
			elseif not CheckAdvCSyntax(nil) then
				AdvCalc.inspos = AdvCalc.inspos - 1
				table.remove(AdvCalc.typed,AdvCalc.inspos)
			end
			AdvCalc.func = table.concat(AdvCalc.typed)
		end
	},
	[CalcIndex(8,1)] = 
	{
		Text = "CE",
		DispColor = 10,
		RunFunction = function()
			if not AdvCalc.ForceInsert and not AdvCalc.ForceInsertOverride then
				AdvCalc.ForceInsert = true
			end
			AdvCalc.inspos = 1
			AdvCalc.typed = {}
			AdvCalc.func = ""
			AdvCalc.AnsDisp = "0"
			AdvCalc.Posttyped = ""
		end
	},
	[CalcIndex(9,1)] = 
	{
		Text = "MemCl",
		DispColor = 10,
		RunFunction = function()
			Derma_Query("Are you sure?","Confirm Memory Clear","Yes",function()
				local oldc = AdvCalc.Colors
				local flst = FunctionList
				AdvCalc = {
					Ans =  0,
					A = 0,
					B = 0,
					C = 0,
					D = 0,
					E = 0,
					F = 0,
					G = 0,
					H = 0,
					I = 0,
					J = 0,
					K = 0,
					L = 0,
					M = 0,
					N = 0,
					O = 0,
					P = 0,
					Q = 0,
					R = 0,
					S = 0,
					T = 0,
					U = 0,
					V = 0,
					W = 0,
					X = 0,
					Y = 0,
					Z = 0,
					func = "",
					AnsDisp = "0",
					typed = {},
					Posttyped = "",
					Alt = false,
					Alpha = false,
					AngleMode = "degrees",
					ForceInsert = true,
					DigitMode = 10,
					inspos = 1,
					History = {},
					Historyi = 1,

					Colors = oldc,
					FunctionList = flst,

					Translations = {
						[1]="Functions",
						[2]="Numbers",
						[3]="Operations",
						[4]="Equators/Solvants",
						[5]="Shift/Alpha Toggler",
						[6]="Anglizer",
						[7]="Autocorrection Toggler",
						[8]="Arrows",
						[9]="Memory Operators",
						[10]="Clearing Operators",
						[11]="Alternate Functions",
						[12]="Variables",
						[13]="Toggled Shift and Alpha",
						[14]="Alternate Alpha Functions",
						[15]="Backspace",
						[16]="Black Text",
						[17]="White Text",
						[18]="Non-rainbow Options",
						[19]="Screen",
						[20]="Screen Text",
						[21]="Graph Line",
						[22]="Graph Debug Text",
						[23]="Graph X-Axis",
						[24]="Graph Y-Axis"
					}
				}
			end,"No")
		end
	},
	[CalcIndex(10,1)] = 
	{
		Text = "<--",
		DispColor = 15,
		RunFunction = function()
			if CheckAdvCSyntax("\"") then
				ToggleAC()
			end
			AdvCalc.inspos = math.max(AdvCalc.inspos - 1,1)
			table.remove(AdvCalc.typed,AdvCalc.inspos)
			AdvCalc.func = table.concat(AdvCalc.typed)
		end
	},
	[CalcIndex(6,0)] = 
	{
		Text = "M+",
		DispColor = 9,
		RunFunction = function()
			AdvCalc.Posttyped = ";AdvCalc.M=AdvCalc.M+AdvCalc.Ans"
			AdvCalcFunc()
			AdvCalc.func = AdvCalc.func.."M+"
			AdvCalc.typed = {}
			AdvCalc.Posttyped = ""
			AdvCalc.inspos = 1
		end
	},
	[CalcIndex(7,0)] = 
	{
		Text = "M-",
		DispColor = 9,
		RunFunction = function()
			AdvCalc.Posttyped = ";AdvCalc.M=AdvCalc.M-AdvCalc.Ans"
			AdvCalcFunc()
			AdvCalc.func = AdvCalc.func.."M-"
			AdvCalc.typed = {}
			AdvCalc.Posttyped = ""
			AdvCalc.inspos = 1
		end
	},
	[CalcIndex(8,0)] = 
	{
		Text = "MR",
		FuncText = "M",
		DispColor = 9,
		ButtonType = "var"
	},
	[CalcIndex(9,0)] = 
	{
		Text = "MC",
		DispColor = 9,
		RunFunction = function()
			AdvCalc.typed = {}
			AdvCalc.Posttyped = "-AdvCalc.Ans;AdvCalc.M=0"
			AdvCalcFunc()
			AdvCalc.func = "MC"
			AdvCalc.Posttyped = ""
			AdvCalc.inspos = 1
		end
	},
	[CalcIndex(9,2)] = 
	{
		Text = "+",
		ButtonType = "operand",
		DispColor = 3
	},
	[CalcIndex(10,2)] = 
	{
		Text = "-",
		ButtonType = "negate",
		DispColor = 3
	},
	[CalcIndex(9,3)] = 
	{
		Text = "x",
		FuncText = "*",
		ButtonType = "pad if null",
		DispColor = 3
	},
	[CalcIndex(10,3)] = 
	{
		Text = "/",
		ButtonType = "pad if null",
		DispColor = 3
	},
	[CalcIndex(9,4)] = 
	{
		Text = "Mod",
		FuncText = "%",
		ButtonType = "pad if null",
		DispColor = 3
	},
	[CalcIndex(10,4)] = 
	{
		Text = "Round",
		FuncText = "Round(",
		ButtonType = "func",
		DispColor = 3
	},
	[CalcIndex(4,1)] = 
	{
		Text = "<",
		DispColor = 8,
		RunFunction = function()
			AdvCalc.inspos = math.max(AdvCalc.inspos - 1,1)
			AdvCalc.func = table.concat(AdvCalc.typed)
		end
	},
	[CalcIndex(6,1)] = 
	{
		Text = ">",
		DispColor = 8,
		RunFunction = function()
			AdvCalc.inspos = math.min(AdvCalc.inspos + 1,#AdvCalc.typed + 1)
			AdvCalc.func = table.concat(AdvCalc.typed)
		end
	},
	[CalcIndex(5,0)] = 
	{
		Text = "^",
		DispColor = 8,
		RunFunction = function()
			AdvCalc.Historyi = math.max(AdvCalc.Historyi - 1,1)
			if AdvCalc.History[AdvCalc.Historyi] then
				AdvCalc.typed = AdvCalc.History[AdvCalc.Historyi]
				AdvCalc.func = table.concat(AdvCalc.typed)
				AdvCalc.inspos = #AdvCalc.History[AdvCalc.Historyi] + 1
			end
		end
	},
	[CalcIndex(5,1)] = 
	{
		Text = "v",
		DispColor = 8,
		RunFunction = function()
			AdvCalc.Historyi = math.min(AdvCalc.Historyi + 1,#AdvCalc.History)
			if AdvCalc.History[AdvCalc.Historyi] then
				AdvCalc.typed = AdvCalc.History[AdvCalc.Historyi]
				AdvCalc.func = table.concat(AdvCalc.typed)
				AdvCalc.inspos = #AdvCalc.History[AdvCalc.Historyi] + 1
			end
		end
	},
	[CalcIndex(10,0)] = 
	{
		Text = "Colors",
		DispColor = 18,
		RainbowColors = true,
		RunFunction = function()
			ShowAdvCColorMenu()
		end
	},
	[CalcIndex(4,0)] = 
	{
		Text = "Options",
		DispColor = 18,
		RainbowColors = true,
		RunFunction = function()
			ShowAdvCOptionMenu()
		end
	},
	[CalcIndex(0,0)] = 
	{
		Text = "SHIFT",
		TextColor = 16,
		DispColor = 5,
		AltDispColor = 13,
		RunFunction = function()
			AdvCalc.Alt = true
		end,
		RunAltFunction = function()
			AdvCalc.Alt = false
		end,
		DisableAutoRelease = true
	},
	[CalcIndex(1,0)] = 
	{
		Text = "ALPHA",
		TextColor = 16,
		DispColor = 5,
		AlphaDispColor = 13,
		RunFunction = function()
			AdvCalc.Alpha = true
		end,
		RunAlphaFunction = function()
			AdvCalc.Alpha = false
		end,
		DisableAutoRelease = true
	},
	[CalcIndex(2,0)] = 
	{
		TextColor = 16,
		DispColor = 6,
		Anglizer = true,
		RunFunction = function()
			if AdvCalc.AngleMode == "degrees" then
				AdvCalc.AngleMode = "radians"
			elseif AdvCalc.AngleMode == "radians" then
				AdvCalc.AngleMode = "gradians"
			else
				AdvCalc.AngleMode = "degrees"
			end
		end
	},
	[CalcIndex(3,0)] = 
	{
		Text = "NoAuto",
		TextColor = 16,
		DispColor = 7,
		RunFunction = function()
			if AdvCalc.ForceInsertOverride then
				AdvCalc.ForceInsert = true
				AdvCalc.ForceInsertOverride = false
				surface.PlaySound("buttons/button17.wav")
				chat.AddText(Color(0,255,0),"Auto-correction enabled")
			else
				AdvCalc.ForceInsert = false
				surface.PlaySound("buttons/button18.wav")
				chat.AddText(Color(255,0,0),"Auto-correction disabled")
				AdvCalc.ForceInsertOverride = true
			end
		end
	},
	[CalcIndex(0,1)] = 
	{
		Text = "(",
		ButtonType = "func",
		AlphaText = "A",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "\"",
		AltAlphaDispColor = 14,
		RunAltAlphaFunction = function()
			ToggleAC()
			table.insert(AdvCalc.typed,AdvCalc.inspos,"\"")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end
	},
	[CalcIndex(1,1)] = 
	{
		Text = ")",
		ButtonType = "raw",
		AlphaText = "B",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "Length",
		FuncAltAlphaText = "Length(",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "func"
	},
	[CalcIndex(2,1)] = 
	{
		Text = "^2",
		AltText = "^3",
		ButtonType = "pad if null",
		AltDispColor = 11,
		AlphaText = "C",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "{",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "func"
	},
	[CalcIndex(3,1)] = 
	{
		Text = "sqrt",
		FuncText = "sqrt(",
		AltText = "cubrt",
		FuncAltText = "cubrt(",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "D",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "}",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "raw"
	},
	[CalcIndex(0,2)] = 
	{
		Text = "^",
		ButtonType = "pad if null",
		AlphaText = "E",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "Vector",
		FuncAltAlphaText = "Vector(",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "func"
	},
	[CalcIndex(1,2)] = 
	{
		Text = "logX,Y",
		FuncText = "log(",
		AltText = "rootX,Y",
		FuncAltText = "root(",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "F",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "Normal",
		FuncAltAlphaText = "Normalize(",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "func"
	},
	[CalcIndex(2,2)] = 
	{
		Text = "log10",
		FuncText = "log10(",
		AltText = "10^",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "G",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "[",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "raw"
	},
	[CalcIndex(3,2)] = 
	{
		Text = "ln",
		FuncText = "ln(",
		AltText = "e^",
		FuncAltText = "e^",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "H",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "]",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "raw"
	},
	[CalcIndex(4,2)] = 
	{
		Text = ",",
		ButtonType = "raw",
		AlphaText = "I",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "..",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "space if num"
	},
	[CalcIndex(5,2)] = 
	{
		Text = "1/x",
		FuncText = "1/",
		AltText = "x^-1",
		FuncAltText = "^-1",
		ButtonType = "var",
		ButtonTypeAlt = "operand",
		AltDispColor = 11,
		AlphaText = "J",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = ":subS,E",
		FuncAltAlphaText = ":sub(",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "space if num"
	},
	[CalcIndex(0,3)] = 
	{
		Text = "(-)",
		FuncText = "-",  -- *Literally* the same meaning, sorry guys :\
		ButtonType = "negate",
		AlphaText = "K",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "<",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "operand"
	},
	[CalcIndex(1,3)] = 
	{
		Text = "sin",
		FuncText = "sin(",
		AltText = "asin",
		FuncAltText = "asin(",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "L",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = ">",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "operand"
	},
	[CalcIndex(2,3)] = 
	{
		Text = "cos",
		FuncText = "cos(",
		AltText = "acos",
		FuncAltText = "acos(",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "M",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "not(",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "raw"
	},
	[CalcIndex(3,3)] = 
	{
		Text = "tan",
		FuncText = "tan(",
		AltText = "atan",
		FuncAltText = "atan(",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "N",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "==",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "operand"
	},
	[CalcIndex(4,3)] = 
	{
		Text = "pi",
		AltText = "2*pi",
		ButtonType = "var",
		AltDispColor = 11,
		AlphaText = "O",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "<=",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "operand"
	},
	[CalcIndex(5,3)] = 
	{
		Text = "e",
		AltText = "1/e",
		ButtonType = "var",
		AltDispColor = 11,
		AlphaText = "P",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = ">=",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "operand"
	},
	[CalcIndex(0,4)] = 
	{
		Text = "Floor",
		FuncText = "Floor(",
		AltText = "Ceil",
		FuncAltText = "Ceil(",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "Q",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = " and ",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "pad if null"
	},
	[CalcIndex(1,4)] = 
	{
		Text = "sinh",
		FuncText = "sinh(",
		ButtonType = "func",
		AlphaText = "R",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = " or ",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "pad if null"
	},
	[CalcIndex(2,4)] = 
	{
		Text = "cosh",
		FuncText = "cosh(",
		ButtonType = "func",
		AlphaText = "S",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "true",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "var"
	},
	[CalcIndex(3,4)] = 
	{
		Text = "tanh",
		FuncText = "tanh(",
		ButtonType = "func",
		AlphaText = "T",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "false",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "var"
	},
	[CalcIndex(4,4)] = 
	{
		Text = "Ran#",
		FuncText = "Rand(",
		ButtonType = "func",
		AlphaText = "U",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "nil",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "var"
	},
	[CalcIndex(5,4)] = 
	{
		Text = "Abs",
		FuncText = "Abs(",
		ButtonType = "func",
		AlphaText = "V",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "Key:Val",
		FuncAltAlphaText = "=",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "pad if null"
	},
	[CalcIndex(0,5)] = 
	{
		Text = "n!(",
		FuncText = "fact(",
		ButtonType = "func",
		AlphaText = "W",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "Cross",
		FuncAltAlphaText = "Cross(",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "func"
	},
	[CalcIndex(1,5)] = 
	{
		Text = "Pol(",
		AltText = "Rec(",
		ButtonType = "func",
		AltDispColor = 11,
		AlphaText = "X",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "Dot",
		FuncAltAlphaText = "Dot(",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "func"
	},
	[CalcIndex(2,5)] = 
	{
		Text = "PrmN,R",
		FuncText = "Permutations(",
		AltText = "CbnN,R",
		FuncAltText = "Combinations(",
		AltDispColor = 11,
		AlphaText = "Y",
		ButtonTypeAlpha = "var",
		AlphaDispColor = 12,
		AltAlphaText = "NumX,B",
		FuncAltAlphaText = "tonumber(",
		AltAlphaDispColor = 14,
		ButtonTypeAltAlpha = "func"
	},
	[CalcIndex(3,5)] = 
	{
		Text = "Itgrl(",
		RunFunction = function()
			ToggleAC()
			table.insert(AdvCalc.typed,AdvCalc.inspos,"Integral(\"")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end,
		AlphaText = "Z",
		RunAlphaFunction = function()
			table.insert(AdvCalc.typed,AdvCalc.inspos,"Z")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end,
		AlphaDispColor = 12,
		AltAlphaText = "[space]",
		RunAltAlphaFunction = function()
			table.insert(AdvCalc.typed,AdvCalc.inspos," ")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end,
		AltAlphaDispColor = 14
	},
	[CalcIndex(4,5)] = 
	{
		Text = "Graph(",
		RunFunction = function()
			ToggleAC()
			table.insert(AdvCalc.typed,AdvCalc.inspos,"Graph(\"")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end,
		AlphaText = "Lower",
		RunAlphaFunction = function()
			table.insert(AdvCalc.typed,AdvCalc.inspos,"Lower(")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end,
		AlphaDispColor = 12,
		AltAlphaText = "Upper",
		RunAltAlphaFunction = function()
			table.insert(AdvCalc.typed,AdvCalc.inspos,"Upper(")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end,
		AltAlphaDispColor = 14
	},
	[CalcIndex(5,5)] = 
	{
		Text = "SavVars",
		RunFunction = function()
			local current = SysTime()
			chat.AddText(Color(255,255,0),"Saving...")
			local vars = {}
			vars.A = AdvCalc.A
			vars.B = AdvCalc.B
			vars.C = AdvCalc.C
			vars.D = AdvCalc.D
			vars.E = AdvCalc.E
			vars.F = AdvCalc.F
			vars.G = AdvCalc.G
			vars.H = AdvCalc.H
			vars.I = AdvCalc.I
			vars.J = AdvCalc.J
			vars.K = AdvCalc.K
			vars.L = AdvCalc.L
			vars.M = AdvCalc.M
			vars.N = AdvCalc.N
			vars.O = AdvCalc.O
			vars.P = AdvCalc.P
			vars.Q = AdvCalc.Q
			vars.R = AdvCalc.R
			vars.S = AdvCalc.S
			vars.T = AdvCalc.T
			vars.U = AdvCalc.U
			vars.V = AdvCalc.V
			vars.W = AdvCalc.W
			vars.X = AdvCalc.X
			vars.Y = AdvCalc.Y
			vars.Z = AdvCalc.Z
			file.Write('advcalcvarvals.txt', util.TableToJSON(vars,true))
			chat.AddText(Color(0,255,0),"Finished in "..math.Round(SysTime()-current,6).."s!")
		end,
		AltText = "LodVars",
		AltDispColor = 11,
		RunAltFunction = function()
			local current = SysTime()
			chat.AddText(Color(255,0,255),"Loading...")
			if file.Exists('advcalcvarvals.txt', 'DATA') then
				table.Merge(AdvCalc,util.JSONToTable(file.Read('advcalcvarvals.txt','DATA')))
				chat.AddText(Color(0,255,0),"Finished in "..math.Round(SysTime()-current,6).."s!")
			else
				chat.AddText(Color(255,0,0),"Load Failed.")
			end
		end,
		AlphaText = "Store",
		AlphaDispColor = 12,
		RunAlphaFunction = function()
			ToggleAC()
			table.insert(AdvCalc.typed,AdvCalc.inspos,"->\"")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end,
		AltAlphaText = "\\",
		AltAlphaDispColor = 14,
		RunAltAlphaFunction = function()
			table.insert(AdvCalc.typed,AdvCalc.inspos,"\\")
			AdvCalc.inspos = AdvCalc.inspos + 1
			AdvCalc.func = table.concat(AdvCalc.typed)
		end
	},
	[CalcIndex(9,5)] = 
	{
		Text = "Ans",
		ButtonType = "var",
		DispColor = 4,
		TextColor = 16
	},
	[CalcIndex(10,5)] = 
	{
		Text = "=",
		DispColor = 4,
		TextColor = 16,
		RunFunction = function()
			AdvCalc.AnsDisp = "Processing..."
			AdvCalcFunc()
		end
	}
}