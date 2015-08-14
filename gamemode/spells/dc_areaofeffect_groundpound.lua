-- Matthew Cormack (@johnjoemcbob)
-- 07/08/15
-- Area of effect ground pound; player launches into the air and activates pound on landing

GM.Spells["dc_areaofeffect_groundpound"] =
{
	Name = "Ground Pound",
	Icon = "icon16/vector.png",
	Type = "Misc",
	Level = 70,
	Cooldown = 10,
	ManaUsage = 50,
	Create = function( self, ply )
		-- Must be on solid ground to cast
		if ( not ply:OnGround() ) then return end

		local spell = ents.Create( "dc_areaofeffect_groundpound" )
			spell:SetPos( ply:GetPos() )
			spell.Owner = ply
			spell:Spawn()
		return spell
	end,
	Range = 500
}