-- Matthew Cormack (@johnjoemcbob)
-- 06/08/15
-- Basic light source totem spell

GM.Spells["dc_totem_light"] =
{
	Name = "Light Totem",
	Icon = "icon16/joystick.png",
	Type = "Totem",
	Cooldown = 5,
	Create = function( self, ply, trace )
		local spell = ents.Create( "dc_totem_light" )
			spell:SetPos( trace.HitPos )
			spell.Owner = ply
			spell:Spawn()
		return spell
	end,
	Range = 500,
	TotemRotate = true
}