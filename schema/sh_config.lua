-- Customize the beep sounds here, before and after voices.
Schema.beepSounds = {}
Schema.beepSounds[FACTION_CP] = {
	on = {
		"npc/overwatch/radiovoice/on1.wav",
		"npc/overwatch/radiovoice/on3.wav",
		"npc/metropolice/vo/on2.wav"
	},
	off = {
		"npc/metropolice/vo/off1.wav",
		"npc/metropolice/vo/off2.wav",
		"npc/metropolice/vo/off3.wav",
		"npc/metropolice/vo/off4.wav",
		"npc/overwatch/radiovoice/off2.wav",
		"npc/overwatch/radiovoice/off2.wav"
	}
}
Schema.beepSounds[FACTION_OW] = {
	on = {
		"npc/combine_soldier/vo/on1.wav",
		"npc/combine_soldier/vo/on2.wav"
	},
	off = {
		"npc/combine_soldier/vo/off1.wav",
		"npc/combine_soldier/vo/off2.wav",
		"npc/combine_soldier/vo/off3.wav"
	}
}

-- Sounds play after the player has died.
Schema.deathSounds = {}
Schema.deathSounds[FACTION_CP] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
}
Schema.deathSounds[FACTION_OW] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
}

-- Sounds the player makes when injured.
Schema.painSounds = {}
Schema.painSounds[FACTION_CP] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav"
}
Schema.painSounds[FACTION_OW] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
}

-- Civil Protection name prefix.
Schema.cpPrefix = "CP-"

-- How long the Combine digits are.
Schema.digitsLen = 5

-- Rank information.
Schema.rctRanks = {"RCT"}
Schema.unitRanks = {"05", "04", "03", "02", "01", "OfC"}
Schema.eliteRanks = {"EpU", "DvL", "SeC"}
Schema.scnRanks = {"SCN", "CLAW.SCN"}

-- What model each rank should be.
Schema.rankModels = {
	["RCT"] = "models/police.mdl",
	[Schema.unitRanks] = "models/dpfilms/metropolice/hl2concept.mdl",
	["OfC"] = "models/dpfilms/metropolice/policetrench.mdl",
	["EpU"] = "models/dpfilms/metropolice/elite_police.mdl",
	["DvL"] = "models/dpfilms/metropolice/blacop.mdl",
	["SeC"] = "models/dpfilms/metropolice/phoenix_police.mdl",
	["SCN"] = "models/combine_scanner.mdl",
	["CLAW.SCN"] = "models/shield_scanner.mdl"
}

-- The default player data when using /data
Schema.defaultData = [[
Points:
Infractions:
]]