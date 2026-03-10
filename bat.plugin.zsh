# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: bat
# @brief: Set `bat` as a cat replacement.
# @repository: https://github.com/johnstonskj/zsh-bat-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# Public variables:
#
# * `BAT`; plugin-defined global associative array with the following keys:
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_OLD_MANPAGER`; remember previous value of MANPAGER.
#   * `_OLD_MANROFFOPT`; remember previous value of MANROFFOPT.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

#
# @description
#
# Set the environment variables `MANPAGER' and `MANROFFOPT' for use with
# bat as the pager. Also, alias `cat` to use bat also.
#
bat_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save bat MANPAGER
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"

    @zplugins_envvar_save bat MANROFFOPT
    export MANROFFOPT="-c"

    @zplugins_define_alias bat cat $(which bat)
    @zplugins_define_alias bat battail 'bat --paging=never -l log'
}

# @internal
bat_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore bat MANPAGER
    @zplugins_envvar_restore bat MANROFFOPT
}
