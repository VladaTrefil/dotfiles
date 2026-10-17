# Release Provisioning Modularization Handoff

**Status:** Approved and deferred. This is a handoff for a separate implementation task. Do not implement it as part of the Catppuccin cursor installation commit.

## Goal

Reduce the mixed responsibilities and file sizes across release installation,
release configuration, and release tests. The next implementation must extract
at least cursor themes, fonts, and RPMs into focused modules in one cohesive
refactor. It must not stop after proving the pattern with cursors.

The resulting structure should let a future maintainer understand or change one
release type without reading the implementation and tests for every other type.
Shared code should contain mechanisms such as hashing, downloading, archive
access, safe staging, and manifest loading, but no cursor-, font-, or RPM-specific
policy.

## Required scope

The refactor must cover all three layers below.

1. **Installation:** split cursor, font, and RPM behavior out of
   `bin/install-releases`. Keep that executable as a thin, stable CLI and
   orchestrator.
2. **Configuration:** split the release manifest by release type and isolate the
   cursor's runtime configuration from the general desktop configuration entry
   point. Preserve the existing package-group mapping used by RPM releases.
3. **Testing:** replace the monolithic release test with type-specific suites and
   shared fixture builders. Keep end-to-end coverage at the public entry points.

Executable releases and Python wheel sets should use the same boundaries when
they are extracted. They may be included in this refactor if doing so makes the
entry point genuinely thin, but cursor, font, and RPM extraction is the minimum
accepted result.

## Proposed structure

```text
bin/
  install-releases                 # argument parsing and top-level dispatch only
  install-packages                 # package/RPM transaction planning and execution
  configure-desktop                # thin desktop configuration orchestrator
  release_installers/
    __init__.py
    manifests.py                   # load, merge, and validate release declarations
    utils.py                       # shared acquisition, hashing, archive, and staging code
    cursors.py                     # cursor validation, state, and installation
    fonts.py                       # font validation, state, and installation
    rpm.py                         # RPM selection and verified-path preparation
    executables.py                 # follow-up or same-refactor extraction
    python_wheels.py               # follow-up or same-refactor extraction
  desktop_configurators/
    cursor                         # gsettings and live Sway cursor synchronization
provision/
  releases.d/
    cursors.json
    fonts.json
    rpm.json
    tools.json
tests/
  release_fixtures.py              # shared archive, manifest, cache, and snapshot helpers
  releases/
    test_cli.py
    test_cursors.py
    test_fonts.py
    test_rpm.py
    test_tools.py
  release-test.py                  # optional compatibility runner, with no test logic
  cursor-config-test.sh
```

Names can change to match an established repository convention, but the
boundaries may not collapse back into a single implementation, manifest, or test
file.

## Responsibilities and interfaces

### CLI and dispatch

`bin/install-releases` must preserve these public modes:

- default: executable and Python-wheel tools;
- `--fonts`: public font releases;
- `--cursors`: cursor themes;
- `--rpm`: verified RPM paths for the package phase;
- `--group NAME`: repeatable RPM group selection;
- `--offline`: cached, checksum-verified artifacts only.

The CLI should load all applicable manifests, select releases, acquire and verify
every selected artifact before changing an installation target, and dispatch
through an explicit kind-to-handler mapping. Prefer an ordinary mapping over a
plugin framework or inheritance hierarchy.

Each type module should expose a small public interface for validating its
manifest entries and applying or preparing its selected releases. The CLI owns
argument semantics and cross-release ordering. A type module owns paths, safety
rules, state files, messages, and installation policy for that type.

### Shared utilities

`utils.py` should own only reusable mechanisms:

- SHA-256 calculation and byte digests;
- HTTPS download/cache acquisition and size verification;
- safe access to ZIP and tar members;
- temporary staging and rollback helpers;
- generic filesystem snapshots used by managed-state checks;
- small atomic write helpers.

Type-specific archive shape, allowed members, target paths, permissions,
messages, and replacement rules remain in the type module. Avoid a generalized
installer abstraction that requires conditionals for every release kind.

### Cursor module and configuration

`cursors.py` owns Xcursor ZIP validation, safe relative symlinks, desired-state
generation, managed-state stamps, rollback, target permissions, and installation
under `$XDG_DATA_HOME/icons`.

The runtime selection logic currently in `bin/configure-desktop` should move to
a focused cursor configurator. The desktop entry point may remain as a thin
orchestrator. Cursor configuration must continue to:

- read the linked `environment.d` values;
- synchronize `org.gnome.desktop.interface` through `gsettings`;
- refresh an active Sway cursor manager so a cached fallback is replaced;
- finish with `catppuccin-mocha-pink-cursors` at size 32;
- safely skip live Sway configuration outside a reachable Sway session.

The Sway, GTK 3/4, and environment configuration files remain declarative
sources. The refactor may add a consistency test, but must not generate or
rewrite those repository files during installation.

### Font module

`fonts.py` owns selected top-level TTF validation, desired-state and stamp
handling, replacement safety, rollback, permissions, and installation under
`$XDG_DATA_HOME/fonts/dotfiles-releases`.

