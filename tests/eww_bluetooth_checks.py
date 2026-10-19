#!/usr/bin/env python3
"""Exercise the Eww Bluetooth watcher's battery-state contract."""

from contextlib import redirect_stdout
import io
from pathlib import Path
import runpy
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "config/eww/bar/scripts/bluetooth"
BLUETOOTH = runpy.run_path(str(SCRIPT))
DeviceWatcher = BLUETOOTH["DeviceWatcher"]

DEVICE_INTERFACE = "org.bluez.Device1"
BATTERY_INTERFACE = "org.bluez.Battery1"
DEVICE_PATH = "/org/bluez/hci0/dev_00_25_D1_44_F9_2E"


class Reply:  # pylint: disable=too-few-public-methods
    """Minimal GetManagedObjects reply returned by the fake connection."""

    def __init__(self, objects):
        self.objects = objects

    def unpack(self):
        """Return the managed-object tuple expected by the watcher."""
        return (self.objects,)


class Connection:  # pylint: disable=too-few-public-methods
    """Replace only the external D-Bus transport in watcher tests."""

    def __init__(self, objects):
        self.objects = objects

    def call_sync(self, *_args):
        """Return the fixture instead of contacting the system bus."""
        return Reply(self.objects)


class Parameters:  # pylint: disable=too-few-public-methods
    """Represent an unpacked D-Bus PropertiesChanged signal."""

    def __init__(self, interface, changed, invalidated=()):
        self.values = (interface, changed, invalidated)

    def unpack(self):
        """Return the signal fields expected by the watcher callback."""
        return self.values


def device_objects(percentage=75):
    """Return a complete BlueZ object fixture for MAJOR V."""
    return {
        DEVICE_PATH: {
            DEVICE_INTERFACE: {
                "Address": "00:25:D1:44:F9:2E",
                "Alias": "MAJOR V",
                "Connected": True,
                "Trusted": True,
            },
            BATTERY_INTERFACE: {
                "Percentage": percentage,
                "Source": "",
            },
        }
    }


def new_watcher(objects):
    """Construct a watcher without starting its GLib event loop."""
    watcher = DeviceWatcher.__new__(DeviceWatcher)
    watcher.connection = Connection(objects)
    watcher.devices = {}
    watcher.last_payload = None
    return watcher


class BluetoothBatteryChecks(unittest.TestCase):
    """Catch dropped initial and live Battery1 percentages."""

    def test_initial_snapshot_publishes_battery_percentage(self):
        """An initial Battery1 percentage is included in watcher output."""
        watcher = new_watcher(device_objects(75))
        output = io.StringIO()

        with redirect_stdout(output):
            watcher._reload()  # pylint: disable=protected-access

        self.assertEqual(
            output.getvalue().strip(),
            '[{"address":"00:25:D1:44:F9:2E","battery":75,'
            '"connected":true,"name":"MAJOR V"}]',
        )

    def test_battery_property_change_publishes_new_percentage(self):
        """A Battery1 change immediately emits the updated percentage."""
        watcher = new_watcher(device_objects(75))
        with redirect_stdout(io.StringIO()):
            watcher._reload()  # pylint: disable=protected-access

        output = io.StringIO()
        parameters = Parameters(BATTERY_INTERFACE, {"Percentage": 76})
        with redirect_stdout(output):
            watcher._properties_changed(  # pylint: disable=protected-access
                watcher.connection,
                "org.bluez",
                DEVICE_PATH,
                "org.freedesktop.DBus.Properties",
                "PropertiesChanged",
                parameters,
                None,
            )

        self.assertEqual(
            output.getvalue().strip(),
            '[{"address":"00:25:D1:44:F9:2E","battery":76,'
            '"connected":true,"name":"MAJOR V"}]',
        )


if __name__ == "__main__":
    unittest.main()
