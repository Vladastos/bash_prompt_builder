#!/bin/bash
function trim_input(){
	local input="$1"
	local output
	output="$(echo "$input" | sed 's/#.*//g' | sed '/^\s*$/d')"
	echo "$output"
}

function read_input(){
	local input
	if [ -f "$bookmark_file" ]; then
		input="$(cat "$bookmark_file")"
	fi
	echo "$input"
}

function open_fzf() {
	local trimmed_input="$1"
	local selected_bookmark
	selected_bookmark="$(echo "$trimmed_input" | fzf --height 40% --reverse --border --margin 2% --border-label=Bookmarks )"
	output=$selected_bookmark
}

function add_bookmark(){
	local bookmark_file="$HOME/.config/bashconfig/bookmarks/bookmarks"
	if ! grep -Fxq "$PWD" "$bookmark_file"; then
		echo "$PWD" >> "$bookmark_file"
	else 
		echo "Bookmark already exists"
	fi
	echo "Bookmark added"
}

function remove_bookmark(){
	if grep -Fxq "$PWD" "$bookmark_file"; then
		local bookmarks
		bookmarks="$(cat "$bookmark_file")"
		local new_bookmarks
		for bookmark in $bookmarks; do
			if [ "$PWD" != "$bookmark" ]; then
				new_bookmarks+="$bookmark"$'\n'
			fi
		done
		echo "$new_bookmarks" > "$bookmark_file"
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
		exit
	fi
	if [ "$args" == "-r" ]; then
		remove_bookmark
		exit
	fi
}

main() {
	local bookmark_file="$HOME/.config/bashconfig/bookmarks/bookmarks"
	local input
	local output
	parse_args "$@"
	input="$(read_input)"
	local trimmed_input
	trimmed_input="$(trim_input "$input")"
	open_fzf "$trimmed_input"
	echo "$output"
}

main "$@"
