#!/bin/bash

source "$FUNCTIONS_DIR/modules/bookmarks/module.bash"
source "$FUNCTIONS_DIR/modules/git/module.bash"

function build_logo(){
    
    local initial_line="${state_color[0]}$corner_up_left${line_horizontal}$ansi_reset"
    local logo="${color_primary[0]}$logo$ansi_reset"

    echo "$initial_line ${logo} "
}

function build_user_container(){
    local user="${color_black[0]}${user_container_color[1]} $user_icon \u $ansi_reset"
    local host="${color_black[0]}${user_container_color[1]}$host_icon \h $ansi_reset"
    local status_container
    status_container="$(build_status_container)"
    local prompt_container_start="${user_container_color[0]}$container_start$ansi_reset"
    echo "$prompt_container_start$user$host$status_container"
}

function build_current_dir_container(){
    

    function build_dir_string(){
        local dir=$(pwd | sed -e "s,^$HOME,$home_icon ,")
        echo "${color_neutral[0]}${color_black[1]}  $dir "
    }



    local bookmark_container="$(build_bookmark_container)"
    local git_branch_container="$(build_git_branch_container)"
    local prompt_container_end=""
    if [ "$git_branch_container" == "" ] && [ "$bookmark_container" == "" ]; then
        local prompt_container_end="${color_black[0]}$container_end$ansi_reset"
    fi
    local line="${color_black[0]}$line_horizontal$line_horizontal$ansi_reset "
    local icon_container_start="${folder_icon_color[0]}$container_start$ansi_reset"
    local icon_container_end="${folder_icon_color[0]}${color_black[1]}$container_end$ansi_reset"
    local icon="$icon_container_start${color_black[0]}${folder_icon_color[1]} $folder_icon $icon_container_end$ansi_reset"
    local dir
    dir="$(build_dir_string)$ansi_reset"
    echo "$line$prompt_container_start$icon$dir$git_branch_container$bookmark_container$prompt_container_end"   
}

function build_status_container(){
    function build_state_icon(){
        if [ "$SHOW_STATE_ICON" -eq 0 ]; then
            return
        fi
        if [ "$EXIT" -eq 0 ]; then
            state_icon="$check_icon"
        else
            state_icon="$cross_icon"
        fi
        printf "${state_color[0]}${color_black[1]}  $state_icon $ansi_reset"
    }
    function build_ssh_agent_icon(){
        if [ "$SHOW_SSH_AGENT" -eq 0 ]; then
            return
        fi
        local number_of_keys=""
        function get_ssh_keys(){

            local ssh_keys
            ssh_keys=""
                ssh_keys=$(ssh-add -l 2> /dev/null)
            local ssh_add_exit_code=$?
            if [ "$ssh_add_exit_code" -ne 0  ]; then
                return
            fi
            if [ "$SHOW_SSH_KEYS" -eq 1 ]; then
            number_of_keys=" $(wc -l <<<"$ssh_keys")"
            fi
        }

        local ssh_agent_icon=""
        local ssh_agent_pid=$(echo "$SSH_AGENT_PID")

        if [ -n "$ssh_agent_pid" ]; then
            get_ssh_keys
            ssh_agent_icon="$key_icon_filled$number_of_keys"
        else
            ssh_agent_icon="$key_icon"
        fi
        printf "${color_neutral[0]}${color_black[1]} $ssh_agent_icon $ansi_reset"
    }
    function build_sudo_icon(){
        function set_has_sudo(){
                sudo -nv 2> /dev/null
                has_sudo=$?
        }
        if [ "$SHOW_SUDO_STATUS" -eq 0 ]; then
            return
        fi
        local sudo_icon=""
        local has_sudo
        set_has_sudo

        if [ "$has_sudo" -eq 0 ]; then
            sudo_icon="$lock_opened_icon"
        else
            sudo_icon="$lock_icon"
        fi
        printf "${color_neutral[0]}${color_black[1]} $sudo_icon $ansi_reset"
    }
    local status_container_start="${user_container_color[0]}${color_black[1]}$container_end$ansi_reset"
    local status_container_end="${color_black[0]}$container_end $ansi_reset"

    if [ "$SHOW_STATE_ICON" -eq 0 ] && [ "$SHOW_SSH_AGENT" -eq 0 ] && [ "$SHOW_SUDO_STATUS" -eq 0 ]; then
        status_container_end="${color_secondary[0]}$container_end $ansi_reset"
        printf "$status_container_end"
        return
        
    fi
    echo "$status_container_start$(build_state_icon)$(build_ssh_agent_icon)$(build_sudo_icon)$status_container_end"

}

function build_arrow(){
    local arrow="${state_color[0]}$corner_down_left$arrow_icon$ansi_reset"
    local dollar_sign=" ${color_tertiary[0]}$ $ansi_reset"
    echo "$arrow$dollar_sign"
}

export -f build_logo build_user_container build_current_dir_container build_arrow
