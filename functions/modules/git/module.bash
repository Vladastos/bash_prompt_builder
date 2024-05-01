
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
