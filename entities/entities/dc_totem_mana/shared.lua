-- Matthew Cormack (@johnjoemcbob)
-- 14/08/15
-- Hero mana regeneration totem

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- The time this totem should last
-- NOTE: After creation CurTime() is added this to make it the end time
ENT.Time = 10

-- The radius of this totem's effect
ENT.Radius = 100

function ENT:Initialize()
	-- Initialize shared totem properties
	self:SetModel( "models/effects/vol_light256x384.mdl" )
	self:SetSolid( SOLID_NONE )
	self:SetPos( self:GetPos() + Vector( 0, 0, 200 ) )

	-- Emit mana bubble particle effect
	--ParticleEffectAttach( "water_bubble_trail_1", PATTACH_POINT_FOLLOW, self, 0 )

	-- Change to the time at which the entity will be removed
	self.Time = self.Time + CurTime()

	-- Remove any previous totems
	if ( self.Owner.Totem and IsValid( self.Owner.Totem ) ) then
		self.Owner.Totem:Remove()
	end
	self.Owner.Totem = self
end

function ENT:Think()
	if ( SERVER ) then
		-- Affect players within range
		local entsinrange = ents.FindInSphere( self:GetPos() - Vector( 0, 0, 200 ), self.Radius )
		for k, v in pairs( entsinrange ) do
			-- Is a player
			if ( v:IsPlayer() ) then
				if ( v:Team() == TEAM_HERO ) then
					v:AddBuff( 6 )
				end
			end
		end

		-- Remove the totem after its time is up
		if ( CurTime() > self.Time ) then
			self:Remove()
		end
	end
end

function ENT:IsSpell()
	return true
end

function ENT:Team()
	return self.Owner:Team()
end