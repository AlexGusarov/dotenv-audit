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
  --fix           Add missing keys to .env with empty values
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

#---Args and flags---
STRICT_MODE=false
FIX_MODE=false
POSITIONAL_ARGS=()
#----------

#---Parse args-----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fix)
    FIX_MODE=true
    shift
    ;;
    --strict)
    STRICT_MODE=true
    shift
    ;;
    -h|--help)
    show_help
    ;;
    -v|--version)
    echo "$VERSION - may the env be with you"
    exit 0
    ;;
    -*)
    log_error "Unknown option: $1"
    exit 1
    ;;
    *)
    POSITIONAL_ARGS+=("$1")
    shift
    ;;
  esac
done
#--------------

#----Validate number of files ----
if [[ ${#POSITIONAL_ARGS[@]} -ne 2 ]]; then
  log_error "Expected 2 arguments: .env and .env.example"
  show_help
fi
#---------------------------------

#---Assign FILE and EXAMPLE-----
FILE_1="${POSITIONAL_ARGS[0]}"
FILE_2="${POSITIONAL_ARGS[1]}"

if [[ "$FILE_1" == *example* ]]; then
EXAMPLE="$FILE_1"
FILE="$FILE_2"
else
EXAMPLE="$FILE_2"
FILE="$FILE_1"
fi
#-------------------------------

#---Check if files exist-------
[ ! -f "$EXAMPLE" ] && log_error "File not found: $EXAMPLE" && exit 1
[ ! -f "$FILE" ] && log_error "File not found: $FILE" && exit 1
#------------------------------

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

log "Starting comparison..."

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

#---CI---
if (( ${#missing_arr[@]} > 0 || ${#extra_arr[@]} > 0 || ${#keys_with_diff_values[@]} > 0 )); then
  log_error "Audit failed. Found issues in env files."
  exit 1
  else
  log_ok "Audit passed. All variables matched."
  exit 0
fi
#---------



