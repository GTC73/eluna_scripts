
print(">>Script: Super Hearthstone")
--54844
--菜单所有者 --默认炉石
local itemEntry    =6948
--阵营
local TEAM_ALLIANCE=0
local TEAM_HORDE=1
--菜单号
local MMENU=1
local TPMENU=2
local GMMENU=3
local ENCMENU=4
--菜单类型
local FUNC=1
local MENU=2
local TP=3
local ENC=4

local SPELL_HEARTHSTONE=8690

--GOSSIP_ICON 菜单图标
local GOSSIP_ICON_CHAT            = 0                    -- 对话
local GOSSIP_ICON_VENDOR          = 1                    -- 货物
local GOSSIP_ICON_TAXI            = 2                    -- 传送
local GOSSIP_ICON_TRAINER         = 3                    -- 训练（书）
local GOSSIP_ICON_INTERACT_1      = 4                    -- 复活
local GOSSIP_ICON_INTERACT_2      = 5                    -- 设为我的家
local GOSSIP_ICON_MONEY_BAG         = 6                    -- 钱袋
local GOSSIP_ICON_TALK            = 7                    -- 申请 说话+黑色点
local GOSSIP_ICON_TABARD          = 8                    -- 工会（战袍）
local GOSSIP_ICON_BATTLE          = 9                    -- 加入战场 双剑交叉
local GOSSIP_ICON_DOT             = 10                   -- 加入战场

--装备位置
local EQUIPMENT_SLOT_HEAD         = 0--头部
local EQUIPMENT_SLOT_NECK         = 1--颈部
local EQUIPMENT_SLOT_SHOULDERS    = 2--肩部
local EQUIPMENT_SLOT_BODY         = 3--身体
local EQUIPMENT_SLOT_CHEST        = 4--胸甲
local EQUIPMENT_SLOT_WAIST        = 5--腰部
local EQUIPMENT_SLOT_LEGS         = 6--腿部
local EQUIPMENT_SLOT_FEET         = 7--脚部
local EQUIPMENT_SLOT_WRISTS       = 8--手腕
local EQUIPMENT_SLOT_HANDS        = 9--手套
local EQUIPMENT_SLOT_FINGER1      = 10--手指1
local EQUIPMENT_SLOT_FINGER2      = 11--手指2
local EQUIPMENT_SLOT_TRINKET1     = 12--饰品1
local EQUIPMENT_SLOT_TRINKET2     = 13--饰品2
local EQUIPMENT_SLOT_BACK         = 14--背部
local EQUIPMENT_SLOT_MAINHAND     = 15--主手
local EQUIPMENT_SLOT_OFFHAND      = 16--副手
local EQUIPMENT_SLOT_RANGED       = 17--远程
local EQUIPMENT_SLOT_TABARD       = 18--徽章

local Instances={--副本表
    {249,0},{249,1},{269,1},{309,0},
    {409,0},{469,0},
    {509,0},{531,0},{532,0},{533,0},{533,1},
    {534,0},{540,1},{542,1},{543,1},{544,0},{545,1},{546,1},{547,1},{548,0},
    {550,0},{552,1},{553,1},{554,1},{555,1},{556,1},{557,1},{558,1},
    {560,1},{564,0},{565,0},{568,0},
    {574,1},{575,1},{576,1},{578,1},
    {580,0},{585,1},{595,1},{598,1},{599,1},
    {600,1},{601,1},{602,1},{603,0},{603,1},{604,1},{608,1},
    {615,0},{615,1},{616,0},{616,1},{619,1},{624,0},{624,1},
    {631,0},{631,1},{631,2},{631,3},{632,1},
    {649,0},{649,1},{649,2},{649,3},--十字军的试炼
    {650,1},{658,1},{668,1},
    {724,0},{724,1},{724,2},{724,3},
}
--随身NPC
local ST={
    TIME   = 90, --秒
    NPCID1 = 190098,
    NPCID2 = 190099,
    --[guid]=lasttime,
}

function ST.SummonNPC(player, entry)
    local guid=player:GetGUIDLow()
    local lastTime,nowTime=(ST[guid] or 0),os.time()

    if(player:IsInCombat())then
        player:SendAreaTriggerMessage("Unable to summon during battle.")
    else
        if(nowTime>lastTime)then
            local map=player:GetMap()
            if(map)then
                player:SendAreaTriggerMessage(map:GetName())
                local x,y,z=player:GetX()+1,player:GetY(),player:GetZ()
                local nz=map:GetHeight(x,y)
                if(nz>z and nz<(z+5))then
                    z=nz
                end
                local NPC=player:SpawnCreature(entry,x,y,z,0, 3,ST.TIME*1000)
                if(NPC)then
                    player:SendAreaTriggerMessage("Summon mobile vendor successfully.")
                    NPC:SetFacingToObject(player)
                    NPC:SendUnitSay(string.format("%s，Greetings, what can I help you with?",player:GetName()),0)
                    lastTime=os.time()+ST.TIME
                else
                    player:SendAreaTriggerMessage("Summon mobile vendor failed.")
                end
            end
        else
            player:SendAreaTriggerMessage("You can't summon NPC again in such a short time.")
        end
    end
    ST[guid]=lastTime
end

function ST.SummonGNPC(player)--召唤商人
    ST.SummonNPC(player, ST.NPCID2)
end


function ST.SummonENPC(player)--召唤 enchantment
    ST.SummonNPC(player, ST.NPCID1)
end

-- TODO: DRY
-- 副本类型
local DUNGEON = 1
local HEROIC  = 2
local RAID    = 3

-- 阵营
local ALLIANCE = 1
local HORDE    = 2

-- 职业
-- local CLASS_HUNTER = 3 --猎人
local AURAS = {
	[ALLIANCE] = {
		[DUNGEON] = 73826, -- 20%
		[HEROIC]  = 73827, -- 25%
		[RAID]    = 73828, -- 30%
	},
	[HORDE] = {
		[DUNGEON] = 73820, -- 20%
		[HEROIC]  = 73821, -- 25%
		[RAID]    = 73822, -- 30%
	},
}
local function AddAuraToPetByInstanceType(player, instanceType)
    -- if player:GetClass() ~= CLASS_HUNTER then
    --     player:SendAreaTriggerMessage("您不是猎人")
    --     return false
    -- end
    local pet = player:GetSelection()
    if pet and pet:GetOwner() == player then
        local auras = player:IsAlliance() and AURAS[ALLIANCE] or AURAS[HORDE]
        local auraId = auras[instanceType]
        if auraId and auraId > 0 then
            pet:AddAura(auraId, pet)
            return true
        end
    end
end
function ST.AddAuraToPet(player)
    local map = player:GetMap()
    local instanceType
    if map:IsDungeon() then
        instanceType = DUNGEON
    elseif map:IsHeroic() then
        instanceType = HEROIC
    elseif map:IsRaid() then
        instanceType = RAID
    end
    if AddAuraToPetByInstanceType(player, instanceType) then
        player:SendAreaTriggerMessage("Your pet has gained an enhanced aura.")
    end
end

local function ResetPlayer(player, flag, text)
    player:SetAtLoginFlag(flag)
    player:SendAreaTriggerMessage("You can only edit after logging in again."..text.."。")
    -- player:SendAreaTriggerMessage("正在返回选择角色菜单")
    -- player:LogoutPlayer(true)
end

