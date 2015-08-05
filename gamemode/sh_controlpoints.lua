-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 03/08/15
-- Control Point placements
-- Placement of control points

-- Currently only for rp_harmonti!

-- NOTE: Indices (i.e. for PrecedingPoint) start at 1, not 0
-- A PrecedingPoint value of 0 or below can be added to opt out
-- and make this a stand alone point (i.e. the first point or
-- a bonus/secret point)
--
-- Time is currently in seconds

GM.ControlPoints = {}

-- Point 1
table.insert(
	GM.ControlPoints,
	{
		Title = "Auberge Bridge",
		Type = "Default",
		Position = Vector( 7113, -475, -543 ),
		Start = Vector( 6763, -685, -600 ),
		End = Vector( 7462, -332, -300 ),
		PrecedingPoint = 0, -- First point
		CaptureSpeed = 280
	}
)
-- Point 2
table.insert(
	GM.ControlPoints,
	{
		Title = "Landebrin Keep",
		Type = "Default",
		Position = Vector( 5374, -6448, -178 ),
		Start = Vector( 5195, -6628, -150 ),
		End = Vector( 5553, -6269, 750 ),
		PrecedingPoint = 1,
		CaptureSpeed = 250
	}
)
-- Point 3
table.insert(
	GM.ControlPoints,
	{
		Title = "Grilleau Watch",
		Type = "Default",
		Position = Vector( 2614, 1355, -375 ),
		Start = Vector( 2550, 1295, -400 ),
		End = Vector( 2679, 1416, 250 ),
		PrecedingPoint = 2,
		CaptureSpeed = 250
	}
)

-- Point 4
table.insert(
	GM.ControlPoints,
	{
		Title = "Grilleau Keep",
		Type = "Default",
		Position = Vector( -340, 1952, 17 ),
		Start = Vector( -536, 1756, -450 ),
		End = Vector( -145, 2148, 450 ),
		PrecedingPoint = 3,
		CaptureSpeed = 250
	}
)