#pragma semicolon 1

#define PLUGIN_VERSION "1.2.1"

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
	
	int iIndex = Store_GetDataIndex(itemid);
	if(g_aTeams.Get(iIndex)+1 == GetClientTeam(client))
	{
		if(iIndex < 0 || iIndex >= g_aArms.Length)
			return g_aTeams.Get(iIndex);
		char sModel[PLATFORM_MAX_PATH];
		g_aArms.GetString(iIndex, sModel, sizeof(sModel));
		DataPack pack = new DataPack();
		pack.WriteCell(GetClientUserId(client));
		pack.WriteString(sModel);
		SetEntPropString(client, Prop_Send, "m_szArmsModel", sModel);
		CreateTimer(0.15, RemovePlayerWeapon, pack);
	}
	return g_aTeams.Get(iIndex);
}

public Action RemovePlayerWeapon(Handle timer, DataPack datapack)
{
	char sModel[PLATFORM_MAX_PATH];
	
	datapack.Reset();
	int client = GetClientOfUserId(datapack.ReadCell());
	
	datapack.ReadString(sModel, sizeof(sModel));
	
	if(0 < client <= MaxClients && IsClientConnected(client) && IsPlayerAlive(client))
	{
		int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
		if (iWeapon != -1)
		{
			RemovePlayerItem(client, iWeapon);
			DataPack pack = new DataPack();
			pack.WriteCell(iWeapon);
			pack.WriteCell(GetClientUserId(client));
			CreateTimer(0.15, GivePlayerWeapon, pack);
		}
	}
	return Plugin_Stop;
}

public Action GivePlayerWeapon(Handle timer, DataPack pack)
{
	pack.Reset();
	int iWeapon = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	if(0 < client <= MAXPLAYERS && IsClientConnected(client) && IsPlayerAlive(client))
	{
		EquipPlayerWeapon(client, iWeapon);
	}
	return Plugin_Stop;
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
	if(iIndex < 0 || iIndex >= g_aArms.Length)
		return Plugin_Continue;
	char sModel[PLATFORM_MAX_PATH];
	g_aArms.GetString(iIndex, sModel, sizeof(sModel));
	SetEntPropString(client, Prop_Send, "m_szArmsModel", sModel);
	return Plugin_Continue;
}
