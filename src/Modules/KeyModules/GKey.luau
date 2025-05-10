-- highzpeedtrain 10/05/2025 --
local typeDefs = require(script.Parent.Parent.TypeDefinitions)

return function(Context, Player : Player, Train : Model)
	if Context.TrainDirection == typeDefs.ReverserDirs.Forward then
		return {"ChangeDirection", typeDefs.ReverserDirs.Reverse}
	elseif Context.TrainDirection == typeDefs.ReverserDirs.Neutral then
		return {"ChangeDirection", typeDefs.ReverserDirs.Forward}
	elseif Context.TrainDirection == typeDefs.ReverserDirs.Reverse then
		return {"ChangeDirection", typeDefs.ReverserDirs.Neutral}
	end
end
