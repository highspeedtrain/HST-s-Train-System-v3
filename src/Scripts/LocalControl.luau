-- highzpeedtrain 10/05/2025 --
local train = script.TrainObject.Value
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end
	local inputDetails = {
		
	}
	train.Remotes.MainRemote:FireServer(input.KeyCode, input.UserInputState)
end)
