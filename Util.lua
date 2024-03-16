require 'AI.USER_AI.Const'

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
  local ownerHalfHp = getMaxHp(owner) - (ownerHp * 0.5)
  local ownerMinHp = getMaxHp(owner) - (ownerHp * 0.2)

  if ownerHp < ownerHalfHp then
    local level = 5
    SkillObject(id, level, skills.HLIF_HEAL, owner)
  elseif GetV(V_MOTION, owner) == MOTION_DAMAGE and ownerHp < ownerMinHp then
    local level = 5
    SkillObject(id, level, skills.HLIF_AVOID, owner)
  end
end

---@param id number
---@param owner number
local function amistr(id, owner) end

---@param id number
---@param owner number
local function filir(id, owner) end

---@param id number
---@param owner number
local function vanilmirth(id, owner) end

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
    -- EIRA = 48,
    -- BAYERI = 49,
    -- SERA = 50,
    -- DIETER = 51,
    -- ELEANOR = 52,
  }
  local skill = humunculus[GetV(V_HOMUNTYPE, myid)]
  if type(skill) == 'function' then
    local lifSp = getSp(myid)
    local lifMinSp = getMaxSp(myid) - (lifSp * 0.2)

    if lifSp > lifMinSp then
      skill(myid, owner)
    end
  end
end
