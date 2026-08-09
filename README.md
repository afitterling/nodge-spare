# NodgeSpare

A tiny macOS menu bar utility that **spares the notch**: it parks a blank, resizable status
item in the notch zone so that zone is claimed by nothing, and your real icons line up clear
of the cutout.

Native Swift + AppKit. No Dock icon, no window, ~200 KB binary, zero dependencies.

## Why

On notched Macs the menu bar is really two strips with a dead zone between them. Status items
fill right-to-left, and whatever reaches the notch gets swallowed by it. NodgeSpare claims that
dead zone with an item exactly the notch's width, so the icons you care about can't land there.

**What this is not:** a spacer *consumes* menu bar width, it doesn't create any. It will not
bring back icons that are already hidden — if your menu bar is overflowing, reserving another
185 pt makes the overflow worse, not better. Use it to keep the notch zone deliberately empty
when you have room to spare; use a manager like Ice or Bartender if you need to *fit* more icons.

## Build & run

```sh
./build.sh          # produces dist/NodgeSpare.app
make run            # build + launch
make install        # build + copy to /Applications + launch
UNIVERSAL=1 ./build.sh   # arm64 + x86_64 fat binary
```

Requires macOS 13+ and the Xcode command line tools.

## First run — position the spacer

macOS decides where new status items appear, so the spacer needs one manual placement:

1. The spacer starts with a **dashed outline** so you can see it.
2. Hold **⌘** and drag it until it sits just to the right of the notch.
3. Turn off *Show Spacer Outline* in the menu. The position is remembered across launches.

## Menu

| Item | What it does |
| --- | --- |
| *Notch: N pt — display* | Live measurement of the attached notched display |
| **Reserve Notch Space** | Master on/off |
| **Match Notch Width Automatically** | Track the measured notch width; off to use the slider |
| **Width** slider | Manual width, 0–400 pt (enabled when auto is off) |
| **Show Spacer Outline** | Dashed outline for finding and ⌘-dragging the item |
| **Only On Notched Displays** | Collapse the spacer in clamshell / external-only setups |
| **Launch at Login** | `SMAppService` registration (needs the installed `.app`) |

The width is re-measured automatically on `didChangeScreenParameters`, so docking,
undocking, or changing resolution keeps it correct.

## How it works

`NSScreen.auxiliaryTopLeftArea` and `auxiliaryTopRightArea` describe the two usable menu bar
strips; everything between them is the notch:

```
notchWidth = screen.frame.width - leftArea.width - rightArea.width
```

On this machine's built-in Retina display that resolves to **185 pt** (1710 − 763 − 762).
That value becomes the `length` of a borderless `NSStatusItem`, whose `autosaveName` persists
the user's ⌘-dragged position.

## Layout

```
Sources/NodgeSpare/
  main.swift            NSApplication bootstrap (.accessory policy)
  AppDelegate.swift     control status item, menu, state refresh
  SpacerItem.swift      the blank spacer status item + outline drawing
  NotchMetrics.swift    notch measurement
  Preferences.swift     UserDefaults wrapper
  LoginItem.swift       SMAppService launch-at-login
  WidthSliderView.swift in-menu slider
Resources/Info.plist    LSUIElement bundle metadata
build.sh                compiles + assembles + ad-hoc signs the .app
```

## Signing

`build.sh` ad-hoc signs by default, which is fine locally. For *Launch at Login* to survive on
other Macs, sign with a real identity:

```sh
CODESIGN_ID="Developer ID Application: Your Name (TEAMID)" ./build.sh
```

## License

MIT
