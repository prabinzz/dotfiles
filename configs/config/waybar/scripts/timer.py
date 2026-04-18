#!/usr/bin/env python3
import sys
import os
import json
import time

STATE_FILE = "/tmp/waybar_timer.json"
DEFAULT_TIME = 25 * 60

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                return json.load(f)
        except:
            pass
    return {"remaining": DEFAULT_TIME, "last_tick": None, "status": "stopped"}

def save_state(state):
    with open(STATE_FILE, "w") as f:
        json.dump(state, f)

def format_time(seconds):
    mins, secs = divmod(int(seconds), 60)
    return f"{mins:02d}:{secs:02d}"

def update():
    state = load_state()
    now = time.time()
    
    if state["status"] == "running":
        if state["last_tick"]:
            elapsed = now - state["last_tick"]
            state["remaining"] -= elapsed
            if state["remaining"] <= 0:
                state["remaining"] = 0
                state["status"] = "stopped"
        state["last_tick"] = now
        save_state(state)

    text = format_time(state["remaining"])
    icon = "󱎫" if state["status"] == "running" else "󱎮" if state["status"] == "paused" else "󱎯"
    
    output = {
        "text": f"{icon} {text}",
        "tooltip": f"Status: {state['status']}\nRemaining: {text}",
        "class": state["status"]
    }
    print(json.dumps(output))

def toggle():
    state = load_state()
    if state["status"] == "running":
        state["status"] = "paused"
        state["last_tick"] = None
    elif state["status"] == "paused":
        state["status"] = "running"
        state["last_tick"] = time.time()
    else: # stopped
        state["status"] = "running"
        state["last_tick"] = time.time()
    save_state(state)

def reset():
    state = {"remaining": DEFAULT_TIME, "last_tick": None, "status": "stopped"}
    save_state(state)

def add(minutes):
    state = load_state()
    state["remaining"] += minutes * 60
    if state["remaining"] < 0:
        state["remaining"] = 0
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
