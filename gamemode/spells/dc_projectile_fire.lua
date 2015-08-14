-- Matthew Cormack (@johnjoemcbob)
-- 10/08/15
-- Basic fire projectile spell

GM.Spells["dc_projectile_fire"] =
{
	Name = "Fireball",
	Description = "A fiery ball of pain",
	Icon = "icon16/wand.png",
	Type = "Projectile",
	Level = 0,
	Cooldown = 0.4,
	ManaUsage = 5,
	Create = function( self, ply, pos )
		local angle = Angle( 0, 0, 0 )

		local spell = ents.Create( "dc_projectile_fireball" )
			spell:SetPos( pos )
			spell.Owner = ply
			spell:Spawn()
		return spell, angle
	end,
	Random = {
		Range = {
			Min = 500,
			Max = 1000,
			ChanceMultiplier = 0
		},
		Cooldown = {
			Min = 3,
			Max = 0.5,
			ChanceMultiplier = 0.5
		},
		Damage = {
			Min = 5,
			Max = 25
		},
		ManaUsage = {
			Min = 5,
			Max = 10,
			ChanceMultiplier = 0
		}
	}
}