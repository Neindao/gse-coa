local GSE = GSE
local L = GSE.L

local Statics = GSE.Static
local GetSpecialization=GetSpecialization or GSE.GetCurrentSpecID
if not GetSpecialization then
	GetSpecialization=GSE.GetCurrentSpecID
end
--- CoA compatibility helpers -------------------------------------------------
-- CoA does not expose usable Dragonflight or Wrath talent APIs.  Keep the
-- public GSE functions stable, but make spec/build data optional and safe.
GSE.CoACompat = GSE.CoACompat or {}

local function gsesafecall(fn, ...)
  if type(fn) ~= "function" then
    return false, nil
  end
  return pcall(fn, ...)
end

local function coanormalise(value)
  if value == nil then
    return nil
  end
  return string.upper(tostring(value):gsub("%s+", ""))
end

function GSE.ResolveClassKey(value)
  if value == nil then
    return nil
  end
  local num = tonumber(value)
  if num ~= nil then
    return num
  end
  return coanormalise(value)
end

function GSE.IsCoAEnvironment()
  if type(IsCustomClass) == "function" then
    local ok, custom = gsesafecall(IsCustomClass)
    if ok and custom ~= nil then
      return true
    end
  end
  if C_ClassInfo and type(C_ClassInfo) == "table" and type(C_ClassInfo.GetAllSpecs) == "function" and C_ClassTalents == nil and C_Traits == nil then
    return true
  end
  return false
end

function GSE.GetCoAEnvironmentInfo()
  local info = {}
  local className, classFile = UnitClass("player")
  info.environment = GSE.IsCoAEnvironment() and "CoA" or "Wrath"
  info.className = className or "UNKNOWN"
  info.classFile = classFile or className or "UNKNOWN"
  info.classID = GSE.GetCurrentClassID()
  info.specID, info.specName, info.specIcon = GSE.GetCurrentSpecID()
  info.storageProfile = GSE.GetStorageProfile()
  info.classOnlyMode = GSE.CoACompat.ClassOnlyMode and true or false
  info.lastSpecFailure = GSE.CoACompat.LastSpecFailure or "none"
  info.hasCClassInfo = C_ClassInfo ~= nil
  info.hasCClassTalents = C_ClassTalents ~= nil
  info.hasCTraits = C_Traits ~= nil
  if type(IsCustomClass) == "function" then
    local ok, value = gsesafecall(IsCustomClass)
    info.isCustomClass = ok and value or nil
  else
    info.isCustomClass = nil
  end
  if type(IsBuildDraftModeEnabled) == "function" then
    local ok, value = gsesafecall(IsBuildDraftModeEnabled)
    info.buildDraft = ok and value or nil
  else
    info.buildDraft = nil
  end
  return info
end

--- Return the characters current spec id
function GSE.GetSpecialization()
  return GSE.GetCurrentSpecID()
end

