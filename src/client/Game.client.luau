-- Brainrot Bay: the client HUD. Cash and income top-right, the next tier to
-- chase under it, lock/rebirth/upgrade buttons bottom-right, the tsunami
-- banner top-centre. Nothing sits in the top-left corner: Roblox's own menu
-- buttons live there. The character moves with the default WASD controls.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBayGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local function makeLabel(parent, name, pos, size, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = pos
	label.Size = size
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
	label.BackgroundTransparency = 0.25
	label.TextColor3 = color
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

-- Cash panel, top-right, clear of the top-left menu buttons.
local cashPanel = Instance.new("Frame")
cashPanel.Name = "CashPanel"
cashPanel.AnchorPoint = Vector2.new(1, 0)
cashPanel.Position = UDim2.new(1, -16, 0, 16)
cashPanel.Size = UDim2.new(0, 280, 0, 76)
cashPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
cashPanel.BackgroundTransparency = 0.25
cashPanel.Parent = gui
local cashLabel = makeLabel(cashPanel, "Cash", UDim2.new(0, 12, 0, 6), UDim2.new(1, -24, 0, 36), 30, Color3.fromRGB(255, 220, 60))
cashLabel.Text = "$100"
local incomeLabel = makeLabel(cashPanel, "Income", UDim2.new(0, 12, 0, 42), UDim2.new(1, -24, 0, 26), 18, Color3.fromRGB(120, 255, 140))
incomeLabel.Text = "+$0/s"
local doubleLabel = makeLabel(cashPanel, "DoubleMoney", UDim2.new(0, 12, 0, 42), UDim2.new(1, -24, 0, 26), 18, Color3.fromRGB(255, 120, 220))
doubleLabel.Text = "2X MONEY EVENT!"
doubleLabel.Visible = false

-- Next tier panel: the chase the player can read at a glance.
local tierPanel = Instance.new("Frame")
tierPanel.Name = "NextTierPanel"
tierPanel.AnchorPoint = Vector2.new(1, 0)
tierPanel.Position = UDim2.new(1, -16, 0, 104)
tierPanel.Size = UDim2.new(0, 280, 0, 92)
tierPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
tierPanel.BackgroundTransparency = 0.25
tierPanel.Parent = gui
local tierHeader = makeLabel(tierPanel, "Header", UDim2.new(0, 12, 0, 6), UDim2.new(1, -24, 0, 22), 16, Color3.fromRGB(140, 220, 255))
tierHeader.Text = "NEXT TIER"
local tierName = makeLabel(tierPanel, "Name", UDim2.new(0, 12, 0, 30), UDim2.new(1, -24, 0, 26), 20, Color3.fromRGB(255, 255, 255))
tierName.Text = "Soggy Sockfish"
local tierCost = makeLabel(tierPanel, "Cost", UDim2.new(0, 12, 0, 58), UDim2.new(1, -24, 0, 26), 18, Color3.fromRGB(255, 190, 40))
tierCost.Text = "$25  •  $1/s"

-- Buttons, bottom-right: lock, rebirth and the three upgrades.
local function makeButton(name, text, y)
	local button = Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = UDim2.new(1, -16, 1, y)
	button.Size = UDim2.new(0, 220, 0, 38)
	button.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Text = text
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.Parent = gui
	return button
end
local lockButton = makeButton("LockButton", "LOCK BASE (60s)", -16)
lockButton.BackgroundColor3 = Color3.fromRGB(40, 160, 220)
local rebirthButton = makeButton("RebirthButton", "REBIRTH", -62)
rebirthButton.BackgroundColor3 = Color3.fromRGB(180, 60, 220)
local slotButton = makeButton("SlotButton", "+SLOT  $10,000", -108)
slotButton.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
local incomeButton = makeButton("IncomeButton", "+10% INCOME  $5,000", -154)
incomeButton.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
local speedButton = makeButton("SpeedButton", "+SPEED  $2,500", -200)
speedButton.BackgroundColor3 = Color3.fromRGB(60, 160, 80)

lockButton.MouseButton1Click:Connect(function()
	remotes.LockBase:FireServer()
end)
rebirthButton.MouseButton1Click:Connect(function()
	remotes.Rebirth:FireServer()
end)
slotButton.MouseButton1Click:Connect(function()
	remotes.BuyUpgrade:FireServer("slot")
end)
incomeButton.MouseButton1Click:Connect(function()
	remotes.BuyUpgrade:FireServer("income")
end)
speedButton.MouseButton1Click:Connect(function()
	remotes.BuyUpgrade:FireServer("speed")
end)

-- Tsunami warning banner, top-centre.
local banner = Instance.new("TextLabel")
banner.Name = "TsunamiBanner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 16)
banner.Size = UDim2.new(0, 560, 0, 46)
banner.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
banner.TextColor3 = Color3.fromRGB(255, 255, 255)
banner.Text = "TSUNAMI INCOMING — RUN TO YOUR BASE!"
banner.TextSize = 24
banner.Font = Enum.Font.GothamBold
banner.Visible = false
banner.Parent = gui

-- Toast line under the banner: bought, sold, stolen, locked, rebirth.
local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 72)
toast.Size = UDim2.new(0, 560, 0, 32)
toast.BackgroundTransparency = 1
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.Text = ""
toast.TextSize = 20
toast.Font = Enum.Font.GothamBold
toast.Parent = gui

