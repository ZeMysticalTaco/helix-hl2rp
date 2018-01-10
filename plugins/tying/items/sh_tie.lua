ITEM.name = "Zip Tie"
ITEM.description = "An orange zip-tie used to restrict players."
ITEM.price = 50
ITEM.model = "models/items/crossbowrounds.mdl"
ITEM.factions = {FACTION_CP, FACTION_OW}
ITEM.functions.Use = {
	OnRun = function(item)
		if (item.beingUsed) then
			return false
		end

		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer() and target:GetChar() and !target:GetNetVar("tying") and !target:GetNetVar("restricted")) then
			item.beingUsed = true

			client:EmitSound("physics/plastic/plastic_barrel_strain"..math.random(1, 3)..".wav")
			client:SetAction("@tying", 5)
			client:doStaredAction(target, function()
				item:remove()

				target:SetRestricted(true)
				target:SetNetVar("tying")

				client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)
			end, 5, function()
				client:SetAction()

				target:SetAction()
				target:SetNetVar("tying")

				item.beingUsed = false
			end)

			target:SetNetVar("tying", true)
			target:SetAction("@beingTied", 5)
		else
			item.player:notifyLocalized("plyNotValid")
		end

		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity)
	end
}

function ITEM:OnCanBeTransfered(inventory, newInventory)
	return !self.beingUsed
end