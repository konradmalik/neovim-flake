{
  notesPath,
  spellPath,
  writeTextDir,
  lib,
}:
writeTextDir "lua/pde/system.lua" (
  ''
    return {
  ''
  + lib.optionalString (notesPath != null) ''
    notes_path = "${notesPath}",
  ''
  + lib.optionalString (spellPath != null) ''
    spell_path = "${spellPath}",
  ''
  + ''
    }
  ''
)
