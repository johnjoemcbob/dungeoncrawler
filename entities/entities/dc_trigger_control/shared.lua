-- Matthew Cormack (@johnjoemcbob)
-- 02/08/15
-- Control Point Trigger Zone
-- This checks for the number of heroes/monsters inside it and,
-- if only one side is present, will start capturing

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	ENT.PrintName = "Control Point Trigger Zone"
end

ENT.Type = "anim"

function ENT:Initialize()
	if SERVER then
		local startpos = Vector( 3273, -5770, 1029 )
		local endpos = Vector( 4060, -6466, 1442 )

		self:SetTrigger( true )
		self:SetSolid( SOLID_BBOX )
		self:SetCollisionBoundsWS( startpos, endpos )
		print( "CREATED" )
	end
end

if SERVER then
	function ENT:StartTouch( entity )
		print( "hello... " .. tostring( entity ) )
	end
end

if CLIENT then
	function ENT:Draw()
		return false
	end
end