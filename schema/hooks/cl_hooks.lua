Schema.displays = {}

function Schema:HUDPaint()
	if (LocalPlayer():IsCombine() and !IsValid(ix.gui.char)) then
		if (!self.overlay) then
			self.overlay = Material("effects/combine_binocoverlay")
			self.overlay:SetFloat("$alpha", "0.3")
			self.overlay:Recompute()
		end

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		local panel = ix.gui.combine

		if (IsValid(panel)) then
			local x, y = panel:GetPos()
			local w, h = panel:GetSize()
			local color = Color(255, 255, 255, panel:GetAlpha())

			for i = 1, #Schema.displays do
				local data = Schema.displays[i]

				if (data) then
					local y2 = y + (i * 22)

					if ((i * 22 + 24) > h) then
						table.remove(self.displays, 1)
					end

					surface.SetDrawColor(data.color.r, data.color.g, data.color.b, panel:GetAlpha() * (panel.mult or 0.2))
					surface.DrawRect(x, y2, w, 22)

					if (#data.realText != #data.text) then
						data.i = (data.i or 0) + 1
						data.realText = data.text:sub(1, data.i)
					end

					draw.SimpleText(data.realText, "BudgetLabel", x + 8, y2 + 12, color, 0, 1)
				end
			end
		end
	end
end

function Schema:AddDisplay(text, color)
	if (LocalPlayer():IsCombine()) then
		color = color or Color(0, 0, 0)

		Schema.displays[#Schema.displays + 1] = {text = tostring(text):upper(), color = color, realText = ""}
		LocalPlayer():EmitSound("buttons/button16.wav", 30, 120)
	end
end

function Schema:OnChatReceived(client, chatType, text, anonymous)
	local class = ix.chat.classes[chatType]

	if (client:IsCombine() and class and class.filter == "ic") then
		return "<:: "..text.." ::>"
	end
end

function Schema:CharacterLoaded(character)
	if (character == LocalPlayer():GetChar()) then
		if (self:IsCombineFaction(character:GetFaction())) then
			vgui.Create("nutCombineDisplay")
		elseif (IsValid(ix.gui.combine)) then
			ix.gui.combine:Remove()
		end
	end
end

function Schema:OnContextMenuOpen()
	if (IsValid(ix.gui.combine)) then
		ix.gui.combine:SetVisible(true)
	end
end

function Schema:OnContextMenuClose()
	if (IsValid(ix.gui.combine)) then
		ix.gui.combine:SetVisible(false)
	end
end

local color = {}
color["$pp_colour_addr"] = 0
color["$pp_colour_addg"] = 0
color["$pp_colour_addb"] = 0
color["$pp_colour_brightness"] = -0.01
color["$pp_colour_contrast"] = 1.35
color["$pp_colour_colour"] = 0.65
color["$pp_colour_mulr"] = 0
color["$pp_colour_mulg"] = 0
color["$pp_colour_mulb"] = 0

function Schema:RenderScreenspaceEffects()
	DrawColorModify(color)
end

netstream.Hook("cDisp", function(text, color)
	Schema:AddDisplay(text, color)
end)

netstream.Hook("plyData", function(...)
	vgui.Create("nutData"):SetData(...)
end)

netstream.Hook("obj", function(...)
	vgui.Create("nutObjective"):SetData(...)
end)

netstream.Hook("voicePlay", function(sounds, volume, index)
	if (index) then
		local client = Entity(index)

		if (IsValid(client)) then
			ix.util.EmitQueuedSounds(client, sounds, nil, nil, volume)
		end
	else
		ix.util.EmitQueuedSounds(LocalPlayer(), sounds, nil, nil, volume)
	end
end)