function GSE.GetCurrentSpecID()
  local className, classFile = UnitClass("player")
  local classKey = GSE.GetCurrentClassID()
  local fallbackName = coanormalise(classFile or className or "CLASS") or "CLASS"

  if GSE.IsCoAEnvironment() then
    GSE.CoACompat.ClassOnlyMode = true
    GSE.CoACompat.LastSpecFailure = "CoA class-only fallback"
    return classKey or fallbackName, "CLASS", "INV_MISC_QUESTIONMARK"
  end

  local okGroup, activeSpec = gsesafecall(GetActiveTalentGroup)
  if not okGroup or activeSpec == nil then
    GSE.CoACompat.ClassOnlyMode = true
    GSE.CoACompat.LastSpecFailure = "GetActiveTalentGroup unavailable"
    return classKey or fallbackName, "CLASS", "INV_MISC_QUESTIONMARK"
  end

  local okTabs, numTabs = gsesafecall(GetNumTalentTabs)
  if not okTabs or not numTabs or numTabs <= 0 then
    GSE.CoACompat.ClassOnlyMode = true
    GSE.CoACompat.LastSpecFailure = "No usable talent tabs"
    return classKey or fallbackName, "CLASS", "INV_MISC_QUESTIONMARK"
  end

  local maxpointspents = 0
  local primarytree = 1
  for tab = 1, numTabs do
    local okTab, tabname, tabicon, nopointsSpent = gsesafecall(GetTalentTabInfo, tab, false, false, activeSpec)
    if okTab and nopointsSpent and nopointsSpent > maxpointspents then
      maxpointspents = nopointsSpent
      primarytree = tab
    end
  end

  local okInfo, name1, icon = gsesafecall(GetTalentTabInfo, primarytree, false, false, activeSpec)
  if not okInfo or not name1 then
    GSE.CoACompat.ClassOnlyMode = true
    GSE.CoACompat.LastSpecFailure = "GetTalentTabInfo failed"
    return classKey or fallbackName, "CLASS", "INV_MISC_QUESTIONMARK"
  end

  name1 = string.upper(name1)
  local specid
  for k,v in pairs(Statics.wotlkSpecIDList) do
    local searchStr = v and string.upper(v) or ""
    local st = string.find(searchStr, name1)
    local isClass, isClass1 = UnitClass("player")
    isClass = isClass and string.upper(isClass) or ""
    isClass1 = isClass1 and string.upper(isClass1) or ""
    local st1 = string.find(searchStr, isClass)
    local st2 = string.find(searchStr, isClass1)
    if st ~= nil and (st1 ~= nil or st2 ~= nil) then
      specid = k
    end
  end

  if specid == nil then
    GSE.CoACompat.ClassOnlyMode = true
    GSE.CoACompat.LastSpecFailure = "Spec mapping failed"
    return classKey or fallbackName, "CLASS", icon or "INV_MISC_QUESTIONMARK"
  end

  GSE.CoACompat.ClassOnlyMode = false
  GSE.CoACompat.LastSpecFailure = nil
  return specid, name1, icon
end

function GSE.GetStorageProfile()
  if GSE.CoACompat and GSE.CoACompat.ClassOnlyMode then
    return "CLASS"
  end
  local specid = GSE.GetCurrentSpecID()
  if GSE.CoACompat and GSE.CoACompat.ClassOnlyMode then
    return "CLASS"
  end
  return specid or "CLASS"
end


--- Return the characters class id
function GSE.GetCurrentClassID()
  local class1, class = UnitClass("player")
  local normClass = coanormalise(class or class1)
  local normClass1 = coanormalise(class1 or class)
  for k,v in pairs(Statics.wotlkClassIDList) do
    local norm = coanormalise(v)
    if norm == normClass or norm == normClass1 then
      return k
    end
  end
  return normClass or normClass1 or "UNKNOWN"
end

--- Return the characters class id
function GSE.GetCurrentClassNormalisedName()
  local classDisplayName, classnormalisedname = UnitClass("player")
  return coanormalise(classnormalisedname or classDisplayName or "UNKNOWN")
end

function GSE.GetClassIDforSpec(specid)
  if type(specid) == "string" and tonumber(specid) == nil then
    local resolved = GSE.ResolveClassKey(specid)
    if resolved then
      return resolved
    end
  end
  --local id, name, description, icon, role, class = GetSpecializationInfoByID(specid)
