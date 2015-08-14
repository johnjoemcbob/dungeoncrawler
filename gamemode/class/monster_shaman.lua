-- Matthew Cormack (@johnjoemcbob)
-- 07/08/15
-- Monster team shaman class
-- Magic focused monster class, with a buff totem special

local CLASS = {}
	CLASS.DisplayName			= "Shaman"
	CLASS.WalkSpeed 			= 300
	CLASS.CrouchedWalkSpeed 	= 0.2
	CLASS.RunSpeed				= 300
	CLASS.DuckSpeed				= 0.2
	CLASS.JumpPower				= 200
	CLASS.PlayerModel			= player_manager.TranslatePlayerModel( "monk" )
	CLASS.DrawTeamRing			= false
	CLASS.DrawViewModel			= false
	CLASS.CanUseFlashlight      = false
	CLASS.MaxHealth				= 100
	CLASS.StartHealth			= 100
	CLASS.StartArmor			= 0
	CLASS.RespawnTime           = 0
	CLASS.DropWeaponOnDie		= false
	CLASS.TeammateNoCollide 	= true
	CLASS.AvoidPlayers			= false
	CLASS.Selectable			= true
	CLASS.FullRotation			= false

function CLASS:Loadout( ply )
	ply:Give( "dc_magichand" )

	ply.Spells = {
		"dc_projectile_poison",
		"dc_totem_shaman"
	}
	SendClientSpellInformation( ply )
end

function CLASS:OnSpawn( ply )
	ply.Ghost = nil
	-- Send ghost status to all players
	for k, v in pairs( player.GetAll() ) do
		SendClientGhostInformation( v, ply )
	end
end

function CLASS:OnDeath( pl, attacker, dmginfo )
end

function CLASS:Think( ply )
	ply:SetMana( math.Clamp( ply:GetMana() + 0.1, 0, 100 ) )
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

player_class.Register( "class_monster_shaman", CLASS )