-- Matthew Cormack (@johnjoemcbob)
-- 08/08/15
-- Poison projectile, inflicts base damage on hit and applies poison debuff

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- Current scale of the projectile
ENT.Scale = 0.01

-- The speed to fire this projectile at
ENT.Speed = 1000

-- The radius to apply poison and damage when blowing up
ENT.Radius = 5

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
	-- Play explosion sound
	self:EmitSound( Sound( "Flashbang.Bounce" ) )

	-- Play explosion effect
	local effectdata = EffectData() 
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() ) 
		effectdata:SetScale( math.random( 1, 3 ) / 5 )
	util.Effect( "StriderBlood", effectdata, true, true )

	-- Apply damage & debuff
	local entsinrange = ents.FindInSphere( self:GetPos(), self.Radius )
	for k, v in pairs( entsinrange ) do
		-- Is another player, on another team
		if ( ( v:IsPlayer() ) and ( v:Team() ~= self.Owner:Team() ) ) then
			v:TakeDamage( self.Damage, self.Owner, self )
			v:AddBuff( 3, GAMEMODE.Buffs[3] )
		end
	end

	-- Remove this projectile now
	self:Remove()
end

if ( CLIENT ) then
	function ENT:Draw()
		self:DrawModel()

		-- Light up the totem
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.pos = self:GetPos() + Vector( 0, 0, 25 )
			dlight.r = 155
			dlight.g = 0
			dlight.b = 255
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
	return self.Owner:Team()
end