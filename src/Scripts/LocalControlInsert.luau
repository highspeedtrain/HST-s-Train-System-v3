local PlayerService = game:GetService("Players")

local Seat = script.Parent.Parent.DriveSystemSeat
local ClientScript = script.LocalControl

local player = nil
local ClientClone = nil

Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if Seat.Occupant then
		player = PlayerService:GetPlayerFromCharacter(Seat.Occupant.Parent)
		
		ClientClone = ClientScript:Clone()
		ClientClone.Parent = player.PlayerGui
		ClientClone.Enabled = true
		
		Seat:CanSetNetworkOwnership(player)
		for _,part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Massless = true
			end
		end
	else
		if ClientClone then
			ClientClone:Destroy()
			ClientClone = nil
		end
		Seat:SetNetworkOwnershipAuto()
	end
end)
