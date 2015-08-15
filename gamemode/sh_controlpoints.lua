-- Matthew Cormack (@johnjoemcbob), Nichlas Rager (@dasomeone), Jordan Brown (@DrMelon)
-- 03/08/15
-- Control Point placements
--
-- NOTE: Indices (i.e. for PrecedingPoint) start at 1, not 0
-- A PrecedingPoint value of 0 or below can be added to opt out
-- and make this a stand alone point (i.e. the first point or
-- a bonus/secret point)

GM.ControlPoints = {}

-- Points for rp_harmonti
GM.ControlPoints["rp_harmonti"] = {}
-- Point 1
table.insert(
	GM.ControlPoints["rp_harmonti"],
	{
		Title = "Auberge Bridge",
		Type = "Default",
		Position = Vector( 7113, -475, -450 ),
		Start = Vector( -350, -210, -150 ),
		End = Vector( 350, 143, 150 ),
		PrecedingPoint = 0, -- First point
		CaptureSpeed = 100
	}
)
-- Point 2
table.insert(
	GM.ControlPoints["rp_harmonti"],
	{
		Title = "Landebrin Keep",
		Type = "Default",
		Position = Vector( 5374, -6448, 330 ),
		Start = Vector( -180, -180, -480 ),
		End = Vector( 180, 180, 420 ),
		PrecedingPoint = 1,
		CaptureSpeed = 80,
		Path = {
			Vector( 3670, -6430 ),
			Vector( 3020, -3170 ),
			Vector( 3875, -260 )
		}
	}
)
-- Point 3
table.insert(
	GM.ControlPoints["rp_harmonti"],
	{
		Title = "Grilleau Watch",
		Type = "Default",
		Position = Vector( 2614, 1355, -75 ),
		Start = Vector( -64, -60, -325 ),
		End = Vector( 64, 60, 325 ),
		PrecedingPoint = 2,
		CaptureSpeed = 60,
		Path = {
			Vector( 3875, -260 ),
			Vector( 3020, -3170 ),
			Vector( 3670, -6430 )
		}
	}
)
-- Point 4
table.insert(
	GM.ControlPoints["rp_harmonti"],
	{
		Title = "Grilleau Keep",
		Type = "Default",
		Position = Vector( -340, 1952, 30 ),
		Start = Vector( -196, -196, -460 ),
		End = Vector( 196, 196, 440 ),
		PrecedingPoint = 3,
		CaptureSpeed = 40
	}
)