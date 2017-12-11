# ZephStore-Arms
## Installation
* Get some arm models for csgo.
* Add the arm models to your server and force the client download them.
* Upload the plugin.
* Add a "arms" entry to the store translation.
* Add a config entry to the items.txt of the store.
* After the first plugin load a config will be generated under /cfg/sourcemod/plguin.store_arms.cfg (Should be self explanatory)

## Configuration Parameters
* "model" --> The path to the mdl file of the arm Model.
* "type" --> Must be "arms"
* "team" --> The ingame team. (3 = CT, 2 = T, 0 = both)

## Exampel Config (items.txt)
```
"Store"
{
	"Gloves"
	{
		"Cloud9"
		{
			"model" "models/weapons/eminem/ct_arms_idf_cloud_9.mdl"
			"price" "600"
			"team" "1"
			"type" "arms"
			"unique_id" "gloves_c9"
		}
	}
}
```
