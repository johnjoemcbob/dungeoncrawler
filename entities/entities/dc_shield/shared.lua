-- Jordan Brown (@drmelon)
-- 14/08/15
-- A floating shield.

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- Flag for whether or not being near this entity should light the player's way
ENT.IsLightSource = true
ENT.LightLevel = 0.2

-- The range of this spell
ENT.Range = 20

-- The radius to spin around the player
ENT.Radius = 20

-- Default Damage -- here damage is used as health.
ENT.Damage = 20

-- Accumulator for sin/cos functions
ENT.Accumulator = 0.0

-- Sin/Cos Offset from start point (so shields are spaced out)
ENT.Offset = 0.0

function ENT:Initialize()
	-- Set up shields

	self:SetModel( "models/props_c17/streetsign004f.mdl" )
	self:SetMaterial( "models/debug/debugwhite" )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self.RenderGroup = RENDERGROUP_BOTH
	self:SetColor( Color( 0, 100, 255, 120	) )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	self:SetMoveType(MOVETYPE_NONE)
	self:SetHealth(self.Damage)

	
end

function ENT:Think()
	-- Rotate around owner at Radius distance.
	if (SERVER) then	
		self:SetParent(self.Owner)
		self.Accumulator = self.Accumulator + 0.1
		self:SetPos(self.Owner:GetPos() + Vector(math.sin(self.Accumulator + self.Offset) * self.Radius, math.cos(self.Accumulator + self.Offset) * self.Radius, 0) + Vector(0, 0, 1) * 50)
		self:SetAngles((self:GetPos() - self.Owner:GetPos()):Angle() + Angle(0, 90, 0))
		
		self:SetParent(nil)
		if(self.Accumulator > 6 or self:Health() < 1) then
			self:Remove()
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

function ENT:BlowUp()
	
	self:Remove()
end

if( CLIENT ) then
	function ENT:Draw()
		render.SetLightingMode(2)
		self:DrawModel()
		render.SetLightingMode(0)
	end
end



function ENT:IsSpell()
	return true
end

function ENT:Team()
	if ( not self.Owner or ( not self.Owner.Team ) ) then return 0 end
	return self.Owner:Team()
end