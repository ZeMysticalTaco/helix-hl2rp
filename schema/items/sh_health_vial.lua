ITEM.name = "Health Vial"
ITEM.category = "Medical"
ITEM.description = "A small vial with green liquid."
ITEM.model = "models/healthvial.mdl"
ITEM.price = 40
ITEM.functions.Use = {
	sound = "items/medshot4.wav",
	OnRun = function(item)
		item.player:SetHealth(math.min(item.player:Health() + 50, 100))
	end
}
ITEM.factions = {FACTION_CP, FACTION_OW}