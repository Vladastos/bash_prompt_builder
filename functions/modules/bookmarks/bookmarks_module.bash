function bk(){
	local bookmark_script="$FUNCTIONS_DIR/modules/bookmarks/bookmarks_exec.bash"
	if [ $# -eq 0 ]; then
		local selected_bookmark
		selected_bookmark=$(bash "${bookmark_script}")
		cd "$selected_bookmark" || exit
	else
		bash "${bookmark_script}" "$@"
	fi
}

export -f bk