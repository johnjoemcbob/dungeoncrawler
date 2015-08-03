local Data

function EFFECT:Init( data )
	Data = data
	self.particles = 120
	self.radius = 15
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	local vOffset = Data:GetOrigin() + Vector( 0, 0, -25 )
	local vAngle = Data:GetAngles()

	local emitter = ParticleEmitter( vOffset, false )
		for i = 0, self.particles do
			local particle = emitter:Add( "effects/softglow", vOffset )
			if particle then
				-- Calculate the x and y velocity of this particle in order to make a circle effect
				local angulardisplacement = 360 / self.particles * i
				local x = math.sin( angulardisplacement )
				local y = math.cos( angulardisplacement )

				particle:SetAngles( vAngle )
				particle:SetVelocity( Vector( x * self.radius, y * self.radius, 0 ) )
				particle:SetColor( 255, 102, 0 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( self.radius / 20 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 0.1 )
				particle:SetStartLength( 1 )
				particle:SetEndSize( 5 )
				particle:SetEndLength( 4 )
				particle:SetGravity( Vector( 0, 0, 0 ) )
			end
		end
	emitter:Finish()
end