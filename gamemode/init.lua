-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 02/08/15
-- Main serverside logic

AddCSLuaFile( "cl_atmosphere.lua" )
AddCSLuaFile( "cl_buff.lua" )
AddCSLuaFile( "cl_spell.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_controlpoints.lua" )
AddCSLuaFile( "sh_chests.lua" )
AddCSLuaFile( "sh_altar_spawns.lua" )
AddCSLuaFile( "sh_buff.lua" )
AddCSLuaFile( "class/hero.lua" )

local files = file.Find( "gamemodes/dungeoncrawler/gamemode/class/monster_*", "GAME" )
for k, file in pairs( files ) do
	AddCSLuaFile( "class/"..file )
end

local files = file.Find( "gamemodes/dungeoncrawler/gamemode/spells/dc_*", "GAME" )
for k, file in pairs( files ) do
	AddCSLuaFile( "spells/"..file )
end

include( "shared.lua" )
include( "sv_buff.lua" )
include( "sv_spell.lua" )

-- Resource downloads
resource.AddFile( "sound/dungeoncrawler/monster01.wav" )
resource.AddFile( "sound/dungeoncrawler/monster02.wav" )
resource.AddFile( "sound/dungeoncrawler/monster03.wav" )
resource.AddFile( "sound/dungeoncrawler/monster04.wav" )
resource.AddFile( "sound/dungeoncrawler/monster05.wav" )

-- Sends to cl_hud.lua
util.AddNetworkString( "DC_Client_Round" )

local LastRoundInfo = {}
function SendClientRoundInformation( textenum, endtime )
	for k, ply in pairs( player.GetAll() ) do
		if ( ply.MessagesReceived ) then
			ply.MessagesReceived["DC_Client_Round"] = nil
		end
	end

	-- Store last message sent
	LastRoundInfo.Text = textenum
	LastRoundInfo.Time = CurTime() + endtime

	-- Send the round information enum (can be looked up within shared.lua)
	net.Start( "DC_Client_Round" )
		net.WriteFloat( textenum )
		net.WriteFloat( endtime )
	net.Broadcast()

	-- Resend this information if it hasn't been replied to
	if ( not timer.Exists( "DC_Client_Round" ) ) then
		timer.Create( "DC_Client_Round", 0.5, 1, function()
			for k, ply in pairs( player.GetAll() ) do
				if ( ( not ply.MessagesReceived ) or ( not ply.MessagesReceived["DC_Client_Round"] ) ) then
					-- Repeat until the client receives it
					SendClientRoundInformation( LastRoundInfo.Text, LastRoundInfo.Time - CurTime() )
				end
			end
		end )
	end
end
net.Receive( "DC_Client_Round", function( len, ply )
	if ( not ply.MessagesReceived ) then
		ply.MessagesReceived = {}
	end
	ply.MessagesReceived["DC_Client_Round"] = true
end )

function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()
end

function GM:SpawnMapItems()
	-- Remove all trap doors
	local removeent = {
		-- Landebrin Keep
		491,
		492,
		493,
		-- Grilleau Keep
		496,
		209,
		217,
	}
	for k, ent in pairs( removeent ) do
		ents.GetByIndex( ent ):Remove()
	end

	-- Load trigger positions and other data from sh_controlpoints.lua
	if ( self.ControlPoints[game.GetMap()] ) then
		for k, v in pairs( self.ControlPoints[game.GetMap()] ) do
			v.Entity = ents.Create( "dc_trigger_control" )
				v.Entity:SetPos( v.Position )
				v.Entity.StartPos = v.Start
				v.Entity.EndPos = v.End
				v.Entity.ID = k
				v.Entity.ZoneName = v.Title
				v.Entity.Type = v.Type
				v.Entity.CaptureSpeed = v.CaptureSpeed
				if ( v.PrecedingPoint >= 1 ) then
					v.Entity.PrecedingPoint = self.ControlPoints[game.GetMap()][v.PrecedingPoint].Entity
				end
			v.Entity:Spawn()
		end
	end

	-- Load chest locations from sh_chests.lua
	if ( self.Chests[game.GetMap()] ) then
		for k, v in pairs( self.Chests[game.GetMap()] ) do
			v.Entity = ents.Create( v.Type )
				v.Entity:SetPos( v.Position )
				v.Entity:SetAngles( v.Angle )
				v.Entity.PrecedingPoint = v.PrecedingPoint
				v.Entity.Level = v.Level
			v.Entity:Spawn()
		end
	end

	-- Spawn spell altars on the map
	for k, v in pairs( self.AltarSpawns ) do
		v.Entity = ents.Create( "dc_altar" )
			v.Entity:SetPos( v.Position )
			v.Entity:SetAngles( v.Rotation )
		v.Entity:Spawn()
	end
