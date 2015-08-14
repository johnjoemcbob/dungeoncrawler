-- Matthew Cormack (@johnjoemcbob)
-- 02/08/15
-- Map Chest
-- This is used for loot chests which already have models in the map,
-- like the normal chests they spawn loot when a hero is close and no
-- monsters are, and if it is not inside a monster control point

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	ENT.PrintName = "Map Chest"
end

ENT.Type = "anim"

-- Flag for whether or not the chest has been opened yet
-- Once open, it will not close again
ENT.IsOpen = false

-- The radius within the player must be in order for the chest to
-- open
ENT.OpenRadius = 150

-- The point which needs to be captured before this can be opened
-- Set by init.lua, loaded from sh_chests.lua
ENT.PrecedingPoint = nil

-- The level of loot this chest will spawn
-- Set by init.lua, loaded from sh_chests.lua
ENT.Level = 0

-- The rotating 'door' (lid) of the chest
ENT.Chest = nil

-- The loot entity deployed by this chest
ENT.Loot = nil

-- The particle system deployed as this chest opens
ENT.OpenEffect = nil

function ENT:Initialize()
	if SERVER then
		-- Find the chest by the closest rotating 'door' (the lid)
		local nearents = ents.FindInSphere( self:GetPos(), self.OpenRadius * 2 )
		local distance = -1
		for k, v in pairs( nearents ) do
			if ( v:GetClass() == "func_door_rotating" ) then
				local compare = v:GetPos()
					compare.z = self:GetPos().z -- Compensate for downplacement
				local dist = self:GetPos():Distance( compare )
				if ( ( distance == -1 ) or ( dist < distance ) ) then
					self.Chest = v
					distance = dist
				end
			end
		end

		-- Remove physics from this game logic entity
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )

		-- Lock the chest to begin with
		self.Chest:Fire( "lock" )
	end
end

if SERVER then
	function ENT:Think()
		if (
			( not self.IsOpen ) and
			(
				( self.PrecedingPoint == 0 ) or
				( not GAMEMODE.ControlPoints[game.GetMap()] ) or
				( not GAMEMODE.ControlPoints[game.GetMap()][self.PrecedingPoint].Entity.MonsterControlled )
			)
		)
		then
			-- Find nearby heroes/monsters
			local nearents = ents.FindInSphere( self:GetPos(), self.OpenRadius )
			for k, v in pairs( nearents ) do
				-- A living hero player
				if ( v:IsPlayer() and ( v:Team() == TEAM_HERO ) and ( not v.Ghost ) ) then
					self:Open( v )
				end
			end
		end
	end

	-- Function in charge of opening the chest model, playing effects & spawning loot
	function ENT:Open( ply )
		-- Play the opening animation on the chest
		self.Chest:Fire( "unlock" )
		timer.Simple( 0.1, function()
			self.Chest:Use( ply, self, USE_ON, 1 )

			timer.Simple( 0.1, function()
				self.Chest:Fire( "lock" )
			end )
		end )

		-- Spawn the loot giver
		self.Loot = ents.Create( "dc_loot" )
		self.Loot:SetPos( self:GetPos() + self:GetAngles():Up() * 10 )
		self.Loot:Spawn()
		self.Loot.Level = self.Level

		-- Spawn the particle system
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetAngles( self:GetAngles() )
		self.OpenEffect = util.Effect( "dc_chestopen", effectdata )

		-- Flag not to give loot more than once
		self.IsOpen = true
	end
end

if CLIENT then
	function ENT:Draw()
		return false
	end
end