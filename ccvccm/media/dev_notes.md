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