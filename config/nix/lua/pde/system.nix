{
  repositoryPath,
  obsidianPath,
  writeTextDir,
}:
writeTextDir "lua/pde/system.lua" ''
  return {
    repository_path = "${if repositoryPath == null then "nil" else repositoryPath}",
    notes_path = "${if obsidianPath == null then "nil" else obsidianPath}",
  }
''
