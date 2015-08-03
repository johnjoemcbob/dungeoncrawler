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

-- The name of this trigger zone
ENT.ZoneName = "Control Point"

-- The type of control point this is
ENT.ZoneType = "Default"

-- The height at which to display the zone's name above the ground
ENT.TitleHeight = 200

-- The flag for whether or not the control point is being captured
ENT.IsCapturing = false

-- The current percentage of capture by the heroes
ENT.CaptureProgress = 0

-- The speed at which heroes can capture (multiplied by the heroes present)
ENT.CaptureSpeed = 50

-- The flag for whether or not this control point is monster controlled
ENT.MonsterControlled = true

-- The point preceding this one, which must be captured before this becomes available
-- NOTE: Can be null, for bonus/secret control points
ENT.PrecedingPoint = null

-- List of the contained players inside this trigger zone
ENT.PlayersContained = {}

function ENT:Initialize()
	if SERVER then
		self:SetTrigger( true )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_BBOX )
		self:SetCollisionBoundsWS( self.StartPos, self.EndPos )
		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
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
	end

	function ENT:RemovePlayer( ply )
		self.PlayersContained[ply:EntIndex()] = null
		PrintTable( self.PlayersContained )

		-- Remove this zone from the player for clientside visuals
		if ( ply.TriggerZone == self ) then
			ply.TriggerZone = null
		end

		-- Check for capture ability against the changed number of contained players
		self:CompairTeamNumbers()
		print( "exit" )
	end

	-- Function to compare the number of heroes and monsters inside the zone,
	-- to decide if it can be captured
	-- NOTE: Flags ENT.IsCapturing to allow ENT:Think to run capturing logic
	function ENT:CompairTeamNumbers()
		local capture = false
			local heroes = false
			local monsters = false
			for k, ply in pairs( self.PlayersContained ) do
				if ( ply:Team() == 1 ) then
					heroes = true
				elseif ( ply:Team() == 2 ) then
					monsters = true
				end
			end
			-- Heroes are present but monsters aren't, capture
			if ( heroes and ( not monsters ) ) then
				capture = true
			end
		self.IsCapturing = capture
	end

	function ENT:Think()
		-- Heroes are capturing and haven't already captured
		if ( self.IsCapturing and self.MonsterControlled ) then
			self.CaptureProgress = self.CaptureProgress + ( FrameTime() * self.CaptureSpeed )

			-- Flag that the heroes have won this point
			if ( self.CaptureProgress >= 100 ) then
				self.CaptureProgress = 100
				self.MonsterControlled = false
				self.IsCapturing = false
				print( "capd")
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