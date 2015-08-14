-- Matthew Cormack (@johnjoemcbob)
-- 07/08/15
-- Hero team base class

if ( SERVER ) then
	util.AddNetworkString( "DC_Client_Ghost" )
	util.AddNetworkString( "DC_Client_Spells" )

	function SendClientGhostInformation( ply, ghostply )
		-- Send the ghost flag to client, in order to predict collisions and show the ghost specific HUD
		net.Start( "DC_Client_Ghost" )
			net.WriteFloat( ghostply:EntIndex() )
			net.WriteBit( ghostply.Ghost )
		net.Send( ply )
	end

	function SendClientSpellInformation( ply )
		-- Send the ghost flag to client, in order to predict collisions and show the ghost specific HUD
		net.Start( "DC_Client_Spells" )
			net.WriteString( ply.Spells[1] or "" )
			net.WriteString( ply.Spells[2] or "" )
		net.Send( ply )
	end
end

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
	-- Heroes on live once
	if ( not ply.Ghost ) then
		ply:Give( "dc_magichand" )

		if ( not ply.LootedSpells ) then
			ply.LootedSpells = {}
			ply:AddSpell( "dc_projectile_fire", 0 )
			ply:AddSpell( "dc_totem_mana", 0 )
		end
		ply.Spells = {
			1,
			2
		}
		SendClientSpellInformation( ply )
	end
end

function CLASS:OnSpawn( ply )
	-- Flag as a ghost if they have spawned more than once
	if ( ply.Ghost and ply.DeathPosition ) then
		ply:SetPos( ply.DeathPosition )
	end
end

function CLASS:OnDeath( ply, attacker, dmginfo )
	-- Flag as a ghost, a dead hero
	ply.Ghost = true
	ply:SetCustomCollisionCheck( true )
	ply.OldMaterial = ply:GetMaterial()
	ply:SetMaterial( "models/effects/vol_light001" ) -- Draw invisible

	-- Send ghost status to all players
	for k, v in pairs( player.GetAll() ) do
		SendClientGhostInformation( v, ply )
	end

	-- Save death position for respawning
	ply.DeathPosition = ply:GetPos()

	-- Check end conditions
	GAMEMODE:CheckEndConditions()

	-- Auto respawn quickly afterwards, if not already manually spawned
    timer.Simple( 2, function()
		if ( not ply:Alive() ) then
			ply:Spawn()
		end
	end )
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

player_class.Register( "class_hero", CLASS )