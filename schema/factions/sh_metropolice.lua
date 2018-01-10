FACTION.name = "fCopName"
FACTION.description = "fCopDesc"
FACTION.color = Color(25, 30, 180)
FACTION.isDefault = false
FACTION.models = {
	"models/police.mdl"
}
FACTION.weapons = {"nut_stunstick"}
FACTION.pay = 25
FACTION.isGloballyRecognized = true

function FACTION:OnGetDefaultName(client)
	if (Schema.digitsLen >= 1) then
		local digits = math.random(tonumber("1"..string.rep("0", Schema.digitsLen-1)), tonumber(string.rep("9", Schema.digitsLen)))
		return Schema.cpPrefix..table.GetFirstValue(Schema.rctRanks).."."..digits, true
	else
		return Schema.cpPrefix..table.GetFirstValue(Schema.rctRanks), true
	end
end

FACTION_CP = FACTION.index
