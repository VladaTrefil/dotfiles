#!/usr/bin/env python3
"""Check the Secret Service provider and ordered desktop autostart contract."""
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]


class SecretServiceChecks(unittest.TestCase):
    def test_provider_is_declared(self):
        apps = (ROOT / 'packages/apps.txt').read_text()
        self.assertRegex(
            apps,
            re.compile(
                r'^gnome-keyring\s+#.*Secret Service.*Proton Mail Bridge',
                re.MULTILINE,
            ),
            'gnome-keyring must document the Bridge Secret Service dependency',
        )

    def test_keyring_precedes_desktop_autostart(self):
        session = (ROOT / 'config/sway/conf.d/60-session.conf').read_text()
        self.assertNotRegex(
            session,
            re.compile(r'^exec dex-autostart\b', re.MULTILINE),
            'Sway must not launch dex-autostart before Secret Service is ready',
        )
        self.assertRegex(
            session,
            re.compile(
                r'^exec \$HOME/\.config/sway/bin/start-autostart$',
                re.MULTILINE,
            ),
            'Sway must use the ordered autostart helper',
        )

        helper_path = ROOT / 'config/sway/bin/start-autostart'
        self.assertTrue(helper_path.is_file(), 'ordered autostart helper is missing')
        helper = helper_path.read_text()
        service = 'systemctl --user start gnome-keyring-daemon.service'
        provider = 'org.freedesktop.secrets'
        dex = 'exec dex-autostart --autostart --environment sway'
        self.assertLess(helper.index(service), helper.index(provider))
        self.assertLess(helper.index(provider), helper.index(dex))
        self.assertRegex(helper, r'attempt\s*<\s*[1-9][0-9]*')
        self.assertIn('sleep 0.1', helper)


if __name__ == '__main__':
    unittest.main()
