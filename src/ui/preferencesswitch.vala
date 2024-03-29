/* preferencesswitch.vala
 *
 * Copyright 2023 Mibi88
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

using GLib;
using Gtk;
using Adw;

[GtkTemplate (ui = "/MibiMdEditor/preferencesswitch.ui")]
public class PreferencesSwitch : Adw.ActionRow {
    // Some variables are commented because they are not used. Uncomment them if
    // you need them.
    [GtkChild]
    public unowned Switch gswitch;
    public virtual bool state {
        get {
            return gswitch.state;
        }
        set {
            gswitch.state = value;
            gswitch.active = value;
        }
    }
    public PreferencesSwitch (string name, string description, bool b) {
        this.title = name;
        this.subtitle = description;
        state = b;
    }
}

