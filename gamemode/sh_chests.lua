-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 14/08/15
-- Loot chest placements
--
-- {
	-- Type = "dc_chest_map", -- The entity to spawn
	-- Position = Vector( 7113, -475, -450 ), -- The position of the chest
	-- PrecedingPoint = 0, -- The control point which much be captured to open this (0 for none)
	-- Level = 0 -- The level of loot contained within (0-100)
-- }

GM.Chests = {}

-- Chests for rp_harmonti
GM.Chests["rp_harmonti"] = {}
-- Chest inside the Auberge Inn (small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 8808, -55, -350 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 0,
		Level = 0
	}
)
-- Chest in a Landebrin house (small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 5920, -5495, -410 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 1,
		Level = 20
	}
)
-- Chest in a Landebrin house (small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 6127, -7160, -430 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 1,
		Level = 20
	}
)
-- Chest in the Landebrin blacksmith (important, small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 5267, -7670, -385 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 1,
		Level = 80
	}
)
-- Chest in the Landebrin keep (important, small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 5228, -6583, -138 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 2,
		Level = 40
	}
)
-- Chest in the Landebrin keep (important, medium)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 5289, -6298, 32 ),
		Angle = Angle( 0, -90, 0 ),
		PrecedingPoint = 2,
		Level = 50
	}
)
-- Chest in the Landebrin keep (important, medium)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 5249, -6580, 368 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 2,
		Level = 50
	}
)
-- Chest in the Landebrin keep (important, large)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 5420, -6590, 540 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 2,
		Level = 100
	}
)
-- Chest in the Grilleau Watch tower (medium)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 2592, 1323, -346 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 3,
		Level = 60
	}
)
-- Chest in a Grilleau house (small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( -1205, 1748, -318 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 3,
		Level = 70
	}
)
-- Chest in a Grilleau house (small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( -407, 448, -408 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 3,
		Level = 70
	}
)
-- Chest in the Grilleau blacksmith (important, small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( 50, 19, -464 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 3,
		Level = 80
	}
)
-- Chest in the Grilleau keep (important, small)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( -237, 1784, -434 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 4,
		Level = 80
	}
)
-- Chest in the Grilleau keep (important, medium)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( -401, 1799, -260 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 4,
		Level = 90
	}
)
-- Chest in the Grilleau keep (important, medium)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( -430, 1789, 73 ),
		Angle = Angle( 0, 90, 0 ),
		PrecedingPoint = 4,
		Level = 90
	}
)
-- Chest in the Grilleau keep (important, large)
table.insert(
	GM.Chests["rp_harmonti"],
	{
		Type = "dc_chest_map",
		Position = Vector( -423, 2077, 245 ),
		Angle = Angle( 0, -90, 0 ),
		PrecedingPoint = 4,
		Level = 100
	}
)