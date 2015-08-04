-- Matthew Cormack (@johnjoemcbob)
-- 04/08/15
-- Base entity for spells in the gamemode
-- When the player activates an ability, a child of this entity will be spawned
-- which will decide the functionality of the spell

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	ENT.PrintName = "Base Spell"
end

ENT.Type = "anim"

function ENT:Initialize()
	if SERVER then
		self:SetTrigger( true )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_BBOX )
		self:SetCollisionBoundsWS( self.StartPos, self.EndPos )
		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

		self.PlayersContained = {}
	end
end

-- Trigger zone server logic
-- NOTE: Players can also be removed from the zone by GM:PostPlayerDeath & GM:PlayerDisconnected (init.lua)
if SERVER then
	function ENT:StartTouch( entity )
		if ( entity:IsPlayer() ) then
			-- Store the player in this zone for capturing logic
			self:AddPlayer( entity )
		end
	end

	function ENT:EndTouch( entity )
		if ( entity:IsPlayer() ) then
			-- Remove the player from this zone for capturing logic
			self:RemovePlayer( entity )
		end
	end

	function ENT:AddPlayer( ply )
		-- Overwrite any other trigger zones the player may have been in before
		-- NOTE: This is an attempt to combat overlapping trigger zones
		if ( ply.TriggerZone and IsValid( ply.TriggerZone ) and ( ply.TriggerZone ~= self ) ) then
			ply.TriggerZone:RemovePlayer( ply )
		end

		-- Add player to this zone
		self.PlayersContained[ply:EntIndex()] = ply
		PrintTable( self.PlayersContained )

		-- Store this zone on the player for clientside visuals
		ply.TriggerZone = self

		-- Check for capture ability against the changed number of contained players
		self:CompairTeamNumbers()
		print( "enter "..self.ZoneName )

		-- Send first information about this point to the new player
		self:SendClientInformation_Inside( ply )
	end

	function ENT:RemovePlayer( ply )
		self.PlayersContained[ply:EntIndex()] = nil
		PrintTable( self.PlayersContained )

		-- Remove this zone from the player for clientside visuals
		if ( ply.TriggerZone == self ) then
			ply.TriggerZone = nil
			self:SendClientInformation_Outside( ply )
		end

		-- Check for capture ability against the changed number of contained players
		self:CompairTeamNumbers()
		print( "exit "..self.ZoneName )
	end

	-- Function to compare the number of heroes and monsters inside the zone,
	-- to decide if it can be captured
	-- NOTE: Flags ENT.TeamCapturing to allow ENT:Think to run capturing logic
	function ENT:CompairTeamNumbers()
		local capture = TEAM_NONE
			local heroes = false
			local monsters = false
			for k, ply in pairs( self.PlayersContained ) do
				if ( ply:Team() == TEAM_HERO ) then
					heroes = true
				elseif ( ply:Team() == TEAM_MONSTER ) then
					monsters = true
				end
			end
			-- Heroes are present and monsters aren't, capture
			if ( heroes and ( not monsters ) ) then
				capture = TEAM_HERO
			end
			-- Monsters are present and heroes aren't, capture
			if ( monsters and ( not heroes ) ) then
				capture = TEAM_MONSTER
			end
			if ( heroes and monsters ) then
				capture = TEAM_BOTH
			end
			-- Can only capture if the point has no preceding points,
			-- or those have been captured already
			if ( self.PrecedingPoint and ( self.PrecedingPoint.MonsterControlled ) ) then
				capture = TEAM_NONE
			end
		self.TeamCapturing = capture
	end

	function ENT:Think()
		-- Point hasn't been captured
		if ( self.MonsterControlled ) then
			-- Heroes are capturing
			if ( self.TeamCapturing == TEAM_HERO ) then
				self.CaptureProgress = self.CaptureProgress + ( FrameTime() * self.CaptureSpeed )
				print( self.CaptureProgress )

				-- Flag that the heroes have won this point
				if ( self.CaptureProgress >= 100 ) then
					self.CaptureProgress = 100
					self.MonsterControlled = false
					self.TeamCapturing = false
					print( "capd "..self.ZoneName )

					-- Add score to any players inside at this point
					for k, ply in pairs( self.PlayersContained ) do
						ply:AddFrags( self.CaptureScore )
					end
				end

				-- Send every frame progress is changed
				for k, ply in pairs( self.PlayersContained ) do
					self:SendClientInformation_Inside( ply )
				end
			-- Heroes are losing progress
			elseif ( self.CaptureProgress > 0 ) then
				-- Monsters are erasing hero capture progress
				-- NOTE: Monsters can only revert before the heroes capture 100%
				if ( self.TeamCapturing == TEAM_MONSTER ) then
					self.CaptureProgress = self.CaptureProgress - ( FrameTime() * self.RevertSpeedMonster )
					print( self.CaptureProgress )
				end
				-- Time is erasing hero capture progress
				-- NOTE: Time can only revert before the heroes capture 100%
				if ( self.TeamCapturing == TEAM_NONE ) then
					self.CaptureProgress = self.CaptureProgress - ( FrameTime() * self.RevertSpeed )
					print( self.CaptureProgress )
				end

				-- Send every frame progress is changed
				for k, ply in pairs( self.PlayersContained ) do
					self:SendClientInformation_Inside( ply )
				end
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		-- Issues here with some map details (i.e. grass, bushes) draw through the rectangle,
		-- also the 3D2D culls too quickly when standing in the trigger zone
		-- 
		-- Draw the control point title a title over the middle, facing the player
		-- local trace = LocalPlayer():GetEyeTrace()
		-- local angle = LocalPlayer():EyeAngles()

		-- cam.Start3D2D( self:GetPos() + Vector( 0, 0, self.TitleHeight ), Angle( 180, angle.y + 90, -90 ), 1 )
			-- -- Title text backdrop
			-- surface.SetDrawColor( Color( 255, 165, 0, 255 ) )
			-- surface.DrawRect( -78, -16, 156, 32 )

			-- -- Title text
			-- surface.SetFont( "DermaLarge" )
			-- surface.SetTextColor( 255, 255, 255, 255 )
			-- surface.SetTextPos( -78, -16 )
			-- surface.DrawText( self.ZoneName )
		-- cam.End3D2D()
	end
end