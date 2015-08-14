-- Matthew Cormack (@johnjoemcbob)
-- 07/08/15
-- Basic physical damage touch spell

GM.Spells["dc_touch_physical"] =
{
	Name = "Claw Slash",
	Icon = "icon16/thumb_up.png",
	Type = "Touch",
	Level = -1,
	Cooldown = 1,
	ManaUsage = 0,
	Create = function( self, ply, target )
		if ( ply:Team() ~= target:Team() ) then
			target:TakeDamage( self.Damage, ply, self )
		end
	end,
	Range = 50,
	Radius = 50,
	Damage = 20
}