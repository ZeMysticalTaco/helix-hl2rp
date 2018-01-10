PLUGIN.name = "Flashlight"
PLUGIN.author = "Chessnut"
PLUGIN.description = "Provides a flashlight item to regular flashlight usage."

function PLUGIN:PlayerSwitchFlashlight(client, state)
	local character = client:GetChar()

	if (!character or !character:GetInv()) then
		return false
	end

	if (character:GetInv():HasItem("flashlight")) then
		return true
	end
end