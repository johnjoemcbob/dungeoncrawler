GM.Name 	= "Dungeon Crawler"
GM.Author 	= "Matthew Cormack (@johnjoemcbob)"
GM.Email 	= ""
GM.Website 	= "www.johnjoemcbob.co.uk"
GM.Help		= "No Help Available"

GM.TeamBased = true					-- Team based game or a Free For All game?
GM.AllowAutoTeam = true				-- Allow auto-assign?
GM.AllowSpectating = true			-- Allow people to spectate during the game?
GM.SecondsBetweenTeamSwitches = 10	-- The minimum time between each team change?
GM.GameLength = 15					-- The overall length of the game
GM.RoundLimit = -1					-- Maximum amount of rounds to be played in round based games
GM.VotingDelay = 5					-- Delay between end of game, and vote. if you want to display any extra screens before the vote pops up
GM.ShowTeamName = true				-- Show the team name on the HUD

GM.NoPlayerSuicide = true			-- Set to true if players should not be allowed to commit suicide.
GM.NoPlayerDamage = false			-- Set to true if players should not be able to damage each other.
									-- Friendly fire or no? Is important question.
GM.NoPlayerSelfDamage = false		-- Allow players to hurt themselves?
GM.NoPlayerTeamDamage = true		-- Allow team-members to hurt each other?
GM.NoPlayerPlayerDamage = false 	-- Allow players to hurt each other?
GM.NoNonPlayerPlayerDamage = false 	-- Allow damage from non players (physics, fire etc)
GM.NoPlayerFootsteps = false		-- When true, all players have silent footsteps
GM.PlayerCanNoClip = false			-- When true, players can use noclip without sv_cheats
GM.TakeFragOnSuicide = true			-- -1 frag on suicide

GM.MaximumDeathLength = 0			-- Player will repspawn if death length > this (can be 0 to disable)
GM.MinimumDeathLength = 2			-- Player has to be dead for at least this long
GM.AutomaticTeamBalance = false     -- Teams will be periodically balanced 
GM.ForceJoinBalancedTeams = false	-- Players won't be allowed to join a team if it has more players than another team
GM.RealisticFallDamage = true		-- Set to true if you want realistic fall damage instead of the fix 10 damage.
GM.AddFragsToTeamScore = true		-- Adds player's individual kills to team score (must be team based)

GM.NoAutomaticSpawning = false		-- Players don't spawn automatically when they die, some other system spawns them
GM.RoundBased = false				-- Round based, like CS
GM.RoundLength = 30					-- Round length, in seconds
GM.RoundPreStartTime = 5			-- Preperation time before a round starts
GM.RoundPostLength = 8				-- Seconds to show the 'x team won!' screen at the end of a round
GM.RoundEndsWhenOneTeamAlive = true	-- CS Style rules

GM.EnableFreezeCam = false			-- TF2 Style Freezecam
GM.DeathLingerTime = 0				-- The time between you dying and it going into spectator mode, 0 disables

GM.SelectModel = true               -- Can players use the playermodel picker in the F1 menu?
GM.SelectColor = false				-- Can players modify the colour of their name? (ie.. no teams)

GM.PlayerRingSize = 48              -- How big are the colored rings under the player's feet (if they are enabled) ?
GM.HudSkin = "SimpleSkin"			-- The Derma skin to use for the HUD components
GM.SuicideString = "died"			-- The string to append to the player's name when they commit suicide.
GM.DeathNoticeDefaultColor = Color( 255, 128, 0 ); -- Default colour for entity kills
GM.DeathNoticeTextColor = color_white; -- colour for text ie. "died", "killed"

GM.ValidSpectatorModes = { OBS_MODE_CHASE, OBS_MODE_IN_EYE, OBS_MODE_ROAMING } -- The spectator modes that are allowed
GM.ValidSpectatorEntities = { "player" }	-- Entities we can spectate, players being the obvious default choice.
GM.CanOnlySpectateOwnTeam = true; -- you can only spectate players on your own team

DeriveGamemode( "fretta13" )

TEAM_GREEN 		= 1
TEAM_ORANGE 	= 2
TEAM_BLUE 		= 3
TEAM_RED 		= 4

--[[
   Name: gamemode:CreateTeams()
   Desc: Set up all your teams here. Note - HAS to be shared.
]]

function GM:CreateTeams()

	if ( !GAMEMODE.TeamBased ) then return end
	
	team.SetUp( TEAM_GREEN, "Green Team", Color( 70, 230, 70 ), true )
	team.SetSpawnPoint( TEAM_GREEN, "info_player_start" ) -- The list of entities can be a table
	
	team.SetUp( TEAM_ORANGE, "Orange Team", Color( 255, 200, 50 ) )
	team.SetSpawnPoint( TEAM_ORANGE, "info_player_start", true )
	
	team.SetUp( TEAM_BLUE, "Blue Team", Color( 80, 150, 255 ) )
	team.SetSpawnPoint( TEAM_BLUE, "info_player_start", true )
	
	team.SetUp( TEAM_RED, "Red Team", Color( 255, 80, 80 ) )
	team.SetSpawnPoint( TEAM_RED, "info_player_start", true )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 200, 200, 200 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, "info_player_start" )
	team.SetClass( TEAM_SPECTATOR, { "Spectator" } )

end