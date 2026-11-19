-- Brainrot Bay: builds the 3D model of one brainrot from a catalog entry.
-- Body, head, eyes and one silly accessory prop, plus a floating label with
-- the readable name, rarity and money-per-second every screenshot needs.

local Catalog = require(script.Parent.Catalog)

local Factory = {}

local function makePart(parent, name, size, offset, color, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = CFrame.new(offset)
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	if shape then
		p.Shape = shape
	end
	p.Parent = parent
	return p
end

-- One prop per accessory id: kept to one to three parts so models stay cheap.
local function addAccessory(model, entry)
	local a = entry.accessory
	if a == "fin" then
		local fin = makePart(model, "Fin", Vector3.new(0.4, 1.6, 1.2), Vector3.new(0, 1.6, -1.2), Color3.fromRGB(40, 90, 200))
		fin.CFrame = fin.CFrame * CFrame.Angles(math.rad(35), 0, 0)
	elseif a == "roll" then
		makePart(model, "Roll", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 2.2, 0), Color3.fromRGB(255, 255, 255), Enum.PartType.Cylinder)
	elseif a == "phone" then
		local phone = makePart(model, "Phone", Vector3.new(0.5, 1.6, 0.5), Vector3.new(1.4, 1.2, 0), Color3.fromRGB(255, 220, 60))
		phone.CFrame = phone.CFrame * CFrame.Angles(0, 0, math.rad(-20))
		makePart(model, "Antenna", Vector3.new(0.15, 0.9, 0.15), Vector3.new(1.7, 2.4, 0), Color3.fromRGB(60, 60, 60))
	elseif a == "couch" then
		makePart(model, "CouchBack", Vector3.new(3.2, 1.4, 0.6), Vector3.new(0, 1.2, -1.2), Color3.fromRGB(120, 60, 30))
		makePart(model, "Remote", Vector3.new(0.5, 0.2, 1.0), Vector3.new(1.2, 1.0, 0.6), Color3.fromRGB(40, 40, 40))
	elseif a == "disco" then
		local ball = makePart(model, "DiscoBall", Vector3.new(1.6, 1.6, 1.6), Vector3.new(0, 2.6, 0), Color3.fromRGB(200, 240, 255), Enum.PartType.Ball)
		ball.Material = Enum.Material.Metal
		ball.Reflectance = 0.6
	elseif a == "slipper" then
		local slip = makePart(model, "Slipper", Vector3.new(1.8, 0.5, 3.0), Vector3.new(0, 2.3, 0.4), Color3.fromRGB(255, 120, 180))
		slip.CFrame = slip.CFrame * CFrame.Angles(math.rad(-12), 0, 0)
	elseif a == "cape" then
		local cape = makePart(model, "Cape", Vector3.new(2.6, 2.6, 0.3), Vector3.new(0, 0.9, -1.3), Color3.fromRGB(220, 40, 40))
		cape.CFrame = cape.CFrame * CFrame.Angles(math.rad(10), 0, 0)
	elseif a == "burrito" then
		local wrap = makePart(model, "Wrap", Vector3.new(2.2, 2.0, 2.0), Vector3.new(0, 2.2, 0), Color3.fromRGB(200, 160, 100), Enum.PartType.Cylinder)
		wrap.CFrame = wrap.CFrame * CFrame.Angles(0, 0, math.rad(90))
		makePart(model, "Lettuce", Vector3.new(1.6, 0.5, 1.6), Vector3.new(0, 2.2, 0.9), Color3.fromRGB(90, 220, 90))
	elseif a == "hat" then
		local brim = makePart(model, "HatBrim", Vector3.new(0.3, 2.6, 2.6), Vector3.new(0, 2.4, 0), Color3.fromRGB(120, 80, 220), Enum.PartType.Cylinder)
		brim.CFrame = brim.CFrame * CFrame.Angles(0, 0, math.rad(90))
		makePart(model, "HatTop", Vector3.new(1.4, 1.3, 1.3), Vector3.new(0, 3.0, 0), Color3.fromRGB(120, 80, 220), Enum.PartType.Cylinder)
		makePart(model, "Star", Vector3.new(0.5, 0.5, 0.5), Vector3.new(0, 3.8, 0), Color3.fromRGB(255, 240, 100), Enum.PartType.Ball)
	elseif a == "washer" then
		local door = makePart(model, "Door", Vector3.new(0.3, 1.6, 1.6), Vector3.new(0, 1.0, 1.3), Color3.fromRGB(140, 200, 255), Enum.PartType.Cylinder)
		door.CFrame = door.CFrame * CFrame.Angles(0, math.rad(90), 0)
		makePart(model, "Knob", Vector3.new(0.4, 0.4, 0.4), Vector3.new(1.0, 1.9, 1.2), Color3.fromRGB(255, 80, 80), Enum.PartType.Ball)
	elseif a == "spaghetti" then
		for i = 1, 4 do
			local noodle = makePart(model, "Noodle" .. i, Vector3.new(2.4, 0.35, 0.35), Vector3.new(-0.7 + i * 0.45, 2.4, 0), Color3.fromRGB(255, 210, 90), Enum.PartType.Cylinder)
			noodle.CFrame = noodle.CFrame * CFrame.Angles(math.rad(90), math.rad((i - 2) * 22), 0)
		end
		makePart(model, "Meatball", Vector3.new(0.9, 0.9, 0.9), Vector3.new(0.8, 2.7, 0.5), Color3.fromRGB(160, 60, 40), Enum.PartType.Ball)
	elseif a == "crown" then
		for i = 1, 3 do
			makePart(model, "CrownSpike" .. i, Vector3.new(0.4, 0.9, 0.4), Vector3.new(-0.7 + (i - 1) * 0.7, 2.7, 0), Color3.fromRGB(255, 210, 40))
		end
		local band = makePart(model, "CrownBand", Vector3.new(0.4, 2.0, 2.0), Vector3.new(0, 2.3, 0), Color3.fromRGB(255, 210, 40), Enum.PartType.Cylinder)
		band.CFrame = band.CFrame * CFrame.Angles(0, 0, math.rad(90))
	end
