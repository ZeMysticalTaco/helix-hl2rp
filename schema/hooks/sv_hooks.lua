function Schema:PlayerFootstep(client, position, foot, soundName, volume)
	if (client:IsRunning()) then
		if (client:Team() == FACTION_CP) then
			client:EmitSound("npc/metropolice/gear"..math.random(1, 6)..".wav", volume * 130)

			return true
		elseif (client:Team() == FACTION_OW) then
			client:EmitSound("npc/combine_soldier/gear"..math.random(1, 6)..".wav", volume * 100)

			return true
		end
	end
end

function Schema:OnCharCreated(client, character)
	local inventory = character:GetInv()

	if (inventory) then		
		if (character:GetFaction() == FACTION_CITIZEN) then
			inventory:Add("cid", 1, {
				name = character:GetName(),
				id = math.random(10000, 99999)
			})
		elseif (self:IsCombineFaction(character:GetFaction())) then
			inventory:Add("radio", 1)
		end
	end
end

function Schema:LoadData()
	self:loadVendingMachines()
	self:loadDispensers()
	self:loadObjectives()
end

function Schema:PostPlayerLoadout(client)
	if (client:IsCombine()) then
		if (client:Team() == FACTION_CP) then
			for k, v in ipairs(ix.class.list) do
				if (client:GetChar():joinClass(k)) then
					break
				end
			end

			hook.Run("PlayerRankChanged", client)

			client:SetArmor(50)
		else
			client:SetArmor(100)
		end

		client:AddDisplay("Local unit protection measures active at "..client:Armor().."%")

		if (ix.plugin.list.scanner and client:IsCombineRank(self.scnRanks)) then
			ix.plugin.list.scanner:createScanner(client, client:getCombineRank() == "CLAW.SCN" and "npc_clawscanner" or nil)
		end
	end
end

function Schema:CanPlayerViewData(client, target)
	if (client:IsCombine()) then
		return true
	end
end

function Schema:PlayerUseDoor(client, entity)
	if (client:IsCombine()) then
		local lock = entity.lock or (IsValid(entity:getDoorPartner()) and entity:getDoorPartner().lock)

		if (client:KeyDown(IN_SPEED) and IsValid(lock)) then
			lock:toggle()

			return false
		elseif (!entity:HasSpawnFlags(256) and !entity:HasSpawnFlags(1024)) then
			entity:Fire("open", "", 0)
		end
	end
end

function Schema:PlayerSwitchFlashlight(client, enabled)
	if (client:IsCombine()) then
		return true
	end
end

function Schema:PlayerRankChanged(client)
	for k, v in pairs(self.rankModels) do
		if (client:IsCombineRank(k)) then
			client:SetModel(v)
		end
	end
end

function Schema:OnCharVarChanged(character, key, oldValue, value)
	if (key == "name" and IsValid(character:getPlayer()) and character:getPlayer():IsCombine()) then
		for k, v in ipairs(ix.class.list) do
			if (character:joinClass(k)) then
				break
			end
		end

		hook.Run("PlayerRankChanged", character:getPlayer())
	end
end

local digitsToWords = {
	[0] = "zero",
	[1] = "one",
	[2] = "two",
	[3] = "three",
	[4] = "four",
	[5] = "five",
	[6] = "six",
	[7] = "seven",
	[8] = "eight",
	[9] = "nine"
}

