ITEM.name = "Vegtable Oil"
ITEM.description = "Often used for cooking food."
ITEM.price = 20
ITEM.model = Model("models/props_junk/garbage_plasticbottle002a.mdl")
ITEM.damage = 15
ITEM.category = "consumables"
ITEM.functions.Drink = {
	OnClick = function()
		LocalPlayer():EmitSound("npc/barnacle/barnacle_gulp"..math.random(1, 2)..".wav")
	end,
	OnRun = function(item)
		item.player:SetHealth(math.min(item.player:Health() + 1, 100))
	end
}
ITEM.permit = "food"