-- Brainrot Bay: stages the cover frame for the thumbnail screenshot.
-- Fills the player's base with the richest brainrots, puts a golden one on
-- the belt, starts a tsunami warning, and stands the player where the shot
-- shows the character, the base, the ticking money, the next tier and the wave.
-- Run from the Studio command bar or from TOUR.json:
--   require(game.ServerScriptService.Server.CoverSetup).setupCoverScene(game.Players:GetPlayers()[1])

local State = require(script.Parent.State)
local Catalog = require(script.Parent.Catalog)
local Economy = require(script.Parent.Economy)
local World = require(script.Parent.World)
local Tsunami = require(script.Parent.Tsunami)

local CoverSetup = {}

local COVER_CAST = { "discopickle", "quantumburrito", "mooncheese", "washer", "spaghetti", "quackington" }

function CoverSetup.setupCoverScene(player)
	local data = State.getPlayerData(player)
	if data == nil then
		return "no player data"
	end
	data.cash = 250000
	data.slots = 8
	for _, record in pairs(data.brainrots) do
		record.model:Destroy()
	end
	data.brainrots = {}
	for i, id in ipairs(COVER_CAST) do
		local entry = Catalog.byId(id)
		Economy.placeBrainrotOnBase(player, entry, nil, false)
	end
	-- A golden brainrot mid-belt so the shot shows the catch waiting.
	local goldenEntry = Catalog.byId("spaghetti")
	local Factory = require(script.Parent.Factory)
	local golden = Factory.buildBrainrotModel(goldenEntry, true)
	golden:PivotTo(CFrame.new(0, 2.2, 0))
	golden.Parent = game:GetService("Workspace").BrainrotBay
	local Conveyor = require(script.Parent.Conveyor)
	table.insert(Conveyor.Belt, { entry = goldenEntry, model = golden, speed = 0, golden = true })
	-- The threat on the horizon: warning banner plus the wave itself.
	task.spawn(function()
		Tsunami.startNow()
	end)
	-- Stand the player at the base edge, facing the belt and the wave.
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(World.Bases.Player.center + Vector3.new(-10, 3, 12), World.Bases.Player.center)
	end
	return "cover scene staged"
end

return CoverSetup
