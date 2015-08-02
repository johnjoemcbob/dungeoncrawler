AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()

	local test = ents.Create( "dc_trigger_control" )
	test:SetPos( Vector( 0, 0, 0 ) )
	test:Spawn()

	local chesttest = ents.Create( "dc_chest_map" )
	chesttest:SetPos( Vector( 8808, -55, -350 ) )
	chesttest:Spawn()
end

function GM:Think()
	self.BaseClass:Think()
end

function GM:PlayerSwitchFlashlight( ply, on )
	return not on
end