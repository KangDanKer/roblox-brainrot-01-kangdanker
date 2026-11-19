-- Brainrot Bay: stealing, base locks and the rival thief. A base lock blocks
-- every steal for 60 seconds; a steal carries the brainrot home on a 30-second
-- clock; Sneaky Pete the NPC thief raids unlocked bases and can be tagged.

local State = require(script.Parent.State)
local Catalog = require(script.Parent.Catalog)
local Factory = require(script.Parent.Factory)
local World = require(script.Parent.World)
local Economy = require(script.Parent.Economy)

local Steal = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local function remotes()
	return ReplicatedStorage:WaitForChild("Remotes")
end

-- Lock your base: no one can steal from it for 60 seconds. 3-minute recharge.
function Steal.lockBase(player)
	local data = State.getPlayerData(player)
	if data == nil then
		return
	end
	local now = os.time()
	if now < data.lockCooldownUntil then
		Economy.toast(player, "Lock recharging! " .. (data.lockCooldownUntil - now) .. "s left")
		return
	end
	data.lockUntil = now + State.LOCK_SECONDS
	data.lockCooldownUntil = now + State.LOCK_COOLDOWN
	Steal.updateLockVisual("Player", true)
	Economy.toast(player, "Base LOCKED for 60 seconds! No one can steal!")
end

-- Glow the forcefield while a base is locked, hide it when the lock lapses.
function Steal.updateLockVisual(baseKey, locked)
	local base = World.Bases[baseKey]
	if base == nil then
		return
	end
	base.lockField.Transparency = locked and 0.55 or 1
end

-- A steal starts: lift the brainrot off its owner's slot and carry it home.
-- ownerInfo: { kind = "player", owner = Player, slot = n } or { kind = "rival", rival = record, slot = n }.
function Steal.trySteal(player, ownerInfo)
	local data = State.getPlayerData(player)
	if data == nil or data.carrying ~= nil then
		return
	end
	local now = os.time()
	local entry, model
	if ownerInfo.kind == "player" then
		local ownerData = State.getPlayerData(ownerInfo.owner)
		if ownerData == nil then
			return
		end
		if State.isLocked(ownerData, now) then
			Economy.toast(player, "That base is LOCKED! Wait for the shield to drop.")
			return
		end
		local record = ownerData.brainrots[ownerInfo.slot]
		if record == nil then
			return
		end
		entry = record.entry
		model = record.model
		ownerData.brainrots[ownerInfo.slot] = nil
	else
		local rival = ownerInfo.rival
		if os.time() < rival.lockUntil then
			Economy.toast(player, rival.name .. "'s base is LOCKED! Wait for the shield to drop.")
			return
		end
		local record = rival.brainrots[ownerInfo.slot]
		if record == nil then
			return
		end
		entry = record.entry
		model = record.model
		rival.brainrots[ownerInfo.slot] = nil
	end
	if State.freeSlot(data) == nil then
		Economy.toast(player, "Your base is FULL! Free a slot first.")
		Steal.returnBrainrot(entry, model, ownerInfo)
		return
	end
	for _, prompt in ipairs(model.PrimaryPart:GetChildren()) do
		if prompt:IsA("ProximityPrompt") then
			prompt:Destroy()
		end
	end
	data.carrying = {
		entry = entry,
		model = model,
		fromKind = ownerInfo.kind,
		fromOwner = ownerInfo.owner,
		fromRival = ownerInfo.rival,
		fromSlot = ownerInfo.slot,
		deadline = os.time() + State.STEAL_SECONDS,
	}
	Economy.toast(player, "STOLEN! Run it home to your base in " .. State.STEAL_SECONDS .. "s!")
	task.spawn(function()
		Steal.carryLoop(player)
	end)
end

-- The carried brainrot floats above the thief until home, timeout or death.
function Steal.carryLoop(player)
	local data = State.getPlayerData(player)
	if data == nil then
		return
	end
	while data.carrying ~= nil do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root == nil or humanoid == nil or humanoid.Health <= 0 then
			Steal.dropCarried(player)
			return
		end
		if os.time() > data.carrying.deadline then
			Economy.toast(player, "Too slow! The brainrot ran back home.")
			Steal.dropCarried(player)
			return
		end
		data.carrying.model:PivotTo(root.CFrame * CFrame.new(0, 6.0, 0))
		if World.distanceToBase(World.Bases.Player, root.Position) < 14 then
			local carried = data.carrying
			data.carrying = nil
			Economy.placeBrainrotOnBase(player, carried.entry, carried.model, false)
			Economy.toast(player, "STOLE " .. carried.entry.name .. "! It earns for YOU now.")
			return
		end
		RunService.Heartbeat:Wait()
	end
