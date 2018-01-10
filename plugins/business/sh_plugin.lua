PLUGIN.name = "Business Permits"
PLUGIN.description = "Adds business permits which are needed to purchase certain goods."
PLUGIN.author = "Chessnut"

function PLUGIN:CanPlayerUseBusiness(client, uniqueID)
	local itemTable = ix.item.list[uniqueID]

	if (itemTable and itemTable.permit) then
		if (!client:GetChar():GetInv():HasItem("permit_"..itemTable.permit)) then
			return false
		end
	end
end