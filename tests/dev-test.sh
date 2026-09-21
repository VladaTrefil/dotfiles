#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
# Runtime installation is a separate, explicit operation. Point this test at its
# HOME; all config, scratch inputs, caches and state still use a fresh HOME.
runtime_home=${1:?Usage: tests/dev-test.sh /path/to/provisioned-test-home}
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture"/{home,tmp,config,data,cache,state,scratch}
export HOME="$fixture/home" TMPDIR="$fixture/tmp"
export XDG_CONFIG_HOME="$fixture/config" XDG_DATA_HOME="$fixture/data"
export XDG_CACHE_HOME="$fixture/cache" XDG_STATE_HOME="$fixture/state"
export ASDF_CONFIG_FILE="$XDG_CONFIG_HOME/asdf/asdfrc"
export ASDF_DATA_DIR="$runtime_home/.local/share/asdf"
export PATH="$HOME/.local/bin:$runtime_home/.local/bin:$ASDF_DATA_DIR/shims:$PATH"
unset ASDF_DIR ASDF_DEFAULT_TOOL_VERSIONS_FILENAME GEM_HOME GEM_PATH RUBYOPT BUNDLE_GEMFILE
export PYTHONDONTWRITEBYTECODE=1 NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
ln -s "$repo_dir/config/asdf/tool-versions" "$HOME/.tool-versions"
for name in asdf stylelint stylua rubocop solargraph npm pry bat; do
    ln -s "$repo_dir/config/$name" "$XDG_CONFIG_HOME/$name"
done
ln -s "$repo_dir/config/pylintrc" "$XDG_CONFIG_HOME/pylintrc"
mkdir -p "$XDG_CONFIG_HOME/codespell"
ln -s "$repo_dir/config/codespell/ignore.txt" "$XDG_CONFIG_HOME/codespell/ignore.txt"
ln -s "$repo_dir/config/codespell/exclude-file.txt" "$XDG_CONFIG_HOME/codespell/exclude-file.txt"
"$repo_dir/bin/configure-tools"
cd "$fixture/scratch"
status=0
python3 "$repo_dir/tests/dev-checks.py" "$repo_dir" || status=$?
python3 "$repo_dir/tests/providers.py" || status=$?
exit "$status"
