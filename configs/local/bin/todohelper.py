#!/usr/bin/env python3
import datetime
import html
from pathlib import Path

TODO_FILE = Path.home() / ".todo"
WEEKDAYS = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

def parse_line(line: str):
    line = line.strip()
    if not line or line.startswith("#") or line.lower().startswith(("done:", "x:", "done ", "x ")):
        return None

    weekly = line.lower().startswith("weekly:")
    if weekly:
        line = line.split(":", 1)[1] if ":" in line[:7] else line[7:].lstrip()

    parts = line.split()
    if not parts:
        return None

    date_str = time_str = None
    task_words = []

    i = len(parts) - 1
    while i >= 0:
        w = parts[i]
        if w.lower() in WEEKDAYS:
            date_str = w.lower()
            task_words = parts[:i]
            break
        if len(w) == 10 and "-" in w:
            try:
                datetime.datetime.strptime(w, "%Y-%m-%d")
                date_str = w
                task_words = parts[:i]
                if i+1 < len(parts) and ":" in parts[-1] and len(parts[-1]) == 5:
                    time_str = parts[-1]
                break
            except:
                pass
        i -= 1

    task = " ".join(task_words).strip() if task_words else " ".join(parts).strip()
    if not task:
        return None

    now = datetime.datetime.now()

    if not date_str:
        return {"task": task, "dt": None, "weekly": weekly, "type": "someday"}

    if date_str in WEEKDAYS:
        wd = WEEKDAYS.index(date_str)
        days = wd - now.weekday()
        if days <= 0: days += 7
        dt = (now + datetime.timedelta(days=days)).replace(hour=23, minute=59)
    else:
        dt = datetime.datetime.strptime(date_str, "%Y-%m-%d")
        if time_str:
            dt = datetime.datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M")
        else:
            dt = dt.replace(hour=23, minute=59)

    if weekly and dt <= now:
        dt += datetime.timedelta(days=7)
    if not weekly and dt <= now:
        return None

    return {"task": task, "dt": dt, "weekly": weekly, "type": "weekly" if weekly else "dated"}

def format_remaining(dt):
    if dt is None: return "someday"
    delta = dt - datetime.datetime.now()
    days, secs = delta.days, delta.seconds
    h, m = divmod(secs // 60, 60)

    if days >= 30:  return f"{days//7}w"
    if days >= 7:   return f"{days}d"
    if days > 0:    return f"{days}d {h}h"
    if h > 0:       return f"{h}h{m:02d}"
    if m > 5:       return f"{m}m"
    return "now"


def main():
    tasks = []
    if TODO_FILE.exists():
        for l in TODO_FILE.read_text().splitlines():
            p = parse_line(l)
            if p:
                tasks.append(p)

    # Your original sorting logic (unchanged)
    tasks.sort(key=lambda x: (x["dt"] or datetime.datetime.max, x["type"] != "dated"))

    esc = lambda s: html.escape(s, quote=False)

    # NEW: Nerd Font icons (logic unchanged)
    ICONS = {
        "weekly": "󰑓",   # calendar repeat
        "someday": "●",  # cloud
        "dated": "●",    # circle (default)
    }

    if not tasks:
        out = {
            "text": "DONE",
            "class": "done",
            "tooltip": "All tasks completed"
        }

    else:
        lines = []
        for t in tasks[:30]:
            # exact same if/elif logic, just replaced strings with icons
            if t["type"] == "weekly":
                icon = ICONS["weekly"]
            elif t["type"] == "someday":
                icon = ICONS["someday"]
            else:
                icon = ICONS["dated"]

            time_str = format_remaining(t["dt"])

            if t["dt"]:
                date_str = (
                    t["dt"].strftime("%a %b %d")
                    if t["dt"].hour == 23
                    else t["dt"].strftime("%a %b %d %H:%M")
                )
            else:
                date_str = "no date"

            line = (
                f"{icon}  <b>{esc(t['task'])}</b>\n"
                f"    {time_str}  <span foreground='#74c7ec'>{date_str}</span>"
            )
            lines.append(line)

        out = {
            "text": "TODO",    # untouched
            "class": "active",
            "tooltip": "\n".join(lines)
        }

    import json
    print(json.dumps(out))


if __name__ == "__main__":
    main()
