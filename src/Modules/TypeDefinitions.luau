-- highzpeedtrain 10/05/2025 --
--[[
	Defines core types for the train system.
]]
local typeDefs = {}
	export type reverserDirections = "Forward"|"Neutral"|"Reverse"
	
	export type TrainContext = {
		CurrentSpeed: number,
		TrainDirection: string,
		ThrottleNotch: number,
		BrakeNotch: number,
		CurrentMaster: VehicleSeat
	}
	
	local reverserDirectionsTable = {
		Forward = "Forward",
		Neutral = "Neutral",
		Reverse = "Reverse"
	}
	typeDefs.ReverserDirs = reverserDirectionsTable

return typeDefs