end

function GM:Think()
	self.BaseClass:Think()

	-- Used to update buffs on players, function located within sv_buff.lua
	self:Think_Buff()
end

function GM:PlayerSwitchFlashlight( ply, on )
	return not on
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )

	-- Send captured state of every control point to the new player
	if ( self.ControlPoints[game.GetMap()] ) then
		for k, point in pairs( self.ControlPoints[game.GetMap()] ) do
			if ( point.Entity and IsValid( point.Entity ) ) then
				point.Entity:SendClientInformation_Capture( ply )
			end
		end
	end

	-- Send ghost status to all players
	for m, ply in pairs( player.GetAll() ) do
		for k, v in pairs( player.GetAll() ) do
			SendClientGhostInformation( v, ply )
		end
	end

	-- If last round send info is still valid, send that to the new player
	if ( LastRoundInfo.Time and ( CurTime() < LastRoundInfo.Time ) ) then
		SendClientRoundInformation( LastRoundInfo.Text, LastRoundInfo.Time - CurTime() )
	end

	-- Used to initialize the player buff table, function located within sv_buff.lua
	self:PlayerInitialSpawn_Buff( ply )

	-- Used to initialize the player spell table, function located within sv_spell.lua
	self:PlayerInitialSpawn_Spell( ply )
end

function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )

	-- Reset any buffs affecting the player
	for k, buff in pairs( self.Buffs ) do
		ply:RemoveBuff( k )
	end
	ply:SetMana( 100 )

	-- No players can zoom in this gamemode
	ply:SetCanZoom( false )
end

function GM:PostPlayerDeath( ply )
	-- Remove this player from any trigger zones they were in
	if ( ply.TriggerZone and IsValid( ply.TriggerZone ) ) then
		ply.TriggerZone:RemovePlayer( ply )
	end
end

function GM:PlayerDisconnected( ply )
	self.BaseClass:PlayerDisconnected( ply )

	-- Remove this player from any trigger zones they were in
	if ( ply.TriggerZone and IsValid( ply.TriggerZone ) ) then
		ply.TriggerZone:RemovePlayer( ply )
	end
end

function GM:GetFallDamage( ply, flFallSpeed )
	-- This can be used to flag never to inflict fall damage on a player or to make them invulnerable a specified number of times
	if ( ply.NoFallDamage == -1 ) then return end
	if ( ply.Ghost ) then return end
	if ( ply.NoFallDamage and ( ply.NoFallDamage > 0 ) ) then
		ply.NoFallDamage = ply.NoFallDamage - 1
		return
	end

	if ( self.RealisticFallDamage ) then
		return flFallSpeed / 8
	end

	return 10
end

