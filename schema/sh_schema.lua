Schema.name = "HL2 RP"
Schema.introName = "Half-Life 2 Roleplay"
Schema.author = "Chessnut"
Schema.description = "Under the rule of the Universal Union."

function Schema:IsCombineFaction(faction)
	return faction == FACTION_CP or faction == FACTION_OW
end

do
	local playerMeta = FindMetaTable("Player")

	function playerMeta:IsCombine()
		return Schema:IsCombineFaction(self:Team())
	end

	function playerMeta:getCombineRank()
		local name = self:Name()

		for k, v in ipairs(Schema.scnRanks) do
			local rank = string.PatternSafe(v)

			if (name:find("[%D+]"..rank.."[%D+]")) then
				return v
			end
		end

		for k, v in ipairs(Schema.rctRanks) do
			local rank = string.PatternSafe(v)

			if (name:find("[%D+]"..rank.."[%D+]")) then
				return v
			end
		end

		for k, v in ipairs(Schema.unitRanks) do
			local rank = string.PatternSafe(v)

			if (name:find("[%D+]"..rank.."[%D+]")) then
				return v
			end
		end

		for k, v in ipairs(Schema.eliteRanks) do
			local rank = string.PatternSafe(v)

			if (name:find("[%D+]"..rank.."[%D+]")) then
				return v
			end
		end
	end

	function playerMeta:IsCombineRank(rank)
		if (type(rank) == "table") then
			local name = self:Name()

			for k, v in ipairs(rank) do
				local rank = string.PatternSafe(v)

				if (name:find("[%D+]"..rank.."[%D+]")) then
					return v
				end				
			end

			return false
		else
			return self:getCombineRank() == rank
		end
	end

	function playerMeta:getRank()
		for k, v in ipairs(team.GetPlayers(FACTION_CP)) do
			local eliteRanks = string.Explode(",", ix.config.Get("rankElite", "RCT"):gsub("%s", ""))
			local unitRanks = string.Explode(",", ix.config.Get("rankUnit", "RCT"):gsub("%s", ""))
			local name = string.PatternSafe(v:Name())

			for k, v in ipairs(eliteRanks) do
				if (name:find(v)) then
					return CLASS_CP_ELITE
				end
			end

			for k, v in ipairs(unitRanks) do
				if (name:find(v)) then
					return CLASS_CP_UNIT
				end
			end

			return CLASS_CP_RCT
		end
	end

	function Schema:IsDispatch(client)
		return client:IsCombineRank(self.eliteRanks) or client:IsCombineRank(self.scnRanks)
	end

	function playerMeta:getDigits()
		if (self:IsCombine()) then
			local name = self:Name():reverse()
			local digits = name:match("(%d+)")

			if (digits) then
				return tostring(digits):reverse()
			end
		end

		return "UNKNOWN"
	end

	if (SERVER) then
		function playerMeta:AddDisplay(text, color)
			if (self:IsCombine()) then
				netstream.Start(self, "cDisp", text, color)
			end
		end

		function Schema:AddDisplay(text, color)
			local receivers = {}

			for k, v in ipairs(player.GetAll()) do
				if (v:IsCombine()) then
					receivers[#receivers + 1] = v
				end
			end

			netstream.Start(receivers, "cDisp", text, color)
		end
	end
end

ix.util.Include("sh_config.lua")
ix.util.Include("sh_commands.lua")
ix.util.IncludeDir("hooks")

if (SERVER) then
	Schema.objectives = Schema.objectives or ""
	
	concommand.Add("nut_Setupnexusdoors", function(client, command, arguments)
		if (!IsValid(client)) then
			if (!ix.plugin.list.doors) then
				return MsgN("[NutScript] Door plugin is missing!")
			end

			local name = table.concat(arguments, " ")

			for _, entity in ipairs(ents.FindByClass("func_door")) do
				if (!entity:HasSpawnFlags(256) and !entity:HasSpawnFlags(1024)) then
					entity:SetNetVar("noSell", true)
					entity:SetNetVar("name", !name:find("%S") and "Nexus" or name)
				end
			end

			ix.plugin.list.doors:SaveDoorData()

			MsgN("[NutScript] Nexus doors have been Set up.")
		end
	end)
end

for k, v in pairs(Schema.beepSounds) do
	for k2, v2 in ipairs(v.on) do
		util.PrecacheSound(v2)
	end

	for k2, v2 in ipairs(v.off) do
		util.PrecacheSound(v2)
	end
end

for k, v in pairs(Schema.deathSounds) do
	for k2, v2 in ipairs(v) do
		util.PrecacheSound(v2)
	end
end

for k, v in pairs(Schema.painSounds) do
	for k2, v2 in ipairs(v) do
		util.PrecacheSound(v2)
	end
end

for k, v in pairs(Schema.rankModels) do
	ix.anim.SetModelClass(v, "metrocop")
	player_manager.AddValidModel("combine", v)

	util.PrecacheModel(v)
end

ix.util.Include("sh_voices.lua")

if (SERVER) then
	function Schema:saveObjectives()
		ix.data.Set("objectives", self.objectives, false, true)
	end

	function Schema:saveVendingMachines()
		local data = {}

		for k, v in ipairs(ents.FindByClass("nut_vendingm")) do
			data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetNetVar("stocks"), v:GetNetVar("active")}
		end

		ix.data.Set("vendingm", data)
	end

	function Schema:saveDispensers()
		local data = {}

		for k, v in ipairs(ents.FindByClass("nut_dispenser")) do
			data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetDisabled() == true and true or nil}
		end

		ix.data.Set("dispensers", data)
	end

	function Schema:loadObjectives()
		self.objectives = ix.data.Get("objectives", "", false, true)
	end

	function Schema:loadVendingMachines()
		local data = ix.data.Get("vendingm") or {}

		for k, v in ipairs(data) do
			local entity = ents.Create("nut_vendingm")
			entity:SetPos(v[1])
			entity:SetAngles(v[2])
			entity:Spawn()
			entity:SetNetVar("stocks", v[3] or {})
			entity:SetNetVar("active", v[4])
		end
	end

	function Schema:loadDispensers()
		for k, v in ipairs(ix.data.Get("dispensers") or {}) do
			local entity = ents.Create("nut_dispenser")
			entity:SetPos(v[1])
			entity:SetAngles(v[2])
			entity:Spawn()

			if (v[3]) then
				entity:SetDisabled(true)
			end
		end
	end
end

ix.chat.Register("dispatch", {
	color = Color(192, 57, 43),
	OnCanSay = function(client)
		if (!Schema:IsDispatch(client)) then
			client:notifyLocalized("notAllowed")

			return false
		end
	end,
	OnChatAdd = function(speaker, text)
		chat.AddText(Color(192, 57, 43), L("icFormat", "Dispatch", text))
	end,
	prefix = {"/dispatch"}
})

ix.chat.Register("request", {
	color = Color(210, 77, 87),
	OnChatAdd = function(speaker, text)
		chat.AddText(Color(210, 77, 87), text)
	end,
	OnCanHear = function(speaker, listener)
		return listener:IsCombine()
	end
})

ix.flag.Add("y", "Access to the light blackmarket items.")
ix.flag.Add("Y", "Access to the heavy blackmarket items.")

ix.currency.Set("", "token", "tokens")