`bin/fetch-assets` remains responsible for optional private assets and calls the
public font mode for public releases. It must not duplicate the public font
installer. Fontconfig visibility and the existing separation between public and
private assets must remain covered by integration tests.

### RPM module and package installation

`rpm.py` owns RPM manifest validation, group membership, checksum/size
verification, the unavailable-COPR diagnostic, and emitting verified local RPM
paths. It never invokes `dnf` itself.

Move the large package-plan and transaction function out of the top-level
`install` script into `bin/install-packages`. The top-level script remains the
user-facing dispatcher and continues to enforce the review, dry-run, root, and
confirmation boundaries. `install-packages` may request verified RPM paths only
through `bin/install-releases --rpm --group ...`; it must never reconstruct or
trust a remote RPM URL itself.

The two meanings of a package group remain linked:

- `packages/<group>.txt` selects the Fedora/Flatpak/COPR package manifest;
- an RPM release's `groups` array selects checksum-pinned RPMs associated with
  that same package group.

### Release configuration

Replace the single `provision/releases.json` with type-oriented files under
`provision/releases.d`. Preserve each release entry's current fields and values.
The manifest loader must fail on duplicate release names, unknown kinds, invalid
type-specific fields, and a release stored in the wrong type file.

Manifest splitting must not weaken the existing invariant that every selected
artifact is verified before any target in that invocation is created or
replaced. The configuration change must also preserve the current pinned URLs,
versions, sizes, SHA-256 values, cursor theme/size, font face selection, and RPM
group membership.

## Testing structure

Create shared fixture helpers for release archives, cache seeding, temporary
repositories, manifest writing, and metadata snapshots. Both Python tests and
shell integration tests should call those helpers instead of embedding new ZIP
or JSON builders.

Split coverage by responsibility:

- `test_cursors.py`: archive traversal, unsafe links, aliases, unmanaged and
  modified targets, permissions, rollback, and idempotence;
- `test_fonts.py`: selected faces, invalid members, fontconfig visibility,
  unmanaged and modified targets, rollback, and idempotence;
- `test_rpm.py`: group filtering, size/checksum failure, unavailable-build
  diagnostics, and verified-path output only;
- `test_cli.py`: mutually exclusive modes, `--group` validation, manifest
  merging, duplicate detection, verify-all-before-mutation, and dispatch;
- `test_tools.py`: existing executable and wheel-set behavior until or after
  those modules are extracted;
- `cursor-config-test.sh`: portal synchronization and the live-Sway refresh
  command sequence;
- `tests/link-test.sh`: only the end-to-end cursor install/configuration
  assertion, using the shared cursor fixture;
- `tests/fetch-assets-test.sh`: only the public/private font integration path,
  using the shared font fixture;
- package tests: dry-run, group mapping, root/confirmation boundaries, and the
  guarantee that only verified local RPM paths reach `dnf`.

If `tests/release-test.py` is kept because external workflows invoke it, make it
a small runner that imports or executes the focused suites. Do not leave fixture
construction or type-specific assertions in it.

## Migration sequence

1. Add shared fixture helpers and characterization tests without changing
   production behavior.
2. Add the manifest-directory loader and prove it rejects duplicates and invalid
   type placement.
3. Extract shared acquisition/staging utilities.
4. Move cursor installation and cursor runtime configuration, then run cursor
   unit and link integration tests.
5. Move font installation and manifest entries, then run font and fetch-assets
   integration tests.
6. Move RPM preparation, package group wiring, and package installation logic,
   then run RPM and package-plan tests.
7. Extract executables and Python wheel sets if included in the implementation;
   otherwise leave explicit dispatch adapters and a documented follow-up.
8. Remove obsolete monolithic code and fixtures only after all public-entry-point
   tests pass.

Keep the steps reviewable, but do not merge a partial end state in which only the
cursor code is modular and the font/RPM work is deferred again.

## Preserved behavior and non-goals

The refactor must preserve:

- current command lines, output streams, and exit behavior;
- checksum and size verification before mutation;
- fail-closed archive handling and symlink rules;
- managed/unmanaged target protection and rollback;
- byte- and metadata-idempotence expectations;
- existing installation paths and modes;
- package dry-run, privilege, confirmation, and no-implicit-`sudo` boundaries;
- Catppuccin Mocha Pink at size 32 and its live Sway refresh;
- offline operation from a fully seeded verified cache.

Do not add a new dependency, change pins, change package membership, redesign the
top-level command set, or introduce a generic plugin system as part of this work.

## Acceptance verification

At minimum, run and pass:

```sh
tests/release-test.py
tests/cursor-config-test.sh
tests/link-test.sh
tests/fetch-assets-test.sh
tests/lint.sh
tests/bootstrap-test.sh
tests/shell-test.sh
python3 tests/manifest-coverage.py
./install packages --group desktop --dry-run
./install packages --group apps --dry-run
git diff --check
```

Also perform offline end-to-end installs for fonts and cursors from a clean
temporary home, verify RPM group selection for `desktop` and `apps`, and confirm
a second run does not change managed file bytes or metadata.
