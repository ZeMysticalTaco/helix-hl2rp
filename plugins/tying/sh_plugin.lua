PLUGIN.name = "Tying"
PLUGIN.author = "Chessnut"
PLUGIN.description = "Adds the ability to tie players."

ix.util.Include("sh_charsearch.lua")

if (SERVER) then
	function PLUGIN:PlayerLoadout(client)
		client:SetNetVar("restricted")
	end

	function PLUGIN:PlayerUse(client, entity)
		if (!client:GetNetVar("restricted") and entity:IsPlayer() and entity:GetNetVar("restricted") and !entity.nutBeingUnTied) then
			entity.nutBeingUnTied = true
			entity:SetAction("@beingUntied", 5)

			client:SetAction("@unTying", 5)
			client:doStaredAction(entity, function()
				entity:SetRestricted(false)
				entity.nutBeingUnTied = false

				client:EmitSound("npc/roller/blade_in.wav")
			end, 5, function()
				if (IsValid(entity)) then
					entity.nutBeingUnTied = false
					entity:SetAction()
				end

				if (IsValid(client)) then
					client:SetAction()
				end
			end)
		end
	end
else
	local COLOR_TIED = Color(245, 215, 110)

	function PLUGIN:DrawCharInfo(client, character, info)
		if (client:GetNetVar("restricted")) then
			info[#info + 1] = {L"isTied", COLOR_TIED}
		end
	end
end