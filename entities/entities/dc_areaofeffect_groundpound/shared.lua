-- Matthew Cormack (@johnjoemcbob)
-- 07/08/15
-- Area of effect ground pound; player launches into the air and activates pound on landing

-- The radius of any touch/area of affect spells
ENT.Radius = 350

-- The damage to inflict if this spell affects a player
ENT.Damage = 30

-- The extra amount of height which can be added/removed from a groundpound if the player launches from atop something or in a ditch
ENT.ExtraHeight = 150

-- The fractional extra amount of damage a bigger drop can cause/smaller drop can revoke
ENT.ExtraDamage = 2

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

function ENT:Initialize()
	if ( SERVER ) then
		-- Store the current z position of the player, so more damage can be dealt based on the height fallen
		self.StartZ = self.Owner:GetPos().z

		-- Fire self upwards
		self.Owner:SetVelocity( self.Owner:GetVelocity() + Vector( 0, 0, 500 ) )

		-- Flag that the player may survive this fall
		if ( self.Owner.NoFallDamage ~= -1 ) then
			self.Owner.NoFallDamage = ( self.Owner.NoFallDamage or 0 ) + 1
		end
	end
end

function ENT:Think()
	if ( SERVER ) then
		-- If the player has landed on the ground or in the water after being fired into the air, activate spell
		if ( self.Owner:IsOnGround() or ( self.Owner:WaterLevel() > 0 ) ) then
			-- Cause damage to surrounding players
			local extra = math.Clamp( self.StartZ - self.Owner:GetPos().z, -self.ExtraHeight, self.ExtraHeight ) / self.ExtraHeight
			local damage = self.Damage + ( extra * ( self.Damage / self.ExtraDamage ) )

			local entsinrange = ents.FindInSphere( self.Owner:GetPos(), self.Radius )
			for k, v in pairs( entsinrange ) do
				-- Is another player, on another team
				if ( ( v:IsPlayer() ) and ( v:Team() ~= self.Owner:Team() ) ) then
					v:TakeDamage( damage, self.Owner, self )
				end
			end

			-- Play effect
			local data = EffectData()
				data:SetOrigin( self.Owner:GetPos() + Vector( 0, 0, 0 ) )
				data:SetAngles( Angle( 0, 0, 0 ) )
			util.Effect( "WaterSurfaceExplosion", data, true, true )

			-- Flag that the player may not survive any more falls
			if ( self.Owner.NoFallDamage ~= -1 ) then
				self.Owner.NoFallDamage = 0
			end

			-- Remove spell
			self:Remove()
		end
	end
end

if ( CLIENT ) then
	function ENT:Draw()

	end
end

-- Base function used as part of any spells which act only at close range to the target
-- NOTE: Intended to be overwritten by child spells, to add extra functionality
-- function ENT:Cast_Touch_Affect( ply, target )

-- end