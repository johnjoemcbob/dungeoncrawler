-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 02/08/15
-- Main serverside logic

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_atmosphere.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_controlpoints.lua" )

include( "shared.lua" )
include( "sh_controlpoints.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()

	for k, v in pairs( self.ControlPoints ) do
		v.Entity = ents.Create( "dc_trigger_control" )
			v.Entity:SetPos( v.Position )
			v.Entity.StartPos = v.Start
			v.Entity.EndPos = v.End
			v.Entity.ZoneName = v.Title
			v.Entity.Type = v.Type
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
end

function GM:PlayerSwitchFlashlight( ply, on )
	return not on
end

function GM:PlayerSpawn( ply )
	-- Temp
	if ( ply:Team() == TEAM_HERO ) then
		ply:SetModel( player_manager.TranslatePlayerModel( "male11" ) )
	else
		ply:SetModel( player_manager.TranslatePlayerModel( "corpse" ) )
	end
end

function GM:PostPlayerDeath( ply )
	-- Remove this player from any trigger zones they were in
	if ( ply.TriggerZone and IsValid( ply.TriggerZone ) ) then
		ply.TriggerZone:RemovePlayer( ply )
	end
end

function GM:PlayerDisconnected( ply )
	-- Remove this player from any trigger zones they were in
	if ( ply.TriggerZone and IsValid( ply.TriggerZone ) ) then
		ply.TriggerZone:RemovePlayer( ply )
	end
end