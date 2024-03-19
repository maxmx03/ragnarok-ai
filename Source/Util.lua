require 'AI.USER_AI.Source.Const'

--------------------------------------------
-- List utility
--------------------------------------------
List = {}

function List.new()
  return { first = 0, last = -1 }
end

function List.pushleft(list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end

function List.pushright(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

function List.popleft(list)
  local first = list.first
  if first > list.last then
    return nil
  end
  local value = list[first]
  list[first] = nil -- to allow garbage collection
  list.first = first + 1
  return value
end

function List.popright(list)
  local last = list.last
  if list.first > last then
    return nil
  end
  local value = list[last]
  list[last] = nil
  list.last = last - 1
  return value
end

function List.clear(list)
  for i, v in ipairs(list) do
    list[i] = nil
  end
  --[[
	if List.size(list) == 0 then
		return
	end
	local first = list.first
	local last  = list.last
	for i=first, last do
		list[i] = nil
	end
--]]
  list.first = 0
  list.last = -1
end

function List.size(list)
  local size = list.last - list.first + 1
  return size
end

-------------------------------------------------

function GetDistance(x1, y1, x2, y2)
  return math.floor(math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2))
end

function GetDistance2(id1, id2)
  local x1, y1 = GetV(V_POSITION, id1)
  local x2, y2 = GetV(V_POSITION, id2)
  if x1 == -1 or x2 == -1 then
    return -1
  end
  return GetDistance(x1, y1, x2, y2)
end

function GetOwnerPosition(id)
  return GetV(V_POSITION, GetV(V_OWNER, id))
end

function GetDistanceFromOwner(id)
  local x1, y1 = GetOwnerPosition(id)
  local x2, y2 = GetV(V_POSITION, id)
  if x1 == -1 or x2 == -1 then
    return -1
  end
  return GetDistance(x1, y1, x2, y2)
end

function IsOutOfSight(id1, id2)
  local x1, y1 = GetV(V_POSITION, id1)
  local x2, y2 = GetV(V_POSITION, id2)
  if x1 == -1 or x2 == -1 then
    return true
  end
  local d = GetDistance(x1, y1, x2, y2)
  if d > 20 then
    return true
  else
    return false
  end
end

function IsInAttackSight(id1, id2)
  local x1, y1 = GetV(V_POSITION, id1)
  local x2, y2 = GetV(V_POSITION, id2)
  if x1 == -1 or x2 == -1 then
    return false
  end
  local d = GetDistance(x1, y1, x2, y2)
  local a = 0
  if MySkill == 0 then
    a = GetV(V_ATTACKRANGE, id1)
  else
    a = GetV(V_SKILLATTACKRANGE_LEVEL, id1, MySkill, MySkillLevel)
  end

  if a >= d then
    return true
  else
    return false
  end
end

---@param id number
local function getMaxHp(id)
  return GetV(V_MAXHP, id)
end

---@param id number
local function getHp(id)
  return GetV(V_HP, id)
end

---@param id number
local function getMaxSp(id)
  return GetV(V_MAXSP, id)
end

---@param id number
local function getSp(id)
  return GetV(V_SP, id)
end

---@param id number
---@param owner number
local function lif(id, owner)
  local skills = {
    HLIF_HEAL = 8001,
    HLIF_AVOID = 8002,
  }
  local ownerHp = getHp(owner)
  local ownerMinHp1 = getMaxHp(owner) - (ownerHp * 0.7)
  local ownerMinHp2 = getMaxHp(owner) - (ownerHp * 0.5)
  local level = 5

  if GetV(V_MOTION, owner) == MOTION_DAMAGE and ownerHp < ownerMinHp2 then
    SkillObject(id, level, skills.HLIF_AVOID, owner)
  elseif ownerHp < ownerMinHp1 then
    SkillObject(id, level, skills.HLIF_HEAL, owner)
  end
end

---@param id number
---@param owner number
local function amistr(id, owner)
  local skills = {
    HAMI_CASTLE = 8005,
    HAMI_DEFENCE = 8006,
  }
  local function myskill()
    local castle_count = 0
    local defence_count = 0
    return {
      castle = function(myid, level, target)
        if castle_count % 2 == 0 then
          SkillObject(myid, level, skills.HAMI_CASTLE, target)
        end
        castle_count = castle_count + 1
      end,
      defence = function(myid, level, target)
        if defence_count % 4 == 0 then
          SkillObject(myid, level, skills.HAMI_DEFENCE, target)
        end
        defence_count = defence_count + 1
      end,
    }
  end
  local ownerHp = getHp(owner)
  local ownerMinHp = getMaxHp(owner) - (ownerHp * 0.3)
  local level = 5
  local owner_motion = GetV(V_MOTION, owner)
  if ownerHp < ownerMinHp and owner_motion == MOTION_DAMAGE then
    myskill().castle(id, level, owner)
  elseif owner_motion == MOTION_DAMAGE then
    myskill().defence(id, level, owner)
  end
end

---@param id number
---@param owner number
local function filir(id, owner)
  local skills = {
    HFLI_FLEET = 8010,
    HFLI_SPEED = 8011,
  }
  local owner_motion = GetV(V_MOTION, owner)
  local level = 5
  if owner_motion == MOTION_ATTACK or owner_motion == MOTION_ATTACK2 then
    SkillObject(id, level, skills.HFLI_FLEET, owner)
  elseif owner_motion == MOTION_DAMAGE then
    SkillObject(id, level, skills.HFLI_SPEED, owner)
  end
end

---@param id number
---@param owner number
local function vanilmirth(id, owner)
  local skills = {
    HVAN_CHAOTIC = 8014,
  }
  local ownerHp = getHp(owner)
  local ownerMinHp = getMaxHp(owner) - (ownerHp * 0.7)
  local level = 5
  if ownerHp < ownerMinHp then
    SkillObject(id, level, skills.HVAN_CHAOTIC, owner)
  end
end

---@param id number
---@param owner number
local function eira(id, owner)
  local skills = {
    MH_LIGHT_OF_REGENE = 8022,
    MH_SILENT_BREEZE = 8026,
  }
  local ownerHp = getHp(owner)
  local ownerMinHp = getMaxHp(owner) - (ownerHp * 0.8)
  local owner_motion = GetV(V_MOTION, owner)
  local level = 5
  if ownerHp < ownerMinHp then
    SkillObject(id, level, skills.MH_SILENT_BREEZE, owner)
  elseif owner_motion == MOTION_DEAD then
    SkillObject(id, level, skills.MH_LIGHT_OF_REGENE, owner)
  end
end

---@param id number
---@param owner number
local function bayeri(id, owner)
  local skills = {
    MH_STEINWAND = 8033,
  }
  local ownerHp = getHp(owner)
  local ownerMinHp = getMaxHp(owner) - (ownerHp * 0.5)
  local owner_motion = GetV(V_MOTION, owner)
  local level = 5
  if (ownerHp < ownerMinHp) and owner_motion == MOTION_DAMAGE then
    MoveToOwner(owner)
    SkillObject(id, level, skills.MH_STEINWAND, owner)
  end
end

---@param id number
---@param owner number
local function sera(id, owner)
  local skills = {
    MH_PAIN_KILLER = 8021,
  }
  local ownerHp = getHp(owner)
  local ownerMinHp = getMaxHp(owner) - (ownerHp * 0.5)
  local owner_motion = GetV(V_MOTION, owner)
  local level = 5
  if (ownerHp < ownerMinHp) and owner_motion == MOTION_DAMAGE then
    MoveToOwner(owner)
    SkillObject(id, level, skills.MH_PAIN_KILLER, owner)
  end
end

---@param id number
---@param owner number
local function dieter(id, owner)
  local skills = {
    MH_GRANITIC_ARMOR = 8040,
    MH_VOLCANIC_ASH = 8043,
  }
  local ownerHp = getHp(owner)
  local ownerMinHp = getMaxHp(owner) - (ownerHp * 0.2)
  local owner_motion = GetV(V_MOTION, owner)
  local level = 5
  if (ownerHp < ownerMinHp) and owner_motion == MOTION_DAMAGE then
    MoveToOwner(owner)
    SkillObject(id, level, skills.MH_GRANITIC_ARMOR, owner)
  elseif owner_motion == MOTION_ATTACK or owner_motion == MOTION_ATTACK2 then
    local x, y = GetV(V_POSITION, owner)
    SkillGround(MyID, MySkillLevel, skills.MH_VOLCANIC_ASH, x, y)
  end
end

---@param myid number
---@param owner number
function AutoCast(myid, owner)
  local humunculus = {
    [1] = lif,
    [2] = amistr,
    [3] = filir,
    [4] = vanilmirth,
    [5] = lif,
    [6] = amistr,
    [7] = filir,
    [8] = vanilmirth,
    [9] = lif,
    [10] = amistr,
    [11] = filir,
    [12] = vanilmirth,
    [13] = lif,
    [14] = amistr,
    [15] = filir,
    [16] = vanilmirth,
    [48] = eira,
    [49] = bayeri,
    [50] = sera,
    [51] = dieter,
    -- [52] = eleanor, dont have any buff
  }
  local skill = humunculus[GetV(V_HOMUNTYPE, myid)]
  if type(skill) == 'function' then
    local mySp = getSp(myid)
    local myMinSp = getMaxSp(myid) - (mySp * 0.2)

    if mySp > myMinSp then
      skill(myid, owner)
    end
  end
end

---@param id number
---@return number
function GetHp(id)
  return GetV(V_HP, id)
end

---@param id number
---@return number
function GetMaxHp(id)
  return GetV(V_MAXHP, id)
end

---@param id number
---@return number
function GetMaxSp(id)
  return GetV(V_MAXSP, id)
end

---@param id number
---@return number
function GetSp(id)
  return GetV(V_SP, id)
end

---@param id number
---@return number
function GetMotion(id)
  return GetV(V_MOTION, id)
end
