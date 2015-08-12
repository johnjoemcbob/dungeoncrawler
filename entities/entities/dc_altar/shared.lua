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
ENT.DelayedCardFlip = 150
ENT.AnimStage = 0 
ENT.MenuOpened = 0
ENT.SpellCardModels = {}
ENT.TotalKnownSpells = 0


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
		if(LocalPlayer():GetPos():Distance(self:GetPos()) < self.Radius && LocalPlayer():Team() == TEAM_HERO) then
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
			
			self.DelayedCardFlip = self.DelayedCardFlip - 1

			
			if(self.DelayedCardFlip <= 0) then
				self.PlayerMenuTime = self.PlayerMenuTime + 1
				if(self.PlayerMenuTime >= 300) then
					self.PlayerMenuTime = 300
				end			
				self.DelayedCardFlip = 0
			end
			
			-- Get list of available spells -- GM.Spells!
			if(self.MenuOpened == 0) then
				local spellnum = 0
				self.TotalKnownSpells = 0
				for k, v in pairs(GAMEMODE.Spells) do
					local cardmodel = ClientsideModel(	"models/props_c17/Frame002a.mdl", RENDERGROUP_BOTH )
					cardmodel:SetPos(self:GetPos() + self:GetAngles():Up() * 40)
					cardmodel:SetAngles(self:GetAngles() + Angle(-90, 0, 0))
					cardmodel:SetModelScale(0.25, 0)
					spellnum = spellnum + 1
					self.TotalKnownSpells = self.TotalKnownSpells + 1
					table.insert(self.SpellCardModels, cardmodel )
					
				end
				self.MenuOpened = 1
			end
			local i = 1
			for k, v in pairs(GAMEMODE.Spells) do
				self:DrawSpellCard(self.SpellCardModels[i], v, i, (self.PlayerMenuTime - i / 200 * 90))
				i = i + 1
			end
			
			
			
			-- When the player presses use...		
				-- Check the player's eye traces against each card
				-- If a card is hit...
					-- Pick this spell, disable the first-picked spell and move second-picked to first-picked slot.
				
	
		else
			self.PlayerMenuTime = 0
			self.DelayedCardFlip = 150
			self.MenuOpened = 0
			-- Delete spell cards
			for k, v in pairs(self.SpellCardModels) do
				if(IsValid(v)) then
					v:Remove()
				end
			end
			self.SpellCardModels = {}

		end
	end
end


--    /!\ UGLY 3D2D CODE /!\
--	IT'S A DISGRACE, DON'T LOOK
--==============================

function ENT:DrawSpellCard(cardmodel, cardinfo, cardnum, rotamt)

	if( CLIENT ) then
		if(cardinfo != nil) then
			-- rotation / movement / floating stuff
			cardmodel:SetPos(self:GetPos() + (self:GetAngles():Right() * ((60 * cardnum / self.TotalKnownSpells) - 35) )   + (self:GetAngles():Up() * (40 + math.sin(CurTime() + cardnum) * 1)))
			cardmodel:SetAngles(self:GetAngles() + Angle(-90 - rotamt, 0, 0))
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

	
	if( CLIENT ) then
		if(LocalPlayer().CurrentAltar == self) then
			self:OpenMenu()
		end
	end

end

function ENT:Draw()
	self:DrawModel()


end
