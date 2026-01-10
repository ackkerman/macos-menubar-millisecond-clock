# msbar — macOS Menu Bar Millisecond Clock

A tiny menu bar resident app that shows the current time as `HH:mm:ss.SSS`. It hides from the Dock and updates every 10ms by default (tune `updateInterval` in `Sources/msbar/msbar.swift` if you prefer ~16.6ms/60Hz).

## Requirements
- macOS 13+ (AppKit)
- SwiftPM (Xcode GUI not required) / Swift 6 toolchain

## Quick start
```bash
make release          # build release binary
./make_app.sh         # produce msbar.app
open msbar.app        # launch (no Dock icon)
```

Install by copying the generated `.app` wherever you like, e.g. `/Applications`:
```bash
cp -R msbar.app /Applications/
open /Applications/msbar.app
```
For the first launch, right-click → “Open” helps pass Gatekeeper prompts.

### Makefile targets
- `make build`   : debug build
- `make release` : release build
- `make run`     : run debug build
- `make test`    : unit tests (requires macOS SDK/XCTest available)
- `make bundle` / `make app` : release build → `.app` bundle
- `make clean`   : clean builds and `.app`

## Implementation notes
- AppKit + `NSStatusItem` with monospaced digit font to avoid width jitter.
- `DispatchSourceTimer` at 10ms on the main queue updates the title.
- Dock hiding via `LSUIElement` in Info.plist and `.accessory` activation policy.
