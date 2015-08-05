-- Matthew Cormack (@johnjoemcbob)
-- 05/08/15
-- Basic fireball projectile

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- Flag for whether or not being near this entity should light the player's way
ENT.IsLightSource = true

-- Current scale of the projectile
ENT.Scale = 0.01

-- The speed to fire this projectile at
ENT.Speed = 1000

function ENT:Initialize()
	-- Custom collision to stop it from hitting self/team-mates
	-- Other side of this functionality can be found in init.lua, GM:ShouldCollide
	self:SetCustomCollisionCheck( true )

	-- Initialize shared projectile properties
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
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
end

function ENT:Think()
	-- Die when inside water
	if ( SERVER ) then
		if ( self:WaterLevel() > 0 ) then
			self:BlowUp()
		end
	end

	-- Increase projectile scale
	if ( self.Scale < 1 ) then
		self.Scale = math.Approach( self.Scale, 1, FrameTime() * 10 )
		self:UpdateScale()
	end

	-- Emit fiery particles
	if ( SERVER ) then
		local velocity = Vector( 0, 0, 0 )
			local physics = self:GetPhysicsObject()
			if ( physics and IsValid( physics ) ) then
				velocity = physics:GetVelocity()
			end
		local forward = self:GetUp()
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetAngles( Angle( self:EntIndex(), 0, 0 ) )
		self.OpenEffect = util.Effect( "dc_fire", effectdata )
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
	self:EmitSound( Sound( "Flashbang.Bounce" ) )
	self:Remove()

	local effectdata = EffectData() 
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() ) 
		effectdata:SetScale( math.random( 1,3 ) )
	util.Effect( "watersplash", effectdata )
end

function ENT:IsSpell()
	return true
end

function ENT:Team()
	return self.Owner:Team()
end