end

-- Builds the model standing on its origin (feet at y = 0). Golden variants are
-- the same entry with a gold body and triple income, for the belt's rare event.
function Factory.buildBrainrotModel(entry, golden)
	local model = Instance.new("Model")
	model.Name = entry.name

	local bodyColor = entry.body
	local income = entry.income
	local displayName = entry.name
	if golden then
		bodyColor = Color3.fromRGB(255, 210, 40)
		income = entry.income * 3
		displayName = "GOLDEN " .. entry.name
	end

	local body = makePart(model, "Body", Vector3.new(3, 2.4, 2.4), Vector3.new(0, 1.2, 0), bodyColor)
	model.PrimaryPart = body
	makePart(model, "Head", Vector3.new(2.2, 1.6, 2.2), Vector3.new(0, 3.0, 0), entry.head)
	local eyeL = makePart(model, "EyeL", Vector3.new(0.5, 0.5, 0.5), Vector3.new(-0.55, 3.1, 1.15), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball)
	eyeL.Material = Enum.Material.Neon
	local eyeR = makePart(model, "EyeR", Vector3.new(0.5, 0.5, 0.5), Vector3.new(0.55, 3.1, 1.15), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball)
	eyeR.Material = Enum.Material.Neon
	makePart(model, "PupilL", Vector3.new(0.25, 0.25, 0.25), Vector3.new(-0.55, 3.1, 1.32), Color3.fromRGB(20, 20, 20), Enum.PartType.Ball)
	makePart(model, "PupilR", Vector3.new(0.25, 0.25, 0.25), Vector3.new(0.55, 3.1, 1.32), Color3.fromRGB(20, 20, 20), Enum.PartType.Ball)
	addAccessory(model, entry)

	-- Readable label: name on top, rarity and $/s underneath, in rarity colour.
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.new(0, 170, 0, 54)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 4.6, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = model
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
	nameLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	nameLabel.BackgroundTransparency = 0.25
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Text = displayName
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = false
	nameLabel.Parent = billboard
	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "SubLabel"
	subLabel.Size = UDim2.new(1, 0, 0.45, 0)
	subLabel.Position = UDim2.new(0, 0, 0.55, 0)
	subLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	subLabel.BackgroundTransparency = 0.25
	subLabel.TextColor3 = Catalog.RARITY_COLORS[entry.rarity]
	subLabel.Text = entry.rarity .. "  •  $" .. income .. "/s"
	subLabel.TextSize = 14
	subLabel.Font = Enum.Font.GothamBold
	subLabel.Parent = billboard

	return model
end

-- A hold-free prompt on the model's body. Callers wire Triggered themselves.
function Factory.attachPrompt(model, objectText, actionText)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = objectText
	prompt.ActionText = actionText
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = model.PrimaryPart
	return prompt
end

return Factory
