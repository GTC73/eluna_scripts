-- 玩家上线欢迎系统

print(">>Script: Player Greeting")

local TEAM_ALLIANCE=0
local TEAM_HORDE=1
--CLASS职业
local CLASS_WARRIOR      = 1--战士
local CLASS_PALADIN      = 2--圣骑士
local CLASS_HUNTER       = 3--猎人
local CLASS_ROGUE        = 4--盗贼
local CLASS_PRIEST       = 5--牧师
local CLASS_DEATH_KNIGHT = 6--死亡骑士
local CLASS_SHAMAN       = 7--萨满
local CLASS_MAGE         = 8--法师
local CLASS_WARLOCK      = 9--术士
local CLASS_DRUID        = 11--德鲁伊

--职业表
local ClassName = {
	[CLASS_WARRIOR]      = "Warrior",
	[CLASS_PALADIN]      = "Paladin",
	[CLASS_HUNTER]       = "Hunter",
	[CLASS_ROGUE]        = "Rogue",
	[CLASS_PRIEST]       = "Priest",
	[CLASS_DEATH_KNIGHT] = "Death Knight",
	[CLASS_SHAMAN]       = "Shaman",
	[CLASS_MAGE]         = "Mage",
	[CLASS_WARLOCK]      = "Warlock",
	[CLASS_DRUID]        = "Druid",
}

local function GetPlayerInfo(player)--得到玩家信息
	local class = ClassName[player:GetClass()] or "? ? ?" --得到职业
	local name = player:GetName()
	local team = ""
	local teamType = player:GetTeam()
	if teamType == TEAM_ALLIANCE then
		team = "|cFF0070d0Alliance|r"
	elseif teamType == TEAM_HORDE then
		team = "|cFFF000A0Horde|r"
	end
	return string.format("%s%sPlayer[|cFF00FF00|Hplayer:%s|h%s|h|r]",team,class,name,name)
end

local function OnPlayerFirstLogin(event, player)--玩家首次登录
	SendWorldMessage("|cFFFF0000[System]|rWelcome"..GetPlayerInfo(player).."'s first login of |cFFFF0000World Of Warcraft.|r")
	print("Player is Created. GUID:"..player:GetGUIDLow())
end

local function OnPlayerLogin(event, player)--玩家登录
	SendWorldMessage("|cFFFF0000[System]|rWelcom"..GetPlayerInfo(player).." logging in.")
	print("Player is Login. GUID:"..player:GetGUIDLow())
end

local function OnPlayerLogout(event, player)--玩家登出
	SendWorldMessage("|cFFFF0000[System]|r"..GetPlayerInfo(player).." logging off.")
	print("Player is Logout. GUID:"..player:GetGUIDLow())
end

RegisterPlayerEvent(30, OnPlayerFirstLogin)--首次登录
RegisterPlayerEvent(3, OnPlayerLogin)--登录
RegisterPlayerEvent(4, OnPlayerLogout)--登出
