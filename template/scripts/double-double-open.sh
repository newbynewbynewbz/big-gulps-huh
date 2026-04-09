#!/usr/bin/env bash
# double-double-open.sh -- Universal launcher for dual dev sessions
# Supports native (iOS Simulator) and web (Brave Browser) modes.
# Called by /double-double skill. Not meant for direct invocation.

set -euo pipefail

# --- Defaults ---
WORKTREE1=""
WORKTREE2=""
PORT1=""
PORT2=""
FIRST_RUN=false
MODE="native"          # native | web
PROJECT_TYPE="expo"    # expo | vite | nextjs | generic
PROJECT_ROOT=""
DEV_CMD1=""
DEV_CMD2=""

# --- Parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --worktree1) WORKTREE1="$2"; shift 2 ;;
    --worktree2) WORKTREE2="$2"; shift 2 ;;
    --port1) PORT1="$2"; shift 2 ;;
    --port2) PORT2="$2"; shift 2 ;;
    --first-run) FIRST_RUN=true; shift ;;
    --mode) MODE="$2"; shift 2 ;;
    --project-type) PROJECT_TYPE="$2"; shift 2 ;;
    --project-root) PROJECT_ROOT="$2"; shift 2 ;;
    --dev-cmd1) DEV_CMD1="$2"; shift 2 ;;
    --dev-cmd2) DEV_CMD2="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$WORKTREE1" ]]; then
  echo "Error: --worktree1 is required"
  exit 1
fi

if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$(pwd)"
fi

# Default worktree2 to worktree1 if not provided (single-worktree mode)
if [[ -z "$WORKTREE2" ]]; then
  WORKTREE2="$WORKTREE1"
fi

# Resolve to absolute paths
WT1_PATH="$PROJECT_ROOT/$WORKTREE1"
WT2_PATH="$PROJECT_ROOT/$WORKTREE2"

# --- Default ports by project type ---
if [[ -z "$PORT1" ]]; then
  case "$PROJECT_TYPE" in
    expo)    PORT1=8081 ;;
    vite)    PORT1=5173 ;;
    nextjs)  PORT1=3000 ;;
    generic) PORT1=3000 ;;
  esac
fi

if [[ -z "$PORT2" ]]; then
  PORT2=$(( PORT1 + 1 ))
fi

# --- Detect screen resolution ---
get_screen_bounds() {
  local resolution_line
  resolution_line=$(system_profiler SPDisplaysDataType 2>/dev/null \
    | grep -i "Resolution:" \
    | head -1)

  SCREEN_W=$(echo "$resolution_line" | sed 's/.*: *\([0-9]*\) x.*/\1/')
  SCREEN_H=$(echo "$resolution_line" | sed 's/.*x *\([0-9]*\).*/\1/')

  # Retina displays report physical pixels; AppleScript uses logical
  if echo "$resolution_line" | grep -qi "retina"; then
    SCREEN_W=$(( SCREEN_W / 2 ))
    SCREEN_H=$(( SCREEN_H / 2 ))
  fi

  # Fallback
  if [[ -z "$SCREEN_W" ]] || [[ "$SCREEN_W" -lt 100 ]]; then
    SCREEN_W=1728
    SCREEN_H=1117
  fi

  echo "Screen: ${SCREEN_W}x${SCREEN_H} (logical)"
}

get_screen_bounds

# --- Calculate window positions ---
MENU_BAR=25

# Left 50% for terminals (stacked top/bottom)
TERM_W=$(( SCREEN_W / 2 ))
HALF_H=$(( (SCREEN_H - MENU_BAR) / 2 ))

T1_X=0; T1_Y=$MENU_BAR; T1_W=$TERM_W; T1_H=$(( MENU_BAR + HALF_H ))
T2_X=0; T2_Y=$(( MENU_BAR + HALF_H )); T2_W=$TERM_W; T2_H=$SCREEN_H

# Right 50% for simulators/browser
RIGHT_X=$TERM_W
RIGHT_W=$(( SCREEN_W - TERM_W ))
RIGHT_H=$(( SCREEN_H - MENU_BAR ))