local Stone={
    GetTimeASString=function(player)
        local inGameTime=player:GetTotalPlayedTime()
        local days=math.modf(inGameTime/(24*3600))
        local hours=math.modf((inGameTime-(days*24*3600))/3600)
        local mins=math.modf((inGameTime-(days*24*3600+hours*3600))/60)
        return days.."天"..hours.."时"..mins.."分"
    end,
    GoHome=function(player)--回到家
        player:CastSpell(player, SPELL_HEARTHSTONE, true)
        player:ResetSpellCooldown(SPELL_HEARTHSTONE, true)
        player:SendBroadcastMessage("You have returned home.")
    end,

    SetHome=function(player)--设置当前位置为家
        local x,y,z,mapId,areaId=player:GetX(),player:GetY(),player:GetZ(),player:GetMapId(),player:GetAreaId()
        player:SetBindPoint(x,y,z,mapId,areaId)
        player:SendBroadcastMessage("You have set the current location to be home.")
    end,

    OpenBank=function(player)--打开银行
        player:SendShowBank(player)
        player:SendBroadcastMessage("Bank opened")
    end,

    WeakOut = function(player) -- Remove resurrection sickness
        if player:HasAura(15007) then
            player:RemoveAura(15007) -- Remove resurrection sickness
            player:SetHealth(player:GetMaxHealth())
            -- self:RemoveAllAuras() -- Remove all auras
            player:SendBroadcastMessage("Resurrection sickness has been removed.")
        else
            player:SendBroadcastMessage("You do not have resurrection sickness.")
        end
    end,

    OutCombat=function(player)--脱离战斗
        if(player:IsInCombat())then
            player:ClearInCombat()
            player:SendAreaTriggerMessage("You have exited combat.")
            player:SendBroadcastMessage("You have exited combat.")
        else
            player:SendAreaTriggerMessage("You are not in combat.")
            player:SendBroadcastMessage("You are not in combat.")
        end
    end,

    WSkillsToMax = function(player) -- Skill proficiency
        player:AdvanceSkillsToMax()
        player:SendBroadcastMessage("Current skill proficiency has been maximized.")
    end,
    MaxHealth = function(player) -- Restore health
        player:SetHealth(player:GetMaxHealth())
        player:SendBroadcastMessage("Health restored to full.")
    end,
    ResetTalents = function(player) -- Reset talents
        player:ResetTalents(true) -- Free reset
        player:SendBroadcastMessage("Talents have been reset.")
    end,

    ResetPetTalents = function(player) -- Reset pet talents
        player:ResetPetTalents()
        player:SendBroadcastMessage("Pet talents have been reset.")
    end,

    ResetAllCD = function(player) -- Reset cooldowns
        player:ResetAllCooldowns()
        player:SendBroadcastMessage("Items and skills cooldowns have been reset.")
    end,

    RepairAll=function(player)--修理装备
        player:DurabilityRepairAll(true,1,false)
        player:SendBroadcastMessage("all equipments repaired")
    end,

    SaveToDB=function(player)--保存数据
        player:SaveToDB()
        player:SendAreaTriggerMessage("Saving successfully.")
    end,

    Logout=function(player)--返回选择角色
        player:SendAreaTriggerMessage("Returning to character menu.")
        player:LogoutPlayer(true)
    end,

    LogoutNosave=function(player)--不保存数据,返回选择角色
        player:SendAreaTriggerMessage("Returning to character menu.")
        player:LogoutPlayer(false)
    end,
    UnBind=function(player)    --副本解绑
        local nowmap=player:GetMapId()
        for k, v in pairs(Instances) do
            local mapid=v[1]
            if(mapid~=nowmap)then
                player:UnbindInstance(v[1],v[2])
            else
                player:SendBroadcastMessage("Current dungeon lock can't be removed.")
            end
        end
        player:SendAreaTriggerMessage("All dungeons lock removed.")
        player:SendBroadcastMessage("All dungeons lock removed.")
    end,
    --[[登录标志
    AT_LOGIN_RENAME            = 0x01,
    AT_LOGIN_RESET_SPELLS      = 0x02,
    AT_LOGIN_RESET_TALENTS     = 0x04,
    AT_LOGIN_CUSTOMIZE         = 0x08,
    AT_LOGIN_RESET_PET_TALENTS = 0x10,
    AT_LOGIN_FIRST             = 0x20,
    AT_LOGIN_CHANGE_FACTION    = 0x40,
    AT_LOGIN_CHANGE_RACE       = 0x80
    ]]--
    ResetName=function(player,code)--修改名字
        local target=player:GetSelection()
        if(target and (target:GetTypeId()==player:GetTypeId()))then
            ResetPlayer(target, 0x1, "Name")
        else
            player:SendAreaTriggerMessage("Please choose a player.")
        end
    end,
    ResetFace=function(player)
        ResetPlayer(player, 0x8, "Face")
    end,
    ResetRace=function(player)
        ResetPlayer(player, 0x80, "Race")
    end,
    ResetFaction=function(player)
        ResetPlayer(player, 0x40, "Factions")
    end,
    ResetSpell=function(player)
        ResetPlayer(player, 0x2, "All spells")
    end,
}

