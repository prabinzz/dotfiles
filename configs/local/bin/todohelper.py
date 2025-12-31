#!/usr/bin/env python3
import sys
import json
import html
import datetime
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, List, Tuple

# Configuration
TODO_FILE = Path.home() / ".todo"
WEEKDAYS = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
ICONS = {
    "weekly": "\ud93d\udec3",   # calendar repeat
    "someday": "●",  # cloud
    "dated": "●",    # circle (default)
}

@dataclass
class Task:
    text: str
    dt: Optional[datetime.datetime]
    is_weekly: bool
    task_type: str  # "weekly", "dated", "someday"

    @property
    def sort_key(self):
        # Sort by date (None/Someday last), then by type (dated preferred over others if dates equal)
        return (self.dt or datetime.datetime.max, self.task_type != "dated")

def parse_date_token(token: str) -> Optional[str]:
    """Returns the token if it matches a date format, else None."""
    if token.lower() in WEEKDAYS:
        return token.lower()
    
    if len(token) == 10 and "-" in token:
        try:
            datetime.datetime.strptime(token, "%Y-%m-%d")
            return token
        except ValueError:
            pass
    return None

def calculate_deadline(date_str: str, time_str: Optional[str]) -> datetime.datetime:
    now = datetime.datetime.now()
    
    if date_str in WEEKDAYS:
        target_wd = WEEKDAYS.index(date_str)
        days_ahead = target_wd - now.weekday()
        if days_ahead <= 0:
            days_ahead += 7
        
        # Base date is upcoming weekday
        base_dt = now + datetime.timedelta(days=days_ahead)
        
        # If time is provided, use it; else default to end of day
        if time_str:
            try:
                t = datetime.datetime.strptime(time_str, "%H:%M").time()
                return datetime.datetime.combine(base_dt.date(), t)
            except ValueError:
                pass # Fallback to default
        return base_dt.replace(hour=23, minute=59)

    else:
        # Specific date YYYY-MM-DD
        dt = datetime.datetime.strptime(date_str, "%Y-%m-%d")
        if time_str:
            try:
                dt = datetime.datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M")
            except ValueError:
                pass
        else:
            dt = dt.replace(hour=23, minute=59)
        return dt

def parse_line(line: str) -> Optional[Task]:
    line = line.strip()
    if not line or line.startswith("#") or line.lower().startswith(("done:", "x:", "done ", "x ")):
        return None

    # Handle weekly prefix
    is_weekly = line.lower().startswith("weekly:")
    if is_weekly:
        # Remove 'weekly:' and trim
        if line[7:].startswith(" "):
            line = line[7:].lstrip()
        else:
            # Handle 'weekly:Task' (no space)
            line = line.split(":", 1)[1].strip()

    parts = line.split()
    if not parts:
        return None

    date_str = None
    time_str = None
    date_index = -1

    # Scan for date from the end
    for i in range(len(parts) - 1, -1, -1):
        token = parts[i]
        if parse_date_token(token):
            date_str = token
            date_index = i
            
            # Check for time immediately following the date
            if i + 1 < len(parts):
                next_token = parts[i+1]
                if ":" in next_token and len(next_token) == 5:
                     # Simple heuristic for HH:MM
                     try:
                         datetime.datetime.strptime(next_token, "%H:%M")
                         time_str = next_token
                     except ValueError:
                         pass
            break

    # Reconstruct task text
    if date_str:
        # Extract everything EXCEPT the date token and the optional time token
        # This preserves text before AND after the date/time
        task_parts = parts[:date_index]
        if time_str:
            # If we found a time, skip the date index and the one after it
            task_parts.extend(parts[date_index+2:])
        else:
            # If no time, skip just the date index
            task_parts.extend(parts[date_index+1:])
        
        task_text = " ".join(task_parts).strip()
    else:
        task_text = " ".join(parts).strip()

    if not task_text:
        return None

    # Calculate Datetime
    dt = None
    task_type = "someday"

    if date_str:
        dt = calculate_deadline(date_str, time_str)
        now = datetime.datetime.now()

        if is_weekly:
            task_type = "weekly"
            # If weekly task passed for this week, move to next week
            if dt <= now:
                dt += datetime.timedelta(days=7)
        else:
            task_type = "dated"
            # Original logic: If dated task is in the past, discard it
            if dt <= now:
                return None
    else:
        # If weekly but no date found, treat as someday or ignore? 
        # Original logic treated "weekly" without date as "someday" effectively, 
        # but forced 'weekly' flag.
        pass

    return Task(text=task_text, dt=dt, is_weekly=is_weekly, task_type=task_type)

def format_remaining(dt: Optional[datetime.datetime]) -> str:
    if dt is None:
        return "someday"
    
    delta = dt - datetime.datetime.now()
    days = delta.days
    secs = delta.seconds
    hours, minutes = divmod(secs // 60, 60)

    if days >= 30:  return f"{days//7}w"
    if days >= 7:   return f"{days}d"
    if days > 0:    return f"{days}d {hours}h"
    if hours > 0:   return f"{hours}h{minutes:02d}"
    if minutes > 5: return f"{minutes}m"
    return "now"

def get_output(tasks: List[Task]):
    if not tasks:
        return {
            "text": "DONE",
            "class": "done",
            "tooltip": "All tasks completed"
        }

    lines = []
    # Process top 30 tasks
    for t in tasks[:30]:
        icon = ICONS.get(t.task_type, ICONS["dated"])
        time_display = format_remaining(t.dt)

        if t.dt:
            # Show time only if it's not the default end-of-day
            if t.dt.hour == 23 and t.dt.minute == 59:
                 date_display = t.dt.strftime("%a %b %d")
            else:
                 date_display = t.dt.strftime("%a %b %d %H:%M")
        else:
            date_display = "no date"

        escaped_task = html.escape(t.text, quote=False)
        
        line = (
            f"{icon}  <b>{escaped_task}</b>\n"
            f"    {time_display}  <span foreground='#74c7ec'>{date_display}</span>"
        )
        lines.append(line)

    return {
        "text": "TODO",
        "class": "active",
        "tooltip": "\n".join(lines)
    }

def main():
    tasks = []
    if TODO_FILE.exists():
        content = TODO_FILE.read_text(encoding="utf-8")
        for line in content.splitlines():
            task = parse_line(line)
            if task:
                tasks.append(task)

    tasks.sort(key=lambda t: t.sort_key)
    
    output_data = get_output(tasks)
    print(json.dumps(output_data))

if __name__ == "__main__":
    main()