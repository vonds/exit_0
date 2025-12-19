#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/xp.sh"
source "$SCRIPT_DIR/ui.sh"

PERFECTS_FILE="$SCRIPT_DIR/../data/.exam_perfects.json"

if [ ! -f "$PERFECTS_FILE" ]; then
  echo '{}' > "$PERFECTS_FILE"
fi

# --- Image helpers -----------------------------------------------------------

_temp_images=()

cleanup_temp_images() {
  for f in "${_temp_images[@]}"; do
    [ -f "$f" ] && rm -f "$f"
  done
}
trap cleanup_temp_images EXIT

# Save a data URL or raw base64 to a temp file; echoes the saved path
save_base64_to_temp() {
  local data="$1"
  local ext="${2:-png}"
  local tmpfile
  tmpfile="$(mktemp --suffix=".$ext" 2>/dev/null || mktemp -t "quizimg.$ext")"

  # If it's a data URL, strip header like: data:image/png;base64,AAAA...
  if [[ "$data" =~ ^data: ]]; then
    local header payload mime subtype
    header="${data%%,*}"
    payload="${data#*,}"
    mime="${header#data:}"; mime="${mime%;base64}"
    subtype="${mime#*/}"
    [ -n "$subtype" ] && tmpfile="${tmpfile%.*}.$subtype"
    printf '%s' "$payload" | base64 -d > "$tmpfile" 2>/dev/null
  else
    # Assume raw base64
    printf '%s' "$data" | base64 -d > "$tmpfile" 2>/dev/null
  fi

  _temp_images+=("$tmpfile")
  echo "$tmpfile"
}

# Try to render or open an image if AUTO_OPEN_IMAGES=1
open_image_if_enabled() {
  local path="$1"
  [ -z "$AUTO_OPEN_IMAGES" ] && return 0

  # Kitty inline if available
  if command -v kitty >/dev/null 2>&1 && kitty +kitten icat --silent --transfer-mode=stream "$path" >/dev/null 2>&1; then
    return 0
  fi

  # imgcat (iTerm/wezterm) if available
  if command -v imgcat >/dev/null 2>&1; then
    imgcat "$path" >/dev/null 2>&1 && return 0
  fi

  # Fall back to system opener
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$path" >/dev/null 2>&1 &
  elif command -v open >/dev/null 2>&1; then
    open "$path" >/dev/null 2>&1 &
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    cmd.exe /c start "$(wslpath -w "$path")" >/dev/null 2>&1 &
  fi
}

# Render a centered “Image:” line with optional caption; returns a resolved path if any
render_question_image() {
  local image_path="$1"
  local image_b64="$2"
  local caption="$3"
  local resolved=""

  if [ -n "$image_b64" ]; then
    resolved="$(save_base64_to_temp "$image_b64")"
  elif [ -n "$image_path" ]; then
    resolved="$image_path"
  fi

  if [ -n "$resolved" ]; then
    echo
    center_text "[Image] $resolved"
    [ -n "$caption" ] && word_wrap_and_center "$caption"
    open_image_if_enabled "$resolved"
  fi

  echo "$resolved"
}
# ---------------------------------------------------------------------------

