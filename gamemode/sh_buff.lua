-- Matthew Cormack (@johnjoemcbob)
-- 06/08/15
-- Buff/debuff shared information, contains the description of every buff
--
-- {
	-- Name = "Sheltered", -- Name for the tooltip
	-- Description = "Under shelter, protected from the elements.", -- Description for the tooltip
	-- Icon = "icon16/house.png", -- Icon to display as the buff's main visuals
	-- Time = 0, -- Times here are in seconds; NOTE - exactly 0.5 flags the client to display a quickly recurring buff (e.g. shelter)
	-- ThinkActivate = function( self, ply ) -- Run every frame to run logic on adding the buff to the player under certain conditions
		-- return true/false -- Whether or not the buff should be activated
	-- end,
	-- Init = function( self, ply ) -- Run when the buff is first added to the player
		
	-- end,
	-- Think = function( self, ply ) -- Run every frame the buff exists on the player
		
	-- end,
	-- Remove = function( self, ply ) -- Run when the buff is removed from the player
		
	-- end
-- }

GM.Buffs = {}

table.insert(
	GM.Buffs,
	{
		Name = "Sheltered",
		Description = "Under shelter, protected from the elements.",
		Icon = "icon16/house.png",
		Time = 0.5, -- Must constantly be re-added by ThinkActivate
		ThinkActivate = function( self, ply )
			local tr = util.TraceLine(
				{
					start = ply:GetPos() + Vector( 0, 0, 1 ) * 20,
					endpos = ply:GetPos() + Vector( 0, 0, 1 ) * 400,
					mask = MASK_SOLID_BRUSHONLY
				}
			)
			if ( tr.Hit ) then
				return true
			end
			return false
		end,
		Init = function( self, ply )
			print( "inside" )
		end,
		Think = function( self, ply )
			
		end,
		Remove = function( self, ply )
			print( "outside" )
		end
	}
)
table.insert(
	GM.Buffs,
	{
		Name = "Soaked",
		Description = "Covered in water, cold and slower.",
		Icon = "icon16/weather_rain.png",
		Time = 30,
		ThinkActivate = function( self, ply )
			if ( ply:WaterLevel() > 0 ) then
				return true
			end
			return false
		end,
		Init = function( self, ply )
			print( "wet" )
		end,
		Think = function( self, ply )
			
		end,
		Remove = function( self, ply )
			print( "dry" )
		end
	}
)