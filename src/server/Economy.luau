-- Brainrot Bay: money. Buying brainrots off the belt, selling them back,
-- the one-second income tick and the next-tier chase the HUD shows.

local State = require(script.Parent.State)
local Catalog = require(script.Parent.Catalog)
local Factory = require(script.Parent.Factory)
local World = require(script.Parent.World)

local Economy = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function remotes()
	return ReplicatedStorage:WaitForChild("Remotes")
end

function Economy.toast(player, message)
	remotes().Toast:FireClient(player, message)
end

-- The cheapest entry richer than the player's best brainrot: the next tier.
function Economy.nextTier(data)
	return Catalog.nextTier(State.bestIncome(data))
end

-- Put a brainrot model on the player's first free slot and register it.
-- Returns the slot index, or nil when the base is full.
function Economy.placeBrainrotOnBase(player, entry, model, golden)
	local data = State.getPlayerData(player)
	if data == nil then
		return nil
	end
	local slot = State.freeSlot(data)
	if slot == nil then
		return nil
	end
	local built = model or Factory.buildBrainrotModel(entry, golden)
	local slotCFrame = World.Bases.Player.slots[slot]
	built:PivotTo(slotCFrame)
	built.Parent = game:GetService("Workspace").BrainrotBay
	data.brainrots[slot] = { entry = entry, model = built, golden = golden or false }
	Economy.attachOwnedPrompts(player, data, slot)
	return slot
end

-- Sell prompt for the owner, steal prompt for everyone else.
function Economy.attachOwnedPrompts(player, data, slot)
	local record = data.brainrots[slot]
	if record == nil then
		return
	end
	local model = record.model
	local sell = Factory.attachPrompt(model, record.entry.name, "Sell " .. State.formatMoney(math.floor(record.entry.cost / 2)))
	sell.Triggered:Connect(function(triggerPlayer)
		if triggerPlayer == player then
			Economy.sellBrainrot(triggerPlayer, slot)
		end
	end)
	local Steal = require(script.Parent.Steal)
	local steal = Factory.attachPrompt(model, record.entry.name, "STEAL!")
	steal.Triggered:Connect(function(triggerPlayer)
		if triggerPlayer ~= player then
			Steal.trySteal(triggerPlayer, { kind = "player", owner = player, slot = slot })
		end
	end)
end

-- Buy a brainrot off the belt: pay, walk it to the base, start its income.
function Economy.buyBrainrot(player, beltRecord)
	local data = State.getPlayerData(player)
	if data == nil then
		return false
	end
	if data.cash < beltRecord.entry.cost then
		Economy.toast(player, "Not enough cash! Need " .. State.formatMoney(beltRecord.entry.cost))
		return false
	end
	if State.freeSlot(data) == nil then
		Economy.toast(player, "Base is FULL! Buy a +SLOT upgrade or rebirth!")
		return false
	end
	data.cash -= beltRecord.entry.cost
	local Conveyor = require(script.Parent.Conveyor)
	Conveyor.removeFromBelt(beltRecord)
	local model = beltRecord.model
	local prompt = model.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt:Destroy()
	end
	-- Walk it home to the base so the buy reads on screen, then register it.
	local slotIndex = State.freeSlot(data)
	if slotIndex ~= nil then
		Conveyor.moveModelTo(model, World.Bases.Player.slots[slotIndex], 1.5)
	end
	local slot = Economy.placeBrainrotOnBase(player, beltRecord.entry, model, beltRecord.golden)
	if slot == nil then
		data.cash += beltRecord.entry.cost
		return false
	end
	Economy.toast(player, "Bought " .. beltRecord.entry.name .. " for " .. State.formatMoney(beltRecord.entry.cost) .. "!")
	return true
end

-- Sell a brainrot back for half its price and free the slot.
function Economy.sellBrainrot(player, slot)
	local data = State.getPlayerData(player)
	if data == nil then
		return
	end
	local record = data.brainrots[slot]
	if record == nil then
		return
	end
	local refund = math.floor(record.entry.cost / 2)
	data.cash += refund
	record.model:Destroy()
	data.brainrots[slot] = nil
	Economy.toast(player, "Sold " .. record.entry.name .. " for " .. State.formatMoney(refund))
end

-- One-second income tick for every player, then a HUD refresh each.
function Economy.tickLoop()
	while true do
		task.wait(1)
		for player, data in pairs(State.Players) do
			local income = State.totalIncome(data)
			if income > 0 then
				data.cash += income
				data.totalEarned += income
			end
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local cashValue = leaderstats:FindFirstChild("Cash")
				if cashValue then
					cashValue.Value = math.floor(data.cash)
				end
			end
			local next = Economy.nextTier(data)
			remotes().UpdateHud:FireClient(player, {
				cash = math.floor(data.cash),
				income = income,
				nextName = next.name,
				nextCost = next.cost,
				nextIncome = next.income,
				nextRarity = next.rarity,
				lockLeft = State.lockSecondsLeft(data, os.time()),
				rebirths = data.rebirths,
				multiplier = data.multiplier,
				slots = data.slots,
				usedSlots = Economy.usedSlots(data),
				doubleMoney = State.DoubleMoney.active,
			})
		end
	end
end

-- Count how many slots a player has filled (for the HUD's base line).
function Economy.usedSlots(data)
	local n = 0
	for _ in pairs(data.brainrots) do
		n += 1
	end
	return n
end

return Economy
