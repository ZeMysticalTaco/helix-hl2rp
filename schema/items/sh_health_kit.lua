ITEM.name = "Health Kit"
ITEM.category = "Medical"
ITEM.description = "A large medical kit capable of more healing."
ITEM.model = "models/items/healthkit.mdl"
ITEM.price = 60
ITEM.functions.Use = {
	sound = "items/medshot4.wav",
	OnRun = function(item)
		item.player:SetHealth(math.min(item.player:Health() + 50, 100))
	end
}
ITEM.factions = {FACTION_CP, FACTION_OW}