end

-- Drop what is carried and send the brainrot back to its old slot.
function Steal.dropCarried(player)
	local data = State.getPlayerData(player)
	if data == nil or data.carrying == nil then
		return
	end
	local carried = data.carrying
	data.carrying = nil
	Steal.returnBrainrot(carried.entry, carried.model, {
		kind = carried.fromKind,
		owner = carried.fromOwner,
		rival = carried.fromRival,
		slot = carried.fromSlot,
	})
end

function Steal.returnBrainrot(entry, model, ownerInfo)
	if ownerInfo.kind == "player" then
		local ownerData = ownerInfo.owner and State.getPlayerData(ownerInfo.owner)
		if ownerData ~= nil then
			ownerData.brainrots[ownerInfo.slot] = { entry = entry, model = model, golden = false }
			model:PivotTo(World.Bases.Player.slots[ownerInfo.slot])
			Economy.attachOwnedPrompts(ownerInfo.owner, ownerData, ownerInfo.slot)
			return
		end
	else
		local rival = ownerInfo.rival
		if rival ~= nil then
			rival.brainrots[ownerInfo.slot] = { entry = entry, model = model, golden = false }
			model:PivotTo(World.Bases[rival.baseKey].slots[ownerInfo.slot])
			Steal.attachRivalPrompt(rival, ownerInfo.slot)
			return
		end
	end
	model:Destroy()
end

function Steal.attachRivalPrompt(rival, slot)
	local record = rival.brainrots[slot]
	if record == nil then
		return
	end
	local prompt = Factory.attachPrompt(record.model, record.entry.name, "STEAL!")
	prompt.Triggered:Connect(function(player)
		Steal.trySteal(player, { kind = "rival", rival = rival, slot = slot })
	end)
end

-- Two rival NPC bases with a few brainrots each and locks that cycle on and off,
-- so there is always someone to steal from — and someone whose shield is up.
-- Rivals sit on slots 1, 4 and 6 (spread across the base): on slots 1, 2, 3
-- they stood 6 studs apart and their labels overlapped into one blob.
-- rival.brainrots is keyed by SLOT number (that is what trySteal,
-- returnBrainrot and attachRivalPrompt all look up), not by loop index.
function Steal.setupRivals()
	local defs = {
		{ baseKey = "Rival1", name = "Sir Quacksalot", entries = { "discopickle", "bananaphone", "couchpotato" }, slots = { 1, 4, 6 } },
		{ baseKey = "Rival2", name = "Madame Zucchini", entries = { "grannyslipper", "quantumburrito", "tproll" }, slots = { 1, 4, 6 } },
	}
	for _, def in ipairs(defs) do
		local rival = { name = def.name, baseKey = def.baseKey, brainrots = {}, lockUntil = 0 }
		for i, id in ipairs(def.entries) do
			local slot = def.slots[i]
			local entry = Catalog.byId(id)
			local model = Factory.buildBrainrotModel(entry, false)
			model:PivotTo(World.Bases[def.baseKey].slots[slot])
			model.Parent = Workspace.BrainrotBay
			rival.brainrots[slot] = { entry = entry, model = model, golden = false }
			Steal.attachRivalPrompt(rival, slot)
		end
		table.insert(State.Rivals, rival)
	end
	task.spawn(function()
		while true do
			for _, rival in ipairs(State.Rivals) do
				local locked = os.time() < rival.lockUntil
				Steal.updateLockVisual(rival.baseKey, locked)
			end
			task.wait(2)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(45)
			for _, rival in ipairs(State.Rivals) do
				rival.lockUntil = os.time() + 40
			end
			task.wait(45)
			for _, rival in ipairs(State.Rivals) do
				rival.lockUntil = 0
			end
		end
	end)
end

