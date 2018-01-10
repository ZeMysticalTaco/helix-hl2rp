function Schema:CanPlayerEditData(client, target)
	if (client:IsCombine()) then
		return true
	end

	return false
end