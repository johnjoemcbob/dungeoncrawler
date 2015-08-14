-- Jordan Brown (@drmelon)
-- 14/08/15
-- Fires a beam of lightning where you're looking.

GM.Spells["dc_lightning"] =
{
	Name = "Lightning Bolt",
	Icon = "icon16/lightning.png",
	Type = "Misc",
	Level = 25,
	Cooldown = 1.0,
	ManaUsage = 30,
	Damage = 20,
	Create = function( self, ply )
		-- Ptchoo!
		local angle = ply:EyeAngles()
		
		local spell = ents.Create( "dc_lightning_bolt" )
			spell:SetPos( ply:EyePos() )
			spell.Owner = ply
			spell:Spawn()
		return spell, angle
	end,
	Random = {
		Range = {
			Min = 500,
			Max = 1000
		},
		Cooldown = {
			Min = 0.75,
			Max = 2.0,
			ChanceMultiplier = 0.3
		},
		Damage = {
			Min = 15,
			Max = 25
		},
		ManaUsage = {
			Min = 25,
			Max = 35
		}
	}
}