-- Sneaky Pete: an NPC thief who raids the richest unlocked base. Touch him
-- while he carries your brainrot and he drops it; a lock makes him bounce.
function Steal.spawnThief()
	local target = nil
	local best = 0
	for player, data in pairs(State.Players) do
		local value = State.bestIncome(data)
		if value > best and data.carrying == nil then
			local recordCount = 0
			for _ in pairs(data.brainrots) do
				recordCount += 1
			end
			if recordCount > 0 then
				target = player
				best = value
			end
		end
	end
	if target == nil then
		return
	end
	local data = State.getPlayerData(target)
	if State.isLocked(data, os.time()) then
		remotes().ThiefAlert:FireAllClients("Sneaky Pete bounced off a LOCKED base!")
		return
	end
	local thief = Instance.new("Model")
	thief.Name = "SneakyPete"
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = Vector3.new(-50, 1, -50)
	torso.Color = Color3.fromRGB(40, 40, 50)
	torso.Anchored = true
	torso.CanCollide = false
	torso.Parent = thief
	thief.PrimaryPart = torso
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.4, 1.4, 1.4)
	head.Position = Vector3.new(-50, 2.8, -50)
	head.Color = Color3.fromRGB(255, 210, 150)
	head.Anchored = true
	head.CanCollide = false
	head.Parent = thief
	local mask = Instance.new("Part")
	mask.Name = "Mask"
	mask.Size = Vector3.new(1.5, 0.5, 0.3)
	mask.Position = Vector3.new(-50, 2.9, -49.2)
	mask.Color = Color3.fromRGB(20, 20, 20)
	mask.Anchored = true
	mask.CanCollide = false
	mask.Parent = thief
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 180, 0, 36)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = thief
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.25
	label.TextColor3 = Color3.fromRGB(255, 120, 120)
	label.Text = "SNEAKY PETE"
	label.TextSize = 20
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard
	thief.Parent = Workspace.BrainrotBay
	remotes().ThiefAlert:FireAllClients("Sneaky Pete is sneaking to a base! Tag him to stop him!")

	local Conveyor = require(script.Parent.Conveyor)
	local base = World.Bases.Player
	local dropped = false
	torso.Touched:Connect(function(hit)
		local character = hit.Parent
		local touchedPlayer = Players:GetPlayerFromCharacter(character)
		if touchedPlayer ~= nil and not dropped then
			dropped = true
		end
	end)
	Conveyor.moveModelTo(thief, CFrame.new(base.center + Vector3.new(0, 2, 0)), 6)
	if dropped then
		remotes().ThiefAlert:FireAllClients("You tagged Sneaky Pete! He dropped nothing and ran off.")
		thief:Destroy()
		return
	end
	if State.isLocked(data, os.time()) then
		remotes().ThiefAlert:FireAllClients("Sneaky Pete bounced off your LOCK!")
		thief:Destroy()
		return
	end
	local bestSlot, bestEntry = nil, nil
	for slot, record in pairs(data.brainrots) do
		if bestEntry == nil or record.entry.income > bestEntry.income then
			bestSlot = slot
			bestEntry = record.entry
		end
	end
	if bestSlot == nil then
		thief:Destroy()
		return
	end
	local stolen = data.brainrots[bestSlot]
	data.brainrots[bestSlot] = nil
	remotes().ThiefAlert:FireAllClients("Sneaky Pete stole " .. bestEntry.name .. "! TAG HIM to make him drop it!")
	local carryUntil = os.time() + 25
	while os.time() < carryUntil and not dropped do
		-- Carried model floats above the thief's head: 6.0 clears the head
		-- top for the 2.0x-scaled model (feet 2.4 below its pivot).
		stolen.model:PivotTo(thief:GetPivot() * CFrame.new(0, 6.0, 0))
		thief:PivotTo(thief:GetPivot() * CFrame.new(-0.12, 0, -0.12))
		RunService.Heartbeat:Wait()
	end
	if dropped then
		Economy.placeBrainrotOnBase(target, bestEntry, stolen.model, false)
		remotes().ThiefAlert:FireAllClients("You tagged Sneaky Pete! " .. bestEntry.name .. " is safe.")
	else
		local rival = State.Rivals[1]
		local slot = 8 -- empty: rivals sit on slots 1, 4, 6
		rival.brainrots[slot] = { entry = bestEntry, model = stolen.model, golden = false }
		stolen.model:PivotTo(World.Bases[rival.baseKey].slots[slot])
		Steal.attachRivalPrompt(rival, slot)
		remotes().ThiefAlert:FireAllClients("Sneaky Pete got away with " .. bestEntry.name .. "! Steal it back!")
	end
	thief:Destroy()
end

function Steal.startThiefLoop()
	task.spawn(function()
		task.wait(100)
		while true do
			Steal.spawnThief()
			task.wait(100)
		end
	end)
end

return Steal
