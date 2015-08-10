-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 02/08/15
-- Main serverside logic

AddCSLuaFile( "cl_atmosphere.lua" )
AddCSLuaFile( "cl_buff.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_controlpoints.lua" )
AddCSLuaFile( "sh_altar_spawns.lua" )
AddCSLuaFile( "sh_buff.lua" )
AddCSLuaFile( "class/hero.lua" )
AddCSLuaFile( "class/monster_undead.lua" )
AddCSLuaFile( "class/monster_shaman.lua" )

include( "shared.lua" )
include( "sv_buff.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()
end

function GM:SpawnMapItems()
	-- Load trigger positions and other data from sh_controlpoints.lua
	for k, v in pairs( self.ControlPoints ) do
		v.Entity = ents.Create( "dc_trigger_control" )
			v.Entity:SetPos( v.Position )
			v.Entity.StartPos = v.Start
			v.Entity.EndPos = v.End
			v.Entity.ID = k
			v.Entity.ZoneName = v.Title
			v.Entity.Type = v.Type
			v.Entity.CaptureSpeed = v.CaptureSpeed
			if ( v.PrecedingPoint >= 1 ) then
				v.Entity.PrecedingPoint = self.ControlPoints[v.PrecedingPoint].Entity
			end
		v.Entity:Spawn()
	end
	
	for k, v in pairs( self.AltarSpawns ) do
		v.Entity  = ents.Create("dc_altar")
			v.Entity:SetPos( v.Position )
			v.Entity:SetAngles( v.Rotation )
		v.Entity:Spawn()
	end

	local chesttest = ents.Create( "dc_chest_map" )
	chesttest:SetPos( Vector( 8808, -55, -350 ) )
	chesttest:Spawn()
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
	for k, point in pairs( self.ControlPoints ) do
		if ( point.Entity and IsValid( point.Entity ) ) then
			point.Entity:SendClientInformation_Capture( ply )
		end
	end

	-- Used to initialize the player buff table, function located within sv_buff.lua
	self:PlayerInitialSpawn_Buff( ply )
end

function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )

	for k, buff in pairs( self.Buffs ) do
		ply:RemoveBuff( k )
	end
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

function GM:ShouldCollide( ent1, ent2 )
	-- Spells fired by your own team should not collide with you
	if
		( ent1:IsSpell() and ent2:IsPlayer() ) or
		( ent1:IsPlayer() and ent2:IsSpell() )
	then
		if ( ent1:Team() == ent2:Team() ) then
			return false
		end
	end
	return true
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
		self:RoundEndWithResult( TEAM_MONSTER, "MONSTER WIN\nHeroes annihilated!" )
	end

	if ( not self.ControlPoints[#self.ControlPoints].Entity.MonsterControlled ) then
		self:RoundEndWithResult( TEAM_HERO, "HERO WIN\nLand reclaimed!" )
	end
end

-- Overwrite to not respawn all important map items after cleaning up the map
function GM:OnPreRoundStart( num )
	-- Cleanup and then spawn all gamemode map items again (e.g. checkpoints)
	game.CleanUpMap()
	self:SpawnMapItems()

	-- Send the reset captured state of every control point to every player
	for k, ply in pairs( player.GetAll() ) do
		for m, point in pairs( self.ControlPoints ) do
			if ( point.Entity and IsValid( point.Entity ) ) then
				point.Entity:SendClientInformation_Capture( ply )
			end
		end
	end

	-- Reset round logic
	for k, ply in pairs( player.GetAll() ) do
		ply.Ghost = nil
		ply.NumberSpawns = nil
	end

	UTIL_StripAllPlayers()
	UTIL_SpawnAllPlayers()
	UTIL_FreezeAllPlayers()
end

function GM:OnRoundStart( num )
	self.BaseClass:OnRoundStart()
end

function GM:OnRoundResult( result, resulttext )
	team.AddScore( result, 1 )
end
-- Don't kill players if they are standing on the spawn point, some maps (i.e. rp_harmonti) only have one spawn
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
