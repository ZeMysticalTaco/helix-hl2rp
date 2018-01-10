local PLUGIN = PLUGIN

if (SERVER) then
	function PLUGIN:searchPlayer(client, target)
		if (IsValid(target:GetNetVar("searcher")) or IsValid(client.nutSearchTarget)) then
			return false
		end

		if (!target:GetChar() or !target:GetChar():GetInv()) then
			return false
		end

		local inventory = target:GetChar():GetInv()

		-- Permit the player to move items from their inventory to the target's inventory.
		inventory.oldOnAuthorizeTransfer = inventory.OnAuthorizeTransfer
		inventory.OnAuthorizeTransfer = function(inventory, client2, oldInventory, item)
			if (IsValid(client2) and client2 == client) then
				return true
			end

			return false
		end
		inventory:sync(client)
		inventory.oldGetReceiver = inventory.GetReceiver
		inventory.GetReceiver = function(inventory)
			return {client, target}
		end
		inventory.OnCheckAccess = function(inventory, client2)
			if (client2 == client) then
				return true
			end
		end

		-- Permit the player to move items from the target's inventory back into their inventory.
		local inventory2 = client:GetChar():GetInv()
		inventory2.oldOnAuthorizeTransfer = inventory2.OnAuthorizeTransfer
		inventory2.OnAuthorizeTransfer = function(inventory3, client2, oldInventory, item)
			if (oldInventory == inventory) then
				return true
			end

			return inventory2.oldOnAuthorizeTransfer(inventory3, client2, oldInventory, item)
		end

		-- Show the inventory menu to the searcher.
		netstream.Start(client, "searchPly", target, target:GetChar():GetInv():getID())

		client.nutSearchTarget = target
		target:SetNetVar("searcher", client)

		return true
	end

	function PLUGIN:CanPlayerInteractItem(client, action, item)
		if (IsValid(client:GetNetVar("searcher"))) then
			return false
		end
	end

	netstream.Hook("searchExit", function(client)
		local target = client.nutSearchTarget

		if (IsValid(target) and target:GetNetVar("searcher") == client) then
			local inventory = target:GetChar():GetInv()
			inventory.OnAuthorizeTransfer = inventory.oldOnAuthorizeTransfer
			inventory.oldOnAuthorizeTransfer = nil
			inventory.GetReceiver = inventory.oldGetReceiver
			inventory.oldGetReceiver = nil
			inventory.OnCheckAccess = nil
				
			local inventory2 = client:GetChar():GetInv()
			inventory2.OnAuthorizeTransfer = inventory2.oldOnAuthorizeTransfer
			inventory2.oldOnAuthorizeTransfer = nil

			target:SetNetVar("searcher", nil)
			client.nutSearchTarget = nil
		end
	end)
else
	function PLUGIN:CanPlayerViewInventory()
		if (IsValid(LocalPlayer():GetNetVar("searcher"))) then
			return false
		end
	end

	netstream.Hook("searchPly", function(target, index)
		local inventory = ix.item.inventories[index]

		if (!inventory) then
			return netstream.Start("searchExit")
		end

		ix.gui.inv1 = vgui.Create("nutInventory")
		ix.gui.inv1:ShowCloseButton(true)
		ix.gui.inv1:SetInventory(LocalPlayer():GetChar():GetInv())

		local panel = vgui.Create("nutInventory")
		panel:ShowCloseButton(true)
		panel:SetTitle(target:Name())
		panel:SetInventory(inventory)
		panel:MoveLeftOf(ix.gui.inv1, 4)
		panel.OnClose = function(this)
			if (IsValid(ix.gui.inv1) and !IsValid(ix.gui.menu)) then
				ix.gui.inv1:Remove()
			end

			netstream.Start("searchExit")
		end

		local oldClose = ix.gui.inv1.OnClose
		ix.gui.inv1.OnClose = function()
			if (IsValid(panel) and !IsValid(ix.gui.menu)) then
				panel:Remove()
			end

			netstream.Start("searchExit")
			ix.gui.inv1.OnClose = oldClose
		end

		ix.gui["inv"..index] = panel	
	end)
end

ix.command.Add("charsearch", {
	OnRun = function(client, arguments)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer() and target:GetNetVar("restricted")) then
			PLUGIN:searchPlayer(client, target)
		end
	end
})