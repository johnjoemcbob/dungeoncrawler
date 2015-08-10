-- Jordan Brown (@drmelon)
-- 09/08/15
-- Spell Altar
-- This entity, when interacted with, allows
-- a player to change which two spells they have equipped.
-- Props in use by the altar
-- models/props_combine/breendesk.mdl
-- models/Gibs/HGIBS.mdl
-- models/Gibs/HGIBS_spine.mdl
-- models/props_docks/dock01_cleat01a.mdl
-- models/props_c17/Frame002a.mdl
-- models/props_lab/bindergreenlabel.mdl
-- Frame002a spawns in a vertical position.

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	ENT.PrintName = "Spell Altar"
end

ENT.Type = "anim"

-- Flag for whether or not being near this entity should light the player's way
ENT.IsLightSource = true
ENT.LightLevel = 2
ENT.Radius = 50
ENT.Active = false
ENT.HornsIgnited = false
ENT.PlayersInRange = {}
ENT.PlayerMenuTime = 0
ENT.AnimStage = 0

function ENT:Initialize()
	-- Set own model for table.
	self:SetModel( "models/props_combine/breendesk.mdl" )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.DefaultPos = self:GetPos()

	-- Store the old angles and reset to default for decoration setup
	local oldangles = self:GetAngles()
	self:SetAngles( Angle( 0, 180, 0 ) )

	if SERVER then
		-- Spawn the altar's decorations

		-- Skull-holder (boat cleat)
		self.SkullHolder = ents.Create( "prop_dynamic" )
		self.SkullHolder:SetModel( "models/props_docks/dock01_cleat01a.mdl" )
		self.SkullHolder:SetAngles( Angle( 0, 90, 0 ) )
		self.SkullHolder:SetPos( self:GetPos() + ( self:GetAngles():Forward() * -15 ) + (self:GetAngles():Up() * 25 ) )
		self.SkullHolder:SetParent( self.Entity )

		-- Skull
		self.Skull = ents.Create( "prop_dynamic" )
		self.Skull:SetModel( "models/Gibs/HGIBS.mdl" )
		self.Skull:SetAngles( Angle( 0, 180, 0 ) )
		self.Skull:SetPos( self.SkullHolder:GetPos() + ( self.SkullHolder:GetAngles():Up() * 15 ) )
		self.Skull:SetParent( self.SkullHolder )

		-- Skull Horn (Left)
		self.SkullHornL = ents.Create( "prop_dynamic" )
		self.SkullHornL:SetModel( "models/Gibs/HGIBS_spine.mdl" )
		self.SkullHornL:SetAngles( Angle( 0, 180, -30) )
		self.SkullHornL:SetPos( self.Skull:GetPos() + ( self.Skull:GetAngles():Up() * 5 ) + ( self.Skull:GetAngles():Right() * -5 ) )
		self.SkullHornL:SetParent( self.SkullHolder )

		-- Skull Horn (Right)
		self.SkullHornR = ents.Create( "prop_dynamic" )
		self.SkullHornR:SetModel( "models/Gibs/HGIBS_spine.mdl" )
		self.SkullHornR:SetAngles( Angle( 0, 0, -30) )
		self.SkullHornR:SetPos( self.Skull:GetPos() + ( self.Skull:GetAngles():Up() * 5 ) + ( self.Skull:GetAngles():Right() * 5 ) )
		self.SkullHornR:SetParent( self.SkullHolder )

		-- Decorative Tablet
		self.Tablet = ents.Create( "prop_dynamic" )
		self.Tablet:SetModel( "models/props_c17/Frame002a.mdl" )
		self.Tablet:SetAngles( Angle( 90, 0, 0 ) )
		self.Tablet:SetPos( self.Entity:GetPos() + ( self.Entity:GetAngles():Up() * 31 ) )
		self.Tablet:SetParent( self.Entity )
	end

	-- Change back to real angles now that the decorations are parented
	self:SetAngles( oldangles )
end

function ENT:CheckHeroes()
	local entsinrange = ents.FindInSphere( self:GetPos(), self.Radius )
	local foundplayer = false
	for k, v in pairs( entsinrange ) do
		-- Is a player
		if ( v:IsPlayer() ) then
			if ( v:Team() == TEAM_HERO ) then
				if( SERVER ) then
					foundplayer = true
				end
			end
		end
	end
	
	if( CLIENT ) then 
		if(LocalPlayer():GetPos():Distance(self:GetPos()) < self.Radius) then
			LocalPlayer().CurrentAltar = self
		end
	end
	
	self.Active = foundplayer
end

function ENT:IgniteHorns()
	-- Light up those horns with particles, woo
	if(!self.HornsIgnited) then
		ParticleEffectAttach( "fire_small_02", PATTACH_POINT_FOLLOW, self.SkullHornL, 0 )
		ParticleEffectAttach( "fire_small_02", PATTACH_POINT_FOLLOW, self.SkullHornR, 0 )
		self:EmitSound("ambient/fire/gascan_ignite1.wav")
		self.HornsIgnited = true
	end