-- Controls hint, bottom-left.
local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint.AnchorPoint = Vector2.new(0, 1)
hint.Position = UDim2.new(0, 16, 1, -16)
hint.Size = UDim2.new(0, 620, 0, 28)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(255, 255, 255)
hint.Text = "WASD move  •  Buy brainrots on the belt  •  Steal when a rival lock is down  •  Run home before the tsunami!"
hint.TextSize = 16
hint.Font = Enum.Font.Gotham
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = gui

gui.Parent = player:WaitForChild("PlayerGui")

-- HUD refresh from the server's one-second tick.
remotes.UpdateHud.OnClientEvent:Connect(function(data)
	cashLabel.Text = "$" .. tostring(data.cash)
	incomeLabel.Text = "+$" .. tostring(data.income) .. "/s"
	incomeLabel.Visible = not data.doubleMoney
	doubleLabel.Visible = data.doubleMoney
	tierName.Text = data.nextName
	tierCost.Text = "$" .. tostring(data.nextCost) .. "  •  $" .. tostring(data.nextIncome) .. "/s  •  " .. data.nextRarity
	if data.lockLeft > 0 then
		lockButton.Text = "LOCKED (" .. tostring(data.lockLeft) .. "s)"
	else
		lockButton.Text = "LOCK BASE (60s)"
	end
	rebirthButton.Text = "REBIRTH x" .. tostring(data.multiplier) .. "  (" .. tostring(data.rebirths) .. ")"
end)

local toastUntil = 0
remotes.Toast.OnClientEvent:Connect(function(message)
	toast.Text = message
	toastUntil = os.clock() + 3
end)

remotes.TsunamiWarning.OnClientEvent:Connect(function(seconds)
	banner.Visible = true
	banner.Text = "TSUNAMI INCOMING — RUN TO YOUR BASE! " .. tostring(seconds) .. "s"
	task.spawn(function()
		for i = seconds, 1, -1 do
			banner.Text = "TSUNAMI INCOMING — RUN TO YOUR BASE! " .. tostring(i) .. "s"
			task.wait(1)
		end
	end)
end)
remotes.TsunamiOver.OnClientEvent:Connect(function()
	banner.Visible = false
end)

remotes.ThiefAlert.OnClientEvent:Connect(function(message)
	toast.Text = message
	toastUntil = os.clock() + 4
end)

-- Clear stale toasts.
task.spawn(function()
	while true do
		task.wait(0.5)
		if toast.Text ~= "" and os.clock() > toastUntil then
			toast.Text = ""
		end
	end
end)
