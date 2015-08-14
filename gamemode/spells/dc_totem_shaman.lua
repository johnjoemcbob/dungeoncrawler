-- Matthew Cormack (@johnjoemcbob)
-- 08/08/15
-- Shaman monster totem spell, buffs monsters and poisons heroes

GM.Spells["dc_totem_shaman"] =
{
	Name = "Shaman Totem",
	Icon = "icon16/flag_purple.png",
	Type = "Totem",
	Level = -1,
	Cooldown = 5,
	ManaUsage = 25,
	Create = function( self, ply, trace )
		local spell = ents.Create( "dc_totem_shaman" )
			spell:SetPos( trace.HitPos )
			spell.Owner = ply
			spell:Spawn()
		return spell
	end,
	Range = 500,
	TotemRotate = true
}