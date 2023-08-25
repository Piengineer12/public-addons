# CCVCCM Notes
Structure of save tables:
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