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
      cooldown = 10,
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

  local skillTables = { lif, amistr, filir, vanilmirth }
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
  if (currentTime - lastSkillTime) > (cooldown * 1000) then
    return true
  else
    return false
  end
end

---@param Humunculu Humunculu
---@param Owner Owner
function Skill.AutoCast(Humunculu, Owner)
  local sp = Humunculu:getSp()
  local maxSp = Humunculu:getMaxSp()
  local minSp = maxSp - (sp * 0.2)
  local OwnerBeingDamaged = GetV(V_MOTION, Owner.id) == MOTION_DAMAGE
  local HomunculusIsFighting = GetV(V_MOTION, Humunculu.id) == MOTION_ATTACK or GetV(V_MOTION, Humunculu.id) == MOTION_ATTACK2

  if sp > minSp then
    for _, skill in pairs(Humunculu.skills) do
      if OwnerBeingDamaged then
        if skill.id == HLIF_AVOID or skill.id == HAMI_DEFENCE then
          if CanUseSkill(skill.lastSkillTime, skill.cooldown) then
            SkillObject(Humunculu.id, Humunculu.skillLevel, skill.id, Owner.id)
            skill.lastSkillTime = GetTick()
          end
        end
      elseif HomunculusIsFighting then
        if
          skill.id == HLIF_CHANGE
          or skill.id == HAMI_BLOODLUST
          or skill.id == HFLI_FLEET
          or skill.id == HFLI_SPEED
        then
          if CanUseSkill(skill.lastSkillTime, skill.cooldown) then
            SkillObject(Humunculu.id, Humunculu.skillLevel, skill.id, Owner.id)
            skill.lastSkillTime = GetTick()
          end
        end
      end
    end
  end
end

return Skill