function Schema:GetPlayerDeathSound(client)
	if (client:IsCombine()) then
		local sounds = self.deathSounds[client:Team()] or self.deathSounds[FACTION_CP]
		local digits = client:getDigits()
		local queue = {"npc/overwatch/radiovoice/lostbiosignalforunit.wav"}

		if (tonumber(digits)) then
			for i = 1, #digits do
				local digit = tonumber(digits:sub(i, i))
				local word = digitsToWords[digit]

				queue[#queue + 1] = "npc/overwatch/radiovoice/"..word..".wav"
			end

			local chance = math.random(1, 7)

			if (chance == 2) then
				queue[#queue + 1] = "npc/overwatch/radiovoice/remainingunitscontain.wav"
			elseif (chance == 3) then
				queue[#queue + 1] = "npc/overwatch/radiovoice/reinforcementteamscode3.wav"
			end

			queue[#queue + 1] = {table.Random(self.beepSounds[client:Team()] and self.beepSounds[client:Team()].off or self.beepSounds[FACTION_CP].off), nil, 0.25}

			for k, v in ipairs(player.GetAll()) do
				if (v:IsCombine()) then
					ix.util.EmitQueuedSounds(v, queue, 2, nil, v == client and 100 or 65)
				end
			end
		end

		self:AddDisplay("lost bio-signal for protection team unit "..digits.." at unknown location", Color(255, 0, 0))

		return table.Random(sounds)
	end
end

function Schema:PlayerHurt(client, attacker, health, damage)
	if (client:IsCombine() and damage > 5) then
		local word = "minor"

		if (damage >= 75) then
			word = "immense"
		elseif (damage >= 50) then
			word = "huge"
		elseif (damage >= 25) then
			word = "large"
		end

		client:AddDisplay("local unit has sustained "..word.." bodily damage"..(damage >= 25 and ", seek medical attention" or ""), Color(255, 175, 0))

		local delay

		if (client:Health() <= 10) then
			delay = 5
		elseif (client:Health() <= 25) then
			delay = 10
		elseif (client:Health() <= 50) then
			delay = 30
		end

		if (delay) then
			client.nutHealthCheck = CurTime() + delay
		end
	end
end

function Schema:GetPlayerPainSound(client)
	if (client:IsCombine()) then
		local sounds = self.painSounds[client:Team()] or self.painSounds[FACTION_CP]

		return table.Random(sounds)
	end
end

function Schema:PlayerTick(client)
	if (client:IsCombine() and client:Alive() and (client.nutHealthCheck or 0) < CurTime()) then
		local delay = 60

		if (client:Health() <= 10) then
			delay = 10
			client:AddDisplay("Local unit vital signs are failing, seek medical attention immediately", Color(255, 0, 0))
		elseif (client:Health() <= 25) then
			delay = 20
			client:AddDisplay("Local unit must seek medical attention immediately", Color(255, 100, 0))
		elseif (client:Health() <= 50) then
			delay = 45
			client:AddDisplay("Local unit is advised to seek medical attention when possible", Color(255, 175, 0))
		end

		client.nutHealthCheck = CurTime() + delay
	end
end

function Schema:PlayerMessageSend(client, chatType, message, anonymous, receivers)
	if (!ix.voice.chatTypes[chatType]) then
		return
	end

	for _, definition in ipairs(ix.voice.GetClass(client)) do
		local sounds, message = ix.voice.GetVoiceList(definition.class, message)

		if (sounds) then
			local volume = 80

			if (chatType == "w") then
				volume = 60
			elseif (chatType == "y") then
				volume = 150
			end
			
			if (definition.OnModify) then
				if (definition.OnModify(client, sounds, chatType, message) == false) then
					continue
				end
			end

			if (definition.isGlobal) then
				netstream.Start(nil, "voicePlay", sounds, volume)
			else
				netstream.Start(nil, "voicePlay", sounds, volume, client:EntIndex())

				if (chatType == "radio" and receivers) then
					for k, v in pairs(receivers) do
						if (receivers == client) then
							continue
						end

						netstream.Start(nil, "voicePlay", sounds, volume * 0.5, v:EntIndex())
					end
				end
			end

			return message
		end
	end
end

function Schema:PlayerStaminaLost(client)
	if (client:IsCombine()) then
		client:AddDisplay("Local unit energy has been exhausted")
	end
end

function Schema:CanPlayerViewObjectives(client)
	return client:IsCombine()
end

function Schema:CanPlayerEditObjectives(client)
	return client:IsCombine()
end

netstream.Hook("dataCls", function(client, text)
	local target = client.nutDataTarget

	if (text and IsValid(target) and target:GetChar() and hook.Run("CanPlayerEditData", client, target)) then
		target:GetChar():SetData("txt", text:sub(1, 750))
		client:EmitSound("buttons/combine_button7.wav", 60, 150)
	end

	client.nutDataTarget = nil
end)

netstream.Hook("obj", function(client, text)
	if (hook.Run("CanPlayerEditObjectives", client)) then
		Schema.objectives = text
		Schema:AddDisplay(client:Name().." has updated the objectives", Color(0, 0, 255))
		Schema:saveObjectives()
	end
end)