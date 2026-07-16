local GSE = GSE
local L = GSE.L
function myUpdateFix()
  GSE:ProcessOOCQueue()
  GSE.ReloadSequences()
  
end
--- This function pops up a confirmation dialog.
function GSE.GUIDeleteSequence(currentSeq, iconWidget)
  StaticPopupDialogs["GSE-DeleteMacroDialog"].text = string.format(L["Are you sure you want to delete %s?  This will delete the macro and all versions.  This action cannot be undone."], GSE.GUIEditFrame.SequenceName)
  StaticPopupDialogs["GSE-DeleteMacroDialog"].OnAccept = function(self, data)
      GSE.GUIConfirmDeleteSequence(GSE.GUIEditFrame.ClassID, GSE.GUIEditFrame.SequenceName)
  end
  StaticPopup_Show ("GSE-DeleteMacroDialog")
  
end

--- This function then deletes the macro
function GSE.GUIConfirmDeleteSequence(classid, sequenceName)
  GSE.GUIViewFrame:Hide()
  GSE.GUIEditFrame:Hide()
  GSE.DeleteSequence(classid, sequenceName)
  GSE.GUIShowViewer()
end


--- Format the text against the GSE Sequence Spec.
function GSE.GUIParseText(editbox)
  if GSEOptions.RealtimeParse then
    local text = GSE.UnEscapeString(editbox:GetText())
    local returntext = GSE.TranslateString(text , GetLocale(), GetLocale(), true)
    editbox:SetText(returntext)
    editbox:SetCursorPosition(string.len(returntext)+2)
  end
end

function GSE.GUILoadEditor(key, incomingframe, recordedstring)
  local classid
  local sequenceName
  local sequence
  local isNewSequence = GSE.isEmpty(key)
  
  if isNewSequence then
    classid = GSE.GetCurrentClassID()
    sequenceName = GSE.getSequenceName()
	GSE.isNewFirstTimeCreated=true
    sequence = {
      ["Author"] = GSE.GetCharacterName(),
      ["Talents"] = GSE.GetCurrentTalents(),
      ["Default"] = 1,
      ["SpecID"] = GSE.GetCurrentSpecID();
      ["MacroVersions"] = {
        [1] = {
          ["PreMacro"] = {},
          ["PostMacro"] = {},
          ["KeyPress"] = {},
          ["KeyRelease"] = {},
          ["StepFunction"] = "Sequential",
          [1] = "/say Hello",
        }
      },
    }
    sequence.Name = sequenceName
    if not GSE.isEmpty(recordedstring) then
      sequence.MacroVersions[1][1] = nil
      sequence.MacroVersions[1] = GSE.SplitMeIntolines(recordedstring)
    end
  else
    local elements = GSE.split(key, ",")
    classid = GSE.ResolveClassKey(elements[1])
    sequenceName = elements[2]
	
    local sourceSequence = GSELibrary[classid] and GSELibrary[classid][sequenceName]
    if GSE.isEmpty(sourceSequence) then
      GSE.Print('GSE-CoA: Could not open sequence ' .. tostring(sequenceName) .. ' because it was not found in storage.', 'GUI')
      return
    end
    sequence = GSE.CloneSequence(sourceSequence, true)
    -- GSE-CoA: preserve user-facing sequence name separately from the internal macro id.
    if GSE.isEmpty(sequence.Name) then
      sequence.Name = sequenceName
    end
    if GSE.isEmpty(sequenceName) and not GSE.isEmpty(sequence.Name) then
      sequenceName = sequence.Name
    end
		GSE.isNewFirstTimeCreated=false
  end
  GSE.GUIEditFrame.SequenceName = sequenceName
  -- Track editor state on the frame itself.  The legacy global
  -- GSE.isNewFirstTimeCreated is changed by editor/layout code, so it cannot
  -- reliably distinguish an unsaved sequence from an existing one.
  GSE.GUIEditFrame.IsNewSequence = isNewSequence
  GSE.GUIEditFrame.OriginalSequenceName = isNewSequence and nil or sequenceName
  GSE.GUIEditFrame.Sequence = sequence
  GSE.GUIEditFrame.ClassID = classid
  GSE.GUIEditFrame.Default = sequence.Default
  GSE.GUIEditFrame.PVP = sequence.PVP or sequence.Default
  GSE.GUIEditFrame.Mythic = sequence.Mythic or sequence.Default
  GSE.GUIEditFrame.Raid = sequence.Raid or sequence.Default
  GSE.GUIEditFrame.Dungeon = sequence.Dungeon or sequence.Default
  GSE.GUIEditFrame.Heroic = sequence.Heroic or sequence.Default
  GSE.GUIEditFrame.Party = sequence.Party or sequence.Default
  GSE.GUIEditorPerformLayout(GSE.GUIEditFrame)
  GSE.GUIEditFrame.ContentContainer:SelectTab("config")

  -- GSE-CoA: after the editor layout/tab redraws, force the visible
  -- name editbox to show the user-facing sequence name.  Some redraw paths
  -- reset the AceGUI editbox text even though GSE.GUIEditFrame.SequenceName
  -- is valid, which makes the header appear blank while saving still works.
  if GSE.GUIEditFrame.nameeditbox then
    local displaySequenceName = GSE.GUIEditFrame.SequenceName
    if GSE.isEmpty(displaySequenceName) and GSE.GUIEditFrame.Sequence and not GSE.isEmpty(GSE.GUIEditFrame.Sequence.Name) then
      displaySequenceName = GSE.GUIEditFrame.Sequence.Name
    end
    if not GSE.isEmpty(displaySequenceName) then
      GSE.GUIEditFrame.SequenceName = displaySequenceName
      GSE.GUIEditFrame.nameeditbox:SetText(displaySequenceName)
    end
  end

  incomingframe:Hide()
  if not InCombatLockdown() then
	myUpdateFix()
	GSE.GUIEditFrame:Show()
  end

