require 'AI.USER_AI.Source.Util'
require 'AI.USER_AI.Source.Const'
local Skill = require 'AI.USER_AI.Source.Skill'

---@class Humunculu
---@field public id number
---@field public enemy number
---@field public skills table
---@field public skillLevel number
---@field public state 'watch' | 'idle' | 'follow' | 'chase' | 'attack' | 'fighting' | 'damage' | 'health' | 'dying' | 'dead'
local Humunculu = {
  id = 0,
  skills = {},
  skill = 0,
  skillLevel = 5,
  state = 'idle',
}

---@class Owner
---@field public id number
local Owner = {
  id = 0,
}

---@class Enemy
---@field public id number
local Enemy = {
  id = 0,
}

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
  [HOLD_CMD] = function()
    -- FIX: GRAVITY DEVELOPERS NEED TO FIX THIS BUG, NOT ME.
    -- HOLD_CMD IS NOT BEING CALLED, THIS FUNCTION SHOULD BE CALLED WHEN THE OWNER
    -- MARK A TARGET.
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
local State = {
  [HUMUNCULU_FIGHTING] = function()
    TraceAI 'HUMUNCULU_FIGHTING'
    for _, skill in pairs(Humunculu.skills) do
      if
        skill.id == HLIF_CHANGE
        or skill.id == HAMI_BLOODLUST
        or skill.id == HFLI_FLEET
        or skill.id == HFLI_SPEED
        or skill.id == MH_GOLDENE_FERSE
        or skill.id == MH_ANGRIFFS_MODUS
        or skill.id == MH_MAGMA_FLOW
      then
        skill.lastSkillTime = UseSkill(Humunculu.id, skill, Owner.id)
      end
    end
    Humunculu.state = 'watch'
  end,
  [OWNER_DAMAGED] = function()
    TraceAI 'OWNER_DAMAGED'
    for _, skill in pairs(Humunculu.skills) do
      if skill.id == HLIF_AVOID or skill.id == HAMI_DEFENCE or skill.id == MH_PAIN_KILLER then
        skill.lastSkillTime = UseSkill(Humunculu.id, skill, Owner.id)
      end
    end
    Humunculu.state = 'watch'
  end,
  [OWNER_LOST_HEALTH] = function()
    TraceAI 'OWNER_LOST_HEALTH'
    for _, skill in pairs(Humunculu.skills) do
      if skill.id == HLIF_HEAL or skill.id == HVAN_CHAOTIC then
        skill.lastSkillTime = UseSkill(Humunculu.id, skill, Owner.id)
      end
    end
    Humunculu.state = 'watch'
  end,
  [OWNER_DYING] = function()
    TraceAI 'OWNER_DYING'
    for _, skill in pairs(Humunculu.skills) do
      if
        skill.id == HLIF_AVOID
        or skill.id == HAMI_CASTLE
        or skill.id == MH_STEINWAND
        or skill.id == HVAN_CHAOTIC
        or skill.id == MH_GRANITIC_ARMOR
        or skill.id == MH_OVERED_BOOST
        or skill.id == MH_SILENT_BREEZE
      then
        skill.lastSkillTime = UseSkill(Humunculu.id, skill, Owner.id)
      end
    end
    Humunculu.state = 'watch'
  end,
  [OWNER_DEAD] = function()
    TraceAI 'OWNER_DEAD'
    for _, skill in pairs(Humunculu.skills) do
      if skill.id == MH_LIGHT_OF_REGENE then
        skill.lastSkillTime = UseSkill(Humunculu.id, skill, Owner.id)
      end
    end
    Humunculu.state = 'watch'
  end,
  [WATCH] = function()
    TraceAI 'WATCH'
    local enoughSp = GetSp(Humunculu.id) > GetMaxSp(Humunculu.id) * 0.1

    if not enoughSp then
      Humunculu.state = 'idle'
      return
    end

    local ownerMotion = GetV(V_MOTION, Owner.id)
    local ownerIsDead = ownerMotion == MOTION_DEAD

    if ownerIsDead then
      Humunculu.state = 'dead'
      return
    end

    local ownerHp = GetHp(Owner.id)
    local ownerMaxHp = GetMaxHp(Owner.id)
    local ownerDying = ownerHp <= ownerMaxHp * 0.3

    if ownerDying then
      TraceAI 'WATCH -> OWNER_DYING'
      Humunculu.state = 'dying'
      return
    end

    local ownerLosingHealth = ownerHp <= ownerMaxHp * 0.7

    if ownerLosingHealth then
      TraceAI 'WATCH -> OWNER_LOST_HEALTH'
      Humunculu.state = 'health'
      return
    end

    local ownerBeingDamaged = ownerMotion == MOTION_DAMAGE
    if ownerBeingDamaged then
      TraceAI 'WATCH -> OWNER_DAMAGED'
      Humunculu.state = 'damage'
      return
    end

    local humunculuMotion = GetV(V_MOTION, Humunculu.id)
    local humunculusIsFighting = humunculuMotion == MOTION_ATTACK or humunculuMotion == MOTION_ATTACK2
    if humunculusIsFighting then
      TraceAI 'WATCH -> FIGHTING'
      Humunculu.state = 'fighting'
      return
    end

    Humunculu.state = 'idle'
  end,
  [IDLE] = function()
    TraceAI 'IDLE'

    local cmd = List.popleft(Command.ResCmdList)
    if cmd ~= nil then
      ProcessCommand(cmd)
    end

    local distance = GetDistanceFromOwner(Humunculu.id)
    if distance > 3 or distance < -1 then
      Humunculu.state = 'follow'
      TraceAI 'IDLE -> FOLLOW'
    else
      Humunculu.state = 'watch'
      TraceAI 'IDLE -> WATCH'
    end
  end,
  [FOLLOW] = function()
    TraceAI 'FOLLOW'

    local OwnerMotion = GetV(V_MOTION, Owner.id)
    local OwnerNotMoving = OwnerMotion == MOTION_SIT or OwnerMotion == MOTION_STAND or OwnerMotion == MOTION_DEAD
    local OwnerTooClose = GetDistanceFromOwner(Humunculu.id) <= 3

    if OwnerNotMoving or OwnerTooClose then
      Humunculu.state = 'idle'
      TraceAI 'FOLLOW -> IDLE : OWNER_NOT_MOVING | OWNER_TOO_CLOSE'
    else
      MoveToOwner(Humunculu.id)
      TraceAI 'FOLLOW -> FOLLOW'
    end
  end,
  [CHASE] = function()
    TraceAI 'CHASE'
    local OwnerTooFar = GetDistanceFromOwner(Owner.id) > 10

    if IsOutOfSight(Humunculu.id, Enemy.id) or OwnerTooFar then
      Humunculu.state = 'follow'
      Enemy.id = 0
      TraceAI 'CHASE -> FOLLOW : ENEMY_OUTSIGHT_IN | OWNER_TOO_FAR'
      return
    end

    if IsInAttackSight(Humunculu.id, Enemy.id, Humunculu) then
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
  end,
  [ATTACK] = function()
    TraceAI 'ATTACK'

    local EnemyIsDead = GetV(V_MOTION, Enemy.id) == MOTION_DEAD
    if IsOutOfSight(Humunculu.id, Enemy.id) or EnemyIsDead then
      Humunculu.state = 'idle'
      TraceAI 'ATTACK -> IDLE'
      return
    end

    if not IsInAttackSight(Humunculu.id, Enemy.id, Humunculu) then
      Humunculu.state = 'chase'
      Humunculu.destX, Humunculu.destY = GetV(V_POSITION, Enemy.id)
      Move(Humunculu.id, Humunculu.destX, Humunculu.destY)
      TraceAI 'ATTACK -> CHASE'
      return
    end

    ---TODO: ATTACK AN ENEMY WITH A SKILL
    Attack(Humunculu.id, Enemy.id)
    TraceAI 'ATTACK -> ATTACK : BASIC ATTACK'
  end,
}

function AI(myid)
  Humunculu.id = myid
  Humunculu.skills = Skill.getSkills(Humunculu)

  Owner.id = GetV(V_OWNER, Humunculu.id)
  local msg = GetMsg(myid)
  local rmsg = GetResMsg(myid)

  if msg[1] == NONE_CMD then
    if rmsg[1] ~= NONE_CMD then
      if List.size(Command.ResCmdList) < 10 then
        List.pushright(Command.ResCmdList, rmsg)
      end
    end
  else
    List.clear(Command.ResCmdList)
    ProcessCommand(msg)
  end

  local action = State[Humunculu.state]

  if action and type(action) == 'function' then
    action()
  end
end
