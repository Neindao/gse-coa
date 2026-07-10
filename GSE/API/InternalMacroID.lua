local GSE = GSE

-- GSE-CoA: separate user-facing sequence names from WoW-safe hidden button names.
-- Sequence names remain exactly as the user typed them.  InternalMacroName is
-- used only for secure buttons and the /click target inside the visible macro.

local function is_empty(value)
  return value == nil or value == ''
end

function GSE.CoASanitizeInternalMacroBase(name)
  name = tostring(name or 'Sequence')
  name = name:gsub('%s+', '_')
  name = name:gsub('[^%w_]', '_')
  name = name:gsub('_+', '_')
  name = name:gsub('^_+', '')
  name = name:gsub('_+$', '')
  if name == '' then
    name = 'Sequence'
  end
  if name:match('^%d') then
    name = 'S_' .. name
  end
  return name
end

function GSE.CoANameHash(name, classid)
  local source = tostring(classid or '') .. ':' .. tostring(name or '')
  local hash = 0
  for i = 1, string.len(source) do
    hash = (hash + (string.byte(source, i) or 0) * i) % 1048576
  end
  return string.format('%05X', hash)
end

function GSE.GenerateInternalMacroName(sequenceName, classid)
  local base = GSE.CoASanitizeInternalMacroBase(sequenceName)
  local original = tostring(sequenceName or '')

  -- Preserve legacy behavior for already-safe names.  This keeps existing
  -- no-space sequences such as ReaperLeveling compatible with old buttons/macros.
  if base == original then
    return base
  end

  return 'GSE_' .. base .. '_' .. GSE.CoANameHash(sequenceName, classid)
end

function GSE.GetOrCreateInternalMacroName(sequenceName, sequence, classid)
  if type(sequence) ~= 'table' then
    return GSE.GenerateInternalMacroName(sequenceName, classid)
  end

  if is_empty(sequence.InternalMacroName) then
    sequence.InternalMacroName = GSE.GenerateInternalMacroName(sequenceName, classid)
  end

  return sequence.InternalMacroName
end

function GSE.GetInternalMacroName(sequenceName, sequence, classid)
  if type(sequence) == 'table' and not is_empty(sequence.InternalMacroName) then
    return sequence.InternalMacroName
  end
  return GSE.GetOrCreateInternalMacroName(sequenceName, sequence, classid)
end

function GSE.FindSequenceByInternalMacroName(internalName)
  if is_empty(internalName) or type(GSELibrary) ~= 'table' then
    return nil, nil, nil
  end

  for classid, library in pairs(GSELibrary) do
    if type(library) == 'table' then
      for sequenceName, sequence in pairs(library) do
        if type(sequence) == 'table' and sequence.InternalMacroName == internalName then
          return sequence, classid, sequenceName
        end
      end
    end
  end

  return nil, nil, nil
end

function GSE.EnsureInternalMacroNames()
  if type(GSELibrary) ~= 'table' then return end

  for classid, library in pairs(GSELibrary) do
    if type(library) == 'table' then
      for sequenceName, sequence in pairs(library) do
        if type(sequence) == 'table' and sequence.MacroVersions then
          GSE.GetOrCreateInternalMacroName(sequenceName, sequence, classid)
        end
      end
    end
  end
end
