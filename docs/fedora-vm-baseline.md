# Fedora VM handoff — B0

The running VirtualBox guest `Fedora dotfiles clean` is Fedora 44 Minimal, user `admin`.
Its boot target remains `multi-user.target`; no display manager, reboot, shutdown, reset or
snapshot was requested by B0. Passwordless sudo is pre-existing test-harness setup, not an
installer feature. The installer does not invoke sudo or configure privileges.

## Installed and verified

- Baseline: Git, tar, rsync, Python 3 and bubblewrap.
- Desktop: kitty, wl-clipboard, XWayland, Fedora guest additions and SwayFX from
  `swayfx/swayfx`; Neovim only for the version/link check. Required dependencies were
  installed with weak dependencies disabled. Full versions are in the
  [package survey](fedora-packages.md).
- `vboxservice` is enabled and active. Guest additions `7.2.16` and host VirtualBox
  `7.2.18` share the 7.2 series; the patch versions differ.
- Guest repo: `/home/admin/Development/dotfiles`, initially deployed at `790c763`.
  Both submodules and Dotbot's nested PyYAML cloned on the guest over HTTPS at their pins.
  The first link install succeeded; the second preserved link metadata and source bytes.
- `~/.config/git` resolves to the repo's `config/git`; `~/.config/nvim` resolves to
  `modules/nvim`, and `init.lua` is readable through it. `nvim --version` reports 0.12.5.
- `tests/link-test.sh` and `tests/sync-nvim-test.sh` pass. `tests/lint.sh` reports
  `SKIP: shellcheck is not on PATH; shell lint was not run.` No tests were changed.
- `./install packages --dry-run` prints `dnf install -- git python3`; a Bash trace and
  the unchanged RPM inventory confirm it did not execute a package transaction.

## Guest-only Sway and clipboard setup

For the user's graphical check, B0 wrote a small regular file at the guest's
`~/.config/sway/config`. It starts kitty, binds Super+Enter to another kitty,
Super+Shift+Q to close a window, and Super+Shift+E to exit SwayFX. It includes
`~/.config/sway/config.d/90-vbox-clipboard.conf`:

```sway
# Guest-local only. Keep the explicit Wayland backend even when DISPLAY is set.
exec sh -c 'test "$(systemd-detect-virt)" = oracle && /usr/bin/VBoxClient --clipboard --session-type wayland'
```

The exact client command is `/usr/bin/VBoxClient --clipboard --session-type wayland`.
It starts with the Sway session, as the logged-in user, and the virtualization guard
prevents execution on physical hardware. No host autostart or generic installer link was added.
Future Sway configuration should own this guest-only fragment and replace the temporary
smoke-test config.

The Fedora package also supplies `/etc/xdg/autostart/vboxclient.desktop`, which invokes
`VBoxClient-all` and automatically selects a backend. A guest user override at
`~/.config/autostart/vboxclient.desktop` sets `Hidden=true` to prevent that competing
autostart if a future session starts XDG autostart entries. The Wayland command above is
the intended clipboard owner. No library was installed to enable the wrong X11 backend.
X11 libraries present on the VM are required dependencies of the requested desktop packages.

`WLR_BACKENDS=headless sway --validate --config ~/.config/sway/config` succeeds.
This checks configuration parsing only. It does not prove a working graphical session,
GPU/DRM rendering, kitty window creation or clipboard exchange. VBoxClient was not started
in the SSH session without a Wayland display.

## User graphical checks still required

1. In the VirtualBox console, log in as `admin` on a TTY and run `sway` as that user.
   The executable belongs to SwayFX. Confirm the compositor starts and kitty opens;
   Super+Enter should open another kitty. This minimal setup uses the Super key.
2. With the VM's shared clipboard set to bidirectional, copy a distinct string on the
   host and run `wl-paste` in guest kitty. Confirm it matches.