local Menu={
    [MMENU]={--Main Menu
        {FUNC, "Teleport home",             Stone.GoHome,        GOSSIP_ICON_CHAT,        false,"Teleport to |cFFF0F000Home|r ?"},
        {FUNC, "Set home location",         Stone.SetHome,        GOSSIP_ICON_INTERACT_1, false,"Setting current location as |cFFF0F000Home|r ?"},
        {FUNC, "Bank",                      Stone.OpenBank,        GOSSIP_ICON_MONEY_BAG},
        {MENU, "Map teleport",              TPMENU,                GOSSIP_ICON_BATTLE},
        {MENU, "Others",                    MMENU+0x10,            GOSSIP_ICON_INTERACT_1},
        {MENU, "Double enchantments",       ENCMENU,            GOSSIP_ICON_TABARD},
        {FUNC, "Remove dungeons loc",       Stone.UnBind,        GOSSIP_ICON_INTERACT_1, false,"Do you wish to remove all dungeons lock ?"},
        {FUNC, "Summon mobile vendor",      ST.SummonGNPC,        GOSSIP_ICON_MONEY_BAG},
        --{FUNC, "Enchantment Master NPC",   ST.SummonENPC,        GOSSIP_ICON_TABARD},
        {MENU, "Class skills trainer",      MMENU+0x20,            GOSSIP_ICON_BATTLE},
        {MENU, "Profession skills trainer", MMENU+0x30,            GOSSIP_ICON_BATTLE},
        -- {FUNC, "Force exit combat",      Stone.OutCombat,    GOSSIP_ICON_CHAT},
        {FUNC, "Instance pet aura",         ST.AddAuraToPet,    GOSSIP_ICON_BATTLE},
    },
    [MMENU+0x10]={--Other Functions
        {FUNC, "Remove Weakness",         Stone.WeakOut,        GOSSIP_ICON_INTERACT_1, false,"Remove weakness and restore health ?"},
        {FUNC, "Talents reset",           Stone.ResetTalents,    GOSSIP_ICON_TRAINER,    false,"Confirm talents reset ?"},
        {FUNC, "Maximize Weapon Skills",  Stone.WSkillsToMax,    GOSSIP_ICON_TRAINER,    false,"Confirm maximize weapon skills ?"},
        {FUNC, "Repair all equipment",    Stone.RepairAll,    GOSSIP_ICON_VENDOR,        false,"Require gold to repair equipment ?"},
        -- {FUNC, "Change name",            Stone.ResetName,    GOSSIP_ICON_CHAT,        false,"Change character name?\n|cFFFFFF00Requires re-login to take effect.|r"},
        -- {FUNC, "Change appearance",      Stone.ResetFace,    GOSSIP_ICON_CHAT,        false,"Change character appearance?\n|cFFFFFF00Requires re-login to take effect.|r"},
        -- {FUNC, "Change race",            Stone.ResetRace,    GOSSIP_ICON_CHAT,        false,"Change character race?\n|cFFFFFF00Requires re-login to take effect.|r"},
        -- {FUNC, "Change faction",         Stone.ResetFaction,    GOSSIP_ICON_CHAT,        false,"Change character faction?\n|cFFFFFF00Requires re-login to take effect.|r"},
        {FUNC, "Forget all spells",       Stone.ResetSpell,    GOSSIP_ICON_CHAT,        false,"Forget all spells?\n|cFFFFFF00Requires re-login to take effect.|r"},
    },
    [GMMENU]={--GM Menu
        {FUNC, "Reset all cooldowns",    Stone.ResetAllCD,        GOSSIP_ICON_INTERACT_1,    false,"Confirm reset all cooldowns ?"},
        {FUNC, "Save character",         Stone.SaveToDB,            GOSSIP_ICON_INTERACT_1},
        {FUNC, "Return to character selection",     Stone.Logout,            GOSSIP_ICON_INTERACT_1,    false,"Return to character selection screen ?"},
        {FUNC, "|cFF800000Do not save character|r",Stone.LogoutNosave,GOSSIP_ICON_INTERACT_1,false,"|cFFFF0000Do not save character and return to character selection screen ?|r"},
    },
    [TPMENU] = { -- Teleport Menu
        {MENU, "|cFF006400[City]|r Main cities",            TPMENU+0x10, GOSSIP_ICON_BATTLE},
        {MENU, "|cFF006400[Starting zone]|r Race starting zone",          TPMENU+0x20, GOSSIP_ICON_BATTLE},
        {MENU, "|cFF0000FF[Wild]|r Eastern Kingdoms",            TPMENU+0x30, GOSSIP_ICON_BATTLE},
        {MENU, "|cFF0000FF[Wild]|r Kalimdor",            TPMENU+0x40, GOSSIP_ICON_BATTLE},
        {MENU, "|cFF0000FF[Wild]|r |cFF006400Outland|r",    TPMENU+0x50, GOSSIP_ICON_BATTLE},
        {MENU, "|cFF0000FF[Wild]|r |cFF4B0082Northrend|r",  TPMENU+0x60, GOSSIP_ICON_BATTLE},
        {MENU, "|cFF006400【5-man】Classic world dungeons|r    ★☆☆☆☆",    TPMENU+0x70, GOSSIP_ICON_BATTLE},
        {MENU, "|cFF0000FF【5-man】Burning Crusade dungeons|r    ★★☆☆☆",    TPMENU+0x80, GOSSIP_ICON_BATTLE},
        {MENU, "|cFF4B0082【5-man】Wrath of the Lich King dungeons|r    ★★★☆☆",    TPMENU+0x90, GOSSIP_ICON_BATTLE},
        {MENU, "|cFFB22222【10-man-40-man】Raid dungeons|r  ★★★★★",      TPMENU+0xa0, GOSSIP_ICON_BATTLE},
        {MENU, "Scenic teleport",            TPMENU+0xb0, GOSSIP_ICON_BATTLE},
        {MENU, "Arena teleport",          TPMENU+0xc0, GOSSIP_ICON_BATTLE},
        {MENU, "World Boss teleport",        TPMENU+0xd0, GOSSIP_ICON_BATTLE},
        {MENU, "Arena teleport",          TPMENU+0xe0, GOSSIP_ICON_BATTLE},
    },
    [TPMENU+0x10]={--主要城市
        {TP, "Stormwind City", 0, -8842.09, 626.358, 94.0867, 3.61363, TEAM_ALLIANCE},
        {TP, "Darnassus", 1, 9869.91, 2493.58, 1315.88, 2.78897, TEAM_ALLIANCE},
        {TP, "Ironforge", 0, -4900.47, -962.585, 501.455, 5.40538, TEAM_ALLIANCE},
        {TP, "Exodar", 530, -3864.92, -11643.7, -137.644, 5.50862, TEAM_ALLIANCE},
        {TP, "Orgrimmar", 1, 1601.08, -4378.69, 9.9846, 2.14362, TEAM_HORDE},
        {TP, "Thunder Bluff", 1, -1274.45, 71.8601, 128.159, 2.80623, TEAM_HORDE},
        {TP, "Undercity", 0, 1633.75, 240.167, -43.1034, 6.26128, TEAM_HORDE},
        {TP, "Silvermoon City", 530, 9738.28, -7454.19, 13.5605, 0.043914, TEAM_HORDE},
        {TP, "[Northrend] Dalaran", 571, 5809.55, 503.975, 657.526, 2.38338},
        {TP, "[Outland] Shattrath", 530, -1887.62, 5359.09, -12.4279, 4.40435},
        {TP, "[Neutral] Booty Bay", 0, -14281.9, 552.564, 8.90422, 0.860144},
        {TP, "[Neutral] Ratchet", 1, -955.21875, -3678.92, 8.29946, 0},
        {TP, "[Neutral] Gadgetzan", 1, -7122.79834, -3704.82, 14.0526, 0},
    },
    [TPMENU+0x20]={--各种族 starting zone
        {TP, "Human starting zone", 0, -8949.95, -132.493, 83.5312, 0, TEAM_ALLIANCE},
        {TP, "Dwarf starting zone", 0, -6240.32, 331.033, 382.758, 6.1, TEAM_ALLIANCE},
        {TP, "Gnome starting zone", 0, -6240, 331, 383, 0, TEAM_ALLIANCE},
        {TP, "Night Elf starting zone", 1, 10311.3, 832.463, 1326.41, 5.6, TEAM_ALLIANCE},
        {TP, "Draenei starting zone", 530, -3961.64, -13931.2, 100.615, 2, TEAM_ALLIANCE},
        {TP, "Orc starting zone", 1, -618.518, -4251.67, 38.718, 0, TEAM_HORDE},
        {TP, "Troll starting zone", 1, -618.518, -4251.67, 38.7, 4.747, TEAM_HORDE},
        {TP, "Tauren starting zone", 1, -2917.58, -257.98, 52.9968, 0, TEAM_HORDE},
        {TP, "Undead starting zone", 0, 1676.71, 1678.31, 121.67, 2.70526, TEAM_HORDE},
        {TP, "Blood Elf starting zone", 530, 10349.6, -6357.29, 33.4026, 5.31605, TEAM_HORDE},
        {TP, "|cFF006400Death Knight starting zone|r", 609, 2355.84, -5664.77, 426.028, 3.65997, TEAM_NONE, 55, 0},
    },
    [TPMENU+0x30]={--Eastern Kingdoms
        {TP, "Elwynn Forest", 0, -9449.06, 64.8392, 56.3581, 3.0704},
        {TP, "Teldrassil", 530, 9024.37, -6682.55, 16.8973, 3.1413},
        {TP, "Dun Morogh", 0, -5603.76, -482.704, 396.98, 5.2349},
        {TP, "Tirisfal Glades", 0, 2274.95, 323.918, 34.1137, 4.2436},
        {TP, "Ghostlands", 530, 7595.73, -6819.6, 84.3718, 2.5656},
        {TP, "Loch Modan", 0, -5405.85, -2894.15, 341.972, 5.4823},
        {TP, "Silverpine Forest", 0, 505.126, 1504.63, 124.808, 1.7798},
        {TP, "Westfall", 0, -10684.9, 1033.63, 32.5389, 6.0738},
        {TP, "Redridge Mountains", 0, -9447.8, -2270.85, 71.8224, 0.28385},
        {TP, "Duskwood", 0, -10531.7, -1281.91, 38.8647, 1.5695},
        {TP, "Hillsbrad Foothills", 0, -385.805, -787.954, 54.6655, 1.0392},
        {TP, "Wetlands", 0, -3517.75, -913.401, 8.86625, 2.6070},
        {TP, "Alterac Mountains", 0, 275.049, -652.044, 130.296, 0.50203},
        {MENU, "Next Page", TPMENU+0x120, GOSSIP_ICON_CHAT},
    },
    [TPMENU+0x120]={--Eastern Kingdoms 2
        {TP, "Arathi Highlands", 0, -1581.45, -2704.06, 35.4168, 0.490373},
        {TP, "Stranglethorn Vale", 0, -11921.7, -59.544, 39.7262, 3.7357},
        {TP, "Desolace", 0, -6782.56, -3128.14, 240.48, 5.6591},
        {TP, "Swamp of Sorrows", 0, -10368.6, -2731.3, 21.6537, 5.2923},
	{TP, "The Hinterlands", 0,  112.406, -3929.74, 136.358, 0.981903},
        {TP, "Searing Gorge", 0, -6686.33, -1198.55, 240.027, 0.91688},
        {TP, "Blasted Lands", 0, -11184.7, -3019.31, 7.29238, 3.20542},
        {TP, "Burning Steppes", 0, -7979.78, -2105.72, 127.919, 5.10148},
        {TP, "Western Plaguelands", 0, 1743.69, -1723.86, 59.6648, 5.23722},
        {TP, "Eastern Plaguelands", 0, 2280.64, -5275.05, 82.0166, 4.747},
        {TP, "Isle of Quel'Danas", 530, 12806.5, -6911.11, 41.1156, 2.2293},
    },
    [TPMENU+0x40]={--Kalimdor
        {TP, "Azuremyst Isle", 530, -4192.62, -12576.7, 36.7598, 1.62813},
        {TP, "Bloodmyst Isle", 530, -2721.67, -12208.90, 9.08, 0},
        {TP, "Darnassus", 1, 9889.03, 915.869, 1307.43, 1.9336},
        {TP, "Durotar", 1, 228.978, -4741.87, 10.1027, 0.416883},
        {TP, "Mulgore", 1, -2473.87, -501.225, -9.42465, 0.6525},
        {TP, "Bloodmyst Isle", 530, -2095.7, -11841.1, 51.1557, 6.19288},
        {TP, "Darkshore", 1, 6463.25, 683.986, 8.92792, 4.33534},
        {TP, "Barrens", 1, -575.772, -2652.45, 95.6384, 0.006469},
        {TP, "Stonetalon Mountains", 1, 1574.89, 1031.57, 137.442, 3.8013},
        {TP, "Ashenvale", 1, 1919.77, -2169.68, 94.6729, 6.14177},
        {TP, "Thousand Needles", 1, -5375.53, -2509.2, -40.432, 2.41885},
        {TP, "Desolace", 1, -656.056, 1510.12, 88.3746, 3.29553},
        {TP, "Dustwallow Marsh", 1, -3350.12, -3064.85, 33.0364, 5.12666},
        {TP, "Feralas", 1, -4808.31, 1040.51, 103.769, 2.90655},
        {TP, "Tanaris Desert", 1, -6940.91, -3725.7, 48.9381, 3.11174},
        {TP, "Azshara", 1, 3117.12, -4387.97, 91.9059, 5.49897},
        {TP, "Felwood", 1, 3898.8, -1283.33, 220.519, 6.24307},
        {TP, "Un'Goro Crater", 1, -6291.55, -1158.62, -258.138, 0.457099},
        {TP, "Silithus", 1, -6815.25, 730.015, 40.9483, 2.39066},
        {TP, "Winterspring", 1, 6658.57, -4553.48, 718.019, 5.18088},
    },
    [TPMENU+0x50]={--Outland
        {TP, "Hellfire Peninsula", 530, -207.335, 2035.92, 96.464, 1.59676},
        {TP, "Hellfire Peninsula - Honor Hold", 530, -683.05, 2657.57, 91.04, 0, TEAM_ALLIANCE},
        {TP, "Hellfire Peninsula - Thrallmar", 530, 139.96, 2671.51, 85.509, 0, TEAM_HORDE},
        {TP, "Zangarmarsh", 530, -220.297, 5378.58, 23.3223, 1.61718},
        {TP, "Terokkar Forest", 530, -2266.23, 4244.73, 1.47728, 3.68426},
        {TP, "Nagrand", 530, -1610.85, 7733.62, -17.2773, 1.33522},
        {TP, "Blade's Edge Mountains", 530, 2029.75, 6232.07, 133.495, 1.30395},
        {TP, "Netherstorm", 530, 3271.2, 3811.61, 143.153, 3.44101},
        {TP, "Shadowmoon Valley", 530, -3681.01, 2350.76, 76.587, 4.25995},
    },
    [TPMENU+0x60]={--Northrend
        {TP, "Borean Tundra", 571, 2954.24, 5379.13, 60.4538, 2.55544},
        {TP, "Howling Fjord", 571, 682.848, -3978.3, 230.161, 1.54207},
        {TP, "Dragonblight", 571, 2678.17, 891.826, 4.37494, 0.101121},
        {TP, "Grizzly Hills", 571, 4017.35, -3403.85, 290, 5.35431},
        {TP, "Zul'Drak", 571, 5560.23, -3211.66, 371.709, 5.55055},
        {TP, "Sholazar Basin", 571, 5614.67, 5818.86, -69.722, 3.60807},
        {TP, "Crystalsong Forest", 571, 5411.17, -966.37, 167.082, 1.57167},
        {TP, "Storm Peaks", 571, 6120.46, -1013.89, 408.39, 5.12322},
        {TP, "Icecrown Glacier", 571, 8323.28, 2763.5, 655.093, 2.87223},
        {TP, "Wintergrasp", 571, 4522.23, 2828.01, 389.975, 0.215009},
    },
    [TPMENU+0x70]={--Classic Dungeons
        {TP, "Gnomeregan", 0, -5163.54, 925.423, 257.181, 1.57423},
        {TP, "The Deadmines", 0, -11209.6, 1666.54, 24.6974, 1.42053},
        {TP, "Stormwind Stockade", 0, -8799.15, 832.718, 97.6348, 6.04085, TEAM_ALLIANCE},
        {TP, "Ragefire Chasm", 1, 1811.78, -4410.5, -18.4704, 5.20165, TEAM_HORDE},
        {TP, "Razorfen Downs", 1, -4657.3, -2519.35, 81.0529, 4.54808},
        {TP, "Razorfen Kraul", 1, -4470.28, -1677.77, 81.3925, 1.16302},
        {TP, "Scarlet Monastery", 0, 2873.15, -764.523, 160.332, 5.10447},
        {TP, "Shadowfang Keep", 0, -234.675, 1561.63, 76.8921, 1.24031},
        {TP, "Wailing Caverns", 1, -731.607, -2218.39, 17.0281, 2.78486},
        {TP, "Blackfathom Deeps", 1, 4249.99, 740.102, -25.671, 1.34062},
        {TP, "Blackrock Depths", 0, -7179.34, -921.212, 165.821, 5.09599},
        {TP, "Blackrock Spire", 0, -7527.05, -1226.77, 285.732, 5.29626},
        {TP, "Dire Maul", 1, -3520.14, 1119.38, 161.025, 4.70454},
        {TP, "Maraudon", 1, -1421.42, 2907.83, 137.415, 1.70718},
        {TP, "Scholomance", 0, 1269.64, -2556.21, 93.6088, 0.620623},
        {TP, "Stratholme", 0, 3352.92, -3379.03, 144.782, 6.25978},
        {TP, "The Temple of Atal'Hakkar", 0, -10177.9, -3994.9, -111.239, 6.01885},
        {TP, "Uldaman", 0, -6071.37, -2955.16, 209.782, 0.015708},
        {TP, "Zul'Farrak", 1, -6801.19, -2893.02, 9.00388, 0.158639},
    },
    [TPMENU+0x80]={--Burning Crusade Dungeons
        {TP, "Auchindoun", 530, -3324.49, 4943.45, -101.239, 4.63901},
        {TP, "Caverns of Time", 1, -8369.65, -4253.11, -204.272, -2.70526},
        {TP, "Coilfang Reservoir", 530, 738.865, 6865.77, -69.4659, 6.27655},
        {TP, "Hellfire Citadel", 530, -347.29, 3089.82, 21.394, 5.68114},
        {TP, "Magisters' Terrace", 530, 12884.6, -7317.69, 65.5023, 4.799},
        {TP, "The Eye (Tempest Keep)", 530, 3100.48, 1536.49, 190.3, 4.62226},
    },
    [TPMENU+0x90]={--Wrath of the Lich King Dungeons
        {TP, "Azjol-Nerub", 571, 3707.86, 2150.23, 36.76, 3.22},
        {TP, "The Culling of Stratholme", 1, -8756.39, -4440.68, -199.489, 4.66289},
        {TP, "Trial of the Champion", 571, 8590.95, 791.792, 558.235, 3.13127},
        {TP, "The Forge of Souls", 571, 4765.59, -2038.24, 229.363, 0.887627},
        {TP, "Gundrak", 571, 6722.44, -4640.67, 450.632, 3.91123},
        {TP, "Icecrown Citadel", 571, 5643.16, 2028.81, 798.274, 4.60242},
        {TP, "The Nexus", 571, 3782.89, 6965.23, 105.088, 6.14194},
        {TP, "Violet Hold", 571, 5693.08, 502.588, 652.672, 4.0229},
        {TP, "Halls of Lightning", 571, 9136.52, -1311.81, 1066.29, 5.19113},
        {TP, "Halls of Stone", 571, 8922.12, -1009.16, 1039.56, 1.57044},
        {TP, "Utgarde Keep", 571, 1203.41, -4868.59, 41.2486, 0.283237},
        {TP, "Utgarde Pinnacle", 571, 1267.24, -4857.3, 215.764, 3.22768},
    },
    [TPMENU+0xa0]={--Raid Dungeons
        {TP, "The Black Temple", 530, -3649.92, 317.469, 35.2827, 2.94285},
        {TP, "Blackwing Lair", 229, 152.451, -474.881, 116.84, 0.001073},
        {TP, "Mount Hyjal Summit", 1, -8177.89, -4181.23, -167.552, 0.913338},
        {TP, "Serpentshrine Cavern", 530, 797.855, 6865.77, -65.4165, 0.005938},
        {TP, "Trial of the Crusader", 571, 8515.61, 714.153, 558.248, 1.57753},
        {TP, "Gruul's Lair", 530, 3530.06, 5104.08, 3.50861, 5.51117},
        {TP, "Magtheridon's Lair", 530, -336.411, 3130.46, -102.928, 5.20322},
        {TP, "Icecrown Citadel", 571, 5855.22, 2102.03, 635.991, 3.57899},
        {TP, "Karazhan", 0, -11118.9, -2010.33, 47.0819, 0.649895},
        {TP, "Molten Core", 230, 1126.64, -459.94, -102.535, 3.46095},
        {TP, "Naxxramas", 571, 3668.72, -1262.46, 243.622, 4.785},
        {TP, "Onyxia's Lair", 1, -4708.27, -3727.64, 54.5589, 3.72786},
        {TP, "Ahn'Qiraj Ruins", 1, -8409.82, 1499.06, 27.7179, 2.51868},
        {MENU, "Next Page", TPMENU+0x190, GOSSIP_ICON_BATTLE},
    },
    [TPMENU+0x190]={--Team Dungeons 2
        {TP, "Sunwell Plateau", 530, 12574.1, -6774.81, 15.0904, 3.13788},
        {TP, "The Eye",  530, 3088.49, 1381.57, 184.863, 4.61973},
        {TP, "Temple of Ahn'Qiraj", 1, -8240.09, 1991.32, 129.072, 0.941603},
        {TP, "The Oculus", 571, 3784.17, 7028.84, 161.258, 5.79993},
        {TP, "Black Temple", 571, 3472.43, 264.923, -120.146, 3.27923},
        {TP, "Ulduar", 571, 9222.88, -1113.59, 1216.12, 6.27549},
        {TP, "Vault of Archavon", 571, 5453.72, 2840.79, 421.28, 0},
        {TP, "Zul'Gurub", 0, -11916.7, -1215.72, 92.289, 4.72454},
        {TP, "Zul'Aman", 530, 6851.78, -7972.57, 179.242, 4.64691},
    },
    [TPMENU+0xb0]={--Scenic Transports
        {TP, "GM Island", 1, 16222.1, 16252.1, 12.5872, 0},
        {TP, "Caverns of Time", 1, -8173.93018, -4737.46387, 33.77735, 0},
        {TP, "Twin Peaks", 1, -3331.35327, 2225.72827, 30.9877, 0},
        {TP, "Dreamgrove", 1, -2914.7561, 1902.19934, 34.74103, 0},
        {TP, "Dreadscar Rift", 1, 4603.94678, -3879.25097, 944.18347, 0},
        {TP, "End of the World Beach", 1, -9851.61719, -3608.47412, 8.93973, 0},
        {TP, "Uldaman Crater", 1, -8562.09668, -2106.05664, 8.85254, 0},
        {TP, "Stone Cairn Lake", 0, -9481.49316, -3326.91528, 8.86435, 0},
        {TP, "Blizzard Barrier", 1, 5478.06006, -3730.8501, 1593.44, 0},
    },
    [TPMENU+0xc0]={--Arena Teleports
        {TP, "Gurubashi Arena", 0, -13181.8, 339.356, 42.9805, 1.18013},
        --Alliance
        {TP, "Warsong Gulch", 0, 1036.794800, -2106.138672, 122.94553, 0, TEAM_ALLIANCE},
        {TP, "Arathi Basin", 0, -1229.860352, -2545.07959, 21.180079, 0, TEAM_ALLIANCE},
        --Horde
        {TP, "Arathi Basin", 0, -847.953491, -3519.764893, 72.607727, 0, TEAM_HORDE},
        {TP, "Warsong Gulch", 0, 396.471863, -1006.229126, 111.719086, 0, TEAM_HORDE},
        {TP, "Alterac Valley", 1, 5.599396, -308.73822, 132.26651, 0, TEAM_HORDE},
    },
    [TPMENU+0xd0]={--Outdoor Boss Teleports
        {TP, "Duskwood", 0, -10526.16895, -434.996796, 50.8948, 0},
        {TP, "Stranglethorn Vale", 0, 759.605713, -3893.341309, 116.4753, 0},
        {TP, "Ashenvale", 1, 3120.289307, -3439.444336, 139.5663, 0},
        {TP, "Azshara", 1, 2622.219971, -5977.930176, 100.5629, 0},
        {TP, "Feralas", 1, -2741.290039, 2009.481323, 31.8773, 0},
        {TP, "Blasted Lands", 0, -12234, -2474, -3, 0},
        {TP, "Silithus", 1, -6292.463379, 1578.029053, 0.1553, 0},
    },
    [MMENU+0x20]={--联盟职业技能 trainer
        --Alliance
        {TP, "Warrior trainer",     0, -8682.700195, 322.091125, 109.437958,    0, TEAM_ALLIANCE},
        {TP, "Paladin trainer",     0, -8573.793945, 877.343018, 106.519310,    0, TEAM_ALLIANCE},
        {TP, "Death Knight trainer",     0, 2365.21, -5658.35, 426.06,        0, TEAM_ALLIANCE},
        {TP, "Shaman trainer",     0, -9032.573242, 545.842590, 72.160950,    0, TEAM_ALLIANCE},
        {TP, "Hunter trainer",     0, -8422.097656, 550.078674, 95.448730,    0, TEAM_ALLIANCE},
        {TP, "Druid trainer",    1, 7870.23, -2586.97, 486.95,            0, TEAM_ALLIANCE},
        {TP, "Rogue trainer",     0, -8751.876953, 381.321930, 101.056236,    0, TEAM_ALLIANCE},
        {TP, "Mage trainer",    0, -9009.386719, 875.746765, 29.621387,    0, TEAM_ALLIANCE},
        {TP, "Warlock trainer",     0, -8972.834961, 1027.723511, 101.40416,    0, TEAM_ALLIANCE},
        {TP, "Priest trainer",     0, -8517.649414, 858.083801, 109.81385,     0, TEAM_ALLIANCE},
        --Horde
        {TP, "Warrior trainer",    1, 1971.24, -4805.08, 56.99,    0, TEAM_HORDE},
        {TP, "Paladin trainer",1, 1936.14, -4138.31, 41.03,0, TEAM_HORDE},
        {TP, "Death Knight trainer",0, 2365.21, -5658.35, 426.06,    0, TEAM_HORDE},
        {TP, "Shaman trainer",    1, 1928.482, -4228.17, 42.3219,    0, TEAM_HORDE},
        {TP, "Hunter trainer",    1, 2135.33, -4610.78, 54.3865,    0, TEAM_HORDE},
        {TP, "Druid trainer",    1, 7870.23, -2586.97, 486.95,0, TEAM_HORDE},
        {TP, "Rogue trainer",    1, 1776.47, -4285.65, 7.44,        0, TEAM_HORDE},
        {TP, "Mage trainer",    1, 1468.58, -4221.86, 59.22,    0, TEAM_HORDE},
        {TP, "Warlock trainer",    1, 1838.19, -4355.78, -14.71,    0, TEAM_HORDE},
        {TP, "Priest trainer",    1, 1454.71, -4179.42, 61.56,     0, TEAM_HORDE},
    },
    [MMENU+0x30]={--专业技能 trainer
        --Alliance
        {TP, "Weapon trainer",     0, -8793.120117, 613.002991, 96.856400,    0, TEAM_ALLIANCE},
        {TP, "Riding trainer",     0, -9443.556641, -1388.178345, 46.9881,    0, TEAM_ALLIANCE},
        {TP, "Flying trainer",     530, -676.925598, 2730.669434, 93.9085,    0, TEAM_ALLIANCE},
        --Horde
        {TP, "Weapon trainer",    1, 2093.829346, -4821.349609, 24.382,    0, TEAM_HORDE},
        {TP, "Riding trainer",    530, 9268.768555, -7508.026367, 38.09,    0, TEAM_HORDE},
        {TP, "Flying trainer",     530, 48.719337, 2741.370850, 85.255180,    0, TEAM_HORDE},
    },
    [ENCMENU] = { -- Enchanter Enchantments
        {MENU, "Helmet",         ENCMENU + 0x20, GOSSIP_ICON_TABARD},
        {MENU, "Shoulders",      ENCMENU + 0x30, GOSSIP_ICON_TABARD},
        {MENU, "Chest",          ENCMENU + 0x40, GOSSIP_ICON_TABARD},
        {MENU, "Shirt",          ENCMENU + 0x10, GOSSIP_ICON_TABARD},
        {MENU, "Waist",          ENCMENU + 0xf0, GOSSIP_ICON_TABARD},
        {MENU, "Legs",           ENCMENU + 0x50, GOSSIP_ICON_TABARD},
        {MENU, "Feet",           ENCMENU + 0x60, GOSSIP_ICON_TABARD},
        {MENU, "Bracers",        ENCMENU + 0x70, GOSSIP_ICON_TABARD},
        {MENU, "Gloves",         ENCMENU + 0x80, GOSSIP_ICON_TABARD},
        {MENU, "Cloak",          ENCMENU + 0x90, GOSSIP_ICON_TABARD},
        {MENU, "Main Hand",      ENCMENU + 0xa0, GOSSIP_ICON_TABARD},
        {MENU, "Off Hand",       ENCMENU + 0xb0, GOSSIP_ICON_TABARD},
        {MENU, "Two-Handed",     ENCMENU + 0xc0, GOSSIP_ICON_TABARD},
        {MENU, "Shield",         ENCMENU + 0xd0, GOSSIP_ICON_TABARD},
        {MENU, "Bow/Crossbow",   ENCMENU + 0xe0, GOSSIP_ICON_TABARD},
    },
    [ENCMENU + 0x10] = { -- Shirt
        {ENC, "Removed Chest enchantment", -1, EQUIPMENT_SLOT_BODY},
        {ENC, "Increase All Stats", 3832, EQUIPMENT_SLOT_BODY},
        {ENC, "Increase Health", 3297, EQUIPMENT_SLOT_BODY},
        {ENC, "Mana Regeneration", 2381, EQUIPMENT_SLOT_BODY},
        {ENC, "Resilience Level", 3245, EQUIPMENT_SLOT_BODY},
        {ENC, "Defense Level", 1953, EQUIPMENT_SLOT_BODY},
        {ENC, "Increase Agility", 1099, EQUIPMENT_SLOT_BODY},
        {ENC, "Attack Power", 3845, EQUIPMENT_SLOT_BODY},
    },
    [ENCMENU + 0x20] = { -- Head
        {ENC, "Removed Helmet enchantment", -1, EQUIPMENT_SLOT_HEAD},
        {ENC, "Increase All Stats", 3832, EQUIPMENT_SLOT_HEAD},
        {ENC, "Spell Power, Critical Strike Level 80", 3820, EQUIPMENT_SLOT_HEAD},
        {ENC, "Spell Power, Mana Regeneration Level 80", 3819, EQUIPMENT_SLOT_HEAD},
        {ENC, "Stamina Increase, Defense Level 80", 3818, EQUIPMENT_SLOT_HEAD},
        {ENC, "Attack Power, Critical Strike Level 80", 3817, EQUIPMENT_SLOT_HEAD},
        {ENC, "Stamina Increase, Versatility Level 80", 3842, EQUIPMENT_SLOT_HEAD},
        {ENC, "Attack Power, Versatility Level 80", 3795, EQUIPMENT_SLOT_HEAD},
        {ENC, "Spell Power, Versatility Level 80", 3797, EQUIPMENT_SLOT_HEAD},
    },
    [ENCMENU + 0x30] = { -- Shoulders
        {ENC, "Removed Shoulder enchantment", -1, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Increase All Stats", 3832, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Attack Power, Versatility Level 80", 3793, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Attack Power", 3845, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Spell Power, Versatility Level 80", 3794, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Stamina Increase, Versatility Level 80", 3852, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Attack Power, Critical Strike Level 80", 3808, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Spell Power, Mana Regeneration Level 80", 3809, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Dodge Level, Defense Level 80", 3811, EQUIPMENT_SLOT_SHOULDERS},
        {ENC, "Spell Power, Critical Strike Level 80", 3810, EQUIPMENT_SLOT_SHOULDERS},
    },
    [ENCMENU + 0x40] = { -- Chest Armor
        {ENC, "Removed Chest enchantment", -1, EQUIPMENT_SLOT_CHEST},
        {ENC, "Increase All Stats", 3832, EQUIPMENT_SLOT_CHEST},
        {ENC, "Increase Health", 3297, EQUIPMENT_SLOT_CHEST},
        {ENC, "Mana Regeneration", 2381, EQUIPMENT_SLOT_CHEST},
        {ENC, "Versatility Level", 3245, EQUIPMENT_SLOT_CHEST},
        {ENC, "Defense Level", 1953, EQUIPMENT_SLOT_CHEST},
    },
    [ENCMENU + 0xf0] = { -- Waist
        {ENC, "Removed Waist enchantment", -1, EQUIPMENT_SLOT_WAIST},
        {ENC, "Increase All Stats", 3832, EQUIPMENT_SLOT_WAIST},
        {ENC, "Increase Health", 3297, EQUIPMENT_SLOT_WAIST},
        {ENC, "Mana Regeneration", 2381, EQUIPMENT_SLOT_WAIST},
        {ENC, "Versatility Level", 3245, EQUIPMENT_SLOT_WAIST},
        {ENC, "Defense Level", 1953, EQUIPMENT_SLOT_WAIST},
    },
    [ENCMENU + 0x50] = { -- Legs
        {ENC, "Removed Leg enchantment", -1, EQUIPMENT_SLOT_LEGS},
        {ENC, "Increase Spirit, Spell Power [70]", 3719, EQUIPMENT_SLOT_LEGS},
        {ENC, "Increase Stamina, Spell Power [70]", 3721, EQUIPMENT_SLOT_LEGS},
        {ENC, "Increase Stamina, Versatility Level [80]", 3853, EQUIPMENT_SLOT_LEGS},
        {ENC, "Increase Stamina, Agility [80]", 3822, EQUIPMENT_SLOT_LEGS},
        {ENC, "Increase Attack Power, Critical Strike Level [80]", 3823, EQUIPMENT_SLOT_LEGS},
        {ENC, "Spell Power", 2332, EQUIPMENT_SLOT_LEGS},
        {ENC, "Attack Power", 3845, EQUIPMENT_SLOT_LEGS},
        {ENC, "Increase All Stats", 3832, EQUIPMENT_SLOT_LEGS},
    },
    [ENCMENU + 0x60] = { -- Feet
        {ENC, "Removed Boot enchantment", -1, EQUIPMENT_SLOT_FEET},
        --{ENC, "Attack Power", 1597, EQUIPMENT_SLOT_FEET},
        {ENC, "Attack Power", 3845, EQUIPMENT_SLOT_FEET},
        {ENC, "Increase Stamina, Movement Speed", 3232, EQUIPMENT_SLOT_FEET},
        {ENC, "Increase Agility", 983, EQUIPMENT_SLOT_FEET},
        {ENC, "Increase Spirit", 1147, EQUIPMENT_SLOT_FEET},
        {ENC, "Increase Health, Health Regeneration", 3244, EQUIPMENT_SLOT_FEET},
        {ENC, "Hit Rating, Critical Strike Rating", 3826, EQUIPMENT_SLOT_FEET},
        {ENC, "Increase Stamina", 1075, EQUIPMENT_SLOT_FEET},
    },
    [ENCMENU + 0x70] = { -- Wrists
        {ENC, "Removed Wrist enchantment", -1, EQUIPMENT_SLOT_WRISTS},
        {ENC, "Increase Stamina", 3850, EQUIPMENT_SLOT_WRISTS},
        {ENC, "Spell Power", 2332, EQUIPMENT_SLOT_WRISTS},
        {ENC, "Attack Power", 3845, EQUIPMENT_SLOT_WRISTS},
        {ENC, "Increase Spirit", 1147, EQUIPMENT_SLOT_WRISTS},
        {ENC, "Expertise Rating", 3231, EQUIPMENT_SLOT_WRISTS},
        --{ENC, "Increase All Stats 1", 2661, EQUIPMENT_SLOT_WRISTS},
        {ENC, "Increase All Stats", 3832, EQUIPMENT_SLOT_WRISTS},
        {ENC, "Increase Intellect", 1119, EQUIPMENT_SLOT_WRISTS},
    },
    [ENCMENU + 0x80] = { -- Hands
        {ENC, "Removed enchantment", -1, EQUIPMENT_SLOT_HANDS},
        {ENC, "Critical Strike Rating", 3249, EQUIPMENT_SLOT_HANDS},
        {ENC, "Increase Threat, Parry Rating", 3253, EQUIPMENT_SLOT_HANDS},
        --{ENC, "Attack Power", 1603, EQUIPMENT_SLOT_HANDS},
        {ENC, "Attack Power", 3845, EQUIPMENT_SLOT_HANDS},
        {ENC, "Increase Agility", 3222, EQUIPMENT_SLOT_HANDS},
        {ENC, "Hit Rating", 3234, EQUIPMENT_SLOT_HANDS},
        {ENC, "Expertise Rating", 3231, EQUIPMENT_SLOT_HANDS},
        {ENC, "Spell Power", 3246, EQUIPMENT_SLOT_HANDS},
    },
    [ENCMENU + 0x90] = { -- Back
        {ENC, "Removed enchantment", -1, EQUIPMENT_SLOT_BACK},
        {ENC, "Enhance Stealth, Increase Agility", 3256, EQUIPMENT_SLOT_BACK},
        {ENC, "Increase Spirit, Reduce Threat", 3296, EQUIPMENT_SLOT_BACK},
        {ENC, "Defense Rating", 1951, EQUIPMENT_SLOT_BACK},
        {ENC, "Haste Rating", 3831, EQUIPMENT_SLOT_BACK},
        {ENC, "Increase Armor", 3294, EQUIPMENT_SLOT_BACK},
        {ENC, "Increase Agility", 1099, EQUIPMENT_SLOT_BACK},
        {ENC, "Arcane Resistance", 1262, EQUIPMENT_SLOT_BACK},
        {ENC, "Attack Power", 3845, EQUIPMENT_SLOT_BACK},
        {ENC, "Increase All Stats", 3832, EQUIPMENT_SLOT_BACK},
    },
    [ENCMENU + 0xa0] = { -- Main Hand
        {ENC, "Removed main hand weapon enchantment", -1, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Increase Stamina", 3851, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Hit Rating, Critical Strike Rating", 3788, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Berserking", 3789, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Black Magic", 3790, EQUIPMENT_SLOT_MAINHAND},
        --{ENC, "Spell Power", 3834, EQUIPMENT_SLOT_MAINHAND},
        --{ENC, "Attack Power", 3833, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Icy Weapon", 3239, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Healthguard", 3241, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Vampiric [75]", 3870, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Blade Ward [75]", 3869, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Increase Agility", 1103, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Increase Spirit", 3844, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Executioner", 3225, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Felstriker", 2673, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Attack Power", 3827, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Spell Power", 3854, EQUIPMENT_SLOT_MAINHAND},
    },
    [ENCMENU + 0xb0] = { -- Off-hand
        {ENC, "Removed off-hand weapon enchantment", -1, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Increase Stamina", 3851, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Hit Rating, Critical Strike Rating", 3788, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Berserking", 3789, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Black Magic", 3790, EQUIPMENT_SLOT_OFFHAND},
        --{ENC, "Spell Power", 3834, EQUIPMENT_SLOT_OFFHAND},
        --{ENC, "Attack Power", 3833, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Icy Weapon", 3239, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Healthguard", 3241, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Vampiric [75]", 3870, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Blade Ward [75]", 3869, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Increase Agility", 1103, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Increase Spirit", 3844, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Executioner", 3225, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Felstriker", 2673, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Attack Power", 3827, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Spell Power", 3854, EQUIPMENT_SLOT_OFFHAND},
    },
    [ENCMENU + 0xe0] = { -- Ranged
        {ENC, "Removed ranged weapon enchantment", -1, EQUIPMENT_SLOT_RANGED},
        {ENC, "Increase Stamina", 3851, EQUIPMENT_SLOT_RANGED},
        {ENC, "Hit Rating, Critical Strike Rating", 3788, EQUIPMENT_SLOT_RANGED},
        --{ENC, "Spell Power", 3834, EQUIPMENT_SLOT_RANGED},
        --{ENC, "Attack Power", 3833, EQUIPMENT_SLOT_RANGED},
        {ENC, "Healthguard", 3241, EQUIPMENT_SLOT_RANGED},
        {ENC, "Increase Agility", 1103, EQUIPMENT_SLOT_RANGED},
        {ENC, "Increase Spirit", 3844, EQUIPMENT_SLOT_RANGED},
        {ENC, "Attack Power", 3827, EQUIPMENT_SLOT_RANGED},
        {ENC, "Spell Power", 3854, EQUIPMENT_SLOT_RANGED},
    },
    [ENCMENU + 0xc0] = { -- Two-Handed
        {ENC, "Removed two-handed weapon enchantment", -1, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Increase Stamina", 3851, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Increase Agility", 1103, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Increase Spirit", 3844, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Hit Rating, Critical Strike Rating", 3788, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Fury", 3789, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Frost Weapon", 3239, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Healthguard", 3241, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Vampirism [75]", 3870, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Blade Ward [75]", 3869, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Executioner", 3225, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Mongoose", 2673, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Attack Power", 3827, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Undead Slaying", 3247, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Giant Slayer", 3251, EQUIPMENT_SLOT_MAINHAND},
        {ENC, "Spell Power", 3854, EQUIPMENT_SLOT_MAINHAND},
    },
    [ENCMENU + 0xd0] = { -- Shield
        {ENC, "Removed shield enchantment", -1, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Defense Rating", 1952, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Increase Intellect", 1128, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Shield Block", 2655, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Resilience Rating", 3229, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Increase Stamina", 1071, EQUIPMENT_SLOT_OFFHAND},
        {ENC, "Block Value", 2653, EQUIPMENT_SLOT_OFFHAND},
    },
}

local function Enchanting(player, EncSpell, Eid, money)-- enchantment (player, enchantment effect, enchantment position)
    local ID = Eid
    local Nowitem = player:GetEquippedItemBySlot(ID) -- Get the item equipped in the specified slot
    if Nowitem and Eid then
	-- If item exists in the specified slot
        -- local WType = Nowitem:GetSubClass() -- Item type (if needed)
        local WName = Nowitem:GetItemLink() -- Get the item's hyperlink

        for solt=0,1 do
            local espellid=Nowitem:GetEnchantmentId(solt)
            if(espellid and espellid>0)then
                Nowitem:ClearEnchantment(solt)
                if(EncSpell<=0)then
                    player:SendBroadcastMessage(WName.."Enchantment removed.("..espellid..")")
                elseif(solt < 1 )then
                    Nowitem:SetEnchantment(espellid, solt+1)
                    break
                end
            end
        end
        if(EncSpell>0)then
            Nowitem:SetEnchantment(EncSpell, 0)
            player:CastSpell(player, 36937)
            player:SendBroadcastMessage(WName.."Item enchanted.")
            player:SetHealth(player:GetMaxHealth())--Recover health
            return true
        end
    else
        player:SendNotification("Unable to find required item equipped on character.")
    end
    return false
end

function Stone.AddGossip(player, item, id)
    player:GossipClearMenu()--Clear Menu
    local Rows=Menu[id] or {}
    local Pteam=player:GetTeam()
    local teamStr,team="",player:GetTeam()
    if(team==TEAM_ALLIANCE)then
        teamStr    ="[|cFF0070d0Alliance|r]"
    elseif(team==TEAM_HORDE)then
        teamStr    ="[|cFFF000A0Horde|r]"
    end
    for k, v in pairs(Rows) do
        local mtype,text,icon,intid=v[1],( v[2] or "???" ), (v[4] or GOSSIP_ICON_CHAT), (id*0x100+k)
        if(mtype==MENU)then
            player:GossipMenuAddItem(icon, text, 0, (v[3] or id )*0x100)
        elseif(mtype==FUNC or mtype==ENC)then
            local code,msg,money=v[5],(v[6]or ""), (v[7] or 0)
            if(mtype==ENC)then
                icon=GOSSIP_ICON_TABARD
            end
            if((code==true or code ==false))then
                player:GossipMenuAddItem(icon, text, money, intid, code, msg, money)
            else
                player:GossipMenuAddItem(icon, text, 0, intid)
            end
        elseif(mtype==TP)then
            local mteam=v[8] or TEAM_NONE
            if(mteam==Pteam)then
                player:GossipMenuAddItem(GOSSIP_ICON_TAXI, teamStr..text, 0, intid, false,"Teleport to |cFFFFFF00"..text.."|r ?",0)
            elseif(mteam ==TEAM_NONE)then
                player:GossipMenuAddItem(GOSSIP_ICON_TAXI, text, 0, intid, false,"Teleport to |cFFFFFF00"..text.."|r ?",0)
            end
        else
            player:GossipMenuAddItem(icon, text, 0, intid)
        end
    end
    if(id > 0)then
		--Add a menu option to return to the previous page.
        local length=string.len(string.format("%x",id))
        if(length>1)then
            local temp=bit_and(id,2^((length-1)*4)-1)
            if(temp ~= MMENU)then
                player:GossipMenuAddItem(GOSSIP_ICON_CHAT,"上一页", 0,temp*0x100)
            end
        end
    end
    if(id ~= MMENU)then
		--Add a menu option to return to the main menu
        player:GossipMenuAddItem(GOSSIP_ICON_CHAT,"Main Menu", 0, MMENU*0x100)
    else
        if(player:GetGMRank()>=3)then --GM confirmation 
            player:GossipMenuAddItem(GOSSIP_ICON_CHAT,"GM Functions", 0, GMMENU*0x100)
        end
        player:GossipMenuAddItem(GOSSIP_ICON_CHAT, "Total online time:|cFF000080"..Stone.GetTimeASString(player).."|r", 0, MMENU*0x100)
    end

    player:GossipSendMenu(1, item)--Send Menu
end

local function CanUse(player)
    -- local map = player:GetMap()
    -- local isInInstance
    -- if map:isDungeon() or map:IsHeroic() or map:isRaid() then
    --     isInInstance = true
    -- end
    -- if not isInInstance and player:IsInCombat() then
    --     player:SendAreaTriggerMessage("战斗中不能使用")
    --     return false
    -- end
    return true
end

function Stone.ShowGossip(event, player, item)
    if not CanUse(player) then
        return false
    end
    -- player:MoveTo(0,player:GetX(),player:GetY(),player:GetZ()+0.01)--移动就停止当前施法
    Stone.AddGossip(player, item, MMENU)
    return false
end

local function Teleport(player, v, cost)
    -- player:StopSpellCast(SPELL_HEARTHSTONE)
    -- player:ResetSpellCooldown(SPELL_HEARTHSTONE, true)
    local map,mapid,x,y,z,o=v[2],v[3],v[4], v[5], v[6],v[7] or 0
    local pname=player:GetName()--得到玩家名
    if(player:Teleport(mapid,x,y,z,o,TELE_TO_GM_MODE))then --Teleport
        local Nplayer=GetPlayerByName(pname)-- Get the player based on the player's name.
        if(Nplayer)then
            Nplayer:SendBroadcastMessage("You have arrived "..map)
            if cost and cost > 0 then
                Nplayer:ModifyMoney(-cost) --pay cost 
            end
        end
    else
        print(">>Eluna Error: Teleport Stone : Teleport To "..mapid)
    end
end

function Stone.SelectGossip(event, player, item, sender, intid, code, menu_id)
    if not CanUse(player) then
        return false
    end
    local menuid=math.modf(intid/0x100)    --菜单组
    local rowid    =intid-menuid*0x100        --第几项
    if(rowid== 0)then
        Stone.AddGossip(player, item, menuid)
    else
        player:GossipComplete()    --关闭菜单
        local v=Menu[menuid] and Menu[menuid][rowid]
        if(v)then                        --如果找到菜单项
            local mtype=v[1] or MENU
            if(mtype==MENU)then
                Stone.AddGossip(player, item, (v[3] or MMENU))
            elseif(mtype==FUNC)then                    --功能
                local f=v[3]
                if(f)then
                    player:ModifyMoney(-sender)        --扣费
                    f(player, code)
                end
            elseif(mtype==ENC)then
                local spellId,equipId=v[3],v[4]
                Enchanting(player, spellId, equipId, 0)
                Stone.AddGossip(player, item, menuid)
            elseif(mtype==TP)then                    --传送
                -- local map,mapId,x,y,z,o=v[2],v[3],v[4], v[5], v[6],v[7] or 0
                -- local x,y,z,mapId,areaId=player:GetX(),player:GetY(),player:GetZ(),player:GetMapId(),player:GetAreaId()
                -- player:SetBindPoint(x,y,z,mapId,areaId)
                -- player:SendBroadcastMessage("已经设置当前位置为家")
                -- player:CastSpell(player, SPELL_HEARTHSTONE, false)--传送特效
                -- player:RegisterEvent(function(_, _, _, p)
                --     OnTeleportTimer(p, v, sender)
                -- end, 9900, 1)
                Teleport(player, v, sender)
            end
        end
    end
end

RegisterItemGossipEvent(itemEntry, 1, Stone.ShowGossip)
RegisterItemGossipEvent(itemEntry, 2, Stone.SelectGossip)
