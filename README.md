# Slack Auto Status

Automatically set your Slack status based on a schedule.

## Setup

1. **Get Slack Token**
   - Go to [Slack API](https://api.slack.com/apps)
   - Create a new app → From scratch
   - Add scope: `users.profile:write`
   - Install app → Copy User OAuth Token (starts with `xoxb-`)

2. **Configure**
   ```bash
   cp .env.example .env
   nano .env  # Add your SLACK_TOKEN
   ```

3. **Edit Schedule**
   ```bash
   nano schedule.conf
   ```

## Usage

### Auto Daemon (runs in background)

```bash
# Run manually
./auto_status.sh

# Or install as systemd service (Linux)
sudo cp slack-status.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now slack-status
```

### Manual Commands

```bash
./slack_status.sh working   # Set Working :computer:
./slack_status.sh offline   # Set Not working :crescent_moon:
./slack_status.sh clear     # Clear status
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

## Customize Status

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
