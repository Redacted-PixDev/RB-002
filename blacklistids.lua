-- Server script (ServerScriptService)
local Players = game:GetService("Players")

-- ✅ Put catalog asset IDs you want to block here (as a list)
local blacklisted = {0, 1, 2}

-- Helper: fast lookup
local function isBlacklistedAssetId(id)
	if not id then return false end
	id = tonumber(id)
	for _, blockedId in ipairs(blacklisted) do
		if id == blockedId then
			return true
		end
	end
	return false
end

local function checkDescriptionForBlacklist(desc)
	if not desc then return false end
	local props = {
		desc.HatAccessory,
		desc.HairAccessory,
		desc.FaceAccessory,
		desc.NeckAccessory,
		desc.ShoulderAccessory,
		desc.FrontAccessory,
		desc.BackAccessory,
		desc.WaistAccessory,
	}
	for _, id in ipairs(props) do
		if isBlacklistedAssetId(id) then
			return true
		end
	end
	return false
end

local function checkCharacterAccessories(character)
	if not character then return false end
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle")
			if handle then
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				local meshId = mesh and mesh.MeshId or handle.MeshId
				if meshId then
					local idStr = tostring(meshId):match("%d+")
					if idStr and isBlacklistedAssetId(idStr) then
						return true
					end
				end
			end
		end
	end
	return false
end

local function inspectPlayer(player)
	local function onCharacter(char)
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local success, desc = pcall(function()
				return humanoid:GetAppliedDescription()
			end)
			if success and checkDescriptionForBlacklist(desc) then
				player:Kick("You are wearing a blocked item.")
				return
			end
		end

		if checkCharacterAccessories(char) then
			player:Kick("You are wearing a blocked item.")
		end
	end

	if player.Character then
		onCharacter(player.Character)
	end
	player.CharacterAdded:Connect(onCharacter)
end

Players.PlayerAdded:Connect(inspectPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	inspectPlayer(p)
end
