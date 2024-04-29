#!/bin/bash

function set_colors(){
    export ansi_reset="\[\033[0m\]"
    export blue="\[\033[0;34m\]"
    export background_blue="\[\033[44m\]"
    export green="\[\033[0;32m\]"
    export background_green="\[\033[42m\]"
    export red="\[\033[0;31m\]"
    export background_red="\[\033[41m\]"
    export yellow="\[\033[0;33m\]"
    export background_yellow="\[\033[43m\]"
    export purple="\[\033[0;35m\]"
    export background_purple="\[\033[45m\]"
    export black="\[\033[0;30m\]"
    export background_black="\[\033[40m\]"
    export white="\[\033[0;37m\]"
    export background_white="\[\033[47m\]"
           
    
}

function set_theme_colors(){
    export color_primary=("$blue" "$background_blue")
    export color_secondary=("$green" "$background_green")
    export color_tertiary=("$yellow" "$background_yellow")
    export color_quaternary=("$purple" "$background_purple")
    export color_success=("$green" "$background_green")
    export color_error=("$red" "$background_red")
    export color_neutral=("$white" "$background_white")
    export color_black=("$black" "$background_black")

    export user_container_color=("${color_primary[0]}" "${color_primary[1]}")
    export folder_icon_color=("${color_primary[0]}" "${color_primary[1]}")
}

function set_line_style(){
    export corner_up_left="╭"
    export corner_up_right="╮"
    export corner_down_left="╰"
    export corner_down_right="╯"
    export line_horizontal="─"
    export line_vertical="│"
}

function set_icons(){
    export check_icon="✔"
    export cross_icon="✖"
    export arrow_icon="⯈"
    export home_icon=""
    export cog_icon="⚙"
    export folder_icon=""
    export lock_icon=""
    export lock_opened_icon=""
    export key_icon=""
    export key_icon_filled=""
    export user_icon=""
    export host_icon="󰇅"
    export bookmark_icon=""
    export arch_icon="󰣇"
    export debian_icon=""
    export fedora_icon=""
    export ubuntu_icon=""
    export manjaro_icon=""
    export mint_icon=""


    export git_icon=""
    export unstaged="◉"
    export untracked="○"
 	export branch_ahead="↑"
 	export branch_behind="↓"

    export container_start=""
    export container_end=""
    
    #container_start="█"
    #container_end="█"
}

function set_logo(){
    local hostname="$(hostnamectl)"
    if [ -n "$(grep "Arch Linux" <<<"$hostname")" ]; then
        logo="$arch_icon"
    elif [ -n "$(grep "Debian" <<<"$hostname")" ]; then
        logo="$debian_icon"
    elif [ -n "$(grep "Fedora" <<<"$hostname")" ]; then
        logo="$fedora_icon"
    elif [ -n "$(grep "Ubuntu" <<<"$hostname")" ]; then
        logo="$ubuntu_icon"
    else
        logo="$cog_icon"
    fi
    export logo
}

function set_theme(){
    set_colors
    set_line_style
    set_theme_colors
    set_icons
    set_logo
}

function set_state(){
    local exit_state="$1"
    state_color=(${color_success[0]} ${color_success[1]})
    if [ "$exit_state" -eq 1 ]; then
        state_color=(${color_error[0]} ${color_error[1]})        
    fi
    
}

export -f set_state

set_theme