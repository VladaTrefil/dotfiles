import json
import os
from pathlib import Path
import re
import subprocess
import sys

root = Path(sys.argv[1])
config = Path(os.environ['XDG_CONFIG_HOME'])
def run(*args, stdin=None, statuses=(0,)):
    result = subprocess.run(args, input=stdin, text=True, capture_output=True)
    assert result.returncode in statuses, (args, result.returncode, result.stdout, result.stderr)
    return result

assert (root / 'config/asdf/tool-versions').read_text() == 'nodejs 24.21.0\nruby 3.4.10\n'
assert run('node', '--version').stdout.strip() == 'v24.21.0'
assert run('ruby', '--version').stdout.startswith('ruby 3.4.10 ')
actual = run('asdf', 'current').stdout.splitlines()[1:]
assert {line.split()[0] for line in actual} == {'nodejs', 'ruby'}, actual
assert all(line.split()[-1] == 'true' for line in actual), actual
print('PASS: declared and provisioned runtimes are exactly nodejs 24.21.0 / ruby 3.4.10')

npm_root = run('npm', 'root', '-g').stdout.strip()
for entry in (root / 'config/asdf/default-npm-packages').read_text().splitlines():
    package, separator, pinned = entry.rpartition('@')
    assert separator and package and pinned, f'Unpinned npm global: {entry}'
    metadata = json.loads((Path(npm_root) / package / 'package.json').read_text())
    assert metadata['name'] == package and metadata['version'] == pinned, (entry, metadata)
    print('NPM', package, metadata['version'], 'PIN', pinned)
gem_names = []
for entry in (root / 'config/asdf/default-gems').read_text().splitlines():
    gem, separator, pinned = entry.rpartition(':')
    assert separator and gem and pinned, f'Unpinned gem global: {entry}'
    result = run('ruby', '-rrubygems', '-e',
                 's=Gem::Specification.find_by_name(ARGV[0]); puts "#{s.name} #{s.version}"', gem)
    assert result.stdout.strip() == f'{gem} {pinned}', (entry, result.stdout)
    gem_names.append(gem)
    print('GEM', result.stdout.strip(), 'PIN', pinned)
assert 'rails' not in gem_names

stylelint = config / 'stylelint/stylelintrc.json'
assert '/home/' not in stylelint.read_text() and '/installs/' not in stylelint.read_text()
for extension, text in [('scss', 'trough { color: red; }\n'), ('sass', 'trough\n  color: red\n')]:
    run('stylelint', '--config', str(stylelint), '--config-basedir', npm_root,
        '--stdin', '--stdin-filename', str(Path.cwd() / ('test.' + extension)), stdin=text)
print('PASS: Stylelint SCSS and Sass resolve bare names with the active npm root; trough accepted')

run('jsonlint', '--compact', stdin='{"valid":true}\n')
bad = run('jsonlint', '--compact', stdin='{"bad":}\n', statuses=(1,))
assert re.search(r'line \d+, col \d+', bad.stderr), bad.stderr
assert json.loads((Path(npm_root) / 'jsonlint/package.json').read_text())['name'] == 'jsonlint'
print('PASS: npm jsonlint accepts --compact and emits nvim-lint line/col diagnostics')

rc = config / 'codespell/codespellrc'
words = (config / 'codespell/ignore.txt').read_text()
run('codespell', '--config', str(rc), '-', stdin=words)
# An unignored typo must still produce a diagnostic.
assert 'teh' in run('codespell', '--config', str(rc), '-', stdin='teh\n', statuses=(65,)).stdout
for directory in [Path.cwd(), Path.home()]:
    result = subprocess.run(['codespell', '--config', str(rc), '-'], input=words,
                            text=True, capture_output=True, cwd=directory)
    assert result.returncode == 0, result.stderr
assert '--ignore-words' not in (root / 'config/shell/aliases.sh').read_text()
print('PASS: codespell rc supplies all six word exceptions and exclusion input from both working directories')

run('bat', '--paging=never', '--color=never', '--style=plain', '--language', 'js', stdin='const x = 1;\n')
assert 'Catppuccin' in run('bat', '--list-themes', '--color=never').stdout
print('PASS: bat rebuilt assets and renders JavaScript using the configured theme')
from pylint.lint import Run
Path('scratch.py').write_text('"""Scratch module."""\nprint(1)\n')
pylint = Run(['--rcfile', str(config / 'pylintrc'), '--persistent=n', '--exit-zero', 'scratch.py'], exit=False)
patterns = pylint.linter.config.ignore_paths
for value, expected in [('xgit/a.py', False), ('building.py', False), ('src/build/a.py', True),
                        ('/tmp/.venv/a.py', True), ('src/dist/a.py', True), ('/tmp/.git/a.py', True)]:
    assert any(pattern.match(value) for pattern in patterns) == expected, value
print('PASS: Pylint exclusions match directory components, including nested/absolute paths')
for tool, version in [('stylua', '2.5.2'), ('selene', '0.31.0'), ('lf', 'r42'),
                      ('lazygit', '0.65.1')]:
    output = run(tool, '-version' if tool == 'lf' else '--version').stdout.strip()
    assert version in output, (tool, output)
    print('RELEASE', output)
Path('scratch.rb').write_text("# frozen_string_literal: true\n\nputs 'hello'\n")
discovery = run('ruby', '-rrubocop', '-e', 'puts RuboCop::ConfigFinder.find_config_path(Dir.pwd)').stdout.strip()
assert Path(discovery).resolve() == (config / 'rubocop/config.yml').resolve(), discovery
registry = run('ruby', '-rrubocop', '-rjson', '-e', r'''
path = RuboCop::ConfigFinder.find_config_path(Dir.pwd)
RuboCop::ConfigLoader.load_file(path)
sections = YAML.load_file(path).keys.grep(%r{\A(?:Rails|Performance|Minitest|Rake)/})
registered = RuboCop::Cop::Registry.global.map(&:cop_name)
puts JSON.generate({
  sections: sections.size,
  departments: sections.group_by { |name| name.split('/').first }.transform_values(&:size),
  missing: sections - registered,
  loaded_extensions: Gem.loaded_specs.keys.grep(/\Arubocop-(rails|performance|minitest|rake)\z/).sort,
  folio_loaded: Gem.loaded_specs.key?('folio')
})
''')
loaded = json.loads(registry.stdout)
assert loaded['sections'] == 38 and not loaded['missing'], loaded
assert loaded['loaded_extensions'] == ['rubocop-minitest', 'rubocop-performance', 'rubocop-rails', 'rubocop-rake'], loaded
assert not loaded['folio_loaded'], loaded
print('RUBOCOP_REGISTRY', registry.stdout.strip())
print('RUBOCOP_SCRATCH_DIR', Path.cwd())
result = run('rubocop', '--cache', 'false', '--format', 'json', 'scratch.rb')
print('$ rubocop --cache false --format json scratch.rb')
print(result.stdout.strip())
print('RUBOCOP_STDERR', repr(result.stderr))
print('RUBOCOP_EXIT', result.returncode)
assert json.loads(result.stdout)['summary']['inspected_file_count'] == 1
assert 'MissingSpec' not in result.stderr and 'Unable to find gem' not in result.stderr
assert not re.search(r'unrecognized cop|unknown cop|supports plugin', result.stderr, re.IGNORECASE), result.stderr
print('PASS: RuboCop discovers XDG config.yml, loads all 38 extension cop sections without Folio, and inspects a non-project Ruby file')

print('PASS: development config integration')