end

function GSE.getSequenceName()
  
  local names1 = GSE.GetSequenceNames()
  local numberOfSeqs = 0
  local currentSpecID, specname, specicon = GSE.GetCurrentSpecID()
  specname = specname or tostring(currentSpecID or "CLASS")
  local newSeqNameTemp = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters("New"..specname))
  local newSeqName = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters("New"..specname))
  local newSeqNumber=numberOfSeqs+1
  if not GSE.isEmpty(GSELibrary[0]) then
    numberOfSeqs = 0
    for k,v in pairs(GSELibrary[0]) do
      numberOfSeqs = numberOfSeqs + 1
      for i,j in ipairs(v.MacroVersions) do
        GSELibrary[0][k].MacroVersions[tonumber(i)] = GSE.UnEscapeSequence(j)
      end
    end
  end
  if numberOfSeqs <= 0 then
    if not GSE.isEmpty(GSELibrary[GSE.GetCurrentClassID()]) then
      for k,v in GSE.pairsByKeys(names1) do
        numberOfSeqs = numberOfSeqs + 1 
      end
    end
  end
  newSeqNumber=numberOfSeqs+1
  newSeqNameTemp = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters("New"..specname..newSeqNumber..GetTime()))
  newSeqNameTemp = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters(newSeqNameTemp))
  for k,v in GSE.pairsByKeys(names1) do
    local elements = GSE.split(k, ",")
    local classid = GSE.ResolveClassKey(elements[1])
    local sequencename = elements[2]
	if newSeqNameTemp == sequencename then
	  newSeqNumber=numberOfSeqs+1
	  newSeqNameTemp = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters("New"..specname..newSeqNumber..GetTime()))
	  newSeqNameTemp = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters(newSeqNameTemp))
	end
  end
  for name, sequence in pairs(GSELibrary[GSE.GetCurrentClassID()]) do
    if newSeqNameTemp == name then
	  newSeqNumber = numberOfSeqs+1
	  newSeqNameTemp = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters("New"..specname..newSeqNumber..GetTime()))
	  newSeqNameTemp = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters(newSeqNameTemp))
	end
  end
  newSeqNameTemp = GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters(newSeqNameTemp))
  newSeqName =  GSE.TrimWhiteSpace(GSE.LowerAndReplaceSpecialCharacters(newSeqNameTemp))
  return newSeqName
