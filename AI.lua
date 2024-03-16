require 'AI.USER_AI.Util'
require 'AI.USER_AI.Const'

-----------------------------
-- global variables
-----------------------------
MyOwner = {
  id = 0,
  x = 0,
  y = 0,
}
MyState = 'IDLE_ST'
MyEnemy = 0
MyDestX = 0
MyDestY = 0
MyPatrolX = 0
MyPatrolY = 0
ResCmdList = List.new()
MyID = 0
MySkill = 0
MySkillLevel = 0

------------- command process  ---------------------
local command = {
  [0] = function()
    MyState = 'IDLE_ST'
  end,
  [1] = function(x, y)
    TraceAI 'OnMOVE_CMD'

    if x == MyDestX and y == MyDestY and MOTION_MOVE == GetV(V_MOTION, MyID) then
      return
    end

    local curX, curY = GetV(V_POSITION, MyID)
    if math.abs(x - curX) + math.abs(y - curY) > 15 then
      List.pushleft(ResCmdList, { MOVE_CMD, x, y })
      x = math.floor((x + curX) / 2)
      y = math.floor((y + curY) / 2)
    end

    Move(MyID, x, y)

    MyState = 'MOVE_CMD_ST'
    MyDestX = x
    MyDestY = y
    MyEnemy = 0
    MySkill = 0
  end,
  [2] = function()
    TraceAI 'OnSTOP_CMD'

    if GetV(V_MOTION, MyID) ~= MOTION_STAND then
      ---@diagnostic disable-next-line: missing-parameter
      Move(MyID, GetV(V_POSITION, MyID))
    end
    MyState = 'IDLE_ST'
    MyDestX = 0
    MyDestY = 0
    MyEnemy = 0
    MySkill = 0
  end,
  [3] = function(id)
    TraceAI 'OnATTACK_OBJECT_CMD'

    MySkill = 0
    MyEnemy = id
    MyState = 'CHASE_ST'
  end,
  [4] = function(x, y)
    TraceAI 'OnATTACK_AREA_CMD'

    if x ~= MyDestX or y ~= MyDestY or MOTION_MOVE ~= GetV(V_MOTION, MyID) then
      Move(MyID, x, y)
    end
    MyDestX = x
    MyDestY = y
    -- MyEnemy = 0
    MyState = 'ATTACK_AREA_CMD_ST'
  end,
  [5] = function(x, y)
    TraceAI 'OnPATROL_CMD'

    MyPatrolX, MyPatrolY = GetV(V_POSITION, MyID)
    MyDestX = x
    MyDestY = y
    Move(MyID, x, y)
    MyState = 'PATROL_CMD_ST'
  end,
  [6] = function()
    TraceAI 'OnHOLD_CMD'

    MyDestX = 0
    MyDestY = 0
    MyEnemy = 0
    MyState = 'HOLD_CMD_ST'
  end,
  [7] = function(level, skill, id)
    TraceAI 'OnSKILL_OBJECT_CMD'

    MySkillLevel = level
    MySkill = skill
    MyEnemy = id
    MyState = 'CHASE_ST'
  end,
  [8] = function(level, skill, x, y)
    TraceAI 'OnSKILL_AREA_CMD'

    Move(MyID, x, y)
    MyDestX = x
    MyDestY = y
    MySkillLevel = level
    MySkill = skill
    MyState = 'SKILL_AREA_CMD_ST'
  end,
  [9] = function()
    if MyState ~= 'FOLLOW_CMD_ST' then
      MoveToOwner(MyID)
      MyState = 'FOLLOW_CMD_ST'
      MyDestX, MyDestY = GetV(V_POSITION, MyOwner.id)
      MyEnemy = 0
      MySkill = 0
      TraceAI 'OnFOLLOW_CMD'
    else
      MyState = 'IDLE_ST'
      MyEnemy = 0
      MySkill = 0
      TraceAI 'FOLLOW_CMD_ST --> IDLE_ST'
    end
  end,
}

function ProcessCommand(msg)
  local cmd = command[msg[1]]

  if type(cmd) == 'function' then
    cmd(msg[2], msg[3], msg[4], msg[5])
  end
end

