{
  lib,
  writeShellScriptBin,
  lua-language-server,
}:
# metapath must be writable
writeShellScriptBin "nvim-typecheck" ''
  check_folder=$1

  if [[ ! $check_folder ]]; then
    echo "must provide folder to check"
    echo "if there will be .luarc.json, it will be read automatically"
    exit 1
  fi

  ${lib.getExe lua-language-server} --check="$check_folder"
''
