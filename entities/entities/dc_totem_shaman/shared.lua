-- Matthew Cormack (@johnjoemcbob)
-- 08/08/15
-- Shaman monster totem, poisons heroes

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- The time this totem should last
-- NOTE: After creation CurTime() is added this to make it the end time
ENT.Time = 20

-- The time between particle effects
ENT.BetweenEffect = 2

-- The runtime until the next particle effect should play
ENT.NextEffect = 0

-- The radius of this totem's effect
ENT.Radius = 100

function ENT:Initialize()
	-- Initialize shared totem properties
	self:SetModel( "models/props_junk/harpoon002a.mdl" )
	self:SetSolid( SOLID_NONE )
	self:SetPos( self:GetPos() + Vector( 0, 0, 5 ) )
	self:SetAngles( Angle( -90, 0, 0 ) )

	if SERVER then
		-- Physics disabled
		self:SetMoveType( MOVETYPE_NONE )

		-- Add a head mounted on the spear
		self.Skull = ents.Create( "prop_dynamic" )
		self.Skull:SetModel( "models/Gibs/HGIBS.mdl" )
		self.Skull:SetAngles( Angle( 0, 180, 0 ) )
		self.Skull:SetPos( self:GetPos() + ( self:GetAngles():Forward() * 50 ) )
		self.Skull:SetParent( self.Entity )
	end

	-- Play sound 
	sound.Play("ambient/creatures/flies" .. math.random(1, 5) ..  ".wav", self:GetPos())
	
	-- Change to the time at which the entity will be removed
	self.Time = self.Time + CurTime()
end

function ENT:Think()
	if ( SERVER ) then
		-- Affect players within range
		local entsinrange = ents.FindInSphere( self:GetPos(), self.Radius )
		for k, v in pairs( entsinrange ) do
			-- Is a player
			if ( v:IsPlayer() ) then
				if ( v:Team() == TEAM_HERO ) then
					v:AddBuff( 3 )
				end
			end
		end

		-- Play particle effect
		if ( CurTime() > self.NextEffect ) then
			local effectdata = EffectData()
				effectdata:SetOrigin( self:GetPos() + ( self:GetAngles():Forward() * 50 ) )
				effectdata:SetAngles( Angle( 0, 0, 0 ) )
			util.Effect( "AntlionGib", effectdata, true, true )

			self.NextEffect = CurTime() + self.BetweenEffect
			
			-- Play sound 
			sound.Play("ambient/creatures/flies" .. math.random(1, 5) ..  ".wav", self:GetPos())
		end

		-- If player dies then remove
		-- Remove the totem after its time is up
		if ( ( CurTime() > self.Time ) or ( not self.Owner:Alive() ) ) then
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