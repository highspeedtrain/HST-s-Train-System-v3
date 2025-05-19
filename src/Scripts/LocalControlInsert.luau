local PlayerService = game:GetService("Players")

local VS1 = script.Parent.Parent.DriveSystemSeat
local VS2 = script.Parent.Parent.DriveSystemSeatTwo
local ClientScript = script.LocalControl

local player = nil
local ClientClone = nil

local function doStuff(Seat : VehicleSeat)
	if Seat.Occupant then
		player = PlayerService:GetPlayerFromCharacter(Seat.Occupant.Parent)

		ClientClone = ClientScript:Clone()
		ClientClone.Parent = player.PlayerGui
		ClientClone.Enabled = true

		Seat:CanSetNetworkOwnership(player)
	else
		if ClientClone then
			ClientClone:Destroy()
			ClientClone = nil
		end
		if Seat:CanSetNetworkOwnership() then
			Seat:SetNetworkOwnershipAuto()
		end
	end
end

VS1:GetPropertyChangedSignal("Occupant"):Connect(function() 
	doStuff(VS1)
end)

VS2:GetPropertyChangedSignal("Occupant"):Connect(function() 
	doStuff(VS2)
end)