end

function GSE.GUIUpdateSequenceList()
  local names = GSE.GetSequenceNames()
  GSE.GUIViewFrame.SequenceListbox:SetList(names)
end

function GSE.GUIToggleClasses(buttonname)
  if not classradio or not specradio then
    return
  end
  if buttonname == "class" then
    classradio:SetValue(true)
    specradio:SetValue(false)
  else
    classradio:SetValue(false)
    specradio:SetValue(true)
  end
end


function GSE.GUIUpdateSequenceDefinition(classid, SequenceName, sequence)

  -- Changes have been made so save them
  for k,v in ipairs(sequence.MacroVersions) do
    sequence.MacroVersions[k] = GSE.TranslateSequenceFromTo(v, GetLocale(), "enUS", SequenceName)
    sequence.MacroVersions[k] = GSE.UnEscapeSequence(sequence.MacroVersions[k])

    -- GSE-CoA: normalize spellbook-generated spell tokens before saving.
    sequence.MacroVersions[k] = GSE.NormalizeExecutionMacroVersion(sequence.MacroVersions[k])
  end

  if not GSE.isEmpty(SequenceName) then
    if GSE.isEmpty(classid) then
      classid = GSE.GetCurrentClassID()
    end
    if not GSE.isEmpty(SequenceName) then
      local vals = {}
      local editorIsNew = GSE.GUIEditFrame and GSE.GUIEditFrame.IsNewSequence
      local originalName = GSE.GUIEditFrame and GSE.GUIEditFrame.OriginalSequenceName or nil
      local isRename = not editorIsNew and not GSE.isEmpty(originalName) and originalName ~= SequenceName

      -- A rename must never overwrite another existing sequence.
      if isRename and GSELibrary[classid] and GSELibrary[classid][SequenceName] then
        GSE.GUIEditFrame:SetStatusText("A sequence named " .. SequenceName .. " already exists.")
        GSE.Print("GSE-CoA: Rename cancelled because " .. tostring(SequenceName) .. " already exists.", "GUI")
        return
      end

      vals.action = isRename and "RenameReplace" or "Replace"
      vals.sequencename = SequenceName
      vals.originalname = originalName
      sequence.Name = SequenceName
      -- Preserve the existing InternalMacroName across renames.  This keeps the
      -- secure button identity stable while only changing the user-facing name.
      GSE.GetOrCreateInternalMacroName((not GSE.isEmpty(originalName) and originalName) or SequenceName, sequence, classid)
      vals.sequence = sequence
      vals.classid = classid
      table.insert(GSE.OOCQueue, vals)

      if GSE.GUIEditFrame then
        -- Once the first save has been queued, later saves from this editor
        -- operate on the user-selected storage name rather than the generated
        -- placeholder.  The queued Replace action creates the record normally.
        GSE.GUIEditFrame.OriginalSequenceName = SequenceName
        GSE.GUIEditFrame.IsNewSequence = false
        GSE.isNewFirstTimeCreated = false
      end
      GSE.GUIEditFrame:SetStatusText(string.format(L["Sequence %s saved."], SequenceName))
    end
  end
end


function GSE.GUIGetColour(option)
  hex = string.gsub(option, "#","")
  return tonumber("0x".. string.sub(option,5,6))/255, tonumber("0x"..string.sub(option,7,8))/255, tonumber("0x"..string.sub(option,9,10))/255
end

function  GSE.GUISetColour(option, r, g, b)
  option = string.format("|c%02x%02x%02x%02x", 255 , r*255, g*255, b*255)
end


function GSE:OnInitialize()
    GSE.GUIRecordFrame:Hide()
    GSE.GUIVersionFrame:Hide()
    GSE.GUIEditFrame:Hide()
    GSE.GUIViewFrame:Hide()
end


function GSE.OpenOptionsPanel()
  local config = LibStub:GetLibrary("AceConfigDialog-3.0")
  config:Open("GSE")
  --config:SelectGroup("GSSE", "Debug")

end
