-- Brainrot Bay: the server entry. Builds the island first, then wires every
-- system and starts the loops: income, the belt, the tsunami, the thief and
-- the double-money event. One state module holds every number (see State).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents first, so every module can find them at require time.
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage
for _, name in ipairs({ "UpdateHud", "TsunamiWarning", "TsunamiOver", "ThiefAlert", "Toast", "LockBase", "Rebirth", "BuyUpgrade" }) do
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
end

-- Rojo turns this init file into the Script itself (named "Server"), with the
-- other modules as its children — so requires here are script.X, NOT
-- script.Parent.X (script.Parent is ServerScriptService). The modules keep
-- script.Parent.X: their parent IS this Script.
local State = require(script.State)
local World = require(script.World)
local Economy = require(script.Economy)
local Conveyor = require(script.Conveyor)
local Steal = require(script.Steal)
local Tsunami = require(script.Tsunami)
local Rebirth = require(script.Rebirth)

-- The island must exist before any character spawns on it.
World.buildWorld()
-- Diagnostic: prove the island exists at runtime. (Rev 5 showed blue studs
-- instead of green grass in Studio — this line settles whether Grass exists.)
local bay = game:GetService("Workspace"):FindFirstChild("BrainrotBay")
local grass = bay and bay:FindFirstChild("Grass")
print("BrainrotBay parts:", bay and #bay:GetChildren() or 0, "| Grass:", grass and ("at " .. tostring(grass.Position) .. " size " .. tostring(grass.Size)) or "MISSING")
Steal.setupRivals()

local function onCharacterAdded(player, character)
	local data = State.getPlayerData(player)
	local humanoid = character:WaitForChild("Humanoid")
	if data ~= nil then
		humanoid.WalkSpeed = 16 + data.speedLevel * 4
	end
	humanoid.Died:Connect(function()
		Steal.dropCarried(player)
	end)
end

local function onPlayerAdded(player)
	local data = State.newPlayerData()
	State.Players[player] = data
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = data.cash
	cash.Parent = leaderstats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

local function onPlayerRemoving(player)
	local data = State.getPlayerData(player)
	if data ~= nil then
		for _, record in pairs(data.brainrots) do
			record.model:Destroy()
		end
		if data.carrying ~= nil then
			Steal.dropCarried(player)
		end
		State.Players[player] = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Client buttons: lock, rebirth and the three upgrades.
remotes.LockBase.OnServerEvent:Connect(function(player)
	Steal.lockBase(player)
end)
remotes.Rebirth.OnServerEvent:Connect(function(player)
	Rebirth.doRebirth(player)
end)
remotes.BuyUpgrade.OnServerEvent:Connect(function(player, upgradeId)
	Rebirth.buyUpgrade(player, upgradeId)
end)

-- The loops: money ticks, the belt walks, the tsunami and the thief.
task.spawn(Economy.tickLoop)
Conveyor.start()
Tsunami.start()
Steal.startThiefLoop()

-- Double-money event: 30 seconds of double income every four minutes.
task.spawn(function()
	while true do
		task.wait(240)
		State.DoubleMoney.active = true
		State.DoubleMoney.endsAt = os.time() + 30
		remotes.Toast:FireAllClients("DOUBLE MONEY EVENT! 2x income for 30 seconds!")
		task.wait(30)
		State.DoubleMoney.active = false
	end
end)

print("Brainrot Bay server ready: world built, belt running, tsunami armed.")
