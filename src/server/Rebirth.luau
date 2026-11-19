-- Brainrot Bay: rebirths and upgrades. A rebirth wipes your cash and your
-- base for a permanent money multiplier and two more slots; upgrades buy
-- extra slots, income percent and walk speed with cash.

local State = require(script.Parent.State)
local Economy = require(script.Parent.Economy)

local Rebirth = {}

Rebirth.BASE_COST = 25000
Rebirth.SLOT_COST = 10000
Rebirth.INCOME_COST = 5000
Rebirth.SPEED_COST = 2500

function Rebirth.rebirthCost(data)
	return Rebirth.BASE_COST * (data.rebirths + 1)
end

function Rebirth.canRebirth(data)
	return data.cash >= Rebirth.rebirthCost(data) and State.bestIncome(data) >= 50
end

-- Reset everything for a permanent x0.5 more money and two more base slots.
function Rebirth.doRebirth(player)
	local data = State.getPlayerData(player)
	if data == nil then
		return
	end
	if not Rebirth.canRebirth(data) then
		Economy.toast(player, "Rebirth needs " .. State.formatMoney(Rebirth.rebirthCost(data)) .. " and a $50/s brainrot!")
		return
	end
	for _, record in pairs(data.brainrots) do
		record.model:Destroy()
	end
	data.brainrots = {}
	data.cash = 0
	data.rebirths += 1
	data.multiplier = 1 + data.rebirths * 0.5
	data.slots = math.min(State.MAX_SLOTS, data.slots + 2)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rebirthValue = leaderstats:FindFirstChild("Rebirths")
		if rebirthValue then
			rebirthValue.Value = data.rebirths
		end
	end
	Economy.toast(player, "REBIRTH #" .. data.rebirths .. "! Money x" .. data.multiplier .. " forever, +" .. 2 .. " slots!")
end

-- One-off cash upgrades: slot, income percent, walk speed.
function Rebirth.buyUpgrade(player, upgradeId)
	local data = State.getPlayerData(player)
	if data == nil then
		return
	end
	if upgradeId == "slot" then
		if data.slots >= State.MAX_SLOTS then
			Economy.toast(player, "Base already at max slots!")
			return
		end
		if data.cash < Rebirth.SLOT_COST then
			Economy.toast(player, "Need " .. State.formatMoney(Rebirth.SLOT_COST) .. " for +1 slot!")
			return
		end
		data.cash -= Rebirth.SLOT_COST
		data.slots += 1
		Economy.toast(player, "+1 base slot! You now have " .. data.slots .. " slots.")
	elseif upgradeId == "income" then
		if data.incomeBonus >= 100 then
			Economy.toast(player, "Income bonus maxed at +100%!")
			return
		end
		if data.cash < Rebirth.INCOME_COST then
			Economy.toast(player, "Need " .. State.formatMoney(Rebirth.INCOME_COST) .. " for +10% income!")
			return
		end
		data.cash -= Rebirth.INCOME_COST
		data.incomeBonus += 10
		Economy.toast(player, "Income +10%! Total bonus +" .. data.incomeBonus .. "%.")
	elseif upgradeId == "speed" then
		if data.speedLevel >= 4 then
			Economy.toast(player, "Speed maxed!")
			return
		end
		if data.cash < Rebirth.SPEED_COST then
			Economy.toast(player, "Need " .. State.formatMoney(Rebirth.SPEED_COST) .. " for +speed!")
			return
		end
		data.cash -= Rebirth.SPEED_COST
		data.speedLevel += 1
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16 + data.speedLevel * 4
		end
		Economy.toast(player, "Faster! Walk speed +" .. data.speedLevel * 4 .. ".")
	end
end

return Rebirth
