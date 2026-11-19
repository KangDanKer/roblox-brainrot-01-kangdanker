-- Brainrot Bay: the belt. Brainrots spawn at the west gate, walk east along
-- the conveyor, and despawn at the far end. A golden one sometimes appears
-- with triple income. Buying happens on the belt's own prompt.

local State = require(script.Parent.State)
local Catalog = require(script.Parent.Catalog)
local Factory = require(script.Parent.Factory)

local Conveyor = {}

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

Conveyor.Belt = {} -- list of { entry, model, speed, golden }
-- One spawn every 5s at 4 studs/s = 20 studs apart, max 6 on the belt:
-- at 4s/8 the models bunched up and their labels overlapped into one row.
Conveyor.SPAWN_INTERVAL = 5
Conveyor.MAX_ON_BELT = 6
-- Body centre height: belt top (1.1) plus the scaled body half-height (2.4
-- at 2.0x), so the scaled models stand ON the belt instead of sinking into it.
Conveyor.BELT_Y = 3.5
Conveyor.START_X = -54
Conveyor.END_X = 54
Conveyor.SPEED = 4

function Conveyor.removeFromBelt(record)
	for i, item in ipairs(Conveyor.Belt) do
		if item == record then
			table.remove(Conveyor.Belt, i)
			return
		end
	end
end

local function spawnBrainrot()
	if #Conveyor.Belt >= Conveyor.MAX_ON_BELT then
		return
	end
	local golden = math.random(100) <= 5
	local entry = Catalog.randomEntry()
	local model = Factory.buildBrainrotModel(entry, golden)
	model:PivotTo(CFrame.new(Conveyor.START_X, Conveyor.BELT_Y, 0))
	model.Parent = Workspace.BrainrotBay
	local record = { entry = entry, model = model, speed = Conveyor.SPEED, golden = golden }
	table.insert(Conveyor.Belt, record)
	local prompt = Factory.attachPrompt(model, entry.name, "BUY " .. State.formatMoney(entry.cost))
	prompt.Triggered:Connect(function(player)
		local Economy = require(script.Parent.Economy)
		Economy.buyBrainrot(player, record)
	end)
end

-- Lerp a whole model to a target CFrame over a duration (used for the walk home).
function Conveyor.moveModelTo(model, target, duration)
	local start = model:GetPivot()
	local elapsed = 0
	while elapsed < duration do
		local dt = RunService.Heartbeat:Wait()
		elapsed += dt
		local t = math.min(1, elapsed / duration)
		local smooth = t * t * (3 - 2 * t)
		model:PivotTo(start:Lerp(target, smooth))
	end
	model:PivotTo(target)
end

function Conveyor.start()
	task.spawn(function()
		while true do
			task.wait(Conveyor.SPAWN_INTERVAL)
			spawnBrainrot()
		end
	end)
	RunService.Heartbeat:Connect(function(dt)
		for i = #Conveyor.Belt, 1, -1 do
			local record = Conveyor.Belt[i]
			local model = record.model
			if model.Parent == nil then
				table.remove(Conveyor.Belt, i)
			else
				local pivot = model:GetPivot()
				model:PivotTo(pivot * CFrame.new(record.speed * dt, 0, 0))
				if pivot.Position.X > Conveyor.END_X then
					model:Destroy()
					table.remove(Conveyor.Belt, i)
				end
			end
		end
	end)
end

return Conveyor
