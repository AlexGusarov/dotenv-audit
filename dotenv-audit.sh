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

say_ok "All right.Start comparing"	

get_keys_from_file () {
  local file=$1
  grep -v '^#' "$file" | grep '=' | cut -d '=' -f1 | sed 's/ *$//' | sort
  }

keys_1=$(get_keys_from_file "$FILE_1")
keys_2=$(get_keys_from_file "$FILE_2")

missing=$(comm -23 <( echo "$keys_2" | sort) <( echo "$keys_1" | sort ))
extra=$(comm -13 <( echo "$keys_2" | sort) <( echo "$keys_1" | sort ))

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
  
  echo 
  echo "$line"
  printf "| %-*s | %-*s |\n" \
  $col_width "Missing variables" $col_width "Extra variables"
  echo "$line"

  for ((i=0; i<max_lines; i++)); do
    printf "| %-*s | %-*s |\n" \
    $col_width "${missing_arr[i]}" $col_width "${extra_arr[i]}"
  done
  echo "$line"
  echo
}

print_diff_table "$missing" "$extra"
