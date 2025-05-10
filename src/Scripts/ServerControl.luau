-- highzpeedtrain 10/05/2025 --
--[[
	Core control for the train system. The entire system relies upon this script.
]]
-- Services --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local train = script.Parent.Parent
-- Modules
local modules = train.Modules
local keyModules = modules.KeyModules

local typeDefs = require(modules.TypeDefinitions)
local trainSpeed = require(modules.TrainSpeed)
-- Remotes
local remote = train.Remotes.MainRemote

-- Core
local LinearVelocity = train:FindFirstChild("DriveVelocity", true)
if LinearVelocity == nil then
	error("Missing LinearVelocity, unable to continue with ")
end

local direction = typeDefs.ReverserDirs.Neutral

-- Other
local config = train.Configuration
local sounds = train.Sounds

-- TrainSpecific values
local throttleNotch = 0
local brakeNotch = 0

remote.OnServerEvent:Connect(function(plr : Player, Keycode, UserInputState)
	local keyPressed = UserInputService:GetStringForKeyCode(Keycode)
	
	if keyPressed == nil then
		return
	end
	
	local module = keyModules:FindFirstChild(keyPressed.."Key")
	if not module then
		warn(keyPressed.." was pressed, but has no implementation!")
		return 
	end
	
	local moduleResult
	
	local context = {
		CurrentSpeed = LinearVelocity.LineVelocity,
		TrainDirection = direction,
		ThrottleNotch = throttleNotch,
		BrakeNotch = brakeNotch
	}
	
	local success, result = pcall(function()
		moduleResult = require(module)(context, plr, train)
	end)
	
	if success == false then
		warn("An error occured while running module "..module.Name)
		warn(result)
		return
	end
	
	if type(moduleResult) == "table" then
		if moduleResult[1] == "ChangeSpeed" then
			print("Module is asking to change speed to "..moduleResult[2])
		elseif moduleResult[1] == "TNotchUp" then
			if throttleNotch < config.MaxThrottleNotch.Value then
				throttleNotch += 1
				sounds.NotchUp:Play()
			end
		elseif moduleResult[1] == "TNotchDown" then
			if throttleNotch > 0 then
				throttleNotch -= 1
				sounds.NotchDown:Play()
			end
		elseif moduleResult[1] == "BNotchUp" then
			if brakeNotch < config.MaxBrakeNotch.Value then
				brakeNotch += 1
				sounds.NotchUp:Play()
			end
		elseif moduleResult[1] == "BNotchDown" then
			if brakeNotch > 0 then
				brakeNotch -= 1
				sounds.NotchDown:Play()
			end
		elseif moduleResult[1] == "ChangeDirection" then 
			if moduleResult[2] == typeDefs.ReverserDirs.Forward then 
				direction = typeDefs.ReverserDirs.Forward
			elseif moduleResult[2] == typeDefs.ReverserDirs.Neutral then 
				direction = typeDefs.ReverserDirs.Neutral
			elseif moduleResult[2] == typeDefs.ReverserDirs.Reverse then 
				direction = typeDefs.ReverserDirs.Reverse	
			else
				warn("An error occured while running module "..module.Name)
				warn("Argument 2 not given or invalid.")
			end
		end
		print("ThrottleNotch: "..throttleNotch)
		print("BrakeNotch: "..brakeNotch)
		print(direction)
	end
end)

RunService.PreSimulation:Connect(function(deltaTimeSim: number)
	local context = {
		CurrentSpeed = LinearVelocity.LineVelocity,
		TrainDirection = direction,
		ThrottleNotch = throttleNotch,
		BrakeNotch = brakeNotch
	}
	
	local newSpeed = trainSpeed:Run(context)
	
	if newSpeed ~= nil then
		LinearVelocity.LineVelocity = newSpeed
	end
end)
