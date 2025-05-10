-- highzpeedtrain 10/05/2025 --
--[[
	Main core for train acceleration and deccel
	
	Modifiying this is not recommended if you don't know what you're doing.
	Use Configuration instead.
]]

local typeDefs = require(script.Parent.TypeDefinitions)

local trainSpeed = {}
	function trainSpeed:Run(context : typeDefs.TrainContext)
		if context.TrainDirection == typeDefs.ReverserDirs.Forward then
			if context.ThrottleNotch > 0 then
				-- Train should be accelerating
				return context.CurrentSpeed + 0.01
			end
			
			if context.BrakeNotch > 0 then
				-- Train should be decelerating
				if context.CurrentSpeed > 0 then
					return context.CurrentSpeed - 0.01
				end
			end
		elseif context.TrainDirection == typeDefs.ReverserDirs.Reverse then
			if context.ThrottleNotch > 0 then
				-- Train should be accelerating
				return context.CurrentSpeed - 0.01
			end

			if context.BrakeNotch > 0 then
				-- Train should be decelerating
				if context.CurrentSpeed > 0 then
					return context.CurrentSpeed + 0.01
				end
			end
		end
	end
return trainSpeed
