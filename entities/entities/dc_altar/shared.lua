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


function ENT:Initialize()
	
	-- Set own model for table.
	self:SetModel( "models/props_combine/breendesk.mdl" )
	self:SetSolid( SOLID_VPHYSICS )
	self.DefaultPos = self:GetPos()

	
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
		self.Skull:SetAngles( Angle( 0, 0, 0 ) )
		self.Skull:SetPos( self.SkullHolder:GetPos() + ( self.SkullHolder:GetAngles():Up() * 15 ) )
		self.Skull:SetParent( self.SkullHolder )
		
		-- Skull Horn (Left)
		self.SkullHornL = ents.Create( "prop_dynamic" )
		self.SkullHornL:SetModel( "models/Gibs/HGIBS_spine.mdl" )
		self.SkullHornL:SetAngles( Angle( 0, 0, -30) )
		self.SkullHornL:SetPos( self.Skull:GetPos() + ( self.Skull:GetAngles():Up() * 5 ) + ( self.Skull:GetAngles():Right() * -5 ) )
		self.SkullHornL:SetParent( self.SkullHolder )	
		
		-- Skull Horn (Right)
		self.SkullHornR = ents.Create( "prop_dynamic" )
		self.SkullHornR:SetModel( "models/Gibs/HGIBS_spine.mdl" )
		self.SkullHornR:SetAngles( Angle( 0, 180, -30) )
		self.SkullHornR:SetPos( self.Skull:GetPos() + ( self.Skull:GetAngles():Up() * 5 ) + ( self.Skull:GetAngles():Right() * 5 ) )
		self.SkullHornR:SetParent( self.SkullHolder )	
		
		-- Decorative Tablet
		self.Tablet = ents.Create( "prop_dynamic" )
		self.Tablet:SetModel( "models/props_c17/Frame002a.mdl" )
		self.Tablet:SetAngles( Angle( 90, 0, 0 ) )
		self.Tablet:SetPos( self.Entity:GetPos() + ( self.Entity:GetAngles():Up() * 31 ) )
		self.Tablet:SetParent( self.Entity )		
		

		
		
	end
	
end

function ENT:CheckHeroes()
	local entsinrange = ents.FindInSphere( self:GetPos(), self.Radius )
	local foundplayer = false
	for k, v in pairs( entsinrange ) do
		-- Is a player
		if ( v:IsPlayer() ) then
			if ( v:Team() == TEAM_HERO ) then
				foundplayer = true
			end
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
	
	
	
	-- If we found players, bring up menu for each of them on clientside? TODO
	-- if( CLIENT ) then
end