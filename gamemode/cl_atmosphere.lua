-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 03/08/15
-- Clientside atmospheric additions

local LastRainEffect = 0

local ps_default_brightness = -0.07
local ps_default_contrast = 1
local ps_default_colour = 1

local ps_dark_brightness = -0.17
local ps_dark_contrast = 1
local ps_dark_colour = 0.7

local DC_PS_Brightness = ps_default_brightness
local DC_PS_Contrast = ps_default_contrast
local DC_PS_Colour = ps_default_colour

function AtmosphereInit()
	
end
hook.Add( "Initialize", "", AtmosphereInit )

function AtmosphereThink()
	-- Find if the player is inside
	-- NOTE: This is used for muffling the rain sounds and lightening the screen inside
	local tr = util.TraceLine(
		{
			start = LocalPlayer():EyePos() + Vector( 0, 0, 1 ) * 20,
			endpos = LocalPlayer():EyePos() + Vector( 0, 0, 1 ) * 300,
		}
	)
	LocalPlayer().Inside = tr.Hit

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

	-- Rain test particles
	if ( CurTime() > LastRainEffect ) then
		local effectdata = EffectData()
			effectdata:SetOrigin( LocalPlayer():GetPos() + Vector( 5, 0, 10 ) )
			effectdata:SetAngles( Angle( 0, 0, 0 ) )
		rain = util.Effect( "dc_rain", effectdata, true, true )
		LastRainEffect = CurTime() + 0.1
	end

	Think_Sound_Rain()
end
hook.Add( "Think", "", AtmosphereThink )

local Sound_Rain = nil
function Think_Sound_Rain()
	-- Play a looping rain sound effect, with pitch/volume alteration for indoor ambience
	-- NOTE: Original credits for this system go to Rick Dark (https://garrysmods.org/download/3952/weatheraddonzip)
	if ( not Sound_Rain ) then
		Sound_Rain = CreateSound( LocalPlayer(), "ambient/weather/rumble_rain.wav" )
		Sound_Rain:Play()
	end

	-- Player is inside
	if ( LocalPlayer().Inside ) then
		soundlevel = math.Approach( Sound_Rain:GetSoundLevel(), 2, 0.195 )
		pitch = math.Approach( Sound_Rain:GetPitch(), 50, 2 )
		Sound_Rain:SetSoundLevel( soundlevel )
		Sound_Rain:ChangePitch( pitch )
	-- Player is outside
	else
		soundlevel = math.Approach( Sound_Rain:GetSoundLevel(), 3.9, 0.195 )
		pitch = math.Approach( Sound_Rain:GetPitch(), 100, 2 )
		Sound_Rain:SetSoundLevel( soundlevel )
		Sound_Rain:ChangePitch( pitch )
	end
end

-- NOTE: Original credits for this system go to Rick Dark (https://garrysmods.org/download/3952/weatheraddonzip)
function PostProcess_DarkOutside()
	if LocalPlayer().Inside then
		DC_PS_Brightness = math.Approach( DC_PS_Brightness, ps_default_brightness, 0.01 )
		DC_PS_Contrast = math.Approach( DC_PS_Contrast, ps_default_contrast, 0.01 )
		DC_PS_Colour = math.Approach( DC_PS_Colour, ps_default_colour, 0.01 )
	else
		DC_PS_Brightness = math.Approach( DC_PS_Brightness, ps_dark_brightness, 0.01 )
		DC_PS_Contrast = math.Approach( DC_PS_Contrast, ps_dark_contrast, 0.01 )
		DC_PS_Colour = math.Approach( DC_PS_Colour, ps_dark_colour, 0.01 )
	end

	local postprocess_colourmodify = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0,
		["$pp_colour_brightness"] = DC_PS_Brightness,
		["$pp_colour_contrast"] = DC_PS_Contrast,
		["$pp_colour_colour"] = DC_PS_Colour
	}
	DrawColorModify( postprocess_colourmodify )
end
hook.Add( "RenderScreenspaceEffects", "PostProcess_DarkOutside", PostProcess_DarkOutside )

function GM:SetupWorldFog()
	render.FogMode( MATERIAL_FOG_LINEAR )
	render.FogStart( 400 )
	render.FogEnd( 1000 )

	return true
end