# Installing MacClock

MacClock is a small menu bar app that fills a secondary display with a clock.
This guide covers building it on one Mac, moving it to the Mac mini that drives
the Wokyis dock, and getting it parked on the dock's screen.

## Requirements

| | Build machine | Mac mini |
|---|---|---|
| macOS | 13 Ventura or newer | 13 Ventura or newer |
| Xcode | Xcode 15 or newer, with the command line tools | Not needed |
| Chip | Intel or Apple silicon | Intel or Apple silicon (the build is universal) |

The dock's screen must show up in **System Settings > Displays** as a second
monitor. MacClock draws to it like any other display.

## 1. Build the app

On the build machine:

```bash
cd ~/Code/Desktop/MacClock
./build.sh
```

That compiles a release build, assembles `build/MacClock.app`, and signs it with
an ad-hoc signature. The app is about half a megabyte.

To install and launch on the build machine itself instead, run
`./build.sh --install`, which copies the app into `/Applications` and opens it.

## 2. Copy it to the Mac mini

Copy `build/MacClock.app` to the Mac mini by AirDrop, a USB drive, file
sharing, or `scp`:

```bash
scp -r ~/Code/Desktop/MacClock/build/MacClock.app <user>@<mac-mini>.local:~/Downloads/
```

On the Mac mini, drag `MacClock.app` into `/Applications`. Keep it there rather
than running it from Downloads. Launch at login registers the app by its
location, so it should not move afterwards.

## 3. First launch

Because the app is signed ad-hoc rather than notarized, macOS may refuse to open
it the first time if the copy picked up a quarantine flag (AirDrop and browser
downloads add one, USB drives and `scp` usually don't).

Either right-click the app in Finder, choose **Open**, and confirm, or clear the
flag in Terminal:

```bash
xattr -dr com.apple.quarantine /Applications/MacClock.app
```

Then open it normally. Nothing appears in the Dock. Look for a clock icon in the
menu bar.

## 4. Point it at the dock's screen

With the dock connected, MacClock picks the smallest display that isn't the main
one on its first launch. That's the dock's panel in a normal setup.

If it guessed wrong or the dock was unplugged at the time, use the menu bar icon:

- **Display** lists every attached screen. Pick the dock's panel.
- **Preview Window** shows the clock in a normal 1280x720 window instead, which
  is handy while the dock isn't attached.

The choice is remembered by the display's name. If you unplug the dock, the
clock falls back to the preview window and returns to the dock when it comes
back.

## 5. Make it start automatically

In the menu bar icon, turn on **Launch at Login**. macOS may show a
notification that MacClock was added as a login item. You can review it under
**System Settings > General > Login Items & Extensions**.

This toggle only works from the installed copy in `/Applications`, not from a
build run straight out of the project folder.

## 6. Pick a face and options

All from the menu bar icon:

- **Clock Face**: Digital, LED, VFD, Flip, or Analog.
- **Color Scheme**: Midnight, Slate, Ember (dark) or Paper, Cloud, Sage (light).
  Applies to the Digital and Analog faces. The three radio-style faces keep
  their own colors.
- **24-Hour Time** and **Show Date**.
- **Always on Top** keeps the clock above other windows if something lands on
  the dock's screen.
- **Quit MacClock**.

Settings are saved immediately and survive restarts.

## Updating

Rebuild on the build machine with `./build.sh`, copy the new `MacClock.app` over
the old one in `/Applications` on the Mac mini, and relaunch. Settings are kept
in the user's preferences, not inside the app, so they carry over. If the
quarantine flag comes back, clear it again as in step 3.

## Uninstalling

1. Quit MacClock from the menu bar icon.
2. Turn off Launch at Login first if it was on, or remove MacClock under
   **System Settings > General > Login Items & Extensions**.
3. Delete `/Applications/MacClock.app`.
4. Optionally remove the saved settings:

```bash
defaults delete com.samduemler.MacClock
```

## Troubleshooting

**"MacClock can't be opened because Apple cannot check it for malicious software."**
The quarantine flag is set. Use the right-click Open method or the `xattr`
command in step 3.

**The clock is on the wrong screen.**
Open the menu bar icon and choose the right one under **Display**. Display names
come from the monitor itself, so the dock's panel may appear under a generic
name such as a model number.

**The clock window is showing on the main display in a normal window.**
That's the preview fallback. Either the chosen display isn't connected or
**Preview Window** is selected. Pick the dock's screen under **Display**.

**Launch at Login is greyed or doesn't stick.**
Make sure the app is running from `/Applications`. Toggle it off and on again
after moving the app.

**The time looks a few seconds stale after waking.**
The app refreshes on wake, on time zone changes, and at every minute boundary.
If it ever looks stuck, quit and reopen it from the menu bar.

**I want to check the faces without the dock attached.**
Choose **Preview Window** under **Display**, or render every face to PNG files:

```bash
cd ~/Code/Desktop/MacClock
swift build
.build/debug/MacClock --snapshot /tmp/faces 1280x720 10:08
```
