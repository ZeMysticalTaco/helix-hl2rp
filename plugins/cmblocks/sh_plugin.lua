PLUGIN.name = "Combine Locks"
PLUGIN.author = "Chessnut"
PLUGIN.description = "Adds Combine locks to doors."

if (SERVER) then
	function PLUGIN:SaveData()
		local data = {}

		for k, v in ipairs(ents.FindByClass("nut_cmblock")) do
			if (IsValid(v.door)) then
				data[#data + 1] = {v.door:MapCreationID(), v.door:WorldToLocal(v:GetPos()), v.door:WorldToLocalAngles(v:GetAngles()), v:GetLocked() == true and true or nil}
			end
		end

		self:SetData(data)
	end

	function PLUGIN:LoadData()
		local data = self:GetData() or {}

		for k, v in ipairs(data) do
			local door = ents.GetMapCreatedEntity(v[1])

			if (IsValid(door) and door:IsDoor()) then
				local entity = ents.Create("nut_cmblock")
				entity:SetPos(door:GetPos())
				entity:Spawn()
				entity:SetDoor(door, door:LocalToWorld(v[2]), door:LocalToWorldAngles(v[3]))
				entity:SetLocked(v[4])

				if (v[4]) then
					entity:toggle(true)
				end
			end
		end
	end
end