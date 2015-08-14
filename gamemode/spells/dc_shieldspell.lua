-- Jordan Brown (@drmelon)
-- 14/08/15
-- Summons 4 shields around the player.

GM.Spells["dc_shieldspell"] =
{
	Name = "Summon Shield",
	Icon = "icon16/shield.png",
	Type = "Misc",
	Level = 15,
	Cooldown = 5.0,
	ManaUsage = 20,
	-- Damage serves as shield health here
	Damage = 25,
	Create = function( self, ply )
		-- Create 4 shields around player
	
		-- Play Sound
		sound.Play("ambient/energy/spark5.wav", ply:GetPos())		
		
		local spell = ents.Create( "dc_shield" )
			spell:SetPos( ply:GetPos() + ply:GetAngles():Forward() * 20 )
			spell.Owner = ply
			spell.Offset = 0.0
			spell:Spawn()
			
		local spell = ents.Create( "dc_shield" )
			spell:SetPos( ply:GetPos() + ply:GetAngles():Forward() * -20 )
			spell.Owner = ply
			spell.Offset = 5
			spell:Spawn()

		local spell = ents.Create( "dc_shield" )
			spell:SetPos( ply:GetPos() + ply:GetAngles():Right() * 20 )
			spell.Owner = ply
			spell.Offset = 2.5
			spell:Spawn()
			
		local spell = ents.Create( "dc_shield" )
			spell:SetPos( ply:GetPos() + ply:GetAngles():Right() * -20 )
			spell.Owner = ply
			spell.Offset = 7.5
			spell:Spawn()
						
			
			

	end,
	Random = {
		Range = {
			Min = 500,
			Max = 1000
		},
		Cooldown = {
			Min = 2.0,
			Max = 7.5,
			ChanceMultiplier = 0.7
		},
		Damage = {
			Min = 10,
			Max = 40
		},
		ManaUsage = {
			Min = 15,
			Max = 35
		}
	}
}