# Simulator-specific (side by side in right half)
SIM_EACH_W=$(( RIGHT_W / 2 ))
S1_X=$RIGHT_X; S1_Y=$MENU_BAR
S2_X=$(( RIGHT_X + SIM_EACH_W )); S2_Y=$MENU_BAR

# --- Detect simulators (native mode) ---
detect_simulators() {
  local devices
  devices=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" || true)

  if [[ -z "$devices" ]]; then
    echo "Error: No iPhone simulators found. Install via Xcode > Settings > Platforms."
    exit 1
  fi

  # Pick first 2 available iPhone devices
  DEVICE1_UDID=$(echo "$devices" | head -1 | grep -oE '[A-F0-9-]{36}')
  DEVICE1_NAME=$(echo "$devices" | head -1 | sed 's/ (.*//' | xargs)

  DEVICE2_UDID=$(echo "$devices" | sed -n '2p' | grep -oE '[A-F0-9-]{36}')
  DEVICE2_NAME=$(echo "$devices" | sed -n '2p' | sed 's/ (.*//' | xargs)

  if [[ -z "$DEVICE1_UDID" ]]; then
    echo "Error: Could not detect simulator UDID. Available devices:"
    echo "$devices"
    exit 1
  fi

  # If only 1 device, use it for both
  if [[ -z "$DEVICE2_UDID" ]]; then
    DEVICE2_UDID="$DEVICE1_UDID"
    DEVICE2_NAME="$DEVICE1_NAME"
    echo "Warning: Only 1 simulator found. Using $DEVICE1_NAME for both."
  fi

  echo "Simulator 1: $DEVICE1_NAME ($DEVICE1_UDID)"
  echo "Simulator 2: $DEVICE2_NAME ($DEVICE2_UDID)"
}

# --- Boot simulators (native mode) ---
boot_simulator() {
  local udid="$1"
  local name="$2"
  local state
  state=$(xcrun simctl list devices | grep "$udid" | grep -o "(Booted)" || true)
  if [[ "$state" == "(Booted)" ]]; then
    echo "  $name already booted"
  else
    echo "  Booting $name..."
    xcrun simctl boot "$udid" 2>/dev/null || true
  fi
}

# --- Detect dev command ---
detect_dev_command() {
  local wt_path="$1"
  local port="$2"
  local device_udid="${3:-}"

  case "$PROJECT_TYPE" in
    expo)
      if [[ "$FIRST_RUN" == true ]]; then
        echo "npx expo run:ios -d $device_udid --port $port"
      else
        echo "npx expo start -p $port"
      fi
      ;;
    vite)
      echo "npm run dev -- --port $port"
      ;;
    nextjs)
      echo "npm run dev -- -p $port"
      ;;
    generic)
      if [[ -n "$port" ]]; then
        echo "PORT=$port npm run dev"
      else
        echo "npm run dev"
      fi
      ;;
  esac
}

# --- Launch native mode (iOS Simulators) ---
launch_native_mode() {
  detect_simulators

  echo "Booting simulators..."
  boot_simulator "$DEVICE1_UDID" "$DEVICE1_NAME" &
  boot_simulator "$DEVICE2_UDID" "$DEVICE2_NAME" &
  wait

  # Open Simulator.app
  open -a Simulator
  echo "Waiting for simulator windows..."
  sleep 4

  # Position simulator windows
  echo "Positioning simulator windows..."
  osascript <<APPLESCRIPT
tell application "Simulator"
  activate
  delay 1
end tell

tell application "System Events"
  tell process "Simulator"
    set winList to windows
    repeat with w in winList
      set winName to name of w
      if winName contains "${DEVICE1_NAME}" then
        set position of w to {${S1_X}, ${S1_Y}}
        set size of w to {${SIM_EACH_W}, ${RIGHT_H}}
      else if winName contains "${DEVICE2_NAME}" then
        set position of w to {${S2_X}, ${S2_Y}}
        set size of w to {${SIM_EACH_W}, ${RIGHT_H}}
      end if
    end repeat
  end tell
end tell
APPLESCRIPT

  # Build dev commands
  if [[ -z "$DEV_CMD1" ]]; then
    DEV_CMD1=$(detect_dev_command "$WT1_PATH" "$PORT1" "$DEVICE1_UDID")
  fi
  if [[ -z "$DEV_CMD2" ]]; then
    DEV_CMD2=$(detect_dev_command "$WT2_PATH" "$PORT2" "$DEVICE2_UDID")
  fi

  # Export for session state
  export DEVICE1_UDID DEVICE1_NAME DEVICE2_UDID DEVICE2_NAME
}