--classid
	local value,classid,class;
	for k,v in pairs(Statics.wotlkClassIDList) do
		if (k==specid) then 
			classid=k  
		end
	end
  
  for k,v in pairs(Statics.wotlkSpecIDList) do
	if (k==specid) then 
		--value=Statics.wotlkSpecIDList[specID]
		local idx=string.find(v," - ")
		if(idx~=nil) then
			class=string.sub(v,idx+3)
		end
		--print(v,last,last[#last])
	    --local class=string.upper(last[#last])
		for k1,v1 in pairs(Statics.wotlkClassIDList) do
			if (string.upper(v1)==string.upper(class)) then 
			classid=k1  
			end
		end
	end
  end
	--local last = string.split( value, "% " )
	--local class=string.upper(last[#last])

  
  -- local classid = 0
  -- if specid <= 12 then
    -- classid = specid
  -- else
    -- for i=1, 12, 1 do
    -- local cdn, st, cid = GetClassInfo(i)--classDisplayName, classTag, classID = GetClassInfo(index)

	 -- st=string.upper(st)
      -- if class == st then
        -- classid = i
      -- end
    -- end
  -- end
   return classid
end

function GSE.GetClassIcon(classid)
  local classicon = {}
  -- classicon[1] = "Interface\\Icons\\inv_sword_27" -- Warrior
  -- classicon[2] = "Interface\\Icons\\ability_thunderbolt" -- Paladin
  -- classicon[3] = "Interface\\Icons\\inv_weapon_bow_07" -- Hunter
  -- classicon[4] = "Interface\\Icons\\inv_throwingknife_04" -- Rogue
  -- classicon[5] = "Interface\\Icons\\inv_staff_30" -- Priest
  -- classicon[6] = "Interface\\Icons\\inv_sword_27" -- Death Knight
  -- classicon[7] = "Interface\\Icons\\inv_jewelry_talisman_04" -- SWhaman
  -- classicon[8] = "Interface\\Icons\\inv_staff_13" -- Mage
  -- classicon[9] = "Interface\\Icons\\spell_nature_drowsy" -- Warlock
 -- classicon[10] = "Interface\\Icons\\Spell_Holy_FistOfJustice" -- Monk
  -- classicon[11] = "Interface\\Icons\\inv_misc_monsterclaw_04" -- Druid
 --classicon[12] = "Interface\\Icons\\INV_Weapon_Glave_01" -- DEMONHUNTER

	
	
   classicon[1] = "Interface\\Icons\\inv_sword_27" -- Warrior
  classicon[2] = "Interface\\Icons\\ability_thunderbolt" -- Paladin
  classicon[3] = "Interface\\Icons\\inv_weapon_bow_07" -- Hunter
  classicon[4] = "Interface\\Icons\\inv_throwingknife_04" -- Rogue
  classicon[5] = "Interface\\Icons\\INV_Staff_30" -- Priest
  classicon[6] = "Interface\\Icons\\Spell_Deathknight_ClassIcon" -- Death Knight
  classicon[7] = "Interface\\Icons\\Spell_Nature_BloodLust" -- SWhaman
  classicon[8] = "Interface\\Icons\\INV_Staff_13" -- Mage
  classicon[9] = "Interface\\Icons\\Spell_Nature_FaerieFire" -- Warlock
	classicon[10] = "Interface\\Icons\\INV_Misc_MonsterClaw_04" -- Monk
  classicon[11] = "Interface\\Icons\\INV_Misc_MonsterClaw_04" -- Druid
	classicon[12] = "Interface\\Icons\\inv_weapon_bow_07" -- DEMONHUNTER
  return classicon[classid]

end

--- Check if the specID provided matches the plauers current class.
function GSE.isSpecIDForCurrentClass(specID)
for k,v in pairs(Statics.wotlkSpecIDList) do
	if (k==specID) then 
		local value=Statics.wotlkSpecIDList[specID]
		if value then
			local parts = GSE.split(value, " - ")
	    local class = string.upper(parts[#parts])
		local currentenglishclass, currentclassDisplayName = UnitClass("player")
		
		currentenglishclass=string.upper(currentenglishclass)
		local currentclassId=string.upper(currentclassDisplayName)
		
		for k1,v1 in pairs(Statics.wotlkClassIDList) do
			if (string.upper(v1)==string.upper(class)) then currentclassId=k1 end
		end
		
		return (class==currentenglishclass or specID==currentclassId)
		end
	end
 end
  return false
end


function GSE.GetSpecNames()
  local keyset={}
  for k,v in pairs(Statics.wotlkSpecIDList) do
    keyset[v] = v
  end
  return keyset
end

--- Returns the Character Name in the form Player@server
function GSE.GetCharacterName()
  return  GetUnitName("player", true) .. '@' .. GetRealmName()
end

--- Returns the current Talent Selections as a string
function GSE.GetCurrentTalents()
  local talents = ""
    for talentTier = 1, 7 do
  --for talentTier = 1, MAX_TALENT_TIERS do
    --local available, selected = GetTalentTierInfo(talentTier, 1)
   -- talents = talents .. (available and selected or "?" .. ",")
   talents = talents .. ("?" .. ",")
  end
  return talents
end


--- Experimental attempt to load a WeakAuras string.
function GSE.LoadWeakauras(str)
  local WeakAuras = WeakAuras

  if WeakAuras then
    WeakAuras.ImportString(str)
  end
end
