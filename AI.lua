require 'AI.USER_AI.Source.Util'
require 'AI.USER_AI.Source.Const'

---@class Humunculu
---@field public id number
---@field public enemy number
---@field public skills table
---@field public skillLevel number
---@field public state 'idle' | 'follow' | 'chase' | 'attack'
---@field public getHp function
---@field public getMaxHp function
---@field public getSp function
---@field public getMaxSp function
---@field public reset function
local Humunculu = {
  id = 0,
  skills = {},
  skill = 0,
  skillLevel = 5,
  state = 'idle',
}
function Humunculu:getHp()
  return GetHp(self.id)
end

function Humunculu:getMaxHp()
  return GetMaxHp(self.id)
end

function Humunculu:getSp()
  return GetSp(self.id)
end

function Humunculu:getMaxSp()
  return GetMaxSp(self.id)
end

---@class Owner
---@field public id number
---@field public getHp function
---@field public getMaxHp function
---@field public getSp function
---@field public getMaxSp function
---@field public reset function
local Owner = {
  id = 0,
}

function Owner:getHp()
  return GetHp(self.id)
end

function Owner:getMaxHp()
  return GetMaxHp(self.id)
end

function Owner:getMaxSp()
  return GetMaxSp(self.id)
end

function Owner:getSp()
  return GetSp(self.id)
end

---@class Enemy
---@field public id number
---@field public destX number
---@field public destY number
---@field public getHp function
---@field public getMaxHp function
---@field public getSp function
---@field public getMaxSp function
---@field public reset function
local Enemy = {
  id = 0,
}

function Enemy:getHp()
  return GetHp(self.id)
end

function Enemy:getMaxHp()
  return GetMaxHp(self.id)
end

function Enemy:getMaxSp()
  return GetMaxSp(self.id)
end

function Enemy:getSp()
  return GetSp(self.id)
end

local Command = {
  ResCmdList = List.new(),
  [NONE_CMD] = function()
    TraceAI 'NONE_CMD'
    Humunculu.state = 'idle'
    Enemy.id = 0
  end,
  [MOVE_CMD] = function(x, y)
    TraceAI 'MOVE_CMD'
    Move(Humunculu.id, x, y)
    Humunculu.state = 'idle'
    Enemy.id = 0
  end,
  [STOP_CMD] = function()
    TraceAI 'STOP_CMD'

    if GetV(V_MOTION, Humunculu.id) ~= MOTION_STAND then
      local y, x = GetV(V_POSITION, Humunculu.id)
      Move(Humunculu.id, x, y)
    end
    Humunculu.state = 'idle'
    Enemy.id = 0
  end,
  [ATTACK_OBJECT_CMD] = function(id)
    TraceAI 'ATTACK_OBJECT_CMD'

    Enemy.id = id
    Humunculu.state = 'chase'
  end,
  [ATTACK_AREA_CMD] = function(x, y)
    TraceAI 'ATTACK_AREA_CMD'
    Move(Humunculu.id, x, y)
    Humunculu.state = 'chase'
  end,
  [PATROL_CMD] = function(x, y)
    TraceAI 'PATROL_CMD'
    Move(Humunculu.id, x, y)
    Enemy.id = GetOwnerEnemy(Humunculu.id)

    if Enemy.id == 0 then
      Enemy.id = GetMyEnemy(Humunculu.id)
    end

    if Enemy.id ~= 0 then
      Humunculu.state = 'chase'
      TraceAI 'PATROL_CMD -> CHASE'
    end
  end,
  -- FIX: GRAVITY DEVELOPERS NEED TO FIX THIS BUG, NOT ME
  [HOLD_CMD] = function()
    TraceAI 'HOLD_CMD'
    local actors = GetActors()

    for _, actor in ipairs(actors) do
      if IsInAttackSight(Humunculu.id, actor) then
        Enemy.id = actor
        Humunculu.state = 'chase'
        TraceAI 'HOLD_CMD -> CHASE'
        break
      end
    end
  end,
  [SKILL_OBJECT_CMD] = function(level, skill, id)
    TraceAI 'SKILL_OBJECT_CMD'
    Enemy.id = id
    Humunculu.skill = skill
    Humunculu.level = level
    Humunculu.state = 'chase'
    TraceAI 'SKILL_OBJECT_CMD -> CHASE'
  end,
  [SKILL_AREA_CMD] = function(level, skill, x, y)
    TraceAI 'SKILL_AREA_CMD'
    Move(Humunculu.id, x, y)

    local destX, destY = GetV(V_POSITION, Humunculu.id)
    ---@diagnostic disable-next-line: redundant-parameter
    if GetDistance(x, y, destX, destY) <= GetV(V_SKILLATTACKRANGE_LEVEL, Humunculu.id, skill, level) then
      SkillGround(Humunculu.id, level, skill, destX, destY)
      Humunculu.state = 'idle'
      Humunculu.skill = 0
    end
  end,
  [FOLLOW_CMD] = function()
    TraceAI 'FOLLOW_CMD'
    Humunculu.state = 'follow'
    TraceAI 'FOLLOW_CMD -> FOLLOW'
  end,
}

