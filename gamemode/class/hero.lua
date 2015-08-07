-- Matthew Cormack (@johnjoemcbob)
-- 07/08/15
-- Hero team base class

local CLASS = {}
	CLASS.DisplayName			= "Hero"
	CLASS.WalkSpeed 			= 300
	CLASS.CrouchedWalkSpeed 	= 0.2
	CLASS.RunSpeed				= 500
	CLASS.DuckSpeed				= 0.2
	CLASS.JumpPower				= 200
	CLASS.PlayerModel			= player_manager.TranslatePlayerModel( "male11" )
	CLASS.DrawTeamRing			= true
	CLASS.DrawViewModel			= true
	CLASS.CanUseFlashlight      = false
	CLASS.MaxHealth				= 100
	CLASS.StartHealth			= 100
	CLASS.StartArmor			= 0
	CLASS.RespawnTime           = 0
	CLASS.DropWeaponOnDie		= false
	CLASS.TeammateNoCollide 	= false
	CLASS.AvoidPlayers			= false
	CLASS.Selectable			= true
	CLASS.FullRotation			= false

function CLASS:Loadout( ply )
	ply:Give( "dc_magichand" )

	ply.Spells = {
		"dc_spell_projectile_fireball",
		"dc_spell_totem_light"
	}
end

function CLASS:OnSpawn( ply )
end

function CLASS:OnDeath( pl, attacker, dmginfo )
end

function CLASS:Think( pl )
end

function CLASS:Move( pl, mv )
end

function CLASS:OnKeyPress( pl, key )
end

function CLASS:OnKeyRelease( pl, key )
end

function CLASS:ShouldDrawLocalPlayer( pl )
	return false
end

function CLASS:CalcView( ply, origin, angles, fov )
end

player_class.Register( "class_hero", CLASS )