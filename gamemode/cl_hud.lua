-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 03/08/15
-- Main clientside hud visuals

-- The currently displayed progress amount, which is lerped as new information is received
local Progress = 0

-- The table of information about the control point minimap
local Minimap = {}

-- Initialization of this message is contained within dc_trigger_control/shared.lua
net.Receive( "DC_Client_ControlPoint", function( len )
	LocalPlayer().ControlPoint = {
		Name = net.ReadString(),
		Progress = net.ReadFloat(),
		TeamCapturing = net.ReadFloat()
	}
end )

function Initialize_HUD( self )
	-- First find the size of the map needed to represent the control points
	local x = {
		min = nil,
		max = nil
	}
	local y = {
		min = nil,
		max = nil
	}
	for k, v in pairs( self.ControlPoints ) do
		if ( ( not x.min ) or ( v.Position.x < x.min ) ) then
			x.min = v.Position.x
		end
		if ( ( not x.max ) or ( v.Position.x > x.max ) ) then
			x.max = v.Position.x
		end
		if ( ( not y.min ) or ( v.Position.y < y.min ) ) then
			y.min = v.Position.y
		end
		if ( ( not y.max ) or ( v.Position.y > y.max ) ) then
			y.max = v.Position.y
		end
	end

	-- Add some extra on each size for a border
	local width = math.Distance( x.min, 0, x.max, 0 )
	local height = math.Distance( y.min, 0, y.max, 0 )
	x.min = x.min - ( width / 10 )
	x.max = x.max + ( width / 10 )
	y.min = y.min - ( height / 10 )
	y.max = y.max + ( height / 10 )

	-- Fill the size information into the table
	Minimap.X = {}
		Minimap.X.min = x.min
		Minimap.X.max = x.max
		Minimap.X.dif = math.Distance( x.min, 0, x.max, 0 )
	Minimap.Y = {}
		Minimap.Y.min = y.min
		Minimap.Y.max = y.max
		Minimap.Y.dif = math.Distance( y.min, 0, y.max, 0 )

	-- Store the normalized control point positions for displaying
	Minimap.Points = {}
	for k, v in pairs( self.ControlPoints ) do
		table.insert( Minimap.Points, {
			Title = v.Title,
			Position = {
				x = ( v.Position.x + math.abs( x.min ) ) / Minimap.X.dif,
				y = ( v.Position.y + math.abs( y.min ) ) / Minimap.Y.dif,
			}
		} )
	end
end

function GM:HUDPaint()
	HUDPaint_ControlPoint_Overall( self )

	HUDPaint_ControlPoint_Current()
end

-- Display information about the overall location and state of all control points
function HUDPaint_ControlPoint_Overall( self )
	--draw.DrawText( self.ControlPoints[2].Title, "TargetID", ScrW() * 0.5, ScrH() * 0.1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

	if ( Minimap.Points ) then
		for k, v in pairs( Minimap.Points ) do
			surface.SetDrawColor( 255, 0, 0, 200 )
			draw.NoTexture()
			draw.Circle( ScrW() * v.Position.x, ScrH() * v.Position.y, 200, math.sin( CurTime() ) * 20 + 25 )
		end

		local plyx = LocalPlayer():GetPos().x
		local plyy = LocalPlayer():GetPos().y
			plyx = ( plyx + math.abs( Minimap.X.min ) ) / Minimap.X.dif
			plyy = ( plyy + math.abs( Minimap.Y.min ) ) / Minimap.Y.dif
		surface.SetDrawColor( 50, 50, 255, 200 )
		draw.NoTexture()
		draw.Circle( ScrW() * plyx, ScrH() * plyy, 100, math.sin( CurTime() ) * 20 + 25 )
	end
end

-- Display information about the current control point, such as name and capture progress
function HUDPaint_ControlPoint_Current()
	if ( not LocalPlayer().ControlPoint ) then return end

	draw.DrawText( LocalPlayer().ControlPoint.Name, "TargetID", ScrW() * 0.5, ScrH() * 0.01, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

	-- Skip to the right value if too far out
	if ( math.abs( LocalPlayer().ControlPoint.Progress - Progress ) > 50 ) then
		Progress = LocalPlayer().ControlPoint.Progress
	-- Lerp upwards if close value
	elseif ( Progress < LocalPlayer().ControlPoint.Progress ) then
		Progress = math.Approach( Progress, LocalPlayer().ControlPoint.Progress, FrameTime() * 100 )
	-- Lerp downwards
	elseif ( Progress > LocalPlayer().ControlPoint.Progress ) then
		Progress = math.Approach( Progress, LocalPlayer().ControlPoint.Progress, -FrameTime() * 100 )
	end

	-- Progress bar for capturing
	local width = 256 / 100 * Progress
	local height = 28
	draw.RoundedBox(
		0,
		( ScrW() * 0.5 ) - ( width / 2 ), ( ScrH() * 0.01 ) - ( height / 2 ),
		width, height,
		Color( 100, 0, 0, 128 )
	)
end

-- From http://wiki.garrysmod.com/page/surface/DrawPoly
function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end