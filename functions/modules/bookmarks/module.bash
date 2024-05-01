#shellcheck source=/dev/null
source "$FUNCTIONS_DIR/modules/bookmarks/bookmarks.bash"

    function build_bookmark_container(){
        local bookmark_file="$BOOKMARKS_FILE"
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
