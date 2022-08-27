function draw.MultiColoredText(data, font, x, y, xAlign, yAlign)
	local w, h = draw.GetMultiColoredTextSize(data, font)
	
	if xAlign == TEXT_ALIGN_RIGHT then
		x = x - w
	elseif xAlign == TEXT_ALIGN_CENTER then
		x = x - w / 2
	end
	if yAlign == TEXT_ALIGN_BOTTOM then
		y = y - h
	elseif yAlign == TEXT_ALIGN_CENTER then
		y = y - h / 2
	end
	
	surface.SetTextPos(x, y)
	
	for i,v in ipairs(data) do
		if istable(v) then
			surface.SetTextColor(v.r or 255, v.g or 255, v.b or 255, v.a or 255)
		else
			surface.DrawText(tostring(v))
		end
	end
	
	return w, h
end

function draw.GetMultiColoredTextSize(data, font)
	local w, h = 0, 0
	surface.SetFont(font)
	for i,v in ipairs(data) do
		if not istable(v) then
			local dW, dH = surface.GetTextSize(tostring(v))
			w = w + dW
			h = math.max(h, dH)
		end
	end
	return w, h
end

-- originally used in cl_ui.lua, ultimately scrapped since Color values only support integers, which is bad for smooth linear interpolation
--[[function LerpColor(amount, color1, color2)
	return Color(
		Lerp(amount, color1.r, color2.r),
		Lerp(amount, color1.g, color2.g),
		Lerp(amount, color1.b, color2.b),
		Lerp(amount, color1.a, color2.a)
	)
end]]