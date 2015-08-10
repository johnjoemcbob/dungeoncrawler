-- Matthew Cormack (@johnjoemcbob)
-- 05/08/15
-- Basic fireball projectile spell

GM.Spells["dc_projectile_fire"] =
{
	Name = "Fireball",
	Icon = "icon16/wand.png",
	Type = "Projectile",
	Cooldown = 0.6,
	Create = function( self, ply, start )
		-- Offset angle can be used to fire projectiles in directions other than straight
		local offsetangle = Angle( 0, 0, 0 )

		local spell = ents.Create( "dc_projectile_fireball" )
			spell:SetPos( start )
			spell.Owner = ply
			spell:Spawn()
		return spell, offsetangle
	end,
	Range = 500
}