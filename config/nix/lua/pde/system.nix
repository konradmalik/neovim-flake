{
  notesPath,
  spellPath,
  writeTextDir,
}:
writeTextDir "lua/pde/system.lua" ''
  return {
    notes_path = "${if notesPath == null then "nil" else notesPath}",
    spell_path = "${if spellPath == null then "nil" else spellPath}",
  }
''
