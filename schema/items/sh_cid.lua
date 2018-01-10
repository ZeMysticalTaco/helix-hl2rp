ITEM.name = "Citizen ID"
ITEM.description = "A flat piece of plastic for identification."
ITEM.model = "models/gibs/metal_gib4.mdl"
ITEM.factions = {FACTION_CP, FACTION_ADMIN}
ITEM.functions.Assign = {
	OnRun = function(item)
		local data = {}
			data.start = item.player:EyePos()
			data.endpos = data.start + item.player:GetAimVector()*96
			data.filter = item.player
		local entity = util.TraceLine(data).Entity

		if (IsValid(entity) and entity:IsPlayer() and entity:Team() == FACTION_CITIZEN) then
			local status, result = item:transfer(entity:GetChar():GetInv():getID())

			if (status) then
				item:SetData("name", entity:Name())
				item:SetData("id", math.random(10000, 99999))
				
				return true
			else
				item.player:notify(result)
			end
		end

		return false
	end,
	OnCanRun = function(item)
		return item.player:IsCombine()
	end
}

function ITEM:GetDescription()
	local description = self.description.."\nThis has been assigned to "..self:GetData("name", "no one")..", #"..self:GetData("id", "00000").."."

	if (self:GetData("cwu")) then
		description = description.."\nThis card has a priority status stamp."
	end

	return description
end