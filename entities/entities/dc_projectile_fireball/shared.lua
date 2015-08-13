-- Matthew Cormack (@johnjoemcbob)
-- 05/08/15
-- Basic fireball projectile

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- Flag for whether or not being near this entity should light the player's way
ENT.IsLightSource = true
ENT.LightLevel = 0.2

-- Current scale of the projectile
ENT.Scale = 0.01

-- The speed to fire this projectile at
ENT.Speed = 1000

-- The range of this spell
ENT.Range = 2000

-- The radius to apply fire and damage when blowing up
ENT.Radius = 10

-- The runtime variable containing the starting position of the particle, for out-of-range cleanup purposes
ENT.StartPos = nil

function ENT:Initialize()
	-- Custom collision to stop it from hitting self/team-mates
	-- Other side of this functionality can be found in init.lua, GM:ShouldCollide
	self:SetCustomCollisionCheck( true )

	-- Initialize shared projectile properties
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:SetMaterial( "models/debug/debugwhite" )
	self:SetColor( Color( 255, 100, 100 ) )
	self:SetSolid( SOLID_BBOX )

	-- Initialize the scalable collision model for this projectile
	local minpos = Vector( -self.Scale, -self.Scale, -self.Scale )
	local maxpos = Vector( self.Scale, self.Scale, self.Scale )
	self:SetCollisionBounds( minpos, maxpos )
	self:PhysicsInitBox( minpos, maxpos )
	self:UpdateScale()

	if SERVER then
		-- Physics enabled
		self:SetMoveType( MOVETYPE_VPHYSICS )

		-- Enable physics and disable gravity
		local physics = self:GetPhysicsObject()
		if ( physics and IsValid( physics ) ) then
			-- Always have a mass of one, if unset the mass will scale with the size of the collision
			--physics:SetMass( 1 )

			physics:EnableGravity( false )
			physics:Wake()
		end
	end

	-- Save the start position of the projectile for cleanup if out of range
	self.StartPos = self:GetPos()

	ParticleEffectAttach( "fire_small_02", PATTACH_POINT_FOLLOW, self, 0 )
end

function ENT:Think()
	-- Increase projectile scale
	if ( self.Scale < 0.5 ) then
		self.Scale = math.Approach( self.Scale, 0.5, FrameTime() * 10 )
		self:UpdateScale()
	end

	if ( SERVER ) then
		-- Die when inside water
		if ( self:WaterLevel() > 0 ) then
			self:BlowUp()
		end

		-- Emit fiery particles
		local velocity = Vector( 0, 0, 0 )
			local physics = self:GetPhysicsObject()
			if ( physics and IsValid( physics ) ) then
				velocity = physics:GetVelocity()
			end
		local forward = self:GetUp()
		-- local effectdata = EffectData()
			-- effectdata:SetOrigin( self:GetPos() )
			-- effectdata:SetAngles( Angle( self:EntIndex(), 0, 0 ) )
		-- self.OpenEffect = util.Effect( "dc_fire", effectdata )

		-- Explode if the spell has gone out of range
		if ( self.StartPos and ( self.StartPos:Distance( self:GetPos() ) > self.Range ) ) then
			self:BlowUp()
		end
	end
end

function ENT:UpdateScale()
	self:SetModelScale( self.Scale, 0 )

	-- Update mass based on scale in order to speed up as the size increases
	local physics = self:GetPhysicsObject()
	if ( physics and IsValid( physics ) ) then
		physics:SetMass( self.Scale )
	end
end

function ENT:PhysicsCollide( data, phys )
	self:BlowUp()
end

function ENT:BlowUp()
	-- Play sound effect
	self:EmitSound( Sound( "Flashbang.Bounce" ) )

	-- Play particle effect
	local effectdata = EffectData() 
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() ) 
		effectdata:SetScale( math.random( 1,3 ) )
	util.Effect( "watersplash", effectdata )

	-- Apply damage and burning debuff to closeby players
	local entsinrange = ents.FindInSphere( self:GetPos(), self.Radius )
	for k, v in pairs( entsinrange ) do
		-- Is another player, on another team
		if ( ( v:IsPlayer() ) and ( v:Team() ~= self.Owner:Team() ) ) then
			v:TakeDamage( self.Damage, self.Owner, self )
			v:AddBuff( 5 )
		end
	end

	-- Destroy the spell
	self:Remove()
end

if ( CLIENT ) then
	function ENT:Draw()
		self:DrawModel()

		-- Light up the totem
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.pos = self:GetPos() + Vector( 0, 0, 25 )
			dlight.r = 255
			dlight.g = 150
			dlight.b = 200
			dlight.brightness = 1
			dlight.Decay = 1000
			dlight.Size = 128
			dlight.DieTime = CurTime() + 1
		end
	end
end

function ENT:IsSpell()
	return true
end

function ENT:Team()
	if ( not self.Owner or ( not self.Owner.Team ) ) then return 0 end
	return self.Owner:Team()
end