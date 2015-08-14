-- Jordan Brown (@drmelon)
-- 14/08/15
-- A beam of lightning.

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- Flag for whether or not being near this entity should light the player's way
ENT.IsLightSource = true
ENT.LightLevel = 0.5

-- The range of this spell
ENT.Range = 2000

-- The radius to apply damage when striking the ground
ENT.Radius = 5

-- Default Damage
ENT.Damage = 20

-- The runtime variable containing the starting position of the particle, for out-of-range cleanup purposes
ENT.StartPos = nil

-- Special Effects (ZAP)
ENT.EffectData = nil

-- env_beam
ENT.BeamRef = nil

function ENT:Initialize()
	-- Set up effect
	if SERVER then
		local startent = ents.Create( "info_target" )
		startent:SetPos( self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 2 + self.Owner:EyeAngles():Up() * -2 )
		startent:SetName( "beamStart" .. self.Owner:Nick() )
		
		local endent = ents.Create( "info_target" )
		local result = self.Owner:GetEyeTrace()
		if(result != nil) then
			endent:SetPos(result.HitPos)
		else
			endent:SetPos(self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * self.Range)
		end
		endent:SetName( "beamEnd" .. self.Owner:Nick() )
		
		local beam = ents.Create( "env_beam" )
		beam:SetAngles( Angle( 260, 0, 0 ) )
		beam:SetKeyValue( "LightningStart", "beamStart" .. self.Owner:Nick() )
		beam:SetKeyValue( "LightningEnd", "beamEnd" .. self.Owner:Nick() )
		beam:SetKeyValue( "rendercolor", "0 " .. 185 + math.random( -16, 16 ) .. " 230" )
		beam:SetKeyValue( "renderamt", 255 )
		beam:SetKeyValue( "texture", "sprites/laserbeam.vmt" )
		beam:SetKeyValue( "damage", 0 ) --beam doesn't do damage, but the hit trace will!
		beam:SetKeyValue( "spawnflags", 1 )
		beam:SetKeyValue( "framestart", 0 )
		beam:SetKeyValue( "framerate", 0 )
		beam:SetKeyValue( "NoiseAmplitude", 5 )
		beam:SetKeyValue( "TextureScroll", 0 )
		beam:SetKeyValue( "life", 0.4 )
		beam:SetKeyValue( "TeamNum", 0 )
		beam:SetKeyValue( "TouchType", 0 )
		beam:SetKeyValue( "Radius", 256 )
		beam:SetKeyValue( "StrikeTime", 1 )
		beam:SetKeyValue( "BoltWidth", 1 )	

		beam:Fire( "turnon", "", "" )
		
		startent:Spawn()
		endent:Spawn()
		beam:Spawn()
		
		-- Remove after they fire
		beam:Fire( "kill", "", 0.4 )
		startent:Fire( "kill", "", 0.4 )
		endent:Fire( "kill", "", 0.4 )
				
		-- Play Sound
		sound.Play("ambient/energy/spark5.wav", startent:GetPos())
		
		if(result != nil) then
			if(result.Entity:IsPlayer() && result.Entity:Team() ~= self.Owner:Team() ) then
				result.Entity:TakeDamage(self.Damage, self.Owner, self)
				result.Entity:SetVelocity(self.Owner:EyeAngles():Forward()*200 + Vector(0, 0, 300) ) --push em
			end
		end
		
		
		self:Remove()
	end
end

function ENT:Think()
	
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

function ENT:IsSpell()
	return true
end

if ( CLIENT ) then
	function ENT:Draw()

	end
end

function ENT:Team()
	if ( not self.Owner or ( not self.Owner.Team ) ) then return 0 end
	return self.Owner:Team()
end