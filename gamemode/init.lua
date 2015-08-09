-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 02/08/15
-- Main serverside logic

AddCSLuaFile( "cl_atmosphere.lua" )
AddCSLuaFile( "cl_buff.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_controlpoints.lua" )
AddCSLuaFile( "sh_buff.lua" )
AddCSLuaFile( "class/hero.lua" )
AddCSLuaFile( "class/monster_undead.lua" )
AddCSLuaFile( "class/monster_shaman.lua" )

include( "shared.lua" )
include( "sh_controlpoints.lua" )
include( "sv_buff.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()

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
		point.Entity:SendClientInformation_Capture( ply )
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
	if ( ply.NoFallDamage and ( ply.NoFallDamage > 0 ) ) then
		ply.NoFallDamage = ply.NoFallDamage - 1
		return
	end

	if ( self.RealisticFallDamage ) then
		return flFallSpeed / 8
	end

	return 10
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
