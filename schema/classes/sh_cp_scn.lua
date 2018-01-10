CLASS.name = "Civil Protection Scanner"
CLASS.description = "A robotic, metal scanner for observing the city."
CLASS.faction = FACTION_CP

function CLASS:OnCanBe(client)
	return client:IsCombineRank(Schema.scnRanks)
end


function CLASS:OnSet(client)
	local scanner = ix.plugin.list.scanner

	if (scanner) then
		scanner:createScanner(client, client:getCombineRank() == "CLAW.SCN" and "npc_clawscanner" or nil)
	else
		client:ChatPrint("The server is missing the 'scanner' plugin.")
	end
end

function CLASS:OnLeave(client)
	if (IsValid(client.nutScn)) then
		local data = {}
			data.start = client.nutScn:GetPos()
			data.endpos = data.start - Vector(0, 0, 1024)
			data.filter = {client, client.nutScn}
		local position = util.TraceLine(data).HitPos

		client.nutScn.spawn = position
		client.nutScn:Remove()
	end
end

CLASS_CP_SCN = CLASS.index