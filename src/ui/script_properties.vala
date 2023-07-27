/* script_properties.vala
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
using GtkSource;
using Gdk;
using WebKit;
using Adw;

[GtkTemplate (ui = "/MibiMdEditor/script_properties.ui")]
public class ScriptProperties : Adw.PreferencesGroup {
    [GtkChild]
    private unowned Adw.EntryRow script_name;
    [GtkChild]
    private unowned Adw.EntryRow script_path;
    private Gtk.StringList language_list;
    [GtkChild]
    private unowned Gtk.Button select_script;
    [GtkChild]
    private unowned Adw.ComboRow syntax_highlighting;
    public Gtk.Window window;
    private void choose_script () {
        stdout.puts ("User tried to choose a script!\n");
        Gtk.FileDialog file_chooser = new Gtk.FileDialog ();
        file_chooser.open.begin (window, null, (obj, res) => {
            try {
                GLib.File file = file_chooser.open.end(res);
                script_path.text = file.get_path ();
            } catch (Error error) {
                stderr.printf ("Error when loading script: %s\n",
                               error.message);
            }
        });
    }
    public ScriptProperties (Gtk.Window _window) {
        window = _window;
    }
    construct {
        // Get all available languages and let the user choose between them for
        // the syntax highlighting ComboRow.
        LanguageManager language_manager = new LanguageManager ();
        language_list = new StringList(language_manager.language_ids);
        syntax_highlighting.model = language_list;
        // Open a file dialog if the select_script Button is pressed
        select_script.clicked.connect (choose_script);
    }
}

