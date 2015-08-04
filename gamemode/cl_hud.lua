-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 03/08/15
-- Main clientside hud visuals

local Progress = 0

-- Initialization of this message is contained within dc_trigger_control/shared.lua
net.Receive( "DC_Client_ControlPoint", function( len )
	LocalPlayer().ControlPoint = {
		Name = net.ReadString(),
		Progress = net.ReadFloat(),
		TeamCapturing = net.ReadFloat()
	}
end )

hook.Add( "HUDPaint", "DC_HUDPaint_ControlPoint", function()
	if ( not LocalPlayer().ControlPoint ) then return end

	draw.DrawText( LocalPlayer().ControlPoint.Name, "TargetID", ScrW() * 0.5, ScrH() * 0.1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

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

	local width = 256 / 100 * Progress
	local height = 28
	draw.RoundedBox( 0, ( ScrW() * 0.5 ) - ( width / 2 ), ( ScrH() * 0.1 ) - ( height / 2 ), width, height, Color( 100, 0, 0, 128 ) ) -- Draw a box
end )