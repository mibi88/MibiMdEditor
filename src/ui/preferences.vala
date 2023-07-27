/* preferences.vala
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

[GtkTemplate (ui = "/MibiMdEditor/preferences.ui")]
public class PreferencesDialog : Adw.PreferencesWindow {
    // Some variables are commented because they are not used. Uncomment them if
    // you need them.
    // Editor settings
    // [GtkChild]
    // private unowned PreferencesPage editor;
    [GtkChild]
    public unowned PreferencesGroup text_edition;
    [GtkChild]
    public unowned PreferencesSwitch bg_grid;
    [GtkChild]
    public unowned PreferencesSwitch lhighlight;
    [GtkChild]
    public unowned PreferencesSwitch auto_indent;
    [GtkChild]
    public unowned PreferencesSwitch mono_font;
    // Generator settings
    // [GtkChild]
    // private unowned PreferencesPage generation;
    //[GtkChild]
    //public unowned ExpanderRow new_script_row;
    [GtkChild]
    private unowned ScriptProperties new_script_properties;
    // Settings saving
    private GLib.Settings settings;
    public PreferencesDialog (Gtk.Window window) {
        settings = new GLib.Settings ("io.github.mibi88.MibiMdEditor");
        transient_for = window;
        destroy_with_parent = true;
        // Text edition group content
        bg_grid.state = settings.get_boolean ("bg-grid");
        lhighlight.state = settings.get_boolean ("lhighlight");
        auto_indent.state = settings.get_boolean ("auto-indent");
        mono_font.state = settings.get_boolean ("mono-font");
        // Set the window that contains the ScriptProperties widgets
        new_script_properties.window = this;
    }
    public void save () {
        settings.set_boolean ("bg-grid", bg_grid.state);
        settings.set_boolean ("lhighlight", lhighlight.state);
        settings.set_boolean ("auto-indent", auto_indent.state);
        settings.set_boolean ("mono-font", mono_font.state);
    }
}

