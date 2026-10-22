# Eww X11 drag experiment

The packaged Eww continues to run the Wayland bar. An optional source build
installs `~/.local/bin/eww-x11` for regular, draggable XWayland windows.

Review and install its build dependencies through the package installer:

```sh
./install packages --group eww-build --dry-run
# Run this command as root; review the plan and type yes:
./install packages --group eww-build
```

As your desktop user, review and run the source provisioning command:

```sh
bin/install-eww-x11 --dry-run
bin/install-eww-x11
```

The command requires confirmation, verifies the source archive against
`provision/eww-x11.json`, and builds with `--locked` and only the X11 feature.
It uses Fedora's Rust toolchain and caches source, crates, and build outputs
under `$XDG_CACHE_HOME/dotfiles/eww-x11`. The default is two parallel build
jobs; `CARGO_BUILD_JOBS` can override it. `--offline` requires cached source
and Cargo dependencies. An unchanged installation is reused; an unmanaged or
modified executable is preserved.

Run the static-text experiment, then hold Alt and left-drag its window:

```sh
experiments/eww-drag/run
```

Stop its separate Eww daemon with `experiments/eww-drag/run kill`.

The dialog intentionally omits `:geometry`: Eww reapplies dialog geometry on
window configuration events, which conflicts with dragging. Sway controls the
initial floating placement and subsequent movement instead.

Validate provisioning behavior with `bash tests/eww-x11-test.sh` and run
`tests/lint.sh` for the repository checks. The live experiment additionally
requires XWayland in the running Sway session.
