# MacClock

A tiny menu bar clock for macOS that fills a small secondary display (built for a
Wokyis dock's 5-inch 1280x720 panel). Native Swift/SwiftUI, no Dock icon, and it
redraws exactly once per minute so it costs essentially nothing to leave running.

## Faces

| Face | Description |
|------|-------------|
| Digital | Clean sans-serif time with date underneath |
| LED | Red seven-segment display with ghost segments and glow, like a 1980s clock radio |
| VFD | Cyan-green vacuum fluorescent version of the segment display |
| Flip | Split-flap hours and minutes cards, like a 1970s flip clock radio |
| Analog | Classic round dial, hour + minute hands, no second hand |

The Digital and Analog faces take a color scheme. Dark: Midnight, Slate, Ember.
Light: Paper, Cloud, Sage. The LED, VFD and Flip faces keep their own fixed looks.

See [INSTALL.md](INSTALL.md) for step-by-step installation on the Mac mini.

## Build

Requires Xcode 15+ (macOS 13 deployment target).

```bash
./build.sh            # produces build/MacClock.app (universal, ad-hoc signed)
./build.sh --install  # also copies to /Applications and launches it
```

To move it to another Mac, copy `build/MacClock.app` over. Because it is ad-hoc
signed, the first launch on the other machine may need right-click > Open (or
`xattr -dr com.apple.quarantine /Applications/MacClock.app` if it arrived with a
quarantine flag).

## Using it

Everything lives in the menu bar clock icon:

- **Clock Face** picks the design.
- **Color Scheme** picks the palette for the Digital and Analog faces.
- **Display** picks which screen the clock fills. "Preview Window" shows a normal
  resizable 1280x720 window instead. On first launch with more than one display
  attached, the smallest non-main display is chosen automatically.
- **24-Hour Time**, **Show Date**, **Always on Top**, **Launch at Login** toggles.

If the chosen display is unplugged, the clock falls back to the preview window
and jumps back to the display when it reappears.

## Previewing faces without a second display

```bash
swift build
.build/debug/MacClock --snapshot /tmp/faces 1280x720 10:08
```

Writes a PNG for every face and color scheme combination into the directory.

## Layout

```
Sources/MacClock/
  main.swift                 entry point (app or --snapshot)
  MacClockApp.swift          MenuBarExtra menu, app delegate, launch-at-login
  ClockWindowController.swift  borderless window placement on the chosen display
  ClockModel.swift           once-per-minute ticker
  ClockSettings.swift        persisted preferences
  ClockTheme.swift           color schemes (background, foreground, secondary, accent, dial)
  TimeParts.swift            formatted time/date pieces for the faces
  ClockRootView.swift        face switcher
  Snapshot.swift             PNG renderer for development
  Faces/                     one file per face
```
