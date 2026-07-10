local GSE = GSE

-- GSE-CoA macro normalizer.
-- Purpose:
--   1. Preserve valid macro conditional blocks, including multi-condition blocks:
--        [nomounted, combat]
--        [@mouseover,help,nodead]
--   2. Remove brackets around spellbook spell tokens:
--        [Soul Strike] -> Soul Strike
--
-- This runs at save/runtime safety points and must not alter non-cast commands.

local knownConditionals = {
  combat=true, nocombat=true,
  nomounted=true, mounted=true,
  help=true, harm=true,
  exists=true, noexists=true,
  dead=true, nodead=true,
  stealth=true, nostealth=true,
  mod=true, nomod=true,
  target=true, player=true,
  pet=true, nopet=true,
  flyable=true, noflyable=true,
  swimming=true, noswimming=true,
  indoors=true, outdoors=true,
  party=true, raid=true, group=true, nogroup=true,
  channeling=true, nochanneling=true,
  equipped=true, noequipped=true,
  known=true, noknown=true,
  stance=true, nostance=true,
  form=true, noform=true,
  spec=true, talent=true,
  pvp=true, nopvp=true,
  arena=true, instance=true, noinstance=true,
  button=true, btn=true,
}

local function trim(value)
  return (value or ""):match("^%s*(.-)%s*$")
end

local function isConditionalPart(part)
  part = trim(part)
  if part == "" then return false end

  -- Unit targeting and explicit target syntax.
  if part:match("^@[%w_]+$") then return true end
  if part:match("^target%s*=") then return true end

  -- Conditionals with values: mod:shift, button:2, stance:1, known:123, equipped:shield.
  local key = part:match("^([%a_]+)%s*[:=]")
  if key and knownConditionals[key:lower()] then return true end

  -- Negated conditionals can appear as nofoo.
  if knownConditionals[part:lower()] then return true end

  return false
end

local function isConditionalBlock(token)
  token = trim(token)
  if token == "" then return false end

  -- Macro condition blocks can contain comma-separated conditionals.
  -- Spell names can contain spaces, so spaces alone are not enough to classify.
  for part in token:gmatch("[^,]+") do
    if not isConditionalPart(part) then
      return false
    end
  end

  return true
end

local function normalizeCastLine(line)
  local prefix, rest = line:match("^(%S+)%s*(.*)$")
  if not prefix or not rest then return line end

  rest = rest:gsub("%[([^%]]+)%]", function(token)
    if isConditionalBlock(token) then
      return "[" .. token .. "]"
    end
    return token
  end)

  return prefix .. " " .. rest
end

function GSE.NormalizeExecutionMacro(text)
  if not text then return text end

  local output = {}

  for line in string.gmatch(text, "[^\r\n]+") do
    local lowerLine = string.lower(line)
    if lowerLine:match("^%s*/castsequence") or lowerLine:match("^%s*/cast") then
      line = normalizeCastLine(line)
    end
    table.insert(output, line)
  end

  return table.concat(output, "\n")
end

function GSE.NormalizeExecutionMacroVersion(version)
  if not version then return version end

  -- Main sequence lines are stored as an indexed table.
  for k,v in ipairs(version) do
    version[k] = GSE.NormalizeExecutionMacro(v)
  end

  -- KeyPress/KeyRelease/PreMacro/PostMacro are also stored as line arrays.
  -- Do NOT table.concat() them into one string, because that collapses lines
  -- and causes commands like:
  --   /run ...;
  --   /startattack
  -- to reopen as:
  --   /run ...;/
  --   startattack
  local sections = { "KeyPress", "KeyRelease", "PreMacro", "PostMacro" }
  for _, section in ipairs(sections) do
    if type(version[section]) == "table" then
      for k,v in ipairs(version[section]) do
        version[section][k] = GSE.NormalizeExecutionMacro(v)
      end
    elseif type(version[section]) == "string" then
      version[section] = { GSE.NormalizeExecutionMacro(version[section]) }
    end
  end

  return version
end
