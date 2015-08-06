-- Matthew Cormack (@johnjoemcbob)
-- 06/08/15
-- Buff/debuff clientside hud visuals
-- Including icon/progress bar for each buff with hover-over descriptions

local Buffs = {}

-- Initialization of this message is contained within sv_buff.lua
net.Receive( "DC_Client_Buff", function( len )
	local id = net.ReadFloat()
	Buffs[id] = net.ReadFloat()

	-- If the buff still exists on the player, use clientside CurTime for visual progress decrease
	if ( Buffs[id] > 0 ) then
		Buffs[id] = Buffs[id] + CurTime()
	end
end )

function GM:Initialize_Buffs()
	-- Create a material cache for each icon16/house
	for k, v in pairs( self.Buffs ) do
		v.Material = Material( v.Icon )
	end
end

function GM:HUDPaint_Buffs()
	local x = 0
	local y = ScrH() / 4
	local size = ScrH() / 10
	for k, v in pairs( Buffs ) do
		if ( v and ( v > 0 ) ) then
			local activetime = v - CurTime()
				-- Flag set in some buffs to never visually decrease progress
				if ( self.Buffs[k].Time == 0.5 ) then
					activetime = self.Buffs[k].Time
				end
			if ( activetime > 0 ) then
				-- Backdrop
				surface.SetDrawColor( 181, 140, 50, 200 )
				surface.DrawRect( x, y, size, size )

				-- Progress green bar
				surface.SetDrawColor( 0, 255, 0, 150 )
				surface.DrawRect( x, y, size / self.Buffs[k].Time * activetime, size )

				-- Icon
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( self.Buffs[k].Material	)
				surface.DrawTexturedRect( x, y, size, size )

				-- Move next buff visual downward
				y = y + ScrH() / 8
			end
		end
	end
end