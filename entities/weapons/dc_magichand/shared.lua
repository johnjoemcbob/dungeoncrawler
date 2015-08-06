AddCSLuaFile( "shared.lua" )

SWEP.PrintName	= "Magic Fists"

SWEP.Author		= ""
SWEP.Purpose	= ""

SWEP.Spawnable	= true
SWEP.UseHands	= true
SWEP.DrawAmmo	= false

SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= ""

SWEP.ViewModelFOV	= 52
SWEP.Slot			= 0
SWEP.SlotPos		= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

local AnimTime = 0
local AnimDir = 1

local ViewModel_Offset_Up = -15
local ViewModel_Offset_Right = 0
local ViewModel_Angle_Roll = 0

function SWEP:Initialize()
	self:SetWeaponHoldType( "fist" )
end

function SWEP:PreDrawViewModel( vm, wep, ply )
	vm:SetMaterial( "engine/occlusionproxy" ) -- Hide that view model with hacky material
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "NextIdle" )
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() )
end

local NextCast1= 0
function SWEP:PrimaryAttack( right )
	if ( SERVER ) then
		if ( CurTime() > NextCast1 ) then
			local spell = ents.Create( self.Owner.Spells[1] )
			spell:Spawn()
			spell:Cast( self.Owner )

			NextCast1 = CurTime() + 0.5
		end
	end
end

local NextCast2 = 0
function SWEP:SecondaryAttack()
	if ( SERVER ) then
		if ( CurTime() > NextCast2 ) then
			local spell = ents.Create( self.Owner.Spells[2] )
			spell:Spawn()
			spell:Cast( self.Owner )

			NextCast2 = CurTime() + 0.5
		end
	end
end

function SWEP:OnRemove()
	if ( IsValid( self.Owner ) ) then
		local vm = self.Owner:GetViewModel()
		if ( IsValid( vm ) ) then vm:SetMaterial( "" ) end
	end
end

function SWEP:Holster( wep )
	self:OnRemove()

	return true
end

function SWEP:Deploy()
	return true
end

if ( CLIENT ) then
	local ViewModel_Dest_Up = -15
	function SWEP:GetViewModelPosition( pos, ang )
		local speed = 0.05

		local dest_up = ViewModel_Dest_Up -- Default up offset (move viewmodel down partly out of vision)
		local dest_right = 0 -- Default right offset (viewmodel centre)
			if ( input.IsKeyDown( KEY_Q ) ) then -- In spell selector
				dest_right = 2.8 -- Focus on left hand
				dest_up = -0.7 -- Move hand into screen centre
			end
			if ( input.IsKeyDown( KEY_E ) ) then -- In spell selector
				ViewModel_Dest_Up = -3
				dest_right = -2.8 -- Focus on right hand
				dest_up = -0.7 -- Move hand into screen centre
			end
		if ( ViewModel_Offset_Right != dest_right ) then
			if ( ViewModel_Offset_Right < dest_right ) then
				ViewModel_Offset_Right = ViewModel_Offset_Right + speed
				if ( ViewModel_Offset_Right > dest_right ) then
					ViewModel_Offset_Right = dest_right
				end
			else
				ViewModel_Offset_Right = ViewModel_Offset_Right - speed
				if ( ViewModel_Offset_Right < dest_right ) then
					ViewModel_Offset_Right = dest_right
				end
			end
		end
		if ( ViewModel_Offset_Up != dest_up ) then
			if ( ViewModel_Offset_Up < dest_up ) then
				ViewModel_Offset_Up = ViewModel_Offset_Up + speed
				if ( ViewModel_Offset_Up > dest_up ) then
					ViewModel_Offset_Up = dest_up
				end
			else
				ViewModel_Offset_Up = ViewModel_Offset_Up - speed
				if ( ViewModel_Offset_Up < dest_up ) then
					ViewModel_Offset_Up = dest_up
				end
			end
		end

		pos = pos + ( ang:Right() * -2 )--* ViewModel_Offset_Right )
		pos = pos + ( ang:Up() * ViewModel_Offset_Up )
		pos = pos + ( ang:Forward() * 1 )--* ViewModel_Offset_Up )

		ang = ang + Angle( 0, 0, 0 )-- ViewModel_Angle_Roll )

		return pos, ang
	end
end

function SWEP:Think()
	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()

	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )

	if ( CLIENT ) then
		if ( not input.IsKeyDown( KEY_Q ) ) then
			AnimTime = AnimTime + ( AnimDir * FrameTime() * 0.3 )
				if ( AnimTime > 0.5 ) then AnimDir = -1 end
				if ( AnimTime < 0.12 ) then AnimDir = 1 end
			vm:SetAnimTime( curtime - AnimTime )
		else
			AnimTime = AnimTime + math.random( 0.005, 0.0075 )
				if ( AnimTime > math.random( 0.275, 0.285 ) ) then AnimTime = math.random( 0.285, 0.305 ) end
			vm:SetAnimTime( curtime - AnimTime )
		end
	end

	ViewModel_Angle_Roll = ViewModel_Angle_Roll + 0.001
end