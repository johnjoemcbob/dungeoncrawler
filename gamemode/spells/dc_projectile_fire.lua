-- Matthew Cormack (@johnjoemcbob)
-- 10/08/15
-- Basic fire projectile spell

GM.Spells["dc_projectile_fire"] =
{
	Name = "Fireball",
	Icon = "icon16/wand.png",
	Type = "Projectile",
	Cooldown = 0.4,
	Create = function( self, ply, pos )
		local angle = Angle( 0, 0, 0 )

		local spell = ents.Create( "dc_projectile_fireball" )
			spell:SetPos( pos )
			spell.Owner = ply
			spell:Spawn()
		return spell, angle
	end,
	Range = 500
}