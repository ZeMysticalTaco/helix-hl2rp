CLASS.name = "Civil Protection Unit"
CLASS.description = "A regular Civil Protection ground unit."
CLASS.faction = FACTION_CP

function CLASS:OnCanBe(client)
	return client:IsCombineRank(Schema.unitRanks)
end

CLASS_CP_UNIT = CLASS.index