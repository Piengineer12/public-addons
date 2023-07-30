-- there must be a better way than polluting the global table...
CCVCCM.AddPayloadToNetMessage = (sendData) =>
	local currentType
	for i, sendUnit in ipairs sendData
		if i % 2 == 0
			switch currentType
				when 's'
					net.WriteString sendUnit
		else
			currentType = sendUnit

CCVCCM.ExtractPayloadFromNetMessage = (typeData) =>
    extracted = {}
    for typ in *typeData
        switch typ
            when 's'
                table.insert extracted, net.ReadString!
	extracted
