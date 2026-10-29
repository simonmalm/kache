<p align="center"><img src="kache-owl.png" alt="The Kache owl" width="160"></p>

# Kache

One terminal for all your computers. Run commands and long jobs on your
other devices, move files between them, see how they are doing, and see
who, or which AI agent, is working where.

**Kache 0.9 is an early release.** It works and is used every day, but
expect rough edges, and please [report them](../../issues).

## Install

Windows 10 and 11 (x64), in PowerShell:

```powershell
irm https://simonmalm.github.io/kache/install.ps1 | iex
```

Or download the installer from the [download page](https://simonmalm.github.io/kache/)
or the [releases](../../releases). A Linux package follows.

Then pair your devices: `kache pair 192.168.1.30` on one, and accept on the
other. `kache` alone opens the window.

## Commands

`kache COMMAND --help` explains each one; `kache guide` covers JSON output,
exit codes and how AI agents use Kache.

### Work on devices

| Command | What it does |
|---|---|
| `kache run DEVICE -- COMMAND` | Run a command on one or more devices, output live |
| `kache job start DEVICE -m "what" -- COMMAND` | Start a job: a command that keeps running after you disconnect |
| `kache job log JOB [-f]` | Show a job's output, or follow it until it ends |
| `kache job stop JOB` | Stop a job and everything it started |
| `kache job input JOB TEXT` | Send a line of input to a running job |
| `kache jobs` | Jobs on all your devices, running ones first |
| `kache wait file\|log\|job\|port` | Wait until a file exists, a log line appears, a job ends or a port opens |
| `kache pick` | The device with the most room for new work now (`any` as a device picks it for you) |

### Files

| Command | What it does |
|---|---|
| `kache ls DEVICE:PATH` | List a folder |
| `kache cat DEVICE:FILE` | Show a text file, in whatever encoding it is in |
| `kache tail DEVICE:FILE` | The last lines of a file |
| `kache find DEVICE:PATH PATTERN` | Find files by name |
| `kache stat DEVICE:PATH` | Size, time and hash of a file or folder |
| `kache patch DEVICE:FILE --old A --new B --hash H` | Replace one piece of text, if the file is still the version you read |
| `kache write DEVICE:FILE --file LOCAL --hash H` | Replace a whole file with a local one's text (`--hash new` creates one) |
| `kache undo` | Undo a change: your last one, the latest to a file, or one backup |
| `kache backups` | Changes Kache can undo |
| `kache push FILE... DEVICE:PATH` | Copy files or folders to a device |
| `kache pull DEVICE:PATH... LOCAL` | Copy files or folders from a device |
| `kache copy DEVICE:PATH all:PATH` | Copy from one device to others |
| `kache sync DIR DEVICE:DIR [--watch]` | Send what changed in a folder, once or continuously |

### Data tools (the same on every device and shell)

| Command | What it does |
|---|---|
| `kache convert IN OUT` | Convert between JSON, YAML, TOML, CSV, TSV and NDJSON |
| `kache query FILE PATH` | A value from a data file; `--min`, `--max`, `--equals` or `--assert` make it a check |
| `kache render TEMPLATE OUT` | Fill a template's `{{name}}` placeholders |
| `kache hash PATH` | SHA-256 of a file or folder; `--save` writes the sums, `--check` compares |
| `kache archive PATHS... OUT` | Pack into a .zip, .tar.gz or .tar |
| `kache extract ARCHIVE` | Unpack a .zip, .tar.gz or .tar |

### Working together

| Command | What it does |
|---|---|
| `kache chat [MESSAGE]` | Read the chat, or write to it; `@name` pings someone |
| `kache actors` | People and agents working right now, and on what |
| `kache feed` | What happened on a device, with who did it |
| `kache evidence ID` | The full report Kache kept when a command failed |
| `kache gaze DEVICE -m "why"` | An AI agent asks to see and use another device's screen |
| `kache service ...` | Commands Kache keeps running (see below) |
| `kache schedule ...` | Commands Kache starts every so often or daily (see below) |
| `kache relay ...` | Chains of steps across devices, agents and people (see below) |

### Devices and health

| Command | What it does |
|---|---|
| `kache devices` | Your devices: online or not, and their health |
| `kache ps` | Programs running on a device, biggest first |
| `kache top` | The programs using the most CPU right now |
| `kache kill PID` | Stop a program |
| `kache gpu` | GPU load, temperature and memory |
| `kache disk` | Free space on each disk |
| `kache inventory` | What a device is: OS, CPU, memory, tools and shells |
| `kache stats` | Health over the last hours (kept for 7 days) |
| `kache shells DEVICE` | Shells installed on a device |
| `kache screenshot DEVICE` | A picture of a device's screens |
| `kache ssh` | Plain SSH sessions and logins (work that bypasses Kache) |
| `kache wake MAC` | Power on a sleeping computer (Wake-on-LAN) |

### What agents may use (set by people)

| Command | What it does |
|---|---|
| `kache lock DEVICE [--uses gpu] [--for 2h]` | Lock a device, or parts of it, for agents |
| `kache unlock DEVICE` | Take its locks off |
| `kache limits DEVICE [--cpu 80 --gpu-temp 83]` | See or set the CPU, memory and temperature limits agents' work keeps under |

### Pairing and names

| Command | What it does |
|---|---|
| `kache pair ADDRESS` | Pair with another device (or `--ssh HOST`: one you reach over SSH) |
| `kache pending` | Pair requests waiting for an answer |
| `kache accept` / `kache deny` | Answer a pair request |
| `kache trusted` | Devices allowed to command this one |
| `kache revoke NAME` | Stop a device from commanding this one |
| `kache remove NAME` | Forget a device this one commands |
| `kache rename [OLD] NEW` | Rename this device, or what you call another one here |
| `kache whoami` | This device's name, addresses and key |
| `kache discover` | Devices on your Tailscale network that run Kache |
| `kache doctor [DEVICE]` | Why a device cannot be reached, step by step |
| `kache listen [MODE]` | Where this device answers: all networks, only Tailscale, or one address |

### Kache itself

| Command | What it does |
|---|---|
| `kache` | Open the window |
| `kache status` | Whether this device's Kache is running |
| `kache update --from FOLDER` | Update devices from a release bundle (an installed copy updates by running the new installer) |
| `kache startup on\|off` | Start Kache at login (`--at-boot`: before anyone logs in) |
| `kache stop` | Stop this device's Kache |
| `kache proxy` | Run Kache in the foreground |
| `kache tray restart` | Start the tray icon afresh |
| `kache mcp` | Serve Kache as tools for AI agents (Model Context Protocol) |
| `kache guide` | How scripts and AI agents use Kache |
| `kache uninstall` | Uninstall (pairings and data are kept) |

### Relays

| Command | What it does |
|---|---|
| `kache relay templates` | Ready-made relays to start from |
| `kache relay new NAME --from TEMPLATE` | Write a relay file to start from |
| `kache relay save FILE` | Add or replace a relay |
| `kache relay list` / `show NAME` | Relays on this device, or one's definition |
| `kache relay start NAME [--set k=v] [--wait]` | Start a run |
| `kache relay runs` / `status RUN` | Recent runs, or one run's steps |
| `kache relay wait RUN` | Follow a run until it ends or needs you |
| `kache relay approve` / `reject RUN STEP` | Answer a step that waits for approval |
| `kache relay go RUN STEP` | Let a step start although others are working on its device |
| `kache relay done RUN STEP` | An agent reports its step done |
| `kache relay brief RUN STEP` | The brief an agent gets for a step |
| `kache relay handed` / `close RUN STEP` | Hand a gaze step's agent its task, or close a session holding a step up |
| `kache relay cancel` / `retry RUN` | Stop a run, or go on where it stopped |
| `kache relay remove NAME` | Remove a relay |

### Services and schedules

| Command | What it does |
|---|---|
| `kache service set NAME DEVICE -m "what" -- COMMAND` | Keep a command running, restarting it after failures |
| `kache schedule set NAME DEVICE -m "what" --every 30m -- COMMAND` | Run a command every so often (or `--daily 03:30`) |
| `kache service\|schedule list` | List them |
| `kache service\|schedule start` / `stop NAME` | Turn one on or off |
| `kache service\|schedule remove NAME` | Remove one |

### Gaze (AI agents, with your permission)

| Command | What it does |
|---|---|
| `kache gaze DEVICE -m "why"` | Ask to see and use a device's screen; the person decides |
| `kache gaze shot` | A screenshot of that screen |
| `kache gaze click X Y` / `move X Y` / `drag X Y X2 Y2` | Use the mouse |
| `kache gaze scroll AMOUNT` | Scroll |
| `kache gaze type TEXT` / `key KEYS` | Type, or press keys like `ctrl+l` |
| `kache gaze wake DEVICE --click X,Y -m "why" TEXT` | Wake an agent idle in an editor, in one go |
| `kache gaze end` | Let the device go |

## Licence

MIT ([LICENSE.txt](LICENSE.txt)). Each release carries
THIRD-PARTY-NOTICES.txt for the components made by others. The source code
is not published yet.