-------------- state process  --------------------
-- local function calculateCircularPosition(center_x, center_y, radius, angle)
--   local x = center_x + radius * math.cos(angle)
--   local y = center_y + radius * math.sin(angle)
--   return x, y
-- end

local state = {}
-- local angle = 0
-- local angular_speed = 0.2
function state.IDLE_ST()
  TraceAI 'IDLE_ST'

  -- indiponivel no momento
  -- local object = GetMyEnemy(MyID)
  -- if object ~= 0 then
  --   MyState = 'CHASE_ST'
  --   MyEnemy = object
  --   TraceAI 'IDLE_ST -> CHASE_ST : ATTACKED_IN'
  --   return
  -- end

  local cmd = List.popleft(ResCmdList)
  if cmd ~= nil then
    ProcessCommand(cmd)
    return
  end

  -- faz homunculo andar entorno do player, mas pode causar crash no jogo.
  -- MyOwner.motion = GetV(V_MOTION, MyOwner.id)
  -- if MyOwner.motion == MOTION_SIT then
  --   local radius = 5
  --
  --   MyOwner.x, MyOwner.y = GetV(V_POSITION, MyOwner.id)
  --
  --   local x, y = calculateCircularPosition(MyOwner.x, MyOwner.y, radius, angle)
  --   Move(MyID, x, y)
  --   angle = angle + angular_speed
  --   return
  -- end

  AutoCast(MyID, MyOwner.id)

  local distance = GetDistanceFromOwner(MyID)
  if distance > 3 or distance < -1 then
    MyState = 'FOLLOW_ST'
    TraceAI 'IDLE_ST -> FOLLOW_ST'
    return
  end
end

function state.FOLLOW_ST()
  TraceAI 'FOLLOW_ST'

  AutoCast(MyID, MyOwner.id)

  if GetDistanceFromOwner(MyID) <= 3 then
    MyState = 'IDLE_ST'
    TraceAI 'FOLLOW_ST -> IDLW_ST'
    return
  elseif GetV(V_MOTION, MyID) == MOTION_STAND then
    MoveToOwner(MyID)
    TraceAI 'FOLLOW_ST -> FOLLOW_ST'
    return
  else
    MoveToOwner(MyID)
  end
end

function state.CHASE_ST()
  TraceAI 'CHASE_ST'

  if IsOutOfSight(MyID, MyEnemy) or GetDistanceFromOwner(MyID) > 10 then
    MyState = 'FOLLOW_ST'
    MyEnemy = 0
    TraceAI 'CHASE_ST -> FOLLOW_ST : ENEMY_OUTSIGHT_IN'
    return
  end

  if IsInAttackSight(MyID, MyEnemy) then
    MyState = 'ATTACK_ST'
    TraceAI 'CHASE_ST -> ATTACK_ST : ENEMY_INATTACKSIGHT_IN'
    return
  end

  ---@diagnostic disable-next-line: redundant-parameter
  local x, y = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
  if MyDestX ~= x or MyDestY ~= y then
    ---@diagnostic disable-next-line: redundant-parameter
    MyDestX, MyDestY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
    ---@diagnostic disable-next-line: param-type-mismatch
    Move(MyID, MyDestX, MyDestY)
    TraceAI 'CHASE_ST -> CHASE_ST : DESTCHANGED_IN'
    return
  end
end

function state.ATTACK_ST()
  TraceAI 'ATTACK_ST'

  if IsOutOfSight(MyID, MyEnemy) then
    MyState = 'IDLE_ST'
    TraceAI 'ATTACK_ST -> IDLE_ST'
    return
  end

  if MOTION_DEAD == GetV(V_MOTION, MyEnemy) then
    MyState = 'IDLE_ST'
    TraceAI 'ATTACK_ST -> IDLE_ST'
    return
  end

  if not IsInAttackSight(MyID, MyEnemy) then
    MyState = 'CHASE_ST'
    ---@diagnostic disable-next-line: redundant-parameter
    MyDestX, MyDestY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
    ---@diagnostic disable-next-line: param-type-mismatch
    Move(MyID, MyDestX, MyDestY)
    TraceAI 'ATTACK_ST -> CHASE_ST  : ENEMY_OUTATTACKSIGHT_IN'
    return
  end

  if MySkill == 0 then
    Attack(MyID, MyEnemy)
  else
    if 1 == SkillObject(MyID, MySkillLevel, MySkill, MyEnemy) then
      MyEnemy = 0
    end

    MySkill = 0
  end
  TraceAI 'ATTACK_ST -> ATTACK_ST  : ENERGY_RECHARGED_IN'
