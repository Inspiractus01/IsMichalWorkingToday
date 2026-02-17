# Is Michal Working Today?

> Is your boss asking "Where's Michal?" Well, wonder no more!

A Slack bot that automatically sets your status based on your schedule. Now your team will always know if Michal is working today or not.

## Do u wanna know if Michal is working today? This bot can tell your boss! 😏

### Is Michal Working Today?

**When working:** you'll see 💻 Working

**When not working:** you'll see 🌙 Not working

No more "Hey, is Michal online?" messages. The status speaks for itself.

---

**⚠️ ATTENTION:** This app might suddenly dissapear when Michal swaps to full-time! Cause you know... school is happening. Until then, enjoy the automated struggle! 🎓→💼

---

## Quick Start

1. **Get a Slack Token**
   - Go to [Slack API](https://api.slack.com/apps)
   - Create a new app → From scratch
   - Add scope: `users.profile:write`
   - Install app → Copy User OAuth Token (starts with `xoxb-`)

2. **Setup**
   ```bash
   cp .env.example .env
   nano .env  # Add your SLACK_TOKEN
   ```

3. **Configure Your Schedule**
   ```bash
   nano schedule.conf
   ```

## Usage

### Run the Daemon

```bash
./auto_status.sh
```

Or as a systemd service (Linux):
```bash
sudo cp slack-status.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now slack-status
```

### Manual Commands

```bash
./slack_status.sh working   # "I'm grinding!"
./slack_status.sh offline  # "I'm free!"
./slack_status.sh clear     # "Who am I?"
./slack_status.sh set "In a meeting" ":meeting:"  # Custom
```

## Schedule Format

Edit `schedule.conf`:
```
Mon=09:00-17:30
Tue=09:00-17:30
Wed=09:00-17:30
```

- Days: Mon, Tue, Wed, Thu, Fri, Sat, Sun
- Time: HH:MM-HH:MM (24-hour format)
- Multiple intervals: `Mon=09:00-12:00,14:00-18:00`

## Customize It

In `schedule.conf`:
```
WORK_TEXT=Working
WORK_EMOJI=:computer:
OFF_TEXT=Not working
OFF_EMOJI=:crescent_moon:
TIMEZONE=Europe/Amsterdam
```

## Requirements

- bash
- curl
- jq

---

*Is Michal working today? Now you know!* 🎉
