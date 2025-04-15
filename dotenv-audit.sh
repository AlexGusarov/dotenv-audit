#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#               _          
# |/  _. ._  o |_) o ._ _| 
# |\ (_| |_) | |_) | | (_| 
#        |                 
#######################################
# Minimalistic .env audit tool
# Zero dependencies.
# Compares two .env-like files for:
# - Missing variables
# - Extra variables
# - Variables with different values
# Author: Alexey Gusarov
#######################################

VERSION="1.0.0"

#---Help---
show_help () {
  cat <<EOF
  dotenv-audit v$VERSION

Usage:
  $(basename "$0") .env .env.example

Compares two .env-like files:
- Shows missing variables
- Shows extra variables
- Detects differing values

Options:
  -h, --help      Show this help
  -v, --version   Show version
EOF
exit 0
}
#------------

#---Colors---
RED=$( tput setaf 1)
YELLOW=$( tput setaf 3)
GREEN=$( tput setaf 2)
BLUE=$( tput setaf 4)
RESET=$( tput sgr0)
#-------------

#---Logging---
log () { echo "${BLUE}$1${RESET}"; }
log_ok () { echo "${GREEN}$1${RESET}"; }
log_warn () { echo "${YELLOW}$1${RESET}"; }
log_error () { echo "${RED}$1${RESET}"; }
#-------------

#---Validation---
[[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help")  ]] && show_help
[[ $# -eq 1 && ( "$1" == "-v" || "$1" == "--version") ]] \
&& echo "$VERSION - may the env be with you" && exit 0
[[ $# -ne 2 ]] && log_error "Expected 2 arguments: .env and .env.example" \
 && show_help
[[ ! -f "$1" ]] && log_error "File not founded: $1" && exit 1
[[ ! -f "$2" ]] && log_error "File not founded: $2" && exit 1
#----------------

#---Args---
FILE="$1"
EXAMPLE="$2"
#----------

#---Utilities---
parse_keys () {
  local file=$1
  grep -v '^#' "$file" | grep '=' | cut -d '=' -f1 | sed 's/ *$//' | sort
  }

parse_value () {
  local key=$1
  local file=$2

  grep -E "^$key=" "$file" | cut -d "=" -f2-
  }

repeat_char () {
  local char="$1"
  local count="$2"
  local out=""

  for ((i=0; i<count; i++)); do
    out+="$char"
  done
  echo "$out"
  }

#---------------

log "Starting comparsion..."

keys_1=$(parse_keys "$FILE")
keys_2=$(parse_keys "$EXAMPLE")

missing_keys=$(comm -23 <( echo "$keys_2" | sort) <( echo "$keys_1" ))
extra_keys=$(comm -13 <( echo "$keys_2" | sort) <( echo "$keys_1" ))
common_keys=$(comm -12 <( echo "$keys_2" | sort) <( echo "$keys_1" ))

compare_and_print_table () {
  local missing="$1"
  local extra="$2"
  local common="$3"
  local col_width=25 # width of column
  local line="+$(repeat_char "-" $(($col_width + 2)))+$(repeat_char "-" $(($col_width + 2)))+"

  missing_arr=()
  while IFS= read -r str; do
    missing_arr+=("$str")
  done <<< "$missing"

  extra_arr=()
  while IFS= read -r str; do
    extra_arr+=("$str")
  done <<< "$extra"
  
  local max_lines=${#missing_arr[@]}
  [ ${#extra_arr[@]} -gt $max_lines ] && max_lines=${#extra_arr[@]}
  
  keys_with_diff_values=()

  while IFS= read -r new_key; do
    val1=$(parse_value "$new_key" "$FILE")
    val2=$(parse_value "$new_key" "$EXAMPLE")
  
    if [ "$val1" != "$val2" ]; then
      keys_with_diff_values+=("$new_key")
   fi
  done <<< "$common_keys"
 
  echo 
  echo "$line"
  printf "| ${YELLOW}%-*s${RESET} | ${YELLOW}%-*s${RESET} |\n" \
  $col_width "Missing variables" $col_width "Extra variables"
  echo "$line"

  for ((i=0; i<max_lines; i++)); do
    printf "| %-*s | %-*s |\n" \
    $col_width "${missing_arr[i]}" $col_width "${extra_arr[i]}"
  done
  echo "$line"

  if [ ${#keys_with_diff_values[@]} -gt 0 ]; then
    printf "| ${YELLOW}%-*s${RESET}|\n" $(($col_width * 2 + 4)) \
    "Variables with different values"
    echo "$line"
    for new_var in "${keys_with_diff_values[@]}"; do
      printf "| %-53s |\n" "$new_var"
    done
    echo "$line"
    fi
    echo

}

compare_and_print_table "$missing_keys" "$extra_keys" "$common_keys"
