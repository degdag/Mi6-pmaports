#!/bin/sh

(
	green="\033[32m"
	reset="\033[0m"
	echo -e "${green}PROTIP:${reset} ^i (ctrl+i) does autocompletion"
)
exec sh
