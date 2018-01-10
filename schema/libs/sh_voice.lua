ix.voice = {}
ix.voice.list = {}
ix.voice.checks = ix.voice.checks or {}
ix.voice.chatTypes = {}

function ix.voice.defineClass(class, onCheck, onModify, global)
	ix.voice.checks[class] = {class = class:lower(), onCheck = onCheck, onModify = onModify, isGlobal = global}
end

function ix.voice.GetClass(client)
	local definitions = {}

	for k, v in pairs(ix.voice.checks) do
		if (v.OnCheck(client)) then
			definitions[#definitions + 1] = v
		end
	end

	return definitions
end

function ix.voice.register(class, key, replacement, source, max)
	class = class:lower()
	
	ix.voice.list[class] = ix.voice.list[class] or {}
	ix.voice.list[class][key:lower()] = {replacement = replacement, source = source}
end

function ix.voice.GetVoiceList(class, text, delay)
	local info = ix.voice.list[class]

	if (!info) then
		return
	end

	local output = {}
	local original = string.Explode(" ", text)
	local exploded = string.Explode(" ", text:lower())
	local phrase = ""
	local skip = 0
	local current = 0

	max = max or 5

	for k, v in ipairs(exploded) do
		if (k < skip) then
			continue
		end

		if (current < max) then
			local i = k
			local key = v

			local nextValue, nextKey

			while (true) do
				i = i + 1
				nextValue = exploded[i]

				if (!nextValue) then
					break
				end

				nextKey = key.." "..nextValue

				if (!info[nextKey]) then
					i = i + 1

					local nextValue2 = exploded[i]
					local nextKey2 = nextKey.." "..(nextValue2 or "")

					if (!nextValue2 or !info[nextKey2]) then
						i = i - 1

						break
					end

					nextKey = nextKey2
				end

				key = nextKey
			end

			if (info[key]) then
				local source = info[key].source
				
				if (type(source) == "table") then
					source = table.Random(source)
				else
					source = tostring(source)
				end
				
				output[#output + 1] = {source, delay or 0.1}
				phrase = phrase..info[key].replacement.." "
				skip = i
				current = current + 1

				continue
			end
		end

		phrase = phrase..original[k].." "
	end
	
	if (phrase:sub(#phrase, #phrase) == " ") then
		phrase = phrase:sub(1, -2)
	end

	return #output > 0 and output or nil, phrase
end
