-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 02/08/15
-- Main clientside logic

include( "shared.lua" )
include( "sh_controlpoints.lua" )
include( "cl_atmosphere.lua" )
include( "cl_hud.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()

	-- Used to setup the control point map, function located within cl_hud.lua
	Initialize_HUD( self )
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