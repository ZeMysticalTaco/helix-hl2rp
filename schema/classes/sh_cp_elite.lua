CLASS.name = "Civil Protection Elite"
CLASS.description = "The top officers of the Civil Protection."
CLASS.faction = FACTION_CP

function CLASS:OnCanBe(client)
	return client:IsCombineRank(Schema.eliteRanks)
end

CLASS_CP_ELITE = CLASS.index