local canMoveConditions = {}

local TypeDefs = require(script.Parent.TypeDefinitions)

function canMoveConditions:CanMove(context : TypeDefs.TrainContext, train : Model)
	-- return true for can move, return false for can't
	-- this will not set speed to 0, it will just prevent the speed from updating if false
	-- have fun
	
	return true
end

return canMoveConditions
