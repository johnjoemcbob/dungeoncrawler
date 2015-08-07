-- Matthew Cormack (@johnjoemcbob)
-- 07/08/15
-- Basic physical damage touch spell

-- The range of this spell
ENT.Range = 50

-- The radius of any touch/area of affect spells
ENT.Radius = 50

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"
ENT.Base = "dc_spell_base"

function ENT:Initialize()
end

-- Called by dc_magichands/shared.lua when this spell is activated
function ENT:Cast( ply )
	self:Cast_Touch( ply )
end

-- Base function used as part of any spells which act only at close range to the target
-- NOTE: Intended to be overwritten by child spells, to add extra functionality
-- function ENT:Cast_Touch_Affect( ply, target )
	
-- end