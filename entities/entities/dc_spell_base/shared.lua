-- Matthew Cormack (@johnjoemcbob)
-- 04/08/15
-- Base entity for spells in the gamemode
-- When the player activates an ability, a child of this entity will be spawned
-- which will decide the functionality of the spell
-- Base spell has no collision, but runs a trace when created from the player's
-- eyes

-- The range of this spell
ENT.Range = 500

-- The radius of any touch/area of affect spells
ENT.Radius = 50

-- The damage to inflict if this spell affects a player
ENT.Damage = 50

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
	end
end

-- Called by dc_magichands/shared.lua when this spell is activated
function ENT:Cast( ply )
	self:Cast_TrapTotem( ply )
	--self:Cast_Projectile( ply )
end

-- Base function for any spells which create world traps to hurt heroes,
-- or totems to buff heroes/debuff monsters
function ENT:Cast_TrapTotem( ply )
	local firstendpos = ply:EyePos() + ply:EyeAngles():Forward() * self.Range
	local tr = util.TraceLine( {
		start = ply:EyePos(),
		endpos = firstendpos,
		mask = MASK_SOLID_BRUSHONLY
	} )
	-- If it hits nothing, project forward by the max range and then fire downwards
	if ( not tr.Hit ) then
		tr = util.TraceLine( {
			start = firstendpos,
			endpos = firstendpos + ply:EyeAngles():Up() * -self.Range,
			mask = MASK_SOLID_BRUSHONLY
		} )
	end
	-- If it still hit nothing, delete self
	if ( not tr.Hit ) then
		self:Remove()
	-- Otherwise continue to creating the trap/totem at the point hit
	else
		local spell = self:Cast_TrapTotem_Create( ply, tr )
		spell.Owner = ply
	end

	-- Remove the spell
	self:Remove()
end

-- Base function used as part of any spells which create world traps to hurt heroes,
-- or totems to buff heroes/debuff monsters
-- NOTE: Intended to be overwritten by child spells, to add extra functionality
function ENT:Cast_TrapTotem_Create( ply, trace )
	local spell = ents.Create( "prop_dynamic" )
		spell:SetModel( "models/props_borealis/bluebarrel001.mdl" )
		spell:SetPos( trace.HitPos )
		spell.Owner = ply
		spell:Spawn()
		spell:GetPhysicsObject():Sleep()
	return spell
end

-- Base function used as part of any spells which create world traps to hurt heroes,
-- or totems to buff heroes/debuff monsters
-- Used to rotate traps/totems depending on the hit normal of the surface cast on
function ENT:Cast_TrapTotem_Rotate( spell, trace )
	-- Rotate the totem based on the trace hit normal
	local angle = trace.HitNormal:Angle()
	-- If the totem has been placed on a near vertical wall
	if (
		( math.abs( math.AngleDifference( angle.p, 0 ) ) <= 20 ) and
		( math.abs( math.AngleDifference( angle.r, 0 ) ) <= 20 )
	) then
		spell:SetAngles( ( ( -angle:Forward() * 10 ) + ( angle:Up() * 2 ) ):Angle() )
	end
end

-- Base function for any spells which fire a projectile
function ENT:Cast_Projectile( ply )
	local spell, angle = self:Cast_Projectile_Create( ply, ply:GetPos() + Vector( 0, 0, 50 ) )
	spell.Range = self.Range
	spell.Owner = ply

	-- Project forward out of the player a little
	local forward = ( ply:EyeAngles() + angle ):Forward()
	spell:SetPos( spell:GetPos() + ( forward * 50 ) )

	-- Fire the projectile
	local physics = spell:GetPhysicsObject()
	if ( physics and IsValid( physics ) ) then
		physics:AddVelocity( forward * spell.Speed )
	end

	-- Remove the spell
	self:Remove()
end

-- Base function used as part of any spells which fire a projectile
-- NOTE: Intended to be overwritten by child spells, to add extra functionality
-- Can be gravity enable or not using spell:GetPhysicsObject():EnableGravity( bool )
function ENT:Cast_Projectile_Create( ply, start )
	-- Offset angle can be used to fire projectiles in directions other than straight
	local offsetangle = Angle( 0, 0, 0 )

	local spell = ents.Create( "prop_physics" )
		spell:SetModel( "models/props_borealis/bluebarrel001.mdl" )
		spell:SetPos( start )
		spell.Owner = ply
		spell:Spawn()
	return spell, offsetangle
end

-- Base function for any spells which fire a projectile
function ENT:Cast_Touch( ply )
	-- Project forward out of the player a little
	local forward = ply:EyeAngles():Forward() * self.Range
	local entsinrange = ents.FindInSphere( ply:GetPos() + forward, self.Radius )
	for k, v in pairs( entsinrange ) do
		-- Is another player
		-- NOTE: Team checking logic is done on a spell by spell basic, to allow for touch buffs for allies, and touch damages for enemies
		if ( ( v:IsPlayer() ) and ( v ~= ply ) ) then
			self:Cast_Touch_Affect( ply, v )
		end
	end

	-- Remove the spell
	self:Remove()
end

-- Base function used as part of any spells which act only at close range to the target
-- NOTE: Intended to be overwritten by child spells, to add extra functionality
function ENT:Cast_Touch_Affect( ply, target )
	if ( ply:Team() ~= target:Team() ) then
		target:TakeDamage( self.Damage, ply, self )
	end
end