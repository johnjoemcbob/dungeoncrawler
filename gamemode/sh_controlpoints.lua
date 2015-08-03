-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 03/08/15
-- Control Point placements
-- Placement of control points

-- Currently only for rp_harmonti!

-- NOTE: Indices (i.e. for PrecedingPoint) start at 1, not 0
-- A PrecedingPoint value of 0 or below can be added to opt out
-- and make this a stand alone point (i.e. the first point or
-- a bonus/secret point)

GM.ControlPoints = {}

-- Point 1
table.insert(
	GM.ControlPoints,
	{
		Title = "Auberge Bridge",
		Type = "Default",
		Position = Vector( 7113, -475, -543 ),
		Start = Vector( 6763, -685, -543 ),
		End = Vector( 7462, -332, -337 ),
		PrecedingPoint = 0 -- First point
	}
)
-- Point 2
table.insert(
	GM.ControlPoints,
	{
		Title = "Landebrin Tower",
		Type = "Default",
		Position = Vector( 5374, -6448, -178 ),
		Start = Vector( 5195, -6628, -178 ),
		End = Vector( 5553, -6269, 680 ),
		PrecedingPoint = 1
	}
)