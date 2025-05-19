-- highzpeedtrain 11/05/2025 --
local train = script.TrainObject.Value
local UserInputService = game:GetService("UserInputService")
local ui = script.TrainGui

local function getNeedleRotation(speed)
	speed = math.clamp(speed, 0, train.Configuration.MaxSpeed.Value)
	local a = (((1-(train.Configuration.MaxSpeed.Value - speed)/train.Configuration.MaxSpeed.Value))*270)-45
	return a
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end
	if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
		if (game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Sit == false) then
			return
		end
	end
	train.Events.Remotes.MainRemote:FireServer(input.KeyCode, input.UserInputState)
end)

local lv = train:FindFirstChild("DriveVelocity", true)

if not lv then
	error("Unable to continue with setup, no LV found (Client)")
end

lv:GetPropertyChangedSignal("LineVelocity"):Connect(function()
	ui.Main.Spinny.Rotation = getNeedleRotation(math.abs(lv.LineVelocity))
	ui.Main.Speedometer.Text = math.floor(math.abs(lv.LineVelocity)*0.625)
end)

for i,v in ui.ButtonDeck:GetChildren() do
	if v:IsA("ImageButton") then 
		v.MouseButton1Click:Connect(function()
			train.Events.Remotes.OnButtonPressed:FireServer(v.Name)
		end)
	end
end
