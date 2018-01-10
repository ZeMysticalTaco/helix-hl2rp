ix.command.Add("doorkick", {
	OnRun = function(self, client, arguments)
		if (client:Team() == FACTION_CP) then
			local aimVector = client:GetAimVector()

			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + aimVector*96
				data.filter = client
			local entity = util.TraceLine(data).Entity

			if (IsValid(entity) and entity:GetClass() == "prop_door_rotating") then
				if (client:forceSequence("kickdoorbaton")) then
					timer.Simple(0.75, function()
						if (IsValid(client) and IsValid(entity)) then
							entity:EmitSound("physics/wood/wood_crate_break"..math.random(1, 5)..".wav", 150)
							entity:blastDoor(aimVector * (360 + client:GetChar():getAttrib("str", 0)*5))
						end
					end)
				end
			else
				return "@dNotValid"
			end
		else
			return "@mustBeCP"
		end
	end
})

ix.command.Add("data", {
	syntax = "<string name>",
	OnRun = function(self, client, arguments)
		local target = ix.command.findPlayer(client, table.concat(arguments, " "))

		if (IsValid(target) and target:GetChar()) then
			if (!hook.Run("CanPlayerViewData", client, target)) then
				return "@noViewData"
			end

			client.nutDataTarget = target
			netstream.Start(client, "plyData", target:GetChar():getData("txt"), target:Name().." ["..target:getDigits().."]", hook.Run("CanPlayerEditData", client, target))
		end
	end
})

ix.command.Add("objectives", {
	OnRun = function(self, client, arguments)
		if (hook.Run("CanPlayerViewObjectives", client)) then
			netstream.Start(client, "obj", Schema.objectives, hook.Run("CanPlayerEditObjectives", client))
		else
			return "@noViewObj"
		end
	end
})

ix.command.Add("Setpriority", {
	syntax = "<number id> [bool status]",
	OnRun = function(self, client, arguments)
		if (!client:IsCombine()) then
			return "@notCombine"
		end

		local id = tonumber(arguments[1])
		local status = util.tobool(arguments[2])

		if (!status) then
			status = nil
		end

		for k2, v2 in pairs(ix.item.instances) do
			if (v2.uniqueID == "cid" and v2:getData("id", 0) == id) then
				v2:SetData("cwu", status)

				return "@prioritySet", v2:getData("name", "John Doe")
			end
		end

		return "@plyNoExist"
	end
})

ix.command.Add("request", {
	syntax = "<string text>",
	OnRun = function(self, client, arguments)
		if ((client.nutNextReq or 0) < CurTime()) then
			local text = table.concat(arguments, " ")
			local item = client:GetChar():GetInv():HasItem("request")

			if (item) then
				if (text:find("%S")) then
					client.nutNextReq = CurTime() + 5
					ix.chat.send(client, "request", "["..item:getData("name", client:Name())..", "..item:getData("id", "ERROR").."] "..text)

					return client:EmitSound("buttons/combine_button5.wav", 50, 40)
				end
			else
				return "@noReqDev"
			end

			client.nutNextReq = CurTime() + 1
			client:EmitSound("buttons/combine_button3.wav", 75, 150)
		end
	end
})