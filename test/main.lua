local profile = require("ultiprofile")

function load_save()
	profile.load()
	profile.set("ABC", "DEF", "HIJ")
	profile.save()
	profile.load()
	assert(profile.get("ABC", "DEF") == "HIJ")
end

local function tables_equal(t1, t2)
	for k, v in pairs(t1) do
		if type(v) == "table" then
			if not tables_equal(v, t2[k]) then
				return false
			end
		else
			if v ~= t2[k] then
				return false
			end
		end
	end
	return true
end

function serialization()
	local demo_table = {"abc", true, 1, {10, "def"}}

	profile.load()
	profile.set("test", "string", "abcdef")
	profile.set("test", "number", 3.14)
	profile.set("test", "boolean", true)
	profile.set("test", "table", demo_table)
	profile.save()

	profile.load()
	assert(profile.get("test", "string") == "abcdef")
	assert(profile.get("test", "number") == 3.14)
	assert(profile.get("test", "boolean") == true)
	assert(tables_equal(profile.get("test", "table"), demo_table))
end

TESTS = {load_save, serialization}

function love.run()
	return function()
		for i, func in ipairs(TESTS) do
			print("== Test ".. i .. " out of ".. #TESTS .. " ==")
			love.filesystem.remove("profile.txt")
			func()
		end

		print("Tests ran successfully.")
		return 0
	end
end
