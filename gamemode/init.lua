AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:InitPostEntity()
	local test = ents.Create( "dc_trigger_control" )
	test.Initialize()
	test.SetPos( Vector( 0, 0, 0 ) )
	test.Spawn()
	print( test )
end

function GM:Think()
	self.BaseClass:Think()
end

function GM:PlayerSwitchFlashlight( ply, on )
	return not on
end