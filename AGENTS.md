# AGENTS.md

Fork of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) ("illogical-impulse") — a Hyprland desktop config with a Quickshell-based shell. Local work is almost entirely in `dots/.config/quickshell/ii/` (QML shell). `origin` = personal fork (`osinniy/dots-hyprland`), `upstream` = end-4/dots-hyprland. Sync via merge/pull from `upstream/main`; don't rewrite shared history.

## Commands

- `./setup install` — full install (interactive; sub-steps: `install-deps`, `install-setups`, `install-files`). `./setup exp-update` (experimental update; locks via `.update-lock`), `./setup uninstall`, `./setup virtmon` (dev: virtual monitors), `./setup checkdeps` (dev: verify pkg existence), `./setup exp-merge` (merge upstream with rebase).
- Never run `setup` or `diagnose` with sudo or as root (`prevent_sudo_or_root` aborts).
- `./diagnose` — dumps diagnostics to `diagnose.result` (gitignored), then interactively offers pastebin upload (0x0.st). Use for shell/hyprland issues.
- Shell scripts are sourced pieces: `setup` loads `sdata/lib/*.sh` and dispatches to `sdata/subcmd-*/0.run.sh`. Output helpers `x`, `v`, `e` come from `sdata/lib/functions.sh`. Respect the "sourced, not executed" convention in `sdata/subcmd-*` scripts.

## How it works

- `dots/` is rsynced to `~/.config` / `~/.local` — **not symlinked**. Editing a file in `dots/` has no effect until `./setup install-files` runs. Sync dirs use `rsync --delete`, so files that exist only in `~/.config/<app>` (not in `dots/`) are deleted — back up before wiping.
- `dots-extra/` = optional extras (emacs, swaylock, via-nix, ...), separate install flow.
- `sdata/dist-arch/` = PKGBUILDs for `illogical-impulse-*` packages installed by `./setup install`; build artifacts (`pkg/`, `src/`, `*.pkg.tar.zst`) are gitignored.
- Submodule: `dots/.config/quickshell/ii/modules/common/widgets/shapes` → end-4/rounded-polygon-qmljs. Run `git submodule update --init --recursive` after cloning or switching branches.
- `cache/` (gitignored) holds local package lists; `repro-steam-overview/` is untracked scratch. Neither should be committed.

## Quickshell dev loop

- Shell runs as `qs -c ii` (`qsConfig=ii` set in `dots/.config/hypr/hyprland/variables.lua`); quickshell + venv live in `~/.local/state/quickshell/.venv` (`ILLOGICAL_IMPULSE_VIRTUAL_ENV`, set in `dots/.config/hypr/hyprland/env.lua`).
- To test QML changes: edit `dots/.config/quickshell/ii/`, run `./setup install-files` (or `--skip-*` flags; see `sdata/subcmd-install/options.sh`), then restart quickshell (e.g. kill `qs` process; Hyprland restarts it via `execs.lua`).
- No tests, no lint, no CI of value locally (.github workflows are upstream's).
