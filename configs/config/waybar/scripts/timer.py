#!/usr/bin/env python3
import sys
import os
import json
import time
import subprocess

STATE_FILE = "/tmp/waybar_timer.json"
WORK_TIME = 45 * 60
BREAK_TIME = 15 * 60

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                state = json.load(f)
                # Ensure all keys exist for backward compatibility
                if "phase" not in state:
                    state["phase"] = "work"
                if "elapsed" not in state:
                    state["elapsed"] = 0
                if "status" not in state:
                    state["status"] = "stopped"
                if "last_tick" not in state:
                    state["last_tick"] = None
                return state
        except:
            pass
    return {"elapsed": 0, "last_tick": None, "status": "stopped", "phase": "work"}

def save_state(state):
    with open(STATE_FILE, "w") as f:
        json.dump(state, f)

def format_time(seconds):
    seconds = max(0, int(seconds))
    mins, secs = divmod(seconds, 60)
    return f"{mins:02d}:{secs:02d}"

def notify(message):
    try:
        subprocess.run(["notify-send", "Timer", message, "-t", "5000"])
        # Play a sound
        sound_path = "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
        if os.path.exists(sound_path):
            subprocess.Popen(["paplay", sound_path])
    except:
        pass

def update():
    state = load_state()
    now = time.time()
    
    if state["status"] == "running":
        if state["last_tick"]:
            passed = now - state["last_tick"]
            state["elapsed"] += passed
        state["last_tick"] = now

        # Phase transitions
        if state["phase"] == "work" and state["elapsed"] >= WORK_TIME:
            notify("Work cycle finished! Time for a break.")
            state["phase"] = "break"
            state["elapsed"] = 0
        elif state["phase"] == "break" and state["elapsed"] >= BREAK_TIME:
            notify("Break finished! Back to work.")
            state["phase"] = "work"
            state["elapsed"] = 0
            
        save_state(state)

    total_time = WORK_TIME if state["phase"] == "work" else BREAK_TIME
    remaining = total_time - state["elapsed"]
    
    text = format_time(remaining)
    icon = "󱎫" if state["phase"] == "work" else "󱎮"
    if state["status"] == "paused":
        icon = "󱎯"
        
    css_class = state["phase"]
    warning_threshold = 300 if state["phase"] == "work" else 120
    if remaining < warning_threshold:
        css_class = "warning"
    if state["status"] == "paused":
        css_class = "paused"

    output = {
        "text": f"{icon} {text}",
        "tooltip": f"Phase: {state['phase'].capitalize()}\nStatus: {state['status']}\nRemaining: {text}",
        "class": css_class
    }
    print(json.dumps(output))

def toggle():
    state = load_state()
    if state["status"] == "running":
        state["status"] = "paused"
        state["last_tick"] = None
    else: # paused or stopped
        state["status"] = "running"
        state["last_tick"] = time.time()
    save_state(state)

def reset():
    state = {"elapsed": 0, "last_tick": None, "status": "stopped", "phase": "work"}
    save_state(state)

def add(seconds):
    state = load_state()
    state["elapsed"] -= seconds
    
    total_time = WORK_TIME if state["phase"] == "work" else BREAK_TIME
    
    if state["elapsed"] < 0:
        state["elapsed"] = 0
    elif state["elapsed"] >= total_time:
        # If we subtracted so much time that we passed the limit
        if state["phase"] == "work":
            state["phase"] = "break"
        else:
            state["phase"] = "work"
        state["elapsed"] = 0
        
    save_state(state)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "toggle":
            toggle()
        elif cmd == "reset":
            reset()
        elif cmd == "add" and len(sys.argv) > 2:
            add(int(sys.argv[2]))
    else:
        update()
