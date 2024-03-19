require 'AI.USER_AI.Source.Const'

---@diagnostic disable: redundant-parameter
local Skill = {}

---@param Humunculu table
---@return table
function Skill.getSupportSkills(Humunculu)
  local t = {}

  local lif = {
    {
      id = HLIF_HEAL,
      cooldown = 20,
      lastSkillTime = 0,
    },
    {
      id = HLIF_AVOID,
      cooldown = 35,
      lastSkillTime = 0,
    },
    {
      id = HLIF_CHANGE,
      cooldown = 1200,
      lastSkillTime = 0,
    },
  }

  local amistr = {
    {
      id = HAMI_CASTLE,
      cooldown = 10, -- ITS NOT THE REAL COOLDOWN
      lastSkillTime = 0,
    },
    {
      id = HAMI_DEFENCE,
      cooldown = 30,
      lastSkillTime = 0,
    },
    {
      id = HAMI_BLOODLUST,
      cooldown = 900,
      lastSkillTime = 0,
    },
  }

  local filir = {
    {
      id = HFLI_FLEET,
      cooldown = 120,
      lastSkillTime = 0,
    },
    {
      id = HFLI_SPEED,
      cooldown = 120,
      lastSkillTime = 0,
    },
  }

  local vanilmirth = {
    {
      id = HVAN_CHAOTIC,
      cooldown = 3,
      lastSkillTime = 0,
    },
  }

  local bayeri = {
    {
      id = MH_GOLDENE_FERSE,
      cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
      lastSkillTime = 0,
    },
    {
      id = MH_STEINWAND,
      cooldown = 10, -- ITS NOT THE REAL COOLDOWN
      lastSkillTime = 0,
    },
    {
      id = MH_ANGRIFFS_MODUS,
      cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
      lastSkillTime = 0,
    },
  }

  local dieter = {
    {
      id = MH_GRANITIC_ARMOR,
      cooldown = 60, -- ITS SKILL DURATION, NOT COOLDOWN
      lastSkillTime = 0,
    },
    {
      id = MH_MAGMA_FLOW,
      cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
      lastSkillTime = 0,
    },
  }

  local eira = {
    {
      id = MH_OVERED_BOOST,
      cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
      lastSkillTime = 0,
    },
    {
      id = MH_LIGHT_OF_REGENE,
      cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
      lastSkillTime = 0,
    },
    {
      id = MH_SILENT_BREEZE,
      cooldown = 21, -- ITS SILENCE DURATION, NOT COOLDOWN
      lastSkillTime = 0,
    },
  }

  local sera = {
    {
      id = MH_PAIN_KILLER,
      cooldown = 120, -- ITS SKILL DURATION, NOT COOLDOWN
      lastSkillTime = 0,
    },
  }

  local skillTables = { lif, amistr, filir, vanilmirth, bayeri, dieter, eira, sera }
  for _, skills in ipairs(skillTables) do
    for _, skill in pairs(skills) do
      if GetV(V_SKILLATTACKRANGE, Humunculu.id, skill.id) ~= 1 then
        table.insert(t, skill)
      end
    end
  end

  return t
end

local function CanUseSkill(lastSkillTime, cooldown)
  local currentTime = GetTick()
  if currentTime - lastSkillTime > (cooldown * 1000) then
    return true
  else
    return false
  end
end

---@param Humunculu Humunculu
---@param Owner Owner
function Skill.AutoCast(Humunculu, Owner)
  local sp = GetV(V_SP, Humunculu.id)
  local maxSp = GetV(V_MAXSP, Humunculu.id)
  local enoughSp = sp > maxSp * 0.1
  local HomunculusIsFighting = GetV(V_MOTION, Humunculu.id) == MOTION_ATTACK
    or GetV(V_MOTION, Humunculu.id) == MOTION_ATTACK2
  local OwnerBeingDamaged = GetV(V_MOTION, Owner.id) == MOTION_DAMAGE
  local OwnerMaxHp = GetV(V_MAXHP, Owner.id)
  local OwnerHp = GetV(V_HP, Owner.id)
  local OwnerLosingHealth = OwnerHp <= OwnerMaxHp * 0.8
  local OwnerIsDying = OwnerHp <= OwnerMaxHp * 0.3
  local OwnerIsDead = GetV(V_MOTION, Owner.id) == MOTION_DEAD

  ---@param skill table
  local function useSkill(skill, why)
    TraceAI('AUTO_CAST -> USE_SKILL: ' .. skill.id .. why)
    if CanUseSkill(skill.lastSkillTime, skill.cooldown) then
      ---TODO: VERIFY THE RANGE AND THE GET CLOSE TO THE OWNER TO USE THE SKILL
      SkillObject(Humunculu.id, Humunculu.skillLevel, skill.id, Owner.id)
    end

    return GetTick()
  end

  if enoughSp then
    for _, skill in pairs(Humunculu.skills) do
      if OwnerIsDead then
        if skill.id == MH_LIGHT_OF_REGENE then
          skill.lastSkillTime = useSkill(skill, ' OwnerIsDead')
          break
        end
      end

      if OwnerLosingHealth and not OwnerIsDying then
        if skill.id == HLIF_HEAL or skill.id == HVAN_CHAOTIC then
          skill.lastSkillTime = useSkill(skill, ' OwnerLosingHealth')
        end
      elseif OwnerIsDying then
        if
          skill.id == HLIF_AVOID
          or skill.id == HAMI_CASTLE
          or skill.id == MH_STEINWAND
          or skill.id == HVAN_CHAOTIC
          or skill.id == MH_GRANITIC_ARMOR
          or skill.id == MH_OVERED_BOOST
          or skill.id == MH_SILENT_BREEZE
        then
          skill.lastSkillTime = useSkill(skill, ' OwnerIsDying')
        end
      elseif OwnerBeingDamaged then
        if skill.id == HLIF_AVOID or skill.id == HAMI_DEFENCE or skill.id == MH_PAIN_KILLER then
          skill.lastSkillTime = useSkill(skill, ' OwnerBeingDamaged')
        end
      elseif HomunculusIsFighting then
        if
          skill.id == HLIF_CHANGE
          or skill.id == HAMI_BLOODLUST
          or skill.id == HFLI_FLEET
          or skill.id == HFLI_SPEED
          or skill.id == MH_GOLDENE_FERSE
          or skill.id == MH_MAGMA_FLOW
        then
          skill.lastSkillTime = useSkill(skill)
        end
      end
    end
  end
end

return Skill
