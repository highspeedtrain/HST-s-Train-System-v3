--!nonstrict
-- highzpeedtrain 10/05/2025 --
--[[
	Main core for train acceleration and deccel
	
	Modifiying this is not recommended if you don't know what you're doing.
	Use Configuration instead.
]]

local typeDefs = require(script.Parent.TypeDefinitions)

local config = script.Parent.Parent.Configuration

local trainSpeed = {}
function trainSpeed:Run(context : typeDefs.TrainContext)
	if (context.TrainDirection == typeDefs.ReverserDirs.Forward) then
		local throttleAdd
		local brakeRem

		if (context.ThrottleNotch > 0) then
			-- Train should be accelerating
			local notchValue : NumberValue = config.AccelNotchSpeeds:FindFirstChild("Notch"..context.ThrottleNotch)
			if notchValue == nil then
				error(`Critical error encountered - Unable to locate acceleration 'Notch{context.ThrottleNotch}', does the value exsist?`)
			end

			for i = 1, config.MaxThrottleNotch.Value do
				if i == context.ThrottleNotch and context.CurrentSpeed < config.MaxSpeed.Value then
					throttleAdd = notchValue.Value or 0
				end
			end
		end

		if (context.BrakeNotch > 0) then
			-- Train should be decelerating
			local notchValue : NumberValue = config.DecelNotchSpeed:FindFirstChild("Notch"..context.BrakeNotch)
			if notchValue == nil then
				error(`Critical error encountered - Unable to locate value 'Notch{context.BrakeNotch}', does the value exsist?`)
			end

			for i = 1, config.MaxThrottleNotch.Value do
				if i == context.BrakeNotch then
					if (math.abs(context.CurrentSpeed) > 0+config.DecelNotchSpeed:FindFirstChild(`Notch{i}`).Value) then
						brakeRem = notchValue.Value
					else
						brakeRem = "STOP"
					end
				end
			end
		end

		if brakeRem == nil then
			brakeRem = 0
		end

		if throttleAdd == nil then
			throttleAdd = 0
		end

		if (brakeRem == "STOP") then
			return 0
		elseif (context.CurrentMaster == script.Parent.Parent.DriveSystemSeatTwo) then
			return (context.CurrentSpeed-throttleAdd)+brakeRem
		else
			return (context.CurrentSpeed+throttleAdd)-brakeRem
		end
	elseif (context.TrainDirection == typeDefs.ReverserDirs.Reverse) then
		local throttleAdd
		local brakeRem

		if (context.ThrottleNotch > 0) then
			-- Train should be accelerating
			local notchValue : NumberValue = config.AccelNotchSpeeds:FindFirstChild("Notch"..context.ThrottleNotch)
			if notchValue == nil then
				error(`Critical error encountered - Unable to locate value 'Notch{context.ThrottleNotch}', does the value exsist?`)
			end

			for i = 1, config.MaxThrottleNotch.Value do
				if i == context.ThrottleNotch then
					if (math.abs(context.CurrentSpeed - notchValue.Value) > math.abs(config.MaxSpeed.Value)) then
						return "MaxSpeed"
					end
					throttleAdd = notchValue.Value
				end
			end
		end

		if context.BrakeNotch > 0 then
			-- Train should be decelerating
			local notchValue : NumberValue = config.DecelNotchSpeed:FindFirstChild("Notch"..context.BrakeNotch)
			if notchValue == nil then
				error(`Critical error encountered - Unable to locate deceleration 'Notch{context.BrakeNotch}', does the value exsist?`)
			end

			for i = 1, config.MaxThrottleNotch.Value do
				if i == context.BrakeNotch then
					if (context.CurrentSpeed < 0-config.DecelNotchSpeed:FindFirstChild(`Notch{i}`).Value) then
						brakeRem = notchValue.Value
					else
						brakeRem =  "STOP"
					end
				end
			end
		end

		if brakeRem == nil then
			brakeRem = 0
		end

		if throttleAdd == nil then
			throttleAdd = 0
		end

		if (brakeRem == "STOP") then
			return 0
		elseif (throttleAdd == "MaxSpeed") then
			return config.MaxSpeed.Value
		elseif (context.CurrentMaster == script.Parent.Parent.DriveSystemSeatTwo) then
			return (context.CurrentSpeed+throttleAdd)-brakeRem
		else
			return (context.CurrentSpeed-throttleAdd)+brakeRem
		end
	end
end
return trainSpeed
