-- Matthew Cormack (@johnjoemcbob)
-- 14/08/15
-- Mana regeneration totem spell

GM.Spells["dc_totem_mana"] =
{
	Name = "Mana Totem",
	Icon = "icon16/flag_blue.png",
	Type = "Totem",
	Level = 0,
	Cooldown = 60,
	ManaUsage = 10,
	Create = function( self, ply, trace )
		local spell = ents.Create( "dc_totem_mana" )
			spell:SetPos( trace.HitPos )
			spell.Owner = ply
			spell:Spawn()
		return spell
	end,
	Range = 250,
	TotemRotate = true
}