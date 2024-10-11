rockspec_format = "3.0"
package = "neovim-flake"
version = "scm-1"
source = {
    url = "git+https://github.com/konradmalik/neovim-flake",
}
dependencies = {
    "lua >= 5.1",
}
test_dependencies = {
    "lua >= 5.1",
}
build = {
    type = "builtin",
}

