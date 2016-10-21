#pragma semicolon 1

#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <store>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Store - Arms",
	author = "good_live",
	description = "Buy some arms. lol.",
	version = PLUGIN_VERSION,
	url = "painlessgaming.eu"
};

ArrayList g_aArms;

public void OnPluginStart()
{
	g_aArms = new ArrayList(PLATFORM_MAX_PATH);
	HookEvent("player_spawn", Event_PlayerSpawn);
	Store_RegisterHandler("arms", "arms", Arms_OnMapStart, Arms_Reset, Arms_Config, Arms_Equip, Arms_Remove, true);
}

public void Arms_OnMapStart()
{
	char sModel[PLATFORM_MAX_PATH];
	for (int i = 0; i <= g_aArms.Length; i++){
		g_aArms.GetString(i, sModel, sizeof(sModel));
		PrecacheModel(sModel, true);
	}
}

public void Arms_Reset()
{
	g_aArms.Clear();
}

public bool Arms_Config(Handle &kv, int itemid)
{
	char sModel[PLATFORM_MAX_PATH];
	KvGetString(kv, "model", sModel, sizeof(sModel));
	Store_SetDataIndex(itemid, g_aArms.PushString(sModel));
	return true;
}

public int Arms_Equip(int client, int itemid)
{
	int iIndex = Store_GetDataIndex(itemid);
	char sModel[PLATFORM_MAX_PATH];
	g_aArms.GetString(iIndex, sModel, sizeof(sModel));
	SetEntPropString(client, Prop_Send, "m_szArmsModel", sModel);
	return 0;
}

public int Arms_Remove(int client, int itemid)
{
	return 0;
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int itemid = Store_GetEquippedItem(client, "arms");
	int iIndex = Store_GetDataIndex(itemid);
	char sModel[PLATFORM_MAX_PATH];
	g_aArms.GetString(iIndex, sModel, sizeof(sModel));
	SetEntPropString(client, Prop_Send, "m_szArmsModel", sModel);
	return Plugin_Continue;
}
