local Data

function EFFECT:Init( data )
	Data = data
	self.particles = 10
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	local vOffset = Data:GetOrigin() + Vector( 0, 0, -18 )

	local emitter = ParticleEmitter( vOffset, false )
		for i = 0, self.particles do
			local particle = emitter:Add( "effects/softglow", vOffset )
			if particle then
				particle:SetAngles( Angle( 0, 0, 0 ) )
				particle:SetVelocity( Vector( math.random( -5, 5 ), math.random( -5, 5 ), math.random( 50, 70 ) ) )
				particle:SetColor( 255, 102, 0 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 1 / ( i + 1 ) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 50 )
				particle:SetStartLength( 50 )
				particle:SetEndSize( 5 )
				particle:SetEndLength( 5 )
				particle:SetGravity( Vector( 0, 0, -10 ) )
			end
		end
	emitter:Finish()
end