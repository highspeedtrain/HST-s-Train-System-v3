-- highzpeedtrain 10/05/2025 --
--[[
	Core control for the train system. The entire system relies upon this script.
]]
-- Services --
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local train = script.Parent.Parent
-- Modules
local modules = train.Modules
local keyModules = modules.KeyModules
local buttonModules = modules.ButtonModules

local typeDefs = require(modules.TypeDefinitions)
local trainSpeed = require(modules.TrainSpeed)
local canMove = require(modules.CanMoveConditions)
-- Remotes
local remote = train.Events.Remotes.MainRemote

-- Core
local LinearVelocities = {}
-- Don't put your LVs in here, they get automatically inserted.
-- TODO Improve LV master-slave system so that Car 1's LV is always the master.

for i,v in train:GetDescendants() do
	if v:IsA("LinearVelocity") and v.Name == "DriveVelocity" then
		table.insert(LinearVelocities, v)
	end
end

if LinearVelocities[1] == nil then
	error("No DriveVelocities found! Did you setup correctly? Halting thread.")
end

local masterLV = LinearVelocities[1]
local direction = typeDefs.ReverserDirs.Neutral
local currentMaster = nil

-- Other
local config = train.Configuration
local sounds = train.DriveSystemSeat.Sounds
local smokeEmms = {train.Chassis.SmokeParts.SmokePartA.SmokeAtt.SmokeEmitter, train.Chassis.SmokeParts.SmokePartB.SmokeAtt.SmokeEmitter}
-- Put your smoke EMITTERS in the table. Do not do attachments, the part, anything else.

local engineSounds = {train.Chassis.Car1.Body.Idle, train.Chassis.Car2.Body.Idle}
-- Put all your engine sounds in here.

-- TrainSpecific values
local throttleNotch = 0
local brakeNotch = 0

local function constructContext()
	local context = {
		CurrentSpeed = masterLV.LineVelocity,
		TrainDirection = direction,
		ThrottleNotch = throttleNotch,
		BrakeNotch = brakeNotch,
		CurrentMaster = currentMaster
	}
	
	return context
end

local function notchUp()
	task.spawn(function()
		local s = sounds.NotchUp:Clone()
		s.Parent = sounds
		s:Play()
		task.wait(s.TimeLength)
	end)
end

local function notchDown()
	task.spawn(function()
		local s = sounds.NotchUp:Clone()
		s.Parent = sounds
		s:Play()
		task.wait(s.TimeLength)
	end)
end

local function doSmoke()
	if throttleNotch == 0 then
		for i,v in smokeEmms do
			TweenService:Create(v, TweenInfo.new(1), {Rate = 6, Acceleration = Vector3.new(0, 3, 0)}):Play()	
			v.Lifetime = NumberRange.new(3)
		end
		
		for i,v in engineSounds do 
			TweenService:Create(v, TweenInfo.new(2), {PlaybackSpeed = 1}):Play()
		end
	elseif throttleNotch == 1 then 
		for i,v in smokeEmms do
			TweenService:Create(v, TweenInfo.new(1), {Rate = 15, Acceleration = Vector3.new(0, 6, 0)}):Play()
			v.Lifetime = NumberRange.new(2.25)
		end
		
		for i,v in engineSounds do 
			TweenService:Create(v, TweenInfo.new(2), {PlaybackSpeed = 1.5}):Play()
		end
	elseif throttleNotch == 2 then 
		for i,v in smokeEmms do
			TweenService:Create(v, TweenInfo.new(1), {Rate = 25, Acceleration = Vector3.new(0, 9, 0)}):Play()
			v.Lifetime = NumberRange.new(1.9)
		end
		
		for i,v in engineSounds do 
			TweenService:Create(v, TweenInfo.new(2), {PlaybackSpeed = 2}):Play()
		end
	elseif throttleNotch == 3 then 
		for i,v in smokeEmms do
			TweenService:Create(v, TweenInfo.new(1), {Rate = 35, Acceleration = Vector3.new(0, 12, 0)}):Play()
			v.Lifetime = NumberRange.new(1.7)
		end
		
		for i,v in engineSounds do 
			TweenService:Create(v, TweenInfo.new(2), {PlaybackSpeed = 2.5}):Play()
		end
	elseif throttleNotch == 4 then 
		for i,v in smokeEmms do
			TweenService:Create(v, TweenInfo.new(1), {Rate = 45, Acceleration = Vector3.new(0, 16, 0)}):Play()
			v.Lifetime = NumberRange.new(1.5)
		end
		
		for i,v in engineSounds do 
			TweenService:Create(v, TweenInfo.new(2), {PlaybackSpeed = 3}):Play()
		end
	end
end