function ProcessCommand(msg)
  local cmd = Command[msg[1]]

  if type(cmd) == 'function' then
    cmd(msg[2], msg[3], msg[4], msg[5])
  end
end

---@param msg string
local function ProcessCommand(msg)
  local cmd = Command[msg[1]]

  if type(cmd) == 'function' then
    cmd(msg[2], msg[3], msg[4], msg[5])
  end
end

---@class State
local State = {}

function State.idle()
  TraceAI 'IDLE'

  local cmd = List.popleft(Command.ResCmdList)
  if cmd ~= nil then
    ProcessCommand(cmd)
  end

  local distance = GetDistanceFromOwner(Humunculu.id)
  if distance > 3 or distance < -1 then
    Humunculu.state = 'follow'
    TraceAI 'IDLE -> FOLLOW'
  end
end

function State.follow()
  TraceAI 'FOLLOW'
  local OwnerMotion = GetMotion(Owner.id)
  local OwnerNotMoving = OwnerMotion == MOTION_SIT or OwnerMotion == MOTION_STAND or OwnerMotion == MOTION_DEAD
  local OwnerTooClose = GetDistanceFromOwner(Humunculu.id) <= 3

  if OwnerNotMoving or OwnerTooClose then
    Humunculu.state = 'idle'
    TraceAI 'FOLLOW -> IDLE : OWNER_NOT_MOVING | OWNER_TOO_CLOSE'
  else
    MoveToOwner(Humunculu.id)
    TraceAI 'FOLLOW -> FOLLOW'
  end
end

function State.chase()
  TraceAI 'CHASE'
  local OwnerTooFar = GetDistanceFromOwner(Owner.id) > 10

  if IsOutOfSight(Humunculu.id, Enemy.id) or OwnerTooFar then
    Humunculu.state = 'follow'
    Enemy.id = 0
    TraceAI 'CHASE -> FOLLOW : ENEMY_OUTSIGHT_IN | OWNER_TOO_FAR'
    return
  end

  if IsInAttackSight(Humunculu.id, Enemy.id) then
    Humunculu.state = 'attack'
    TraceAI 'CHASE -> ATTACK : ENEMY_INATTACKSIGHT_IN'
    return
  end

  ---@diagnostic disable-next-line: redundant-parameter
  local x, y = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, Enemy.id, Humunculu.skill, Humunculu.skillLevel)
  local destX, destY = GetV(V_POSITION, Humunculu.id)
  if destX ~= x or destY ~= y then
    ---@diagnostic disable-next-line: redundant-parameter
    destX, destY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, Enemy.id, Humunculu.skill, Humunculu.skillLevel)
    ---@diagnostic disable-next-line: param-type-mismatch
    Move(Humunculu.id, destX, destY)
    TraceAI 'CHASE -> CHASE : DESTCHANGED_IN'
    return
  end
end

function State.attack()
  TraceAI 'ATTACK'

  local EnemyIsDead = GetV(V_MOTION, Enemy.id) == MOTION_DEAD
  if IsOutOfSight(Humunculu.id, Enemy.id) or EnemyIsDead then
    Humunculu.state = 'idle'
    TraceAI 'ATTACK -> IDLE'
    return
  end

  if not IsInAttackSight(Humunculu.id, Enemy.id) then
    Humunculu.state = 'chase'
    Humunculu.destX, Humunculu.destY = GetV(V_POSITION, Enemy.id)
    Move(Humunculu.id, Humunculu.destX, Humunculu.destY)
    TraceAI 'ATTACK -> CHASE'
    return
  end

  ---TODO: ATTACK AN ENEMY WITH A SKILL
  Attack(Humunculu.id, Enemy.id)
  TraceAI 'ATTACK -> ATTACK : BASIC ATTACK'
end

function AI(myid)
  Humunculu.id = myid
  Owner.id = GetV(V_OWNER, Humunculu.id)

  local action = State[Humunculu.state]

  if action and type(action) == 'function' then
    action()
  end
end
