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
    private unowned PreferencesGroup scripts;
    [GtkChild]
    private unowned ExpanderRow new_script_row;
    private ScriptProperties new_script_properties;
    // Settings saving
    private GLib.Settings settings;
    // Script list widgets
    private Adw.ExpanderRow[] expanders;
    private ScriptProperties[] script_properties;
    public signal void refresh_scripts () {
        stdout.puts ("Nothing connected to script refreshing.\n");
    }
    public void refresh_script_list () {
        // Remove all childs of scripts, the widget that will contain the list
        // of all the scripts.
        for (int i=0;i<expanders.length;i++) {
            scripts.remove (expanders[i]);
            stdout.puts (@"Removed ExpanderRow $i\n");
        }
        // List all scripts
        Variant names_variant = settings.get_value ("script-names");
        int scripts_amount = (int)names_variant.n_children ();
        expanders = {};
        script_properties = {};
        for (int i=0;i<scripts_amount;i++) {
            expanders += new ExpanderRow ();
            script_properties += new ScriptProperties (this, false, i);
            script_properties[i].edition_end.connect (refresh_script_list);
            expanders[i].title = script_properties[i].script_name.text;
            expanders[i].add_row (script_properties[i]);
            scripts.add (expanders[i]);
            stdout.puts (@"Adding script $i\n");
        }
        refresh_scripts ();
    }
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
        new_script_properties = new ScriptProperties (this, true, 0);
        new_script_row.add_row (new_script_properties);
        new_script_properties.edition_end.connect (refresh_script_list);
        refresh_script_list ();
    }
    public void save () {
        settings.set_boolean ("bg-grid", bg_grid.state);
        settings.set_boolean ("lhighlight", lhighlight.state);
        settings.set_boolean ("auto-indent", auto_indent.state);
        settings.set_boolean ("mono-font", mono_font.state);
    }
}

