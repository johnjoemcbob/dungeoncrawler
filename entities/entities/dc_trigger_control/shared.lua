-- Matthew Cormack (@johnjoemcbob)
-- 02/08/15
-- Control Point Trigger Zone
-- This checks for the number of heroes/monsters inside it and,
-- if only one side is present, will start capturing

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	ENT.PrintName = "Control Point Trigger Zone"
end

ENT.Type = "anim"

-- The bounding box corner positions for this trigger
ENT.StartPos = Vector( 0, 0, 0 )
ENT.EndPos = Vector( 1, 1, 1 )

-- The id of this trigger zone in the table
ENT.ID = 0

-- The name of this trigger zone
ENT.ZoneName = "Control Point"

-- The type of control point this is
ENT.ZoneType = "Default"

-- The height at which to display the zone's name above the ground
ENT.TitleHeight = 200

-- The flag for which team is capturing the control point (TEAM_NONE,TEAM_HERO,TEAM_MONSTER)
ENT.TeamCapturing = TEAM_NONE

-- The current percentage of capture by the heroes
ENT.CaptureProgress = 0

-- The speed at which heroes can capture (multiplied by the heroes present)
ENT.CaptureSpeed = 50

-- The points to be awarded to the capturing players
ENT.CaptureScore = 2

-- The speed at which time reverts capture progress
ENT.RevertSpeed = ENT.CaptureSpeed / 4

-- The speed at which monsters revert capture progress
ENT.RevertSpeedMonster = ENT.RevertSpeed * 2

-- The flag for whether or not this control point is monster controlled
ENT.MonsterControlled = true

-- The point preceding this one, which must be captured before this becomes available
-- NOTE: Can be nil, for bonus/secret control points
ENT.PrecedingPoint = nil

-- List of the contained players inside this trigger zone
-- NOTE: The table must be created inside Initialize so that it is not shared
-- between all trigger zones
ENT.PlayersContained = nil

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

-- NET message initialization and send logic
if SERVER then
	util.AddNetworkString( "DC_Client_ControlPoint" )
	util.AddNetworkString( "DC_Client_ControlPoint_Capture" )

	-- NOTE: ply can be a single player or a table of players (?)
	function ENT:SendClientInformation_Inside( ply )
		-- Send the relevant information about this control point to any players within it
		net.Start( "DC_Client_ControlPoint" )
			net.WriteString( self.ZoneName )
			net.WriteFloat( tonumber( self.CaptureProgress or 0 ) )
			net.WriteFloat( tonumber( self.TeamCapturing or 0 ) )
		net.Send( ply )
	end

	-- NOTE: ply can be a single player or a table of players (?)
	function ENT:SendClientInformation_Outside( ply )
		-- Send the null information to blank the player's HUD of the point they just exited
		net.Start( "DC_Client_ControlPoint" )
			net.WriteString( "" )
			net.WriteFloat( 0 )
			net.WriteFloat( 0 )
		net.Send( ply )
	end

	-- NOTE: ply can be a single player or a table of players (?)
	function ENT:SendClientInformation_Capture( ply )
		-- Send the null information to blank the player's HUD of the point they just exited
		net.Start( "DC_Client_ControlPoint_Capture" )
			net.WriteFloat( self.ID )
			net.WriteBit( self.MonsterControlled )
		net.Send( ply )
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

		-- Store this zone on the player for clientside visuals
		ply.TriggerZone = self

		-- Check for capture ability against the changed number of contained players
		self:CompairTeamNumbers()

		-- Send first information about this point to the new player
		self:SendClientInformation_Inside( ply )
	end

	function ENT:RemovePlayer( ply )
		self.PlayersContained[ply:EntIndex()] = nil

		-- Remove this zone from the player for clientside visuals
		if ( ply.TriggerZone == self ) then
			ply.TriggerZone = nil
			self:SendClientInformation_Outside( ply )
		end

		-- Check for capture ability against the changed number of contained players
		self:CompairTeamNumbers()
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

				-- Flag that the heroes have won this point
				if ( self.CaptureProgress >= 100 ) then
					self.CaptureProgress = 100
					self.MonsterControlled = false
					self.TeamCapturing = false

					-- Add score to any players inside at this point
					for k, ply in pairs( self.PlayersContained ) do
						ply:AddFrags( self.CaptureScore )
					end

					-- Send captured state to every player
					for k, ply in pairs( player.GetAll() ) do
						self:SendClientInformation_Capture( ply )
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
				end
				-- Time is erasing hero capture progress
				-- NOTE: Time can only revert before the heroes capture 100%
				if ( self.TeamCapturing == TEAM_NONE ) then
					self.CaptureProgress = self.CaptureProgress - ( FrameTime() * self.RevertSpeed )
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