-- Brainrot Bay: the brainrot cast. Twelve original absurd characters on a
-- six-rung rarity ladder. Nothing here copies the real Steal a Brainrot cast:
-- every name, joke and look is invented for this game.

local Catalog = {}

Catalog.RARITY_ORDER = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Brainrot God" }

Catalog.RARITY_COLORS = {
	Common = Color3.fromRGB(150, 200, 110),
	Rare = Color3.fromRGB(80, 160, 255),
	Epic = Color3.fromRGB(180, 90, 255),
	Legendary = Color3.fromRGB(255, 190, 40),
	Mythic = Color3.fromRGB(255, 80, 120),
	["Brainrot God"] = Color3.fromRGB(90, 240, 255),
}

Catalog.RARITY_WEIGHTS = {
	Common = 40,
	Rare = 28,
	Epic = 16,
	Legendary = 9,
	Mythic = 5,
	["Brainrot God"] = 2,
}

-- accessory: the one silly prop that makes the model read at a glance.
Catalog.ENTRIES = {
	{ id = "sockfish", name = "Soggy Sockfish", rarity = "Common", cost = 25, income = 1,
		body = Color3.fromRGB(90, 140, 255), head = Color3.fromRGB(255, 220, 130), accessory = "fin",
		blurb = "Smells like victory. And feet." },
	{ id = "tproll", name = "Toilet Paperrollini", rarity = "Common", cost = 60, income = 2,
		body = Color3.fromRGB(245, 245, 245), head = Color3.fromRGB(200, 220, 255), accessory = "roll",
		blurb = "Always prepared. Never flushed." },
	{ id = "bananaphone", name = "Banana Phone-ini", rarity = "Rare", cost = 200, income = 6,
		body = Color3.fromRGB(255, 220, 60), head = Color3.fromRGB(255, 240, 150), accessory = "phone",
		blurb = "Ring ring. It is a banana." },
	{ id = "couchpotato", name = "Couch Potato Supreme", rarity = "Rare", cost = 400, income = 10,
		body = Color3.fromRGB(150, 90, 50), head = Color3.fromRGB(210, 170, 110), accessory = "couch",
		blurb = "Has not moved since 2019. Earns anyway." },
	{ id = "discopickle", name = "Disco Pickle", rarity = "Epic", cost = 1000, income = 20,
		body = Color3.fromRGB(60, 200, 90), head = Color3.fromRGB(120, 255, 140), accessory = "disco",
		blurb = "Brines all night. Dances all day." },
	{ id = "grannyslipper", name = "Grandma's Flying Slipper", rarity = "Epic", cost = 2000, income = 35,
		body = Color3.fromRGB(255, 150, 200), head = Color3.fromRGB(255, 210, 230), accessory = "slipper",
		blurb = "It knows where you live. It flies." },
	{ id = "captainunderpants", name = "Captain Underpantsasaurus", rarity = "Legendary", cost = 5000, income = 70,
		body = Color3.fromRGB(80, 200, 220), head = Color3.fromRGB(255, 255, 255), accessory = "cape",
		blurb = "A dinosaur. In underpants. In charge." },
	{ id = "quantumburrito", name = "Quantum Burrito", rarity = "Legendary", cost = 10000, income = 120,
		body = Color3.fromRGB(220, 180, 120), head = Color3.fromRGB(140, 220, 90), accessory = "burrito",
		blurb = "Both eaten and uneaten until observed." },
	{ id = "mooncheese", name = "Moon Cheese Wizard", rarity = "Mythic", cost = 25000, income = 250,
		body = Color3.fromRGB(255, 240, 150), head = Color3.fromRGB(180, 140, 255), accessory = "hat",
		blurb = "Turned the moon into cheese. For profit." },
	{ id = "washer", name = "Interdimensional Washing Machine", rarity = "Mythic", cost = 50000, income = 400,
		body = Color3.fromRGB(230, 230, 240), head = Color3.fromRGB(120, 200, 255), accessory = "washer",
		blurb = "Your socks go in. Money comes out." },
	{ id = "spaghetti", name = "The Almighty Spaghetti Monster", rarity = "Brainrot God", cost = 150000, income = 900,
		body = Color3.fromRGB(255, 210, 90), head = Color3.fromRGB(255, 90, 60), accessory = "spaghetti",
		blurb = "Praise be to the noodle. Ramen." },
	{ id = "quackington", name = "Sir Reginald von Quackington III", rarity = "Brainrot God", cost = 300000, income = 1500,
		body = Color3.fromRGB(255, 255, 255), head = Color3.fromRGB(255, 200, 40), accessory = "crown",
		blurb = "A duck. A sir. A third. Enough said." },
}

function Catalog.byId(id)
	for _, entry in ipairs(Catalog.ENTRIES) do
		if entry.id == id then
			return entry
		end
	end
	return nil
end

-- Weighted random pick over the rarity ladder, then a random entry of that rarity.
function Catalog.randomEntry()
	local total = 0
	for _, w in pairs(Catalog.RARITY_WEIGHTS) do
		total += w
	end
	local roll = math.random(total)
	local rarity = "Common"
	for _, name in ipairs(Catalog.RARITY_ORDER) do
		roll -= Catalog.RARITY_WEIGHTS[name]
		if roll <= 0 then
			rarity = name
			break
		end
	end
	local pool = {}
	for _, entry in ipairs(Catalog.ENTRIES) do
		if entry.rarity == rarity then
			table.insert(pool, entry)
		end
	end
	return pool[math.random(#pool)]
end

-- The cheapest entry richer than the player's best brainrot: the next tier to chase.
function Catalog.nextTier(bestIncome)
	local best = nil
	for _, entry in ipairs(Catalog.ENTRIES) do
		if entry.income > bestIncome then
			if best == nil or entry.cost < best.cost then
				best = entry
			end
		end
	end
	return best or Catalog.ENTRIES[#Catalog.ENTRIES]
end

return Catalog
