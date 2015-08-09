-- Matthew Cormack (@johnjoemcbob)
-- 08/08/15
-- Poison projectile spell, inflicts base damage on hit and applies poison debuff

-- The range of this spell
ENT.Range = 500

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"
ENT.Base = "dc_spell_base"

function ENT:Initialize()
end

-- Called by dc_magichands/shared.lua when this spell is activated
function ENT:Cast( ply )
	self:Cast_Projectile( ply )
end

-- Base function used as part of any spells which fire a projectile
-- NOTE: Intended to be overwritten by child spells, to add extra functionality
-- Can be gravity enable or not using spell:GetPhysicsObject():EnableGravity( bool )
function ENT:Cast_Projectile_Create( ply, start )
	-- Offset angle can be used to fire projectiles in directions other than straight
	local offsetangle = Angle( 0, 0, 0 )

	local spell = ents.Create( "dc_projectile_poison" )
		spell:SetPos( start )
		spell.Owner = ply
		spell:Spawn()
	return spell, offsetangle
end