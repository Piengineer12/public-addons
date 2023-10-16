InsaneStats:SetDefaultConVarCategory("Point Commander")

InsaneStats:RegisterConVar("pointcmder_enabled", "insanestats_pointcmder_enabled", "0", {
	display = "Fix point_*command", desc = "Causes point_*command entities to work in maps. Note that there already exists other addons that fixes this particular issue.",
	type = InsaneStats.BOOL
})

InsaneStats:RegisterConVar("pointcmder_reportinput", "insanestats_pointcmder_reportinput", "0", {
	display = "Print Received Inputs", desc = "Prints a message into console when an entity receives an input. \z
    If the same entity receives the same input, only the first N times will be printed, unless N is below 0.",
	type = InsaneStats.INT, min = -1, max = 14
})