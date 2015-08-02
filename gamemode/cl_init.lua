include( 'shared.lua' )

function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:Think()
	self.BaseClass:Think()

	-- Setup the fake skybox to follow the player, just outside the fog radius
	-- This is present as a black curtain in case the map skybox is too bright
	if ( not LocalPlayer().ClientSkybox ) or ( not IsValid( LocalPlayer().ClientSkybox ) ) then
		LocalPlayer().ClientSkybox = ClientsideModel(
			"models/props_phx/construct/metal_dome360.mdl",
			RENDERGROUP_OPAQUE
		)
		LocalPlayer().ClientSkybox:SetMaterial( "models/debug/debugwhite" )
		LocalPlayer().ClientSkybox:SetColor( Color( 0, 0, 0, 255 ) )
		LocalPlayer().ClientSkybox:SetModelScale( 40, 0 )
	else
		LocalPlayer().ClientSkybox:SetPos( LocalPlayer():GetPos() - Vector( 0, 0, 1000 ) )
	end
end

function GM:SetupWorldFog()
	render.FogMode( MATERIAL_FOG_LINEAR )
	render.FogStart( 400 )
	render.FogEnd( 1000 )

	return true
end