end

function state.MOVE_CMD_ST()
  TraceAI 'MOVE_CMD_ST'

  local x, y = GetV(V_POSITION, MyID)
  if x == MyDestX and y == MyDestY then
    MyState = 'IDLE_ST'
  end
end

function state.STOP_CMD_ST() end

function state.ATTACK_OBJECT_CMD_ST() end

function state.ATTACK_AREA_CMD_ST()
  TraceAI 'ATTACK_AREA_CMD_ST'

  if MyEnemy ~= 0 then
    MyState = 'CHASE_ST'
    return
  end

  local x, y = GetV(V_POSITION, MyID)
  if x == MyDestX and y == MyDestY then
    MyState = 'IDLE_ST'
  end
end

function PATROL_CMD_ST()
  TraceAI 'PATROL_CMD_ST'

  local object = GetOwnerEnemy(MyID)
  if object == 0 then
    object = GetMyEnemy(MyID)
  end

  if object ~= 0 then
    MyState = 'CHASE_ST'
    MyEnemy = object
    TraceAI 'PATROL_CMD_ST -> CHASE_ST : ATTACKED_IN'
    return
  end

  local x, y = GetV(V_POSITION, MyID)
  if x == MyDestX and y == MyDestY then
    MyDestX = MyPatrolX
    MyDestY = MyPatrolY
    MyPatrolX = x
    MyPatrolY = y
    Move(MyID, MyDestX, MyDestY)
  end
end

function state.HOLD_CMD_ST()
  TraceAI 'HOLD_CMD_ST'

  if MyEnemy ~= 0 then
    local d = GetDistance(MyEnemy, MyID)
    if d ~= -1 and d <= GetV(V_ATTACKRANGE, MyID) then
      Attack(MyID, MyEnemy)
    else
      MyEnemy = 0
    end
    return
  end

  local object = GetMyEnemy(MyID)
  if object == 0 then
    return
  end

  MyEnemy = object
end

function state.SKILL_OBJECT_CMD_ST() end

function state.SKILL_AREA_CMD_ST()
  TraceAI 'SKILL_AREA_CMD_ST'

  local x, y = GetV(V_POSITION, MyID)
  ---@diagnostic disable-next-line: redundant-parameter
  if GetDistance(x, y, MyDestX, MyDestY) <= GetV(V_SKILLATTACKRANGE_LEVEL, MyID, MySkill, MySkillLevel) then
    SkillGround(MyID, MySkillLevel, MySkill, MyDestX, MyDestY)
    MyState = 'IDLE_ST'
    MySkill = 0
  end
end

function GetMyEnemy(myid)
  local result = 0
  local actors = GetActors()
  local enemys = {}
  local index = 1
  for _, v in ipairs(actors) do
    if v ~= MyOwner.id and v ~= myid then
      local motion = GetV(V_MOTION, v)
      if 1 == IsMonster(v) and motion ~= MOTION_DEAD and motion ~= MOTION_STAND then
        enemys[index] = v
        index = index + 1
      end
    end
  end

  local min_dis = 100
  local dis
  for i, v in ipairs(enemys) do
    dis = GetDistance2(myid, v)
    if dis < min_dis then
      result = v
      min_dis = dis
    end
  end

  return result
end

function AI(myid)
  MyID = myid
  MyOwner.id = GetV(V_OWNER, MyID)
  local msg = GetMsg(myid)
  local rmsg = GetResMsg(myid)

  if msg[1] == NONE_CMD then
    if rmsg[1] ~= NONE_CMD then
      if List.size(ResCmdList) < 10 then
        List.pushright(ResCmdList, rmsg)
      end
    end
  else
    List.clear(ResCmdList)
    ProcessCommand(msg)
  end

  local action = state[MyState]

  if type(action) == 'function' then
    action()
  end
end