end

function ENT:ExtinguishHorns()
	self.SkullHornL:StopParticles()
	self.SkullHornR:StopParticles()
	self.HornsIgnited = false
end

function ENT:OpenMenu()
	if( CLIENT ) then
		if( self:GetPos():Distance( LocalPlayer():GetPos() ) <= self.Radius * 1.5 ) then
			-- Increment animation timer
			self.PlayerMenuTime = self.PlayerMenuTime + 1
			
			if(self.PlayerMenuTime >= 300) then
				self.PlayerMenuTime = 300
			end
			
			
			-- Get list of available spells -- GM.Spells!
			
			-- Check animation stage and render accordingly, rendering a card for each spell
			if(self.AnimStage == 0) then
				-- Stage 1: Cards are face-down, and rotate up to face the viewer.
					--for k, v in pairs( GM.Spells ) do
						-- Draw card per spell	(separate 3D2D calls? individual card rotations that way)								
						self:Draw3D2DCard(0, 0, self.PlayerMenuTime / 300 * -90)
				--end
			end
			
			
			
			-- When the player presses use...		
				-- Check the player's eye traces against each card
				-- If a card is hit...
					-- Pick this spell, disable the first-picked spell and move second-picked to first-picked slot.
				
	
		else
			self.PlayerMenuTime = 0
		end
	end
end


--    /!\ UGLY 3D2D CODE /!\
--	IT'S A DISGRACE, DON'T LOOK
--==============================

function ENT:Draw3D2DCard(cardnum, cardinfo, rotamt)

	if( CLIENT ) then
		if(cardnum == nil) then
			cardnum = 0
		end

		
		if(rotamt > -45) then
			-- Front-Side of Spell Card
			cam.Start3D2D( self:GetPos() + self:GetAngles():Up() * 35 + (Vector( 0, -rotamt / 15,  rotamt / 35 ) * self:GetAngles():Forward()) + (self:GetAngles():Up() * (math.sin(CurTime()))), self:GetAngles() + Angle( 180 + rotamt, 0, 0 ), 1 )
				surface.SetDrawColor( Color( 255, 255, 255, 255 ))
				surface.DrawRect(0, 0+cardnum*16, -15, 7)
			cam.End3D2D()
			
			-- Back-Side of Spell Card
			cam.Start3D2D( self:GetPos() + self:GetAngles():Up() * 35.1 +(Vector( 0, -rotamt / 14.8,  rotamt / 35 ) * self:GetAngles():Forward())  + (self:GetAngles():Up() * (math.sin(CurTime()))) , self:GetAngles() + Angle( 0 + rotamt, 0, 0 ), 1 )
				surface.SetDrawColor( Color( math.sin(CurTime() / 0.70) * 100 + 100, 25, math.cos(CurTime() / 0.75) * 100 + 100, 255 ) )	
				surface.DrawRect(0, 0+cardnum*16, 15, 7)
			cam.End3D2D()		
		else

			
			-- Back-Side of Spell Card
			cam.Start3D2D( self:GetPos() + self:GetAngles():Up() * 35.1 + (Vector( 0, -rotamt / 14.8,  rotamt / 35 ) * self:GetAngles():Forward())  + (self:GetAngles():Up() * (math.sin(CurTime()))) , self:GetAngles() + Angle( 0 + rotamt, 0, 0 ), 1 )
				surface.SetDrawColor( Color( math.sin(CurTime() / 0.70) * 100 + 100, 25, math.cos(CurTime() / 0.75) * 100 + 100, 255 ) )	
				surface.DrawRect(0, 0+cardnum*16, 15, 7)
			cam.End3D2D()	
			
			-- Front-Side of Spell Card
			cam.Start3D2D( self:GetPos() + self:GetAngles():Up() * 35 + (Vector( 0, -rotamt / 15,  rotamt / 35 ) * self:GetAngles():Forward())  + (self:GetAngles():Up() * (math.sin(CurTime()))), self:GetAngles() + Angle( 180 + rotamt, 0, 0 ), 1 )
				surface.SetDrawColor( Color( 255, 255, 255, 255 ))
				surface.DrawRect(0, 0+cardnum*16, -15, 7)
			cam.End3D2D()
		end
	end
	

end

function ENT:Think()
	-- The spell altar should light up the horns when heroes get close, and then extinguish if nobody is nearby.
	self:CheckHeroes()
	
	
	if( SERVER ) then
		if(self.Active) then
			self.IsLightSource = true
			self:IgniteHorns()
		else
			self.IsLightSource = false
			self:ExtinguishHorns()
		end
	end



end

function ENT:Draw()
	self:DrawModel()
	

end

-- Hook for 3D2D
hook.Add( "PostDrawOpaqueRenderables", "AltarMenu", function()
	
	local altar = LocalPlayer().CurrentAltar
	if(altar != nil && IsValid(altar)) then
		altar:OpenMenu()
	end
	
	
end )
