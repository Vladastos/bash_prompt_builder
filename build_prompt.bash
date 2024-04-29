#!/bin/bash
PROMPTORIUM_DIR="$HOME/.config/bashconfig/promptorium"
FUNCTIONS_DIR="$PROMPTORIUM_DIR/functions"
CONFIG_FILE="$FUNCTIONS_DIR/config.bash"


# shellcheck source=/dev/null
source "$CONFIG_FILE"


# shellcheck source=/dev/null
source "$FUNCTIONS_DIR/utils.bash" # Imports the utils function as well as setting the theme (icons, colors, etc)


# shellcheck source=/dev/null
source "$FUNCTIONS_DIR/prompt_elements.bash"

function build_prompt(){
    
    local EXIT="$?"
    set_state $EXIT


    PS1="$(build_logo)$(build_user_container)$(build_current_dir_container)\n"
    PS1+="$(build_arrow)"
}
