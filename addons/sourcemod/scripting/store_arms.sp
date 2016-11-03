#pragma semicolon 1

#define PLUGIN_VERSION "1.0.2"

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
ArrayList g_aTeams;

public void OnPluginStart()
{
	g_aArms = new ArrayList(PLATFORM_MAX_PATH);
	g_aTeams = new ArrayList();
	HookEvent("player_spawn", Event_PlayerSpawn);
	Store_RegisterHandler("arms", "arms", Arms_OnMapStart, Arms_Reset, Arms_Config, Arms_Equip, Arms_Remove, true);
}

public void Arms_OnMapStart()
{
	char sModel[PLATFORM_MAX_PATH];
	for (int i = 0; i < g_aArms.Length; i++){
		g_aArms.GetString(i, sModel, sizeof(sModel));
		PrecacheModel(sModel, true);
	}
}

public void Arms_Reset()
{
	g_aArms.Clear();
	g_aTeams.Clear();
}

public bool Arms_Config(Handle &kv, int itemid)
{
	char sModel[PLATFORM_MAX_PATH];
	KvGetString(kv, "model", sModel, sizeof(sModel));
	Store_SetDataIndex(itemid, g_aArms.PushString(sModel));
	g_aTeams.Push(KvGetNum(kv, "team", 0));
	return true;
}

public int Arms_Equip(int client, int itemid)
{
	return g_aTeams.Get(Store_GetDataIndex(itemid));
}

public int Arms_Remove(int client, int itemid)
{
	return g_aTeams.Get(Store_GetDataIndex(itemid));
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int itemid = Store_GetEquippedItem(client, "arms", GetClientTeam(client)-1);
	if(itemid < 0)
	{
		itemid = Store_GetEquippedItem(client, "arms", 0);
		if(itemid < 0)
		 	return Plugin_Continue;
	}
	int iIndex = Store_GetDataIndex(itemid);
	char sModel[PLATFORM_MAX_PATH];
	g_aArms.GetString(iIndex, sModel, sizeof(sModel));
	SetEntPropString(client, Prop_Send, "m_szArmsModel", sModel);
	return Plugin_Continue;
}
