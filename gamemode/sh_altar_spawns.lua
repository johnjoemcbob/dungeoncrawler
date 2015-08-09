-- Jordan Brown (@DrMelon)
-- 09/08/15
-- Spell Altar placements
-- Placement of Spell Altars

-- Currently only for rp_harmonti!

-- NOTE: Indices (i.e. for PrecedingPoint) start at 1, not 0
-- A PrecedingPoint value of 0 or below can be added to opt out
-- and make this a stand alone point (i.e. the first point or
-- a bonus/secret point)
--


GM.AltarSpawns = {}

-- Spawn Area
table.insert(
	GM.AltarSpawns,
	{
		Position = Vector( 8586, -24, -392 ),
		Rotation = Angle( 0, 0, 0 )
	}
)
-- Blacksmith
table.insert(
	GM.AltarSpawns,
	{
		Position = Vector( 132, 234, -504 ),
		Rotation = Angle( 0, 0, 0 )
	}
)
-- Small Tower
table.insert(
	GM.AltarSpawns,
	{
		Position = Vector( 2381, -6483, -398 ),
		Rotation = Angle( 0, 180, 0 )
	}
)

-- Village Tower
table.insert(
	GM.AltarSpawns,
	{
		Position = Vector( 5388, -6266, 659 ),
		Rotation = Angle( 0, 90, 0 )
	}
)

-- Forest Tower
table.insert(
	GM.AltarSpawns,
	{
		Position = Vector( 1148, 6961, -340 ),
		Rotation = Angle( 0, 0, 0 )
	}
)