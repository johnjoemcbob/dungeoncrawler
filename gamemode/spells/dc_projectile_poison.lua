-- Matthew Cormack (@johnjoemcbob)
-- 08/08/15
-- Poison projectile spell, inflicts base damage on hit and applies poison debuff

GM.Spells["dc_projectile_poison"] =
{
	Name = "Poison",
	Icon = "icon16/wand.png",
	Type = "Projectile",
	Cooldown = 1.6,
	Create = function( self, ply, start )
		-- Offset angle can be used to fire projectiles in directions other than straight
		local offsetangle = Angle( 0, 0, 0 )

		local spell = ents.Create( "dc_projectile_poison" )
			spell:SetPos( start )
			spell.Owner = ply
			spell:Spawn()
		return spell, offsetangle
	end,
	Range = 500
}