choose_exam() {
  clear
  echo
  echo
  echo
  print_banner "Linux Practice Menu"
  echo

  center_menu "1) System Architecture A"
  center_menu "2) System Architecture B"
  center_menu "3) System Architecture C"
  center_menu "4) System Architecture D"
  center_menu "5) System Architecture E"
  center_menu "6) System Architecture F"
  center_menu "7) System Architecture G"
  center_menu "8) System Architecture H"
  center_menu "9) System Architecture I"
  center_menu "10) System Architecture J"
  center_menu "11) System Architecture K"
  center_menu "12) Package And System Management A"
  center_menu "13) Package And System Management B"
  center_menu "14) Package And System Management C"
  center_menu "15) Package And System Management D"
  center_menu "16) Package And System Management E"
  center_menu "17) Package And System Management F"
  center_menu "18) Package And System Management G"
  center_menu "19) Package And System Management H"
  center_menu "20) Package And System Management I"
  center_menu "21) Networking Fundamentals A"
  center_menu "22) Networking Fundamentals B"
  center_menu "23) Networking Fundamentals C"
  center_menu "24) Networking Fundamentals D"
  center_menu "25) Networking Fundamentals E"
  center_menu "26) Networking Fundamentals F"
  center_menu "27) Networking Fundamentals G"
  center_menu "28) Networking Fundamentals H"
  center_menu "29) Networking Fundamentals I"
  center_menu "30) System Services A"
  center_menu "31) System Services B"
  center_menu "32) System Services C"
  center_menu "33) System Services D"
  center_menu "34) System Services E"
  center_menu "35) System Services F"
  center_menu "36) System Services G"
  center_menu "37) System Services H"
  center_menu "38) System Services I"
  center_menu "39) Security A"
  center_menu "40) Security B"
  center_menu "41) Security C"
  center_menu "42) Security D"
  center_menu "43) Security E"
  center_menu "44) Security F"
  center_menu "45) Security G"
  center_menu "46) Security H"
  center_menu "47) Security I"
  center_menu "48) Security Full Test"
  center_menu "49) Administrative Tasks A"
  center_menu "50) Administrative Tasks B"
  center_menu "51) Administrative Tasks C"
  center_menu "52) Administrative Tasks D"
  center_menu "53) Administrative Tasks E"
  center_menu "54) Administrative Tasks F"
  center_menu "55) Administrative Tasks G"
  center_menu "56) Administrative Tasks H"
  center_menu "57) Administrative Tasks I"
  center_menu "58) GNU and Unix Commands A"
  center_menu "59) GNU and Unix Commands B"
  center_menu "60) GNU and Unix Commands C"
  center_menu "61) GNU and Unix Commands D"
  center_menu "62) GNU and Unix Commands E"
  center_menu "63) GNU and Unix Commands F"
  center_menu "64) GNU and Unix Commands G"
  center_menu "65) GNU and Unix Commands H"
  center_menu "66) GNU and Unix Commands I"
  center_menu "67) Linux Filesystem A"
  center_menu "68) Linux Filesystem B"
  center_menu "69) Linux Filesystem C"
  center_menu "70) Linux Filesystem D"
  center_menu "71) Linux Filesystem E"
  center_menu "72) Linux Filesystem F"
  center_menu "73) Linux Filesystem G"
  center_menu "74) Linux Filesystem H"
  center_menu "75) Linux Filesystem I"
  center_menu "76) Practice Test A"
  center_menu "77) Edge-case Test"
  center_menu "78) CIDR"
  center_menu "79) A+ Mobile Devices 1"
  center_menu "80) Exit"
  echo

  while true; do
    read -p "$(center_text 'Choose an option [1–4]: '; echo)" choice
    case $choice in
      1)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_a.json"
        run_exam "System Architecture A"
        return
        ;;
      2)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_b.json"
        run_exam "System Architecture B"
        return
        ;;
      3)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_c.json"
        run_exam "System Architecture C"
        return
        ;;
      4)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_d.json"
        run_exam "System Architecture D"
        return
        ;;
      5)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_e.json"
        run_exam "System Architecture E"
        return
        ;;
      6)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_f.json"
        run_exam "System Architecture F"
        return
        ;;
      7)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_g.json"
        run_exam "System Architecture G"
        return
        ;;
      8)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_h.json"
        run_exam "System Architecture H"
        return
        ;;
      9)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_i.json"
        run_exam "System Architecture I"
        return
        ;;
      10)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_j.json"
        run_exam "System Architecture J"
        return
        ;;
      11)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_architecture_k.json"
        run_exam "System Architecture K"
        return
        ;;
      12)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_a.json"
        run_exam "Package And System Management A"
        return
        ;;
      13)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_b.json"
        run_exam "Package And System Management B"
        return
        ;;
      14)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_c.json"
        run_exam "Package And System Management C"
        return
        ;;
      15)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_d.json"
        run_exam "Package And System Management D"
        return
        ;;
      15)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_d.json"
        run_exam "Package And System Management D"
        return
        ;;
      16)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_e.json"
        run_exam "Package And System Management E"
        return
        ;;
      17)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_f.json"
        run_exam "Package And System Management F"
        return
        ;;
      18)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_g.json"
        run_exam "Package And System Management G"
        return
        ;;
      19)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_h.json"
        run_exam "Package And System Management H"
        return
        ;;
      20)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_package_and_system_management_i.json"
        run_exam "Package And System Management I"
        return
        ;;
      21)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_a.json"
        run_exam "Networking Fundamentals A"
        return
        ;;
      22)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_b.json"
        run_exam "Networking Fundamentals B"
        return
        ;;
      23)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_c.json"
        run_exam "Networking Fundamentals C"
        return
        ;;
      24)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_d.json"
        run_exam "Networking Fundamentals D"
        return
        ;;
      25)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_e.json"
        run_exam "Networking Fundamentals E"
        return
        ;;
      26)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_f.json"
        run_exam "Networking Fundamentals F"
        return
        ;;
      27)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_g.json"
        run_exam "Networking Fundamentals G"
        return
        ;;
      28)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_h.json"
        run_exam "Networking Fundamentals H"
        return
        ;;
      29)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/networking_fundamentals_i.json"
        run_exam "Networking Fundamentals I"
        return
        ;;
      30)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_a.json"
        run_exam "System Services A"
        return
        ;;
      31)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_b.json"
        run_exam "System Services B"
        return
        ;;
      32)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_c.json"
        run_exam "System Services C"
        return
        ;;
      33)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_d.json"
        run_exam "System Services D"
        return
        ;;
      34)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_e.json"
        run_exam "System Services E"
        return
        ;;
      35)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_f.json"
        run_exam "System Services F"
        return
        ;;
      36)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_g.json"
        run_exam "System Services G"
        return
        ;;
      37)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_h.json"
        run_exam "System Services H"
        return
        ;;
      38)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/system_services_i.json"
        run_exam "System Services I"
        return
        ;;
      39)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_a.json"
        run_exam "Security A"
        return
        ;;
      40)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_b.json"
        run_exam "Security B"
        return
        ;;
      41)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_c.json"
        run_exam "Security C"
        return
        ;;
      42)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_d.json"
        run_exam "Security D"
        return
        ;;
      43)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_e.json"
        run_exam "Security E"
        return
        ;;
      44)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_f.json"
        run_exam "Security F"
        return
        ;;
      45)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_g.json"
        run_exam "Security G"
        return
        ;;
      46)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_h.json"
        run_exam "Security H"
        return
        ;;
      47)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_i.json"
        run_exam "Security I"
        return
        ;;
      48)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/security_full_test.json"
        run_exam "Security Full Test"
        return
        ;;
      49)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_a.json"
        run_exam "Administrative Tasks A"
        return
        ;;
      50)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_b.json"
        run_exam "Administrative Tasks B"
        return
        ;;
      51)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_c.json"
        run_exam "Administrative Tasks C"
        return
        ;;
      52)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_d.json"
        run_exam "Administrative Tasks D"
        return
        ;;
      53)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_e.json"
        run_exam "Administrative Tasks E"
        return
        ;;
      54)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_f.json"
        run_exam "Administrative Tasks F"
        return
        ;;
      55)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_g.json"
        run_exam "Administrative Tasks G"
        return
        ;;
      56)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_h.json"
        run_exam "Administrative Tasks H"
        return
        ;;
      57)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/administrative_tasks_i.json"
        run_exam "Administrative Tasks I"
        return
        ;;
      58)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_a.json"
        run_exam "GNU and Unix Commands A"
        return
        ;;
      59)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_b.json"
        run_exam "GNU and Unix Commands B"
        return
        ;;
      60)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_c.json"
        run_exam "GNU and Unix Commands C"
        return
        ;;
      61)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_d.json"
        run_exam "GNU and Unix Commands D"
        return
        ;;
      62)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_e.json"
        run_exam "GNU and Unix Commands E"
        return
        ;;
      63)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_f.json"
        run_exam "GNU and Unix Commands F"
        return
        ;;
      64)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_g.json"
        run_exam "GNU and Unix Commands G"
        return
        ;;
      65)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_h.json"
        run_exam "GNU and Unix Commands H"
        return
        ;;
      66)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_i.json"
        run_exam "GNU and Unix Commands I"
        return
        ;;
      66)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/gnu_and_unix_commands_i.json"
        run_exam "GNU and Unix Commands I"
        return
        ;;
      67)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_a.json"
        run_exam "Linux Filesystem A"
        return
        ;;
      68)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_b.json"
        run_exam "Linux Filesystem B"
        return
        ;;
      69)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_c.json"
        run_exam "Linux Filesystem C"
        return
        ;;
      70)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_d.json"
        run_exam "Linux Filesystem D"
        return
        ;;
      71)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_e.json"
        run_exam "Linux Filesystem E"
        return
        ;;
      72)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_f.json"
        run_exam "Linux Filesystem F"
        return
        ;;
      73)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_g.json"
        run_exam "Linux Filesystem G"
        return
        ;;
      74)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_h.json"
        run_exam "Linux Filesystem H"
        return
        ;;
      75)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/linux_filesystem_i.json"
        run_exam "Linux Filesystem I"
        return
        ;;
      76)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/practice_exam_a.json"
        run_exam "Practice Test A"
        return
        ;;
      77)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/edge_case_test_questions.json"
        run_exam "Edge-case Test"
        return
        ;;
      78)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/cidr.json"
        run_exam "CIDR"
        return
        ;;
      79)
        QUESTIONS_FILE="$SCRIPT_DIR/../data/a_plus_mobile_devices.json"
        run_exam "CIDR"
        return
        ;;
      80)
        return
        ;;
      *)
        print_error "   Invalid option. Please enter a valid number."
        ;;
    esac
  done
}

