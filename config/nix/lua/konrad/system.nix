{ notesPath, repositoryPath, writeTextDir }:
let
  argOrNil = x: if x == null then "nil" else x;
in
writeTextDir "lua/konrad/system.lua" ''
  return {
     notes_path = "${argOrNil notesPath}",
     repository_path = "${argOrNil repositoryPath}",
  }
''
