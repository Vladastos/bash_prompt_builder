#!/bin/bash
BOOKMARKS_DIR="$FUNCTIONS_DIR/modules/bookmarks"
BOOKMARKS_FILE="$BOOKMARKS_DIR/bookmarks"
function trim_input(){
	local input="$1"
	local output
	output="$(echo "$input" | sed 's/#.*//g' | sed '/^\s*$/d')"
	echo "$output"
}

function read_input(){
	local input
	if [ -f "$BOOKMARKS_FILE" ]; then
		input="$(cat "$BOOKMARKS_FILE")"
	fi
	echo "$input"
}

function open_fzf() {
	local trimmed_input="$1"
	local preview_cmd
	preview_cmd="exa --tree --level=2 --git-ignore --group-directories-first --color=always --icons {}"
	local selected_bookmark
	selected_bookmark="$(echo "$trimmed_input" | fzf-tmux -h 60% -w 80% --preview-window=up:50% --preview "$preview_cmd")"
	output=$selected_bookmark
}

function add_bookmark(){
	if ! grep -Fxq "$PWD" "$BOOKMARKS_FILE"; then
		echo "$PWD" >> "$BOOKMARKS_FILE"
	else 
		echo "Bookmark already exists"
		return
	fi
	echo "Bookmark added"
}

function remove_bookmark(){
	if grep -Fxq "$PWD" "$BOOKMARKS_FILE"; then
		local bookmarks
		bookmarks="$(cat "$BOOKMARKS_FILE")"
		local new_bookmarks
		for bookmark in $bookmarks; do
			if [ "$PWD" != "$bookmark" ]; then
				new_bookmarks+="$bookmark"$'\n'
			fi
		done
		echo "$new_bookmarks" > "$BOOKMARKS_FILE"
		echo "Bookmark removed"
	else
		echo "Bookmark not found"
	fi
}

function parse_args() {
	local args
	args="$1"
	if [ "$args" == "-a" ]; then
		add_bookmark
		return 1
	fi
	if [ "$args" == "-r" ]; then
		remove_bookmark
		return 1
	fi
}

main() {
	local input
	local output
	parse_args "$@" || return 0
	input="$(read_input)"
	local trimmed_input
	trimmed_input="$(trim_input "$input")"
	open_fzf "$trimmed_input"
	echo "$output"
}

function bk(){
	if [ $# -eq 0 ]; then
		local selected_bookmark
		selected_bookmark=$(main "$@")
		cd "$selected_bookmark" || exit
	else
		main "$@"
	fi
}

function ff(){

	function find_bookmark_parent() {
		if [ "$1" == "$HOME" ] || [ "$1" == "/" ]; then
			echo "$1"
			return
		fi
		local bookmarks
		bookmarks="$(cat "$BOOKMARKS_FILE")"
		for bookmark in $bookmarks; do
			if [ "$1" == "$bookmark" ]; then
				echo "$bookmark"
				return
			fi
		done
		find_bookmark_parent "$(dirname "$1")"

	}
	local selection
	local exa_cmd
	local bat_cmd
	exa_cmd="exa --icons --tree --level=2 --group-directories-first"
	bat_cmd="bat --color=always"
	selection=$(fzf-tmux --walker-root=$(find_bookmark_parent "$PWD") -h 60% -w 80% --preview "if [ -d {} ]; then $exa_cmd {}; else $bat_cmd {}; fi")
	if [ -d "$selection" ]; then
		cd "$selection" || exit
	else
		cd "$(dirname "$selection")" || exit
	fi

}

export -f bk ff
