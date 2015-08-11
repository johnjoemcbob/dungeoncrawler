local Data
local emitter

local function collide( particle, position, normal )
	-- Kill the falling rain particle
	particle:SetDieTime( 0 )

	-- Emit a new particle for the splash effect
	-- if ( math.random( 1, 70 ) == 1 ) then
		-- local effectdata = EffectData() 
			-- effectdata:SetStart( position )
			-- effectdata:SetOrigin( position ) 
			-- effectdata:SetScale( math.random( 1, 3 ) )
		-- util.Effect( "watersplash", effectdata )
	-- end
end

function EFFECT:Init( data )
	Data = data
	self.particles = 120
	self.radius = 500

	local vOffset = Data:GetOrigin() + Vector( 0, 0, 400 )
	local vAngle = Data:GetAngles()

	emitter = ParticleEmitter( vOffset, false )
		for i = 0, self.particles do
			-- Calculate the x and y velocity of this particle in order to make a circle effect
			local angulardisplacement = 360 / self.particles * i
			local x = math.sin( angulardisplacement ) * self.radius
			local y = math.cos( angulardisplacement ) * self.radius

			
			local particle = emitter:Add( "particle/Water/WaterDrop_001a", vOffset + Vector( math.random( 0, x ), math.random( 0, y ), math.random( -50, 10 ) ) )
			if particle then
				particle:SetVelocity( Vector( 0, 0, -500 ) )
				particle:SetColor( 180, 180, 180 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 4 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 5 )
				particle:SetStartLength( 1 )
				particle:SetEndSize( 10 )
				particle:SetEndLength( 10 )
				particle:SetGravity( Vector( 0, 0, -10 ) )
				particle:SetCollide( true )
				particle:SetBounce( 0 )
				particle:SetCollideCallback( collide )
			end
		end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end