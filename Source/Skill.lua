require 'AI.USER_AI.Source.Const'

---@diagnostic disable: redundant-parameter
local Skill = {}

--FIX: BLAME GRAVITY, I WILL UNCOMMENT WHEN THEY FIX THIS
-- ---@param Humunculu table
-- ---@return table
-- function Skill.getSupportSkills(Humunculu)
--   local t = {}

--   local lif = {
--     {
--       id = HLIF_HEAL,
--       cooldown = 20,
--       lastSkillTime = 0,
--     },
--     {
--       id = HLIF_AVOID,
--       cooldown = 35,
--       lastSkillTime = 0,
--     },
--     {
--       id = HLIF_CHANGE,
--       cooldown = 1200,
--       lastSkillTime = 0,
--     },
--   }

--   local amistr = {
--     {
--       id = HAMI_CASTLE,
--       cooldown = 10, -- ITS NOT THE REAL COOLDOWN
--       lastSkillTime = 0,
--     },
--     {
--       id = HAMI_DEFENCE,
--       cooldown = 30,
--       lastSkillTime = 0,
--     },
--     {
--       id = HAMI_BLOODLUST,
--       cooldown = 900,
--       lastSkillTime = 0,
--     },
--   }

--   local filir = {
--     {
--       id = HFLI_FLEET,
--       cooldown = 120,
--       lastSkillTime = 0,
--     },
--     {
--       id = HFLI_SPEED,
--       cooldown = 120,
--       lastSkillTime = 0,
--     },
--   }

--   local vanilmirth = {
--     {
--       id = HVAN_CHAOTIC,
--       cooldown = 3,
--       lastSkillTime = 0,
--     },
--   }

--   local bayeri = {
--     {
--       id = MH_GOLDENE_FERSE,
--       cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
--       lastSkillTime = 0,
--     },
--     {
--       id = MH_STEINWAND,
--       cooldown = 10, -- ITS NOT THE REAL COOLDOWN
--       lastSkillTime = 0,
--     },
--     {
--       id = MH_ANGRIFFS_MODUS,
--       cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
--       lastSkillTime = 0,
--     },
--   }

--   local dieter = {
--     {
--       id = MH_GRANITIC_ARMOR,
--       cooldown = 60, -- ITS SKILL DURATION, NOT COOLDOWN
--       lastSkillTime = 0,
--     },
--     {
--       id = MH_MAGMA_FLOW,
--       cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
--       lastSkillTime = 0,
--     },
--   }

--   local eira = {
--     {
--       id = MH_OVERED_BOOST,
--       cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
--       lastSkillTime = 0,
--     },
--     {
--       id = MH_LIGHT_OF_REGENE,
--       cooldown = 90, -- ITS SKILL DURATION, NOT COOLDOWN
--       lastSkillTime = 0,
--     },
--     {
--       id = MH_SILENT_BREEZE,
--       cooldown = 21, -- ITS SILENCE DURATION, NOT COOLDOWN
--       lastSkillTime = 0,
--     },
--   }

--   local sera = {
--     {
--       id = MH_PAIN_KILLER,
--       cooldown = 120, -- ITS SKILL DURATION, NOT COOLDOWN
--       lastSkillTime = 0,
--     },
--   }

--   local skillTables = { lif, amistr, filir, vanilmirth, bayeri, dieter, eira, sera }
--   local index = 1
--   for _, skills in ipairs(skillTables) do
--     for _, skill in pairs(skills) do
--       if GetV(V_SKILLATTACKRANGE, Humunculu.id, skill.id) ~= 1 then
--         t[index] = skill
--         index = index + 1
--       end
--     end
--   end

--   return t
-- end

---@param Humunculu table
---@return table
function Skill.getSkills(Humunculu)
  local homun_type = GetV(V_HOMUNTYPE, Humunculu.id)
  TraceAI('HOMUN_TYPE: ' .. homun_type)

  if homun_type == LIF or homun_type == LIF2 or homun_type == LIF_H then
    return {
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
  elseif homun_type == AMISTR or homun_type == AMISTR2 or homun_type == AMISTR_H then
    return {
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
  elseif homun_type == FILIR or homun_type == FILIR2 or homun_type == FILIR_H then
    return {
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
  elseif homun_type == VANILMIRTH or homun_type == VANILMIRTH2 or homun_type == VANILMIRTH_H then
    return {
      {
        id = HVAN_CHAOTIC,
        cooldown = 3,
        lastSkillTime = 0,
      },
    }
  elseif homun_type == BAYERI then
    return {
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
  elseif homun_type == DIETER then
    return {
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
  elseif homun_type == EIRA then
    return {
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
  elseif homun_type == SERA then
    return {
      {
        id = MH_PAIN_KILLER,
        cooldown = 120, -- ITS SKILL DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
    }
  end

  -- If the homunculus type is not recognized, return an empty table
  return {}
end

return Skill
