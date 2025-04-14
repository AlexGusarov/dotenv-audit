#!/bin/bash
# Minimalistic .env file audit tool in pure Bash. Zero dependencies.


RED=$( tput setaf 1)
YELLOW=$( tput setaf 3)
GREEN=$( tput setaf 2)
BLUE=$( tput setaf 4)
RESET=$( tput sgr0)

say_ok () {
  echo "${GREEN}$1${RESET}"
  }

say_warn () {
  echo "${YELLOW}$1${RESET}"
  }

say_error () {
  echo "${RED}$1${RESET}"
  }

say_info () { 
  echo "${BLUE}$1${RESET}"
  }

if [ $# -ne 2 ]; then
	say_error "Need two files"
	say_info "Example:"
	say_info  "$0 .env .env_example"
	exit 1
fi

FILE_1="$1"
FILE_2="$2"

if [ ! -f "$FILE_1" ]; then
	say_error "File not founded:"
	exit 1
fi

if [ ! -f "$FILE_2" ]; then
	say_error "File not founded: $FILE_2"

	exit 1
fi

say_ok "Start comparing..."	

get_keys_from_file () {
  local file=$1
  grep -v '^#' "$file" | grep '=' | cut -d '=' -f1 | sed 's/ *$//' | sort
  }

get_value_by_key () {
  local key=$1
  local file=$2

  grep -E "^$key=" "$file" | cut -d "=" -f2-
  }

keys_1=$(get_keys_from_file "$FILE_1")
keys_2=$(get_keys_from_file "$FILE_2")

missing_keys=$(comm -23 <( echo "$keys_2" | sort) <( echo "$keys_1" | sort ))
extra_keys=$(comm -13 <( echo "$keys_2" | sort) <( echo "$keys_1" | sort ))
common_keys=$(comm -12 <( echo "$keys_2" | sort) <( echo "$keys_1" | sort ))

repeat_char () {
  local char="$1"
  local count="$2"
  local out=""

  for ((i=0; i<count; i++)); do
    out+="$char"
  done

  echo "$out"
  }

print_diff_table () {
  local missing="$1"
  local extra="$2"
  local common="$3"
  local col_width=25 # width of column
  local line="+$(repeat_char "-" 27)+$(repeat_char "-" 27)+"

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
    val1=$(get_value_by_key "$new_key" "$FILE_1")
    val2=$(get_value_by_key "$new_key" "$FILE_2")
  
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

print_diff_table "$missing_keys" "$extra_keys" "$common_keys"
