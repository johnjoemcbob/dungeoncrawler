local Data

function EFFECT:Init( data )
	Data = data
	self.particles = 100
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	local vOffset = Data:GetOrigin() + Vector( 0, 0, -30 )
	local vAngle = Data:GetAngles()

	local emitter = ParticleEmitter( vOffset, false )
		for i = 0, self.particles do
			local particle = emitter:Add( "effects/softglow", vOffset )
			if particle then
				particle:SetAngles( vAngle )
				particle:SetVelocity( Vector( math.random( -40, 40 ), math.random( 20, 50 ), math.random( 40, 50 ) ) )
				particle:SetColor( 255, 102, 0 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 2 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 0.1 )
				particle:SetStartLength( 1 )
				particle:SetEndSize( 5 )
				particle:SetEndLength( 4 )
				particle:SetGravity( Vector( 0, 0, -50 ) )
			end
		end
	emitter:Finish()
end