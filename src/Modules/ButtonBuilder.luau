--!strict
-- highzpeedtrain 19/05/2025 --
--[[
	Module for building buttons on the Train UI
]]
local typeDefs = require(script.Parent.TypeDefinitions)

local config = script.Parent.Parent.Configuration
local trainUi = script.Parent.Parent.Scripts.LocalControlInsert.LocalControl.TrainGui

local buttonBuilder = {}

export type button = {
	Button: ImageButton,
	Name: string,
	Color: Color3,
	Image: string
}
	
function buttonBuilder.new(Name : string, Color : Color3, Image : string) : button
	local clone = script.Button:Clone()
	clone.Name = Name
	clone.BackgroundColor3 = Color
	if Image then 
		clone.Image = Image
	end
	
	clone.Parent = trainUi.ButtonDeck
	
	local self = {
		Button = clone,
		Name = Name,
		Color = Color,
		Image = Image
	}
	
	return self
end
	
return buttonBuilder
