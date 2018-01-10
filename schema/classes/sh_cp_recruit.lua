CLASS.name = "Civil Protection Recruit"
CLASS.description = "The bottom of the Civil Protection."
CLASS.faction = FACTION_CP

function CLASS:OnCanBe(client)
	return client:IsCombineRank(Schema.rctRanks)
end

CLASS_CP_RCT = CLASS.index