generate_shuffled_indexes() {
  local count=$1
  local indexes=()
  for ((i = 0; i < count; i++)); do
    indexes+=($i)
  done
  for ((i = count - 1; i > 0; i--)); do
    j=$((RANDOM % (i + 1)))
    tmp=${indexes[i]}
    indexes[i]=${indexes[j]}
    indexes[j]=$tmp
  done
  echo "${indexes[@]}"
}

normalize_answer() {
  echo "$1" | tr '[:lower:]' '[:upper:]' | grep -oE '[A-Z]' | sort | tr '\n' ' ' | xargs
}

increment_perfect_count() {
  local exam_name="$1"
  current_count=$(jq -r --arg exam "$exam_name" '.[$exam] // 0' "$PERFECTS_FILE")
  new_count=$((current_count + 1))
  tmp_file=$(mktemp)
  jq --arg exam "$exam_name" --argjson count "$new_count" '.[$exam] = $count' "$PERFECTS_FILE" > "$tmp_file" && mv "$tmp_file" "$PERFECTS_FILE"
}

get_perfect_count() {
  local exam_name="$1"
  jq -r --arg exam "$exam_name" '.[$exam] // 0' "$PERFECTS_FILE"
}

word_wrap_and_center() {
  local input="$1"
  local width=${2:-70}
  local line=""
  for word in $input; do
    if (( ${#line} + ${#word} + 1 > width )); then
      center_text "$line"
      line="$word"
    else
      if [[ -z "$line" ]]; then
        line="$word"
      else
        line="$line $word"
      fi
    fi
  done
  [[ -n "$line" ]] && center_text "$line"
}

run_exam() {
  local EXAM_TITLE="$1"
  clear
  center_text "Linux Practice Exam: $EXAM_TITLE"
  echo

  # Validate that the question file exists and has content
  if [ ! -f "$QUESTIONS_FILE" ]; then
    print_error "Question file not found: $QUESTIONS_FILE"
    read -p "   Press Enter to return to the menu..."
    return
  fi

  if ! jq empty "$QUESTIONS_FILE" &>/dev/null; then
    print_error "Invalid JSON in: $QUESTIONS_FILE"
    read -p "   Press Enter to return to the menu..."
    return
  fi

  TOTAL=$(jq length "$QUESTIONS_FILE")
  if [ "$TOTAL" -eq 0 ]; then
    print_error "No questions found in $QUESTIONS_FILE"
    read -p "   Press Enter to return to the menu..."
    return
  fi

  INDEXES=($(generate_shuffled_indexes $TOTAL))
  local question_count=0
  local any_wrong=0

  for i in "${INDEXES[@]}"; do
    QUESTION=$(jq ".[$i]" "$QUESTIONS_FILE")
    TEXT=$(echo "$QUESTION" | jq -r '.question')
    ANSWER=$(echo "$QUESTION" | jq -r '.answer')
    EXPLANATION=$(echo "$QUESTION" | jq -r '.explanation')

    # New: optional image fields
    IMAGE=$(echo "$QUESTION" | jq -r '.image // empty')
    IMAGE_B64=$(echo "$QUESTION" | jq -r '.image_base64 // empty')
    IMAGE_CAPTION=$(echo "$QUESTION" | jq -r '.image_caption // empty')

    OPTIONS=()
    while IFS= read -r line; do
      OPTIONS+=("$line")
    done < <(jq -r '.options[]' <<< "$QUESTION")

    local correct=0
    while [ $correct -eq 0 ]; do
      clear
      center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
      center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
      echo
      center_text "Question $((question_count + 1)) of $TOTAL"
      echo
      word_wrap_and_center "$TEXT"

      # New: render/show image if present
      render_question_image "$IMAGE" "$IMAGE_B64" "$IMAGE_CAPTION" >/dev/null

      echo

      local formatted_opts=()
      for opt in "${OPTIONS[@]}"; do
        letter="${opt:0:2}"
        text="${opt:3}"
        formatted_opts+=("  $letter $text")
      done

      max_len=0
      for line in "${formatted_opts[@]}"; do
        (( ${#line} > max_len )) && max_len=${#line}
      done

      for line in "${formatted_opts[@]}"; do
        pad=$(( ($(tput cols) - max_len) / 2 ))
        printf "%*s%s\n" "$pad" "" "$line"
      done

      echo
      read -p "    Your answer (e.g. A C): " USER_ANSWER

      USER_ANSWER_NORM=$(normalize_answer "$USER_ANSWER")
      CORRECT_ANSWER_NORM=$(normalize_answer "$ANSWER")

      if [[ "$USER_ANSWER_NORM" == "$CORRECT_ANSWER_NORM" ]]; then
        print_success "Correct!"
        print_info "Explanation:"
        word_wrap_and_center "$EXPLANATION"
        award_xp 167
        echo
        print_info "You earned 167 XP!"
        echo
        read -p "   Press Enter to continue..."
        correct=1
        ((question_count++))
      else
        print_error "Incorrect. Try again."
        any_wrong=1
        echo
        read -p "   Press Enter to retry..."
      fi
    done
  done

  clear
  center_draw_stats_panel "$LEVEL" "$XP" "$(calculate_xp_to_next_level)"
  center_draw_progress_bar "$XP" "$(calculate_xp_to_next_level)"
  echo
  print_banner "Exam Complete!"
  word_wrap_and_center "You've completed all $EXAM_TITLE questions!"
  echo

  if [[ $any_wrong -eq 0 ]]; then
    print_success "🏆 Flawless Victory! You earned a bonus of 5294 XP!"
    award_xp 5294
    increment_perfect_count "$EXAM_TITLE"
    count=$(get_perfect_count "$EXAM_TITLE")
    echo
    word_wrap_and_center "🎖️ You've now completed '$EXAM_TITLE' perfectly $count time(s)!"
    echo
    read -p "                                   Press Enter to continue..."
  fi

  while true; do
    clear
    echo
    print_banner "What would you like to do next?"
    echo
    center_text "1) Try Again"
    center_text "2) Return to Menu"
    echo
    read -p "$(center_text 'Choose an option [1–2]: '; echo)" next_step
    case $next_step in
        1) run_exam "$EXAM_TITLE" ;;
        2) return ;;
        *) print_error "   Invalid input. Please enter 1 or 2." ;;
    esac
  done
}

# If you want to immediately start the menu when sourcing this file directly:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  choose_exam
fi
