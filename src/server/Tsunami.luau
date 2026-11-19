-- Brainrot Bay: the tsunami. Every couple of minutes a warning banner counts
-- down, then a giant wave sweeps the map from the bay. Inside your own base
-- you are safe; caught outside, the wave flings you and drops what you carry.

local State = require(script.Parent.State)
local World = require(script.Parent.World)

local Tsunami = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

Tsunami.FIRST_IN = 90
Tsunami.EVERY = 150
Tsunami.WARNING_SECONDS = 10
Tsunami.SAFE_RADIUS = 22

local function remotes()
	return ReplicatedStorage:WaitForChild("Remotes")
end

local function playerInSafeZone(player)
	local data = State.getPlayerData(player)
	if data == nil then
		return false
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return false
	end
	return World.distanceToBase(World.Bases.Player, root.Position) < Tsunami.SAFE_RADIUS
end

-- The wave itself: a huge translucent wall that crosses the map from the bay.
function Tsunami.sweepWave()
	State.Tsunami.active = true
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(160, 26, 8)
	wave.Position = Vector3.new(0, 10, -85)
	wave.Color = Color3.fromRGB(40, 140, 255)
	wave.Material = Enum.Material.Glass
	wave.Transparency = 0.3
	wave.Anchored = true
	wave.CanCollide = false
	wave.Parent = Workspace.BrainrotBay
	local foam = Instance.new("Part")
	foam.Name = "WaveFoam"
	foam.Size = Vector3.new(160, 3, 9)
	foam.Position = Vector3.new(0, 24, -85)
	foam.Color = Color3.fromRGB(255, 255, 255)
	foam.Material = Enum.Material.Neon
	foam.Transparency = 0.4
	foam.Anchored = true
	foam.CanCollide = false
	foam.Parent = Workspace.BrainrotBay

	local startZ = -85
	local endZ = 85
	local duration = 9
	local elapsed = 0
	while elapsed < duration do
		local dt = RunService.Heartbeat:Wait()
		elapsed += dt
		local t = math.min(1, elapsed / duration)
		local z = startZ + (endZ - startZ) * t
		wave.Position = Vector3.new(0, 10, z)
		foam.Position = Vector3.new(0, 24, z)
		for player in pairs(State.Players) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root ~= nil and math.abs(root.Position.Z - z) < 5 and not playerInSafeZone(player) then
				root.AssemblyLinearVelocity = Vector3.new(0, 45, 70)
				local Steal = require(script.Parent.Steal)
				Steal.dropCarried(player)
			end
		end
	end
	wave:Destroy()
	foam:Destroy()
	State.Tsunami.active = false
	remotes().TsunamiOver:FireAllClients()
end

-- Warn, wait, then sweep. Public so the tour and the cover setup can call it.
function Tsunami.startNow()
	if State.Tsunami.warning or State.Tsunami.active then
		return
	end
	State.Tsunami.warning = true
	remotes().TsunamiWarning:FireAllClients(Tsunami.WARNING_SECONDS)
	task.wait(Tsunami.WARNING_SECONDS)
	State.Tsunami.warning = false
	Tsunami.sweepWave()
	State.Tsunami.nextAt = os.time() + Tsunami.EVERY
end

function Tsunami.start()
	State.Tsunami.nextAt = os.time() + Tsunami.FIRST_IN
	task.spawn(function()
		while true do
			local waitFor = State.Tsunami.nextAt - os.time()
			if waitFor > 0 then
				task.wait(waitFor)
			end
			Tsunami.startNow()
		end
	end)
end

return Tsunami
