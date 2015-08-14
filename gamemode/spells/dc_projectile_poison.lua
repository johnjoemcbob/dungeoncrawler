-- Matthew Cormack (@johnjoemcbob)
-- 10/08/15
-- Basic poison projectile spell

GM.Spells["dc_projectile_poison"] =
{
	Name = "Poisonball",
	Icon = "icon16/wand.png",
	Type = "Projectile",
	Level = -1,
	Cooldown = 0.5,
	ManaUsage = 5,
	Create = function( self, ply, pos )
		local angle = Angle( 0, 0, 0 )

		local spell = ents.Create( "dc_projectile_poison" )
			spell:SetPos( pos )
			spell.Owner = ply
			spell:Spawn()
		return spell, angle
	end,
	Range = 500
}