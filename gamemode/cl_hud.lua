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

-- Initialization of this message is contained within dc_trigger_control/shared.lua
-- NOTE: Isn't JUST sent after capture, is also used on new players to update them on the
-- either monstercontrolled/not
net.Receive( "DC_Client_ControlPoint_Capture", function( len )
	if ( Minimap.Points ) then
		local id = math.Round( net.ReadFloat() )
		Minimap.Points[id].MonsterControlled = net.ReadBit() == 1
	end
end )

function GM:Initialize_HUD()
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
			},
			MonsterControlled = true
		} )
	end
end

function GM:ContextMenuOpen()
	return true
end

function GM:OnContextMenuOpen()
	gui.EnableScreenClicker( true )
end

function GM:OnContextMenuClose()
	gui.EnableScreenClicker( false )
end

function GM:HUDPaint()
	-- Personal information
	self:HUDPaint_Health()
	self:HUDPaint_Mana()
	self:HUDPaint_Buffs()

	-- Control point information
	self:HUDPaint_ControlPoint_Overall()
	self:HUDPaint_ControlPoint_Current()
end

-- Display health
function GM:HUDPaint_Health()
	local width = ScrW() / 5
	local height = ScrH() / 20
	local x = ( ScrW() / 2 ) - ( width / 2 )
	local y = ( ScrH() / 20 * 18 ) - ( height / 2 )
	local borderdivision = 20

	-- Health bar border
	draw.RoundedBox(
		0,
		x, y,
		width, height,
		Color( 50, 50, 50, 150 )
	)

	-- Move the health bar inside the border
	local x = x + height / borderdivision
	local y = y + height / borderdivision
	local width = width - ( height / borderdivision * 2 )
	local height = height - ( height / borderdivision * 2 )

	-- Health bar
	draw.RoundedBox(
		0,
		x, y,
		width * ( LocalPlayer():Health() / LocalPlayer():GetMaxHealth() ), height,
		Color( 200, 50, 50, 255 )
	)
end

-- Display mana
function GM:HUDPaint_Mana()
	if ( not LocalPlayer().Mana ) then
		LocalPlayer().Mana = 100
		LocalPlayer().MaxMana = 200
	end

	local width = ScrW() / 4
	local height = ScrH() / 20
	local x = ( ScrW() / 2 ) - ( width / 2 )
	local y = ( ScrH() / 20 * 19.25 ) - ( height / 2 )
	local borderdivision = 20

	-- Mana bar border
	draw.RoundedBox(
		0,
		x, y,
		width, height,
		Color( 50, 50, 50, 150 )
	)

	-- Move the mana bar inside the border
	local x = x + height / borderdivision
	local y = y + height / borderdivision
	local width = width - ( height / borderdivision * 2 )
	local height = height - ( height / borderdivision * 2 )

	-- Mana bar
	draw.RoundedBox(
		0,
		x, y,
		width * ( LocalPlayer().Mana / LocalPlayer().MaxMana ), height,
		Color( 50, 50, 200, 255 )
	)
end

-- Display information about the overall location and state of all control points
function GM:HUDPaint_ControlPoint_Overall()
	-- Calculate the coordinates to display at, depending on the users resolution
	-- (the control point positions are normalized on initialization)
	local width = ScrW() / 10
	local height = ScrH() / 10
	local x = ( ScrW() / 2 ) - ( width / 2 )
	local y = ( height / 2 )
	local radius = width / 5

	-- Display the map
	if ( Minimap.Points ) then
		for k, v in pairs( Minimap.Points ) do
			if ( v.MonsterControlled ) then
				surface.SetDrawColor( 255, 0, 0, 200 )
			else
				surface.SetDrawColor( 0, 0, 255, 200 )
			end
			draw.NoTexture()
			draw.Circle( x + ( width * v.Position.x ), y + ( height * v.Position.y ), radius, 25 )
		end

		-- Player's position in the world
		local plyx = LocalPlayer():GetPos().x
		local plyy = LocalPlayer():GetPos().y
			plyx = ( plyx + math.abs( Minimap.X.min ) ) / Minimap.X.dif
			plyy = ( plyy + math.abs( Minimap.Y.min ) ) / Minimap.Y.dif
		surface.SetDrawColor( 50, 50, 255, 200 )
		draw.NoTexture()
		draw.Circle( x + ( width * plyx ), y + ( height * plyy ), radius / 2, 5 )
	end
end

-- Display information about the current control point, such as name and capture progress
function GM:HUDPaint_ControlPoint_Current()
	if ( not LocalPlayer().ControlPoint ) then return end

	-- Display the name of this point
	local textcolour = Color( 255, 255, 255, 255 )
	draw.DrawText( LocalPlayer().ControlPoint.Name, "TargetID", ScrW() * 0.5, ScrH() * 0.01, textcolour, TEXT_ALIGN_CENTER )

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
	local progresscolour = Color( 0, 0, 255, 128 )
		if ( Progress ~= 100 ) then
			progresscolour = Color( 255, 0, 0, 128 )
		end
	local width = 256 / 100 * Progress
	local height = 28
	draw.RoundedBox(
		0,
		( ScrW() * 0.5 ) - ( width / 2 ), ( ScrH() * 0.01 ) - ( height / 2 ),
		width, height,
		progresscolour
	)
end

-- Hide all of the default HUD elements
local HUDHide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudSuitPower = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudWeaponSelection = true
}
hook.Add( "HUDShouldDraw", "DC_HUDShouldDraw", function( name )
	if ( HUDHide[ name ] ) then return false end
end )

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