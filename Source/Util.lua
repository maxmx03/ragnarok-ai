---@diagnostic disable: redundant-parameter
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

function IsInAttackSight(id1, id2, Humunculu)
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
    a = GetV(V_SKILLATTACKRANGE_LEVEL, id1, Humunculu.skill, Humunculu.skillLevel)
  end

  if a >= d then
    return true
  else
    return false
  end
end

function GetHp(id)
  return GetV(V_HP, id)
end

function GetMaxHp(id)
  return GetV(V_MAXHP, id)
end

function GetSp(id)
  return GetV(V_SP, id)
end

function GetMaxSp(id)
  return GetV(V_MAXSP, id)
end

---@param lastSkillTime number
---@param cooldown number
---@return boolean
local function CanUseSkill(lastSkillTime, cooldown)
  local currentTime = GetTick()
  if currentTime - lastSkillTime > (cooldown * 1000) then
    return true
  else
    return false
  end
end

---@param id number
---@param skill table
---@param target number
---@return number
function UseSkill(id, skill, target)
  TraceAI('AUTO_CAST -> USE_SKILL: ' .. skill.id)

  if CanUseSkill(skill.lastSkillTime, skill.cooldown) then
    local x, y = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, target, skill.id, skill.skillLevel)
    local destX, destY = GetV(V_POSITION, id)
    if destX ~= x or destY ~= y then
      destX, destY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, target, skill.id, skill.skillLevel)
      Move(id, destX, destY)
      TraceAI 'AUTO_CAST -> CHASE : DESTCHANGED_IN'
    end
  end

  SkillObject(id, skill.skillLevel, skill.id, target)
  return GetTick()
end