local function evaluateModuleReturns(moduleResult, module : ModuleScript)
	if type(moduleResult) == "table" then
		if moduleResult[1] == "ChangeSpeed" then
			for i,v in LinearVelocities do
				v.LineVelocity = moduleResult[2]
			end
		elseif moduleResult[1] == "TNotchUp" then
			if throttleNotch < config.MaxThrottleNotch.Value then
				notchUp()
				throttleNotch += 1
				doSmoke()
			end
		elseif moduleResult[1] == "TNotchDown" then
			if throttleNotch > 0 then
				notchDown()
				throttleNotch -= 1
				doSmoke()
			end
		elseif moduleResult[1] == "BNotchUp" then
			if brakeNotch < config.MaxBrakeNotch.Value then
				notchUp()
				brakeNotch += 1
			end
		elseif moduleResult[1] == "BNotchDown" then
			if brakeNotch > 0 then
				notchDown()
				brakeNotch -= 1
			end
		elseif moduleResult[1] == "ChangeDirection" then 
			sounds.Reverser:Play()
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
		if throttleNotch == 0 then 

		end
		print("ThrottleNotch: "..throttleNotch)
		print("BrakeNotch: "..brakeNotch)
		print(direction)
	end
end

train.DriveSystemSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
	local occ = train.DriveSystemSeat.Occupant
	
	if (occ == nil) then 
		if (train.DriveSystemSeatTwo.Occupant == nil) then	
			currentMaster = nil
		else
			currentMaster = train.DriveSystemSeatTwo
		end
	else
		currentMaster = train.DriveSystemSeat
	end
end)

train.DriveSystemSeatTwo:GetPropertyChangedSignal("Occupant"):Connect(function()
	local occ = train.DriveSystemSeatTwo.Occupant

	if (occ == nil) then 
		if (train.DriveSystemSeat.Occupant == nil) then	
			currentMaster = nil
		else
			currentMaster = train.DriveSystemSeat
		end
	else
		currentMaster = train.DriveSystemSeatTwo
	end
end)

train.Events.Remotes.OnButtonPressed.OnServerEvent:Connect(function(plr, Name)
	local hum : Humanoid = plr.Character:FindFirstChild("Humanoid")

	if hum == nil then 
		return
	end
	
	-- Remote Event Security
	if not (hum.SeatPart == train.DriveSystemSeat) and 
		not (hum.SeatPart == train.DriveSystemSeatTwo) 
		or not (hum.SeatPart == train.DriveSystemSeatTwo) and 
		not (hum.SeatPart == train.DriveSystemSeat)
	then 
		plr:Kick("You aren't the player in the seat!")
		return
	end
	
	local module = buttonModules:FindFirstChild(Name)
	
	if module == nil then
		if RunService:IsStudio() then 
			warn(`A button called {Name} was pressed, but has no implementation.`)
		end
		return
	end
	
	local moduleResult

	local success, result = pcall(function()
		moduleResult = require(module)(constructContext(), plr, train)
	end)
	
	if success == false then
		warn("An error occured while running module "..module.Name)
		warn(result)
		return
	end
	
	evaluateModuleReturns(moduleResult, module)
end)

remote.OnServerEvent:Connect(function(plr : Player, Keycode, UserInputState)
	local keyPressed = UserInputService:GetStringForKeyCode(Keycode)
	
	if keyPressed == nil then
		return
	end
	
	if keyPressed == "Space" then 
		return
	end
	
	local hum : Humanoid = plr.Character:FindFirstChild("Humanoid")
	
	if hum == nil then 
		return
	end
	
	-- Remote Event Security
	if not (hum.SeatPart == train.DriveSystemSeat) and 
		not (hum.SeatPart == train.DriveSystemSeatTwo) 
	or not (hum.SeatPart == train.DriveSystemSeatTwo) and 
		not (hum.SeatPart == train.DriveSystemSeat)
	then 
		plr:Kick("You aren't the player in the seat!")
		return
	end
	
	if (hum.SeatPart == train.DriveSystemSeatTwo) and not (train.DriveSystemSeat.Occupant == nil) then 
		warn("Input recieved from Drive Seat Two, but a player is in Drive Seat One. Using input from Drive Seat One")
		return
	end
	
	local module = keyModules:FindFirstChild(keyPressed.."Key")
	if not module then
		if RunService:IsStudio() then 
			warn(keyPressed.." was pressed, but has no implementation!")
		end
		return 
	end
	
	local moduleResult
	
	local success, result = pcall(function()
		moduleResult = require(module)(constructContext(), plr, train)
	end)
	
	if success == false then
		warn("An error occured while running module "..module.Name)
		warn(result)
		return
	end
	
	evaluateModuleReturns(moduleResult, module)
end)

train.Events.Functions.GetContext.OnInvoke = function()
	return constructContext()
end

RunService.PreSimulation:Connect(function(deltaTimeSim: number)
	local newSpeed = trainSpeed:Run(constructContext())
	
	if newSpeed ~= nil and canMove:CanMove(constructContext(), train) then
		for i,v in LinearVelocities do
			v.LineVelocity = newSpeed
		end
	end
end)
