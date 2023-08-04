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
    public unowned Adw.EntryRow script_name;
    [GtkChild]
    private unowned Adw.EntryRow script_path;
    private Gtk.StringList language_list;
    [GtkChild]
    private unowned Gtk.Button select_script;
    [GtkChild]
    private unowned Gtk.Button save;
    [GtkChild]
    private unowned Gtk.Button delete_button;
    [GtkChild]
    private unowned Adw.ComboRow syntax_highlighting;
    public Gtk.Window window;
    private GLib.Settings settings;
    private LanguageManager language_manager;
    public bool new_script;
    public int script_position;
    public signal void edition_end () {
        stdout.puts ("Nothing to do at save end!\n");
    }
    private void delete_script_action () {
        if (new_script) return;
        Variant names_variant = settings.get_value ("script-names");
        Variant files_variant = settings.get_value ("script-files");
        Variant syntax_highlighting_variant =
                            settings.get_value ("script-syntax-highlighting");
        VariantBuilder names_variantbuilder =
                                    new VariantBuilder(new VariantType ("as"));
        VariantBuilder files_variantbuilder =
                                    new VariantBuilder(new VariantType ("as"));
        VariantBuilder syntax_highlighting_variantbuilder =
                                    new VariantBuilder(new VariantType ("as"));
        VariantIter iter = names_variant.iterator ();
        for (int i=0;i<names_variant.n_children ();i++) {
            if (i != script_position) {
                string? str = "";
                iter.next ("s", &str);
                names_variantbuilder.add ("s", str);
                stdout.puts (@"Copied item $i.\n");
            }
        }
        iter = files_variant.iterator ();
        for (int i=0;i<files_variant.n_children ();i++) {
            if (i != script_position) {
                string? str = "";
                iter.next ("s", &str);
                files_variantbuilder.add ("s", str);
                stdout.puts (@"Copied item $i.\n");
            }
        }
        iter = syntax_highlighting_variant.iterator ();
        for (int i=0;i<syntax_highlighting_variant.n_children ();i++) {
            if (i != script_position) {
                string? str = "";
                iter.next ("s", &str);
                syntax_highlighting_variantbuilder.add ("s", str);
                stdout.puts (@"Copied item $i.\n");
            }
        }
        // Convert all VariantBuilders to Variants
        names_variant = names_variantbuilder.end ();
        files_variant = files_variantbuilder.end ();
        syntax_highlighting_variant = syntax_highlighting_variantbuilder.end ();
        // Save everything
        settings.set_value ("script-names", names_variant);
        settings.set_value ("script-files", files_variant);
        settings.set_value ("script-syntax-highlighting",
                            syntax_highlighting_variant);
        edition_end ();
    }
    private void delete_script () {
        if (new_script) return;
        Gtk.AlertDialog cancel_dialog = new Gtk.AlertDialog (
                    "Do you really want to remove this script?");
        cancel_dialog.buttons = {_("OK"), _("Cancel")};
        cancel_dialog.default_button = 1;
        cancel_dialog.cancel_button = 1;
        cancel_dialog.choose.begin (window, null, (obj, res) => {
            try {
                if (cancel_dialog.choose.end (res) ==
                    cancel_dialog.cancel_button) {
                    stdout.puts ("Removing cancelled\n");
                } else {
                    delete_script_action ();
                }
            } catch (Error error) {
                stderr.printf ("Error when removing script: %s\n",
                               error.message);
            }
        });
    }
    private void save_script () {
        Variant names_variant = settings.get_value ("script-names");
        Variant files_variant = settings.get_value ("script-files");
        Variant syntax_highlighting_variant =
                            settings.get_value ("script-syntax-highlighting");
        VariantIter iter = names_variant.iterator ();
        int script_amount = (int)iter.n_children ();
        stdout.puts (@"$script_amount scripts currently existing.\n");
        if (new_script) {
            if (script_amount > 0) {
                for (int i=0;i<script_amount;i++) {
                    string? name = "";
                    iter.next ("s", &name);
                    if (name != "") {
                        if (name == script_name.text) {
                            ToastOverlay toast_overlay = new ToastOverlay ();
                            string message =
                                    @"Script named \"$name\" already exists.";
                            stdout.puts (@"$message\n");
                            Toast toast = new Toast (message);
                            toast.timeout = 0;
                            toast_overlay.add_toast (toast);
                            return;
                        }
                    }
                }
            } else {
                stdout.puts ("Skip checking for existing script name.\n");
            }
        }
        stdout.puts ("Checks passed.\n");
        // Copying all the Variants to VariantBuilders.
        VariantBuilder names_variantbuilder =
                                    new VariantBuilder(new VariantType ("as"));
        VariantBuilder files_variantbuilder =
                                    new VariantBuilder(new VariantType ("as"));
        VariantBuilder syntax_highlighting_variantbuilder =
                                    new VariantBuilder(new VariantType ("as"));
        stdout.puts ("VariantBuilders created.\n");
        iter = names_variant.iterator ();
        for (int i=0;i<names_variant.n_children ();i++) {
            if (!new_script && i == script_position) {
                names_variantbuilder.add ("s", script_name.text);
                stdout.puts (@"Replaced item $i.\n");
            } else {
                string? str = "";
                iter.next ("s", &str);
                names_variantbuilder.add ("s", str);
                stdout.puts (@"Copied item $i.\n");
            }
        }
        iter = files_variant.iterator ();
        for (int i=0;i<files_variant.n_children ();i++) {
            if (!new_script && i == script_position) {
                files_variantbuilder.add ("s", script_path.text);
                stdout.puts (@"Replaced item $i.\n");
            } else {
                string? str = "";
                iter.next ("s", &str);
                files_variantbuilder.add ("s", str);
                stdout.puts (@"Copied item $i.\n");
            }
        }
        iter = syntax_highlighting_variant.iterator ();
        for (int i=0;i<syntax_highlighting_variant.n_children ();i++) {
            if (!new_script && i == script_position) {
                syntax_highlighting_variantbuilder.add ("s",
                    language_manager.language_ids[syntax_highlighting.selected]
                );
                stdout.puts (@"Replaced item $i.\n");
            } else {
                string? str = "";
                iter.next ("s", &str);
                syntax_highlighting_variantbuilder.add ("s", str);
                stdout.puts (@"Copied item $i.\n");
            }
        }
        if (new_script) {
            // Adding everything to the VariantBuilders
            names_variantbuilder.add ("s", script_name.text);
            files_variantbuilder.add ("s", script_path.text);
            syntax_highlighting_variantbuilder.add ("s",
                language_manager.language_ids[syntax_highlighting.selected]);
        }
        // Convert all VariantBuilders to Variants
        names_variant = names_variantbuilder.end ();
        files_variant = files_variantbuilder.end ();
        syntax_highlighting_variant = syntax_highlighting_variantbuilder.end ();
        // Save everything
        settings.set_value ("script-names", names_variant);
        settings.set_value ("script-files", files_variant);
        settings.set_value ("script-syntax-highlighting",
                            syntax_highlighting_variant);
        edition_end ();
        stdout.puts ("Script saved!\n");
    }
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
    public ScriptProperties (Gtk.Window _window, bool _new_script,
                             int _script_position) {
        window = _window;
        new_script = _new_script;
        script_position = _script_position;
        // Get all available languages and let the user choose between them for
        // the syntax highlighting ComboRow.
        language_manager = new LanguageManager ();
        language_list = new StringList (language_manager.language_ids);
        syntax_highlighting.model = language_list;
        // Open a file dialog if the select_script Button is pressed
        select_script.clicked.connect (choose_script);
        save.clicked.connect (save_script);
        settings = new GLib.Settings ("io.github.mibi88.MibiMdEditor");
        if (new_script) {
            delete_button.destroy ();
            stdout.puts ("Delete button destroyed!\n");
        } else {
            delete_button.visible = true;
            delete_button.clicked.connect (delete_script);
            // Set the current value of the script item
            Variant names_variant = settings.get_value ("script-names");
            Variant files_variant = settings.get_value ("script-files");
            Variant syntax_highlighting_variant = settings.get_value (
                                                "script-syntax-highlighting");
            if (names_variant.n_children () > 0) {
                string str = names_variant.get_child_value (
                                                            script_position
                                                            ).get_string ();
                script_name.text = str;
                str = files_variant.get_child_value (
                                                     script_position
                                                     ).get_string ();
                script_path.text = str;
                string language = syntax_highlighting_variant.get_child_value (
                                            script_position).get_string ();
                int i;
                for (i=0;i<language_manager.language_ids.length;i++) {
                    if (language_manager.language_ids[i] == language) {
                        break;
                    }
                }
                if (i < 0 || i >= language_manager.language_ids.length) i = 0;
                stdout.puts (@"Language position in list: $i\n");
                syntax_highlighting.selected = i;
            }
        }
    }
}

