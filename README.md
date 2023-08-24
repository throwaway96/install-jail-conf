# `jail_app.conf` Installer

**NOTE:** You'll have to provide your own URLs for `jail_app.conf` and
`jail_app.conf.sig`.

This script will download, verify, and install
`jail_app.conf`/`jail_app.conf.sig`.

## How-to

1. Replace URLs in script with valid ones. Make sure your editor preserves the
   LF line endings.
2. Upload `jailinst.sh` to your TV. Put it somewhere writable, like `/tmp` or `/media/developer/temp`.
3. Run `jailinst.sh` on the TV. (Either use `sh jailinst.sh` or make it executable and use
   e.g. `./jailinst.sh`.)
4. If verification was successful, reboot the TV for the new configuration to
   take effect.

## License

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along
with this program. If not, see <https://www.gnu.org/licenses/>.

See `LICENSE` for details.
