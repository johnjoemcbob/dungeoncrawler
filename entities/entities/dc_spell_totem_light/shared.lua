-- Matthew Cormack (@johnjoemcbob)
-- 06/08/15
-- Basic light source totem spell

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
	self:Cast_TrapTotem( ply )
end

-- Base function used as part of any spells which create world traps to hurt heroes,
-- or totems to buff heroes/debuff monsters
-- NOTE: Intended to be overwritten by child spells, to add extra functionality
function ENT:Cast_TrapTotem_Create( ply, trace )
	local spell = ents.Create( "dc_totem_light" )
		spell:SetPos( trace.HitPos )
		spell.Owner = ply
		spell:Spawn()
		self:Cast_TrapTotem_Rotate( spell, trace )
	return spell
end