3. Run `printf 'B0 guest to host\n' | wl-copy` in kitty, then paste into a host application.
   Confirm it matches. `pgrep -af '[V]BoxClient.*clipboard'` can show the selected backend.
4. If needed, exit only the Sway session with Super+Shift+E. Leave the VM running for
   the orchestrator. B0 did not verify the host's bidirectional clipboard setting.

No Neovim plugin installation or parser build was run; those belong to Block 3.

## Transfer details for repeat deployments

The host SSH default invocation failed on the ownership/permissions of
`/etc/ssh/ssh_config.d/20-systemd-ssh-proxy.conf` in the worker environment. Passing
`-F /home/vlada/.ssh/config` used the existing alias successfully without changing host
SSH configuration. The deployment included the superproject's `.git` but excluded both
`modules/` and `.git/modules/`, so cached submodule repositories could not bypass network clones.
It also excluded `*secret*env*`, uppercase equivalents and `Documents`.

The copied `.git/config` contained a host-local SSH URL override for the Neovim submodule.
Running `git submodule sync --recursive` on the guest restored the HTTPS URL recorded in
`.gitmodules` before `./install link`. The host repository configuration was not changed.
A fresh superproject clone would not contain that copied local override.

The transition report `../dotfiles-transition/reports/B0-vm-baseline.md` contains the
command transcripts, deviations and final repository/VM state. No remote push was run.

## Graphics: VirtualBox needs software rendering (found during B0 manual validation)

The VM could not run a Wayland compositor in either of its default graphics states. Both failures are
**VirtualBox-only**; neither exists on the physical machine, which has a Radeon RX 9070 on `amdgpu`.

| VM setting | Result |
|---|---|
| VMSVGA, `accelerate3d=on` (original) | SwayFX starts but stalls for ~1 minute. Kernel logs `vmwgfx […] This configuration is likely broken. Please switch to a supported graphics device`, plus repeated `vmw_msg_ioctl: Failed to open channel`. |
| VMSVGA, `accelerate3d=off` | No hardware GL at all. `MESA-EGL: egl: failed to create dri2 screen`, `EGL_NOT_INITIALIZED`, `fx_renderer: Could not initialize EGL`, `sway/server.c: Failed to create renderer`. Compositor exits immediately. |
| VMSVGA, `accelerate3d=off` + software GL | **Works.** Clean start, no vmwgfx warnings, `Initialized vmwgfx 2.21.0` only. |

Host-side setting (applied):
```
VBoxManage modifyvm "Fedora dotfiles clean" --accelerate3d off
```
VMSVGA itself must stay — it is the only controller providing the KMS that Wayland requires.

Guest-side, the session needs:
```
WLR_RENDERER_ALLOW_SOFTWARE=1   # wlroots may accept a software renderer
LIBGL_ALWAYS_SOFTWARE=1         # Mesa selects llvmpipe instead of the failing vmwgfx DRI driver
```
Provided by `mesa-dri-drivers` (`swrast_dri.so`, `kms_swrast_dri.so`) and `libgallium`, already installed.

**These two variables belong only in the VirtualBox machine profile**, never the physical one — on real
hardware they would force a Radeon to render on the CPU. They live beside the `VBoxClient` clipboard
command in the VM-only fragment.

### Consequence for Blocks 5–7
Everything is CPU-rendered in the VM, so those blocks can verify that SwayFX configuration is
**correct** — that blur, shadows, rounded corners and opacity are configured and visibly applied — but
they cannot say anything about **performance**. A sluggish session in the VM is not a signal to tune
effect settings. Effect cost is measured on physical hardware, separately, as the plan already states.

## B0 manual validation: PASSED (user, 2026-09-21)
SwayFX starts from a TTY · kitty opens, `Super+Enter` spawns another · VirtualBox clipboard verified
in **both** directions with `wl-copy`/`wl-paste` · `Super+Shift+E` exits cleanly.
