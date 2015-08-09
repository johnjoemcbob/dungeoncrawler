-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 02/08/15
-- Main clientside logic

include( "shared.lua" )
include( "cl_atmosphere.lua" )
include( "cl_hud.lua" )
include( "cl_buff.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()

	-- Used to setup the control point map, function located within cl_hud.lua
	self:Initialize_HUD()

	-- Used to precache the buff icons, function located within cl_buff.lua
	self:Initialize_Buffs()
end

function GM:Think()
	self.BaseClass:Think()
end

-- Setup view model hands for cast weapon
hook.Add( "PostDrawViewModel", "DC_PostDrawViewModel_Hands", function( vm, ply, weapon )
	if ( weapon.UseHands or ( not weapon:IsScripted() ) ) then
		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then
			hands:DrawModel()
		end
	end
end )

-- Setup hero halo outlines for monster players
hook.Add( "PreDrawHalos", "DC_PreDrawHalos", function()
	if ( LocalPlayer():Team() ~= TEAM_MONSTER ) then return end

	if ( not LocalPlayer().HaloPulse ) then
		LocalPlayer().HaloPulse = 1
		LocalPlayer().HaloPulseTarget = 15
	else
		local speed = FrameTime() * 10
			if ( LocalPlayer().HaloPulse == LocalPlayer().HaloPulseTarget ) then
				LocalPlayer().HaloPulseTarget = -LocalPlayer().HaloPulseTarget
			end
			if ( LocalPlayer().HaloPulseTarget < LocalPlayer().HaloPulse ) then
				speed = -speed
			end
		LocalPlayer().HaloPulse = math.Approach( LocalPlayer().HaloPulse, LocalPlayer().HaloPulseTarget, speed )
	end

	for k, ply in pairs( player.GetAll() ) do
		if ( ply:Team() == TEAM_HERO ) then
			halo.Add( { ply }, Color( 0, 0, 255 ), LocalPlayer().HaloPulse, LocalPlayer().HaloPulse, 2, true, true )
		elseif ( ply:Team() == TEAM_MONSTER ) then
			halo.Add( { ply }, Color( 255, 0, 0 ), LocalPlayer().HaloPulse, LocalPlayer().HaloPulse, 2, true, true )
		end
	end
end )

-- Overwrite base fretta team rings to only display to players on the same team
local CircleMat = Material( "SGM/playercircle" );

function GM:DrawPlayerRing( pPlayer )

	if ( !IsValid( pPlayer ) ) then return end
	if ( !pPlayer:GetNWBool( "DrawRing", false ) ) then return end
	if ( !pPlayer:Alive() ) then return end
	if ( pPlayer:Team() ~= LocalPlayer():Team() ) then return end
	
	local trace = {}
	trace.start 	= pPlayer:GetPos() + Vector(0,0,50)
	trace.endpos 	= trace.start + Vector(0,0,-300)
	trace.filter 	= pPlayer
	
	local tr = util.TraceLine( trace )
	
	if not tr.HitWorld then
		tr.HitPos = pPlayer:GetPos()
	end

	local color = table.Copy( team.GetColor( pPlayer:Team() ) )
	color.a = 40;

	render.SetMaterial( CircleMat )
	render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, GAMEMODE.PlayerRingSize, GAMEMODE.PlayerRingSize, color )	

end