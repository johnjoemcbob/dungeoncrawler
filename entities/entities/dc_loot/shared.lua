-- Matthew Cormack (@johnjoemcbob)
-- 02/08/15
-- Loot
-- This distributes loot once to each hero player
-- Once a player has received their portion of the loot,
-- this entity will disappear in their view

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	ENT.PrintName = "Loot"
end

ENT.Type = "anim"

-- Table containing the heroes which have already claimed loot from
-- this source
ENT.HeroesClaimed = {}

-- Store the original position of the loot for resetting during animation
ENT.DefaultPos = null

-- The outlying scale values to lerp between
ENT.StartScale = 0.1
ENT.MinScale = 0.8
ENT.MaxScale = 1.2
ENT.TargetScale = ENT.MinScale
ENT.IcrementScale = 0.4

-- The speed at which to rotate the loot, multiplied by FrameTime()
ENT.RotationSpeed = 40

function ENT:Initialize()
	self:SetModel( "models/props_lab/binderblue.mdl" )
	self:SetModelScale( self.StartScale, 0 )

	self.DefaultPos = self:GetPos()

	if SERVER then
		-- Remove physics from this game logic entity
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
	end
end

if SERVER then
	function ENT:Think()
		-- Play the loot halo effect
		local forward = self:GetUp()
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetAngles( self:GetAngles() )
		self.OpenEffect = util.Effect( "dc_loothalo", effectdata )
	end
end

if CLIENT then
	function ENT:Draw()
		local function round( num, idp )
			return tonumber( string.format( "%." .. ( idp or 0 ) .. "f", num ) )
		end

		-- Apply some small scaling for visual appeal
		local oldscale = round( self:GetModelScale(), 3 )
		if ( oldscale == self.StartScale ) then
			-- Reset to the original position after playing the opening animation
			--self:SetPos( self.DefaultPos )

			self.TargetScale = self.MinScale
		elseif ( oldscale == self.MinScale ) then
			self.TargetScale = self.MaxScale
		elseif ( oldscale == self.MaxScale ) then
			self.TargetScale = self.MinScale
		end

		-- Lerp between scales (built in lerp wasn't working as I expected -MC)
		if ( self.TargetScale > oldscale ) then
			self:SetModelScale( oldscale + self.IcrementScale * FrameTime(), 0 )
		else
			self:SetModelScale( oldscale - self.IcrementScale * FrameTime(), 0 )
		end

		-- Move on the Z axis depending on the opening chest animation and the scale of the loot
		if ( oldscale < self.MinScale ) then
			-- These aren't very pretty magical numbers but it works
			self:SetPos( self.DefaultPos + Vector( 0, 0, -30 + ( oldscale - self.StartScale ) * 10 ) )
		else
			self:SetPos( self:GetPos() + Vector( 0, 0, ( 1 - oldscale ) * 0.1 ) )

			-- Slowly rotate the yaw of the loot
			self:SetAngles( self:GetAngles() + Angle( 0, FrameTime() * self.RotationSpeed, 0 ) )
		end

		self:DrawModel()

		-- Light up the loot tome
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.pos = self:GetPos()
			dlight.r = 255
			dlight.g = 150
			dlight.b = 200
			dlight.brightness = 1
			dlight.Decay = 1000
			dlight.Size = 128
			dlight.DieTime = CurTime() + 1
		end
	end
end