# --- Launch web mode (Brave Browser) ---
launch_web_mode() {
  # Check Brave exists
  if [[ ! -d "/Applications/Brave Browser.app" ]]; then
    echo "Error: Brave Browser not found at /Applications/Brave Browser.app"
    echo "Install from https://brave.com or use a different browser."
    exit 1
  fi

  # Build dev commands
  if [[ -z "$DEV_CMD1" ]]; then
    DEV_CMD1=$(detect_dev_command "$WT1_PATH" "$PORT1")
  fi
  if [[ -z "$DEV_CMD2" ]]; then
    DEV_CMD2=$(detect_dev_command "$WT2_PATH" "$PORT2")
  fi

  # Launch Brave with 2 tabs positioned in the right half
  echo "Opening Brave Browser..."
  osascript <<APPLESCRIPT
tell application "Brave Browser"
  activate
  make new window
  delay 0.5
  set bounds of front window to {${RIGHT_X}, ${MENU_BAR}, ${SCREEN_W}, ${SCREEN_H}}
  set URL of active tab of front window to "http://localhost:${PORT1}"
  tell front window to make new tab with properties {URL:"http://localhost:${PORT2}"}
end tell
APPLESCRIPT

  # No simulator UDIDs in web mode
  DEVICE1_UDID=""
  DEVICE1_NAME="Brave Tab 1"
  DEVICE2_UDID=""
  DEVICE2_NAME="Brave Tab 2"
}

# --- Launch terminals ---
launch_terminals() {
  echo "Opening Terminal windows..."
  osascript <<APPLESCRIPT
tell application "Terminal"
  activate

  -- Create Terminal 1 (top-left) for worktree 1
  set term1 to do script "cd '${WT1_PATH}' && echo '=== Worktree 1: ${WORKTREE1} (port ${PORT1}) ===' && ${DEV_CMD1}"
  set bounds of front window to {${T1_X}, ${T1_Y}, ${T1_W}, ${T1_H}}

  -- Create Terminal 2 (bottom-left) for worktree 2
  set term2 to do script "cd '${WT2_PATH}' && echo '=== Worktree 2: ${WORKTREE2} (port ${PORT2}) ===' && ${DEV_CMD2}"
  set bounds of front window to {${T2_X}, ${T2_Y}, ${T2_W}, ${T2_H}}
end tell
APPLESCRIPT
}

# ==============================================================
# MAIN
# ==============================================================

echo "=== Double-Double Open (${MODE} mode, ${PROJECT_TYPE}) ==="

if [[ "$MODE" == "native" ]]; then
  launch_native_mode
elif [[ "$MODE" == "web" ]]; then
  launch_web_mode
else
  echo "Error: Unknown mode '$MODE'. Use 'native' or 'web'."
  exit 1
fi

launch_terminals

echo ""
echo "=== Double-Double Session Launched ==="
echo "  Mode: ${MODE} (${PROJECT_TYPE})"
echo "  Terminal 1 (top-left):    ${WORKTREE1} -> port ${PORT1} -> ${DEVICE1_NAME}"
echo "  Terminal 2 (bottom-left): ${WORKTREE2} -> port ${PORT2} -> ${DEVICE2_NAME}"
if [[ "$MODE" == "native" ]]; then
  echo "  Simulators on the right side of the screen"
else
  echo "  Brave Browser tabs on the right side of the screen"
fi
echo ""
echo "Run '/double-double close' when you're done."
