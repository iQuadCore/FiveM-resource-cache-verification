hashValidatedUsers = {}

local function RemovePlayerFromHashCheck(username,identifier)
	for i,user in pairs(hashValidatedUsers) do
		if user.identifier == identifier then
			table.remove(hashValidatedUsers,i)
		end
	end
end

Citizen.CreateThread(function()
	AddEventHandler('playerDropped', function(reason)
		RemovePlayerFromHashCheck(GetPlayerName(source),GetPlayerIdentifier(source,1))
	end)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10000)
		for i,user in pairs(hashValidatedUsers) do 
			if user.verified == false then 
				if user.waitTime > 32 then
					for i,player in ipairs(GetPlayers()) do 
						if GetPlayerIdentifier(source,1) == user.identifier then
							RemovePlayerFromHashCheck(GetPlayerName(player),GetPlayerIdentifier(source,1))
							DropPlayer(player, "Hash Validation Timeout")
						end
					end
				else
					hashValidatedUsers[i].waitTime = hashValidatedUsers[i].waitTime+1
				end
			end
		end
	end

end)

Citizen.CreateThread(function()
	AddEventHandler('playerConnecting', function(playerName)
		table.insert(hashValidatedUsers, { identifier = GetPlayerIdentifier(source,1), joining = true, waitTime = 0, verified = false, hashes = FilesHashesToVerify })
	end)
end) 


local verifiedhashes = {}
Citizen.CreateThread(function()
	Wait(500)
	for i,a in pairs(FilesHashesToVerify) do
		local f = LoadResourceFile(a.resource, a.file)
		local hash = sha1(f)
		table.insert(verifiedhashes, {resource = a.resource, file = a.file, hash = hash})
	end
end)

Citizen.CreateThread(function()
	RegisterServerEvent("VerifyFileHash")
	AddEventHandler("VerifyFileHash", function(hashes)
		for uid,User in ipairs(hashValidatedUsers) do
			if User.identifier == GetPlayerIdentifier(source,1) then
				for i,a in ipairs(verifiedhashes) do
					if a.hash == hashes[i].hash then
						hashValidatedUsers[uid].hashes[i].v = true
						if i == #verifiedhashes then
							hashValidatedUsers[uid].verified = true
						end
					else
						RemovePlayerFromHashCheck(GetPlayerName(source))
						DropPlayer(source, "Hash Validation Failed")
					end
				end
			end
		end
	end)
