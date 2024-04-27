#!/bin/bash

build_prompt(){

    local EXIT="$?"
    local SHOW_GIT_BRANCH=0
    local SHOW_SSH_AGENT=0
    local SHOW_SSH_KEYS=0
    local SHOW_SUDO_STATUS=0
    local SHOW_STATE_ICON=1
    local SHOW_BOOKMARKS=1
    local user="\u"
    local hostname="\h"
    local ansi_reset="\[\033[0m\]"
 
    function set_state(){
        state_color=(${color_success[0]} ${color_success[1]})
        if [ "$EXIT" -eq 1 ]; then
            state_color=(${color_error[0]} ${color_error[1]})        
        fi
        
    }

    function set_theme(){
        function set_line_style(){
            corner_up_left="╭"
            corner_up_right="╮"
            corner_down_left="╰"
            corner_down_right="╯"
            line_horizontal="─"
            line_vertical="│"

        }
        function set_colors(){
            blue="\[\033[0;34m\]"
            background_blue="\[\033[44m\]"
            green="\[\033[0;32m\]"
            background_green="\[\033[42m\]"
            red="\[\033[0;31m\]"
            background_red="\[\033[41m\]"
            yellow="\[\033[0;33m\]"
            background_yellow="\[\033[43m\]"
            purple="\[\033[0;35m\]"
            background_purple="\[\033[45m\]"
            black="\[\033[0;30m\]"
            background_black="\[\033[40m\]"
            white="\[\033[0;37m\]"
            background_white="\[\033[47m\]"
            
            color_primary=("$blue" "$background_blue")
            color_secondary=("$green" "$background_green")
            color_tertiary=("$yellow" "$background_yellow")
            color_quaternary=("$purple" "$background_purple")
            color_success=("$green" "$background_green")
            color_error=("$red" "$background_red")
            color_neutral=("$white" "$background_white")
            color_black=("$black" "$background_black")
                
            user_container_color=("${color_primary[0]}" "${color_primary[1]}")
            folder_icon_color=("${color_primary[0]}" "${color_primary[1]}")
        }
        function set_icons(){
            check_icon="✔"
            cross_icon="✖"
            arrow_icon="⯈"
            home_icon=""
            cog_icon="⚙"
            folder_icon=""
            lock_icon=""
            lock_opened_icon=""
            key_icon=""
            key_icon_filled=""
            user_icon=""
            host_icon="󰇅"
            bookmark_icon=""
            arch_icon="󰣇"
            debian_icon=""
            fedora_icon=""
            ubuntu_icon=""
            manjaro_icon=""
            mint_icon=""


            git_icon=""
            unstaged="◉"
     		untracked="○"
 	    	branch_ahead="↑"
 		    branch_behind="↓"

            container_start=""
            container_end=""
            #container_start="█"
            #container_end="█"
        }
        set_line_style
        set_colors
        set_icons
        #TODO: implement different themes and themes customization
    }
 
    function build_logo(){
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
        }

        set_logo

        local initial_line="${state_color[0]}$corner_up_left${line_horizontal}$ansi_reset"
        local logo="${color_primary[0]}$logo$ansi_reset"
        local user="${color_tertiary[0]}$user$ansi_reset"

        echo "$initial_line ${logo} "
    }

    function build_user_container(){
        local user="${color_black[0]}${user_container_color[1]} $user_icon $user$ansi_reset"
        local host="${color_black[0]}${user_container_color[1]} $host_icon $hostname $ansi_reset"
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
    
    function build_git_branch_container(){
        
        function set_git_status(){
            git_status=$(git status 2> /dev/null)
            if [ -z "$git_status" ]; then
                return
            fi
        }
        function set_git_branch(){
            git_branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
        }
        function set_git_container_colors(){
            if [ "$git_branch" == "master" ] || [ "$git_branch" == "main" ]; then
                git_container_colors=("${color_secondary[0]}" "${color_secondary[1]}")
            else
                git_container_colors=("${color_tertiary[0]}" "${color_tertiary[1]}")
            fi
        }
        function build_git_status_icons(){

            local local_status_icon=""
            local remote_status_icon=""

            if [ -n "$(grep "nothing to commit" <<<"$git_status")" ]; then
                local_status_icon="$check_icon"
            fi
            if [ -n "$(grep "Changes to be committed" <<<"$git_status")" ]; then
                
                if [ -n "$(grep "Untracked files" <<<"$git_status")" ] || [ -n "$(grep "Changes not staged for commit" <<<"$git_status")" ]; then
                    local_status_icon="$untracked"
                else
                    local_status_icon="$unstaged"
                fi
            elif [ -n "$(grep "Changes not staged for commit" <<<"$git_status")" ] || [ -n "$(grep "Untracked files" <<<"$git_status")" ]; then
                local_status_icon="$untracked"
            fi
            if [ -n "$(grep "Your branch is ahead of" <<<"$git_status")" ]; then
                remote_status_icon=" $branch_ahead"
            fi
            if [ -n "$(grep "Your branch is behind of" <<<"$git_status")" ]; then
                remote_status_icon=" $branch_behind"
            fi
            echo "${git_container_colors[1]}$local_status_icon${color_error[0]}${git_container_colors[1]}$remote_status_icon"
        }
        if [ "$SHOW_GIT_BRANCH" -eq 0 ]; then
            return
        fi
        set_git_status
        set_git_branch
        set_git_container_colors
        if [ -z "$git_branch" ]; then
            echo "${color_black[0]}$container_end$ansi_reset"
            return
        fi
        
        local git_branch="${color_black[0]}${git_container_colors[1]} $git_icon $git_branch"
        local git_branch_container_start="${git_container_colors[0]}${color_black[1]}$container_start$ansi_reset"
        local git_branch_container_end="${git_container_colors[0]}$container_end$ansi_reset"
        echo "$git_branch_container_start$git_branch $(build_git_status_icons) $git_branch_container_end "
    }

        function build_bookmark_container(){
                local bookmark_file="$HOME/.config/bashconfig/bookmarks/bookmarks"
                local bookmarks="$(cat "$bookmark_file")"
                local is_bookmark 
                is_bookmark="0"
                for bookmark in $bookmarks; do
                    if [ "$PWD" == "$bookmark" ]; then
                        is_bookmark="1"
                        break
                    fi
                done
            if [ "$SHOW_BOOKMARKS" -eq 0 ] || [  "$is_bookmark" == "0" ]; then
                return
            fi
            local bookmark_container_start="${color_black[0]}${color_quaternary[1]}$container_end$ansi_reset"
            local bookmark_icon="${color_black[0]}${color_quaternary[1]} $bookmark_icon $ansi_reset"
            local bookmark_container_end="${color_quaternary[0]}$container_end$ansi_reset"
            local bookmark="$bookmark_container_start$bookmark_icon$ansi_reset$bookmark_container_end"
            echo "$bookmark"
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

    set_theme
    set_state $EXIT


    PS1="$(build_logo)$(build_user_container)$(build_current_dir_container)\n"
    PS1+="$(build_arrow)"
}
