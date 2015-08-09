-- Matthew Cormack (@johnjoemcbob)
-- 06/08/15
-- Basic light source totem

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- Flag for whether or not being near this entity should light the player's way
ENT.IsLightSource = true
ENT.LightLevel = 1

-- The time this totem should last
-- NOTE: After creation CurTime() is added this to make it the end time
ENT.Time = 300

function ENT:Initialize()
	-- Initialize shared totem properties
	self:SetModel( "models/props_c17/canister01a.mdl" )
	self:SetMaterial( "models/props_wasteland/wood_fence01a" )
	self:SetSolid( SOLID_NONE )
	self:SetPos( self:GetPos() + Vector( 0, 0, 5 ) )

	if SERVER then
		-- Physics disabled
		self:SetMoveType( MOVETYPE_NONE )
	end

	-- Change to the time at which the entity will be removed
	self.Time = self.Time + CurTime()

	-- Start particle effects on the head of the totem
	ParticleEffectAttach( "fire_small_02", PATTACH_POINT_FOLLOW, self, 1 )
end

function ENT:Think()
	if ( SERVER ) then
		if ( CurTime() > self.Time ) then
			self:Remove()
		end
	end
end

if ( CLIENT ) then
	function ENT:Draw()
		self:DrawModel()

		-- Light up the totem
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.pos = self:GetPos() + Vector( 0, 0, 35 )
			dlight.r = 255
			dlight.g = 69
			dlight.b = 0
			dlight.Brightness = 1
			dlight.Decay = 500
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

function ENT:IsSpell()
	return true
end

function ENT:Team()
	return self.Owner:Team()
end