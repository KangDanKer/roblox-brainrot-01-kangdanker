-- Brainrot Bay: the single source of truth for all game state.
-- Every module reads and writes player, rival, tsunami and event state here,
-- so there is exactly one place where a number can disagree with another.

local State = {}

State.Players = {} -- [Player] = playerData
State.Rivals = {} -- list of rival NPC base records
State.Tsunami = { active = false, warning = false, nextAt = 0 }
State.DoubleMoney = { active = false, endsAt = 0 }

State.START_CASH = 100
State.START_SLOTS = 4
State.MAX_SLOTS = 12
State.LOCK_SECONDS = 60
State.LOCK_COOLDOWN = 180
State.STEAL_SECONDS = 30

function State.newPlayerData()
	return {
		cash = State.START_CASH,
		rebirths = 0,
		multiplier = 1,
		slots = State.START_SLOTS,
		brainrots = {}, -- [slot] = { entry = catalogEntry, model = Model }
		lockUntil = 0,
		lockCooldownUntil = 0,
		carrying = nil, -- { entry, model, fromKind, fromOwner, fromSlot, deadline }
		speedLevel = 0,
		incomeBonus = 0, -- extra percent from upgrades
		totalEarned = 0,
	}
end

function State.getPlayerData(player)
	return State.Players[player]
end

-- Money per second from every brainrot on the base, after multipliers.
function State.totalIncome(data)
	local sum = 0
	for _, record in pairs(data.brainrots) do
		sum += record.entry.income
	end
	local mult = data.multiplier * (1 + data.incomeBonus / 100)
	if State.DoubleMoney.active then
		mult *= 2
	end
	return math.floor(sum * mult)
end

function State.bestIncome(data)
	local best = 0
	for _, record in pairs(data.brainrots) do
		best = math.max(best, record.entry.income)
	end
	return best
end

function State.freeSlot(data)
	for i = 1, data.slots do
		if data.brainrots[i] == nil then
			return i
		end
	end
	return nil
end

function State.isLocked(data, now)
	return now < data.lockUntil
end

function State.lockSecondsLeft(data, now)
	return math.max(0, math.floor(data.lockUntil - now))
end

function State.formatMoney(n)
	local s = tostring(math.floor(n))
	local out = ""
	while #s > 3 do
		out = "," .. s:sub(-3) .. out
		s = s:sub(1, -4)
	end
	return "$" .. s .. out
end

return State
