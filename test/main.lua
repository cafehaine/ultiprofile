local profile = require("ultiprofile")

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

local check_count = 0
local check_fails = 0

local function check_equals(a, b)
	check_count = check_count + 1

	local equal
	if type(a) == "table" then
		equal = tables_equal(a, b)
	else
		equal = a == b
	end

	if not equal then
		check_fails = check_fails + 1
		local infos = debug.getinfo(2)
		print("Check failed! in function defined at line "..infos.linedefined.." in line "..infos.currentline)
	end
end

function load_save()
	profile.load()
	profile.set("ABC", "DEF", "HIJ")
	profile.save()
	profile.load()
	check_equals(profile.get("ABC", "DEF"), "HIJ")
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
	check_equals(profile.get("test", "string"), "abcdef")
	check_equals(profile.get("test", "number"), 3.14)
	check_equals(profile.get("test", "boolean"), true)
	check_equals(profile.get("test", "table"), demo_table)
end

function migration()
	profile.load({metadata={version=0}})
	profile.set("abc", "def", "ghi")
	profile.save()

	profile.load({metadata={version=1}})
	check_equals(profile.get("abc2", "def", "ghi"), "ghi")
	check_equals(profile.get("abc", "def", "ghi"), nil)
end

TESTS = {"load_save", "serialization", "migration"}

function love.run()
	return function()
		local total_failed = 0
		for i, name in ipairs(TESTS) do
			check_count = 0
			check_fails = 0
			print()
			print("==> Running test '"..name.."' ("..i.."/"..#TESTS..")")
			love.filesystem.remove("profile.txt")
			_G[name]()
			print("==> "..check_fails.." checks failed out of "..check_count)
			total_failed = total_failed + check_fails
		end
		if total_failed == 0 then
			print("Tests ran successfully.")
			return 0
		end
		print("Some tests failed.")
		return 1
	end
end