function GM:CheckEndConditions()
	if ( not self:InRound() ) then return end

	local livingplayers = false
		for k, ply in pairs( player.GetAll() ) do
			if ( ( ply:Team() == TEAM_HERO ) and ( not ply.Ghost ) ) then
				livingplayers = true
			end
		end
	if ( not livingplayers ) then
		self:RoundEndWithResult( TEAM_MONSTER, ROUNDTEXT_WIN_MONSTER )
	end

	if ( self.ControlPoints[game.GetMap()] ) then
		if ( not self.ControlPoints[game.GetMap()][#self.ControlPoints[game.GetMap()]].Entity.MonsterControlled ) then
			self:RoundEndWithResult( TEAM_HERO, ROUNDTEXT_WIN_HERO )
		end
	end
end

-- Overwrite to not respawn all important map items after cleaning up the map
function GM:OnPreRoundStart( num )
	-- Reset round logic
	for k, ply in pairs( player.GetAll() ) do
		ply.Ghost = nil
		ply:SetCustomCollisionCheck( false )
		if ( ply.OldMaterial ) then
			ply:SetMaterial( ply.OldMaterial ) -- Draw visible again
			ply.OldMaterial = nil
		end

		-- Send ghost status to all players
		for k, v in pairs( player.GetAll() ) do
			SendClientGhostInformation( v, ply )
		end

		-- Remove players from any trigger zones they were in
		if ( ply.TriggerZone and IsValid( ply.TriggerZone ) ) then
			ply.TriggerZone:RemovePlayer( ply )
		end

		-- Remove loot from players
		-- Now initialized in the hero class loadout
		ply.LootedSpells = nil
		ply.Spells = {}
	end

	-- Cleanup and then spawn all gamemode map items again (e.g. checkpoints)
	-- NOTE: Must be after other reset logic as some of the resetting requires that the old entities exist
	game.CleanUpMap()
	self:SpawnMapItems()

	-- Send the reset captured state of every control point to every player
	if ( self.ControlPoints[game.GetMap()] ) then
		for k, ply in pairs( player.GetAll() ) do
			for m, point in pairs( self.ControlPoints[game.GetMap()] ) do
				if ( point.Entity and IsValid( point.Entity ) ) then
					point.Entity:SendClientInformation_Capture( ply )
				end
			end
		end
	end

	UTIL_StripAllPlayers()
	UTIL_SpawnAllPlayers()
	UTIL_FreezeAllPlayers()

	SendClientRoundInformation( ROUNDTEXT_PRE, self.RoundPreStartTime )
end

function GM:OnRoundStart( num )
	self.BaseClass:OnRoundStart()

	SendClientRoundInformation( ROUNDTEXT_BEGIN, 3 )
end

function GM:OnRoundResult( result, resulttext )
	team.AddScore( result, 1 )

	SendClientRoundInformation( tonumber( resulttext ), self.RoundPostLength )
end

-- Don't kill players if they are standing on the spawn point, some maps (i.e. rp_harmonti) only have one spawn
-- Also, players will be moved to the appropriate area after spawning
function GM:IsSpawnpointSuitable( ply, spawnpointent, bMakeSuitable )
	local pos = spawnpointent:GetPos()

	-- Note that we're searching the default hull size here for a player in the way of our spawning.
	-- This seems pretty rough, seeing as our player's hull could be different.. but it should do the job
	-- ( HL2DM kills everything within a 128 unit radius )
	local entsinrange = ents.FindInBox( pos + Vector( -16, -16, 0 ), pos + Vector( 16, 16, 72 ) )

	if ( ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED ) then return true end

	local blockers = 0
	for k, v in pairs( entsinrange ) do
		if ( IsValid( v ) && v:GetClass() == "player" && v:Alive() ) then
			blockers = blockers + 1
		end
	end

	if ( blockers > 0 ) then return false end
	return true
end

-- Overwrite base fretta logic here to cap the amount of heroes at 4
function GM:PlayerRequestTeam( ply, teamid )
	if ( teamid == TEAM_HERO ) then
		local count = 0
			for k, v in pairs ( player.GetAll() ) do
				if ( v:Team() == TEAM_HERO ) then
					count = count + 1
				end
			end
		if ( count >= 4 ) then
			ply:ChatPrint( "Heroes team full, spawning as a monster" )
			return self.BaseClass:PlayerRequestTeam( ply, TEAM_MONSTER )
		end
	end

	return self.BaseClass:PlayerRequestTeam( ply, teamid )
end

-- Make a shallow copy of a table (from http://lua-users.org/wiki/CopyTable)
function table.shallowcopy( orig )
    local orig_type = type( orig )
    local copy
    if ( orig_type == "table" ) then
        copy = {}
        for orig_key, orig_value in pairs( orig ) do
            copy[orig_key] = orig_value
        end
	-- Number, string, boolean, etc
    else
        copy = orig
    end
    return copy
end

hook.Add( "PlayerSpawn", "DC_PlayerSpawn_HandsSetup", function( ply )
	ply:SetupHands() -- Create the hands view model and call GM:PlayerSetHandsModel
end )

hook.Add( "PlayerSetHandsModel", "DC_PlayerSetHandsModel_Hands", function( ply, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end )