local hashtable = {}
Citizen.CreateThread(function() -- hash generation thread
	Wait(5000)
	for i,a in ipairs(FilesHashesToVerify) do
		local hash = crc32(LoadResourceFile(a.resource, a.file))
		table.insert(hashtable, {resource = a.resource,file = a.file, hash = hash})
		if i == #FilesHashesToVerify then
			TriggerServerEvent("VerifyFileHash", hashtable)
		end
		Wait(500)
	end
end)
