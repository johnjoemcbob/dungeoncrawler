-- Matthew Cormack (@johnjoemcbob)
-- 02/08/15
-- Map Chest
-- This is used for loot chests which already have models in the map,
-- like the normal chests they spawn loot when a hero is close and no
-- monsters are, and if it is not inside a monster control point

local Material_Padlock = Material( "icon16/lock.png" )

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

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Locked" )
end

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

		-- Display a padlock if the chest has a preceding point
		if ( self.PrecedingPoint ) then
			self:SetLocked( self.PrecedingPoint )
		end
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

		-- Play the opening sound
		self:EmitSound( "ambient/machines/catapult_throw.wav" )

		-- Flag not to give loot more than once
		self.IsOpen = true
	end

	function ENT:ControlPointCaptured( point )
		if ( not self.PrecedingPoint ) then return end

		-- Stop displaying the padlock if the chest is unlocked
		if ( point >= self.PrecedingPoint ) then
			self:SetLocked( 0 )
		end
	end
end

if CLIENT then
	function ENT:Draw()
		return false
	end

	hook.Add( "PostDrawOpaqueRenderables", "DC_DrawChestPadlock", function()
		for k, chest in pairs( ents.FindByClass( "dc_chest_map" ) ) do
			if ( chest:GetLocked() ~= 0 ) then
				cam.Start3D2D( chest:GetPos() + ( chest:GetAngles():Forward() * 22 ) + Vector( 0, 0, -25 ), chest:GetAngles() + Angle( 0, 90, 90 ), 1 )
					surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
					surface.SetMaterial( Material_Padlock )
					surface.DrawTexturedRect( -8, -8, 16, 16 )
				cam.End3D2D()
				cam.Start3D2D( chest:GetPos() + ( chest:GetAngles():Forward() * 22 ) + Vector( 0, 0, -30 ), chest:GetAngles() + Angle( 0, 90, 90 ), 0.1 )
					local font = "CloseCaption_Bold"
					local text = GAMEMODE.ControlPoints[game.GetMap()][chest:GetLocked()].Title
					draw.SimpleTextOutlined( text, font, 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color( 0, 0, 0, 255 ) )
				cam.End3D2D()
			end
		end
	end )
end