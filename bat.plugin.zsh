# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: bat
# Repository: https://github.com/johnstonskj/zsh-bat-plugin
#
# Description:
#
#   Simple environment setup for using `bat` as a cat replacement.
#
# Public variables:
#
# * `BAT`; plugin-defined global associative array with the following keys:
#   * \`_PLUGIN_DIR\`; the directory the plugin is sourced from.
#   * \`_FUNCTIONS\`; a list of all functions defined by the plugin.
#   * \`_OLD_MANPAGER\`; remember previous value of MANPAGER.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA BAT
BAT[_PLUGIN_DIR]="${0:h}"
BAT[_ALIASES]=""
BAT[_FUNCTIONS]=""

# Saving the current state for any modified global environment variables.
BAT[_OLD_MANPAGER]="${MANPAGER}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `BAT[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.bat_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${BAT[_FUNCTIONS]}" ]]; then
        BAT[_FUNCTIONS]="${fn_name}"
    elif [[ ",${BAT[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        BAT[_FUNCTIONS]="${BAT[_FUNCTIONS]},${fn_name}"
    fi
}
.bat_remember_fn .bat_remember_fn

.bat_define_alias() {
    local alias_name="${1}"
    local alias_value="${2}"

    alias ${alias_name}=${alias_value}

    if [[ -z "${BAT[_ALIASES]}" ]]; then
        BAT[_ALIASES]="${alias_name}"
    elif [[ ",${BAT[_ALIASES]}," != *",${alias_name},"* ]]; then
        BAT[_ALIASES]="${BAT[_ALIASES]},${alias_name}"
    fi
}
.bat_remember_fn .bat_remember_alias

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
bat_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${BAT[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done
    
    # Remove all remembered aliases.
    local aliases
    IFS=',' read -r -A aliases <<< "${BAT[_ALIASES]}"
    local alias
    for alias in ${aliases[@]}; do
        unalias "${alias}"
    done

    # Reset global environment variables .
    export MANPAGER="${BAT[_OLD_MANPAGER]}"
    
    # Remove the global data variable.
    unset BAT

    # Remove this function.
    unfunction bat_plugin_unload
}

############################################################################
# Plugin-defined Aliases
############################################################################

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

.bat_define_alias cat 'bat'
.bat_define_alias battail 'bat --paging=never -l log'

############################################################################
# Initialize Plugin
############################################################################

true
