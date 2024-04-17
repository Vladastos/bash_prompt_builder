#!/bin/bash

build_prompt(){
    local EXIT="$?"
    local user="\u"
    local dir="\w"
    local ansi_reset="\[\033[0m\]"
    function set_state(){
        local exit_code="$1"
        state_color=(${color_success[0]} ${color_success[1]})
        if [ "$exit_code" -eq 1 ]; then
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
            
            color_primary=($blue $background_blue)
            color_secondary=($green $background_green)
            color_tertiary=($yellow $background_yellow)
            color_quaternary=($purple $background_purple)
            color_success=($green $background_green)
            color_error=($red $background_red)
            color_neutral=($white $background_white)
            color_black=($black $background_black)
            
        }
        function set_icons(){
            check_icon="✔"
            cross_icon="✖"
            arrow_icon="⯈"
            logo="󰣇"
            cog_icon="⚙"
            folder_icon=""

            git_icon=""
            unstaged="◉"
     		untracked="○"
 	    	branch_ahead="↑"
 		    branch_behind="↓"

            container_start=""
            container_end=""
        }
        set_line_style
        set_colors
        set_icons
        #TODO: implement different themes and themes customization
    }
    function build_logo(){
        local initial_line="${state_color[0]}$corner_up_left${line_horizontal}$ansi_reset"
        local logo="${color_primary[0]}$logo$ansi_reset"
        local user="${color_tertiary[0]}$user$ansi_reset"

        echo "$initial_line ${logo} "
    }

    function build_user_container(){
        local user="${color_black[0]}${state_color[1]} $user $ansi_reset"
        local prompt_container_start="${state_color[0]}$container_start$ansi_reset"
        local prompt_container_end="${state_color[0]}$container_end$ansi_reset"
        echo "$prompt_container_start$user$prompt_container_end "
    }

    function build_current_dir_container(){
        local line="${color_black[0]}$line_horizontal$line_horizontal$ansi_reset "
        local dir="${color_primary[0]}${color_black[1]} $folder_icon $dir $ansi_reset"
        local prompt_container_start="${color_black[0]}$container_start$ansi_reset"
        local prompt_container_end="${color_black[0]}$container_end$ansi_reset"
        echo "$line$prompt_container_start$dir$prompt_container_end $(build_git_branch_container)"   
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
                git_container_colors=(${color_secondary[0]} ${color_black[1]})
            else
                git_container_colors=(${color_tertiary[0]} ${color_black[1]})
            fi
        }
        function build_git_status_icons(){

            local local_status_icon=""
            local remote_status_icon=""

            if [ -n "$(grep "nothing to commit" <<<"$git_status")" ]; then
                local_status_icon="${color_success[0]}${color_black[1]}$check_icon"
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
            echo "${color_black[1]}$local_status_icon${color_quaternary[0]}${color_black[1]}$remote_status_icon"
        }
        set_git_status
        set_git_branch
        set_git_container_colors
        if [ -z "$git_branch" ]; then
            return
        fi
        
        local git_branch="${git_container_colors[0]}${git_container_colors[1]} $git_icon $git_branch"
        local git_branch_container_start="${color_black[0]}$container_start$ansi_reset"
        local git_branch_container_end="${color_black[0]}$container_end$ansi_reset"
        echo "$git_branch_container_start$git_branch $(build_git_status_icons) $git_branch_container_end "
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
