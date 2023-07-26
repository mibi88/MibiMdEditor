/* window.vala
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

[GtkTemplate (ui = "/MibiMdEditor/window.ui")]
public class MibiMdEditor : Adw.ApplicationWindow {
    // Some constants of the app
    public const string TITLE = "MibiMdEditor"; // App title
    public const string APPICON =
        "/MibiMdEditor/icons/hicolor/scalable/apps/MibiMdEditor.svg";
    private const int WIDTH = 640;
    private const int HEIGHT = 480;
    // Subtitle of the window if no file is opened :
    private const string NOTHING_OPEN_TEXT = "New file";
    //// WIDGETS ////
    // Some variables are commented because they are not used. Uncomment them if
    // you need them.
    // Box that contains everything
    // [GtkChild]
    // private unowned Gtk.Box vbox;
    // All widgets are in a horizontal box, except the headerbar
    [GtkChild]
    private unowned Gtk.Paned hbox;
    // SourceView that will contain the source text
    // [GtkChild]
    // private ScrolledWindow textwindow;
    public GtkSource.LanguageManager language;
    [GtkChild]
    public unowned GtkSource.Buffer text_buffer;
    [GtkChild]
    public unowned GtkSource.View text;
    // WebView that previews the rendered source text
    [GtkChild]
    private unowned WebView preview;
    // Headerbar
    // [GtkChild]
    // private unowned Adw.HeaderBar headerbar;
    // Title and subtitle labels
    // [GtkChild]
    // private new unowned Label title;
    [GtkChild]
    private unowned Label subtitle;
    // Headerbar new button
    [GtkChild]
    private unowned Button new_button;
    // Headerbar open button
    [GtkChild]
    private unowned Button open_button;
    // Headerbar save MenuButton
    // [GtkChild]
    // private unowned MenuButton save_menu;
    // Export button
    [GtkChild]
    private unowned Button export_button;
    // Headerbar saved icon
    [GtkChild]
    private unowned Image saved_icon;
    // File chooser dialog
    private FileDialog file_chooser;
    // Undo Button
    [GtkChild]
    private unowned Button undo_button;
    // Redo Button
    [GtkChild]
    private unowned Button redo_button;
    // Headerbar burger
    // [GtkChild]
    // private unowned MenuButton burger_menu;
    // Burger Menu
    // private GLib.Menu burger_popup;
    //// OTHER VARIABLES ////
    // True if a file is open
    private bool file_open = false;
    // True if the file is already saved
    private bool file_saved = true;
    // The file that is currently opened :
    private string file_name = NOTHING_OPEN_TEXT;
    // The html data
    private string html_data;
    // The opened file
    private GLib.File file = null;
    // The html generator
    private Generator generator;
    // If the window was closed
    private bool closed = false;
    //// METHODS ////
    // DIALOGS //
    // WINDOW //
    public void quit() {
        stdout.puts ("User tried to quit.\n");
        if (!file_saved) {
            Gtk.AlertDialog cancel_dialog = new Gtk.AlertDialog (
                    """Your file isn't saved!
Do you really want to quit?""");
            cancel_dialog.buttons = {"Ok", "Cancel"};
            cancel_dialog.default_button = 1;
            cancel_dialog.cancel_button = 1;
            cancel_dialog.choose.begin (this, null, (obj, res) => {
                try {
                    if (cancel_dialog.choose.end (res) ==
                        cancel_dialog.cancel_button) {
                        stdout.puts ("Quit cancelled\n");
                    } else {
                        destroy ();
                        closed = true;
                    }
                } catch (Error error) {
                    stderr.printf ("Error when loading file: %s\n",
                                   error.message);
                }
            });
        } else {
            destroy ();
            closed = true;
        }
    }
    // WIDGETS ///
    public void load_preferences () {
        GLib.Settings settings =
            new GLib.Settings ("io.github.mibi88.MibiMdEditor");
        text.background_pattern = settings.get_boolean ("bg-grid") ?
                                  BackgroundPatternType.GRID :
                                  BackgroundPatternType.NONE;
        text.highlight_current_line = settings.get_boolean ("lhighlight");
        text.auto_indent = settings.get_boolean ("auto-indent");
        text.monospace = settings.get_boolean ("mono-font");
    }
    private void update_saved_icon () {
        if (file_saved) {
            saved_icon.set_from_icon_name("drive-harddisk-symbolic");
        } else {
            saved_icon.set_from_icon_name("document-edit-symbolic");
        }
    }
    private void update_subtitle () {
        if (file != null) {
            file_name = file.get_path ();
        }
        subtitle.label = file_name;
    }
    // PREVIEW //
    // Generate html from source code
    private void generate_html () {
        html_data = generator.generate_html (text.buffer.text);
    }
    // Update the preview
    private void update_webview () {
        generate_html ();
        preview.load_html (html_data, null);
        update_saved_icon ();
    }
    private void update_preview () {
        file_saved = false;
        update_webview ();
    }
    // FILE //
    // Create a new file
    public void new_file () {
        if (!file_saved) {
            Gtk.AlertDialog cancel_dialog = new Gtk.AlertDialog (
                """Your file isn't saved!
Do you really want to create a new file?""");
            cancel_dialog.buttons = {"Ok", "Cancel"};
            cancel_dialog.default_button = 1;
            cancel_dialog.cancel_button = 1;
            cancel_dialog.choose.begin (this, null, (obj, res) => {
                try {
                    if (cancel_dialog.choose.end (res) ==
                        cancel_dialog.cancel_button) {
                        stdout.puts ("New file creation cancelled\n");
                    } else {
                        text.buffer.text = "";
                        file_open = false;
                        file_saved = true;
                        file_name = NOTHING_OPEN_TEXT;
                        file = null;
                        update_webview ();
                    }
                } catch (Error error) {
                    stderr.printf ("Error when loading file: %s\n",
                                   error.message);
                }
            });
        } else {
            text.buffer.text = "";
            file_open = false;
            file_saved = true;
            file_name = NOTHING_OPEN_TEXT;
            file = null;
            update_webview ();
        }
        update_saved_icon ();
        update_subtitle ();
    }
    // Open a file
    private void open_file_dialog () {
        file_chooser = new Gtk.FileDialog ();
        file_chooser.open.begin (this, null, (obj, res) => {
            try {
                uint8[] contents;
                string etag_out;
                file = file_chooser.open.end(res);
                file.load_contents (null, out contents,
                                    out etag_out);
                text.buffer.text = (string) contents;
                file_open = true;
                file_saved = true;
                update_webview ();
            } catch (Error error) {
                stderr.printf ("Error when loading file: %s\n",
                               error.message);
            }
            update_saved_icon ();
            update_subtitle ();
        });
    }
    public void open_file () {
        if (!file_saved) {
            Gtk.AlertDialog cancel_dialog = new Gtk.AlertDialog (
                "Your file isn't saved!\nDo you really want to open a file?");
            cancel_dialog.buttons = {"Ok", "Cancel"};
            cancel_dialog.default_button = 1;
            cancel_dialog.cancel_button = 1;
            cancel_dialog.choose.begin (this, null, (obj, res) => {
                try {
                    if (cancel_dialog.choose.end (res) ==
                        cancel_dialog.cancel_button) {
                        stdout.puts ("New file creation cancelled\n");
                    } else {
                        open_file_dialog ();
                    }
                } catch (Error error) {
                    stderr.printf ("Error when loading file: %s\n",
                                   error.message);
                }
            });
        } else {
            open_file_dialog ();
        }
    }
    // Save the file
    public void save_file () {
        if (file != null) {
            try {
                file.replace_contents (text.buffer.text.data, null, true,
                                       FileCreateFlags.NONE, null, null);
                file_saved = true;
            } catch (Error error) {
                stderr.printf ("Error when saving file: %s\n", error.message);
            }
        } else {
            save_as_file ();
        }
        update_saved_icon ();
        update_subtitle ();
    }
    // Save as the file
    public void save_as_file () {
        file_chooser = new Gtk.FileDialog ();
        file_chooser.save.begin (this, null, (obj, res) => {
            try {
                GLib.File tmp_file = file_chooser.save.end (res);
                file = tmp_file;
                file.replace_contents (text.buffer.text.data, null, true,
                                       FileCreateFlags.NONE, null, null);
                file_open = true;
                file_saved = true;
            } catch (Error error) {
                stderr.printf ("Error when saving file: %s\n", error.message);
            }
            update_saved_icon ();
            update_subtitle ();
        });
    }
    public void export_html () {
        file_chooser = new Gtk.FileDialog ();
        file_chooser.save.begin(this, null, (obj, res) => {
            try {
                GLib.File export_file = file_chooser.save.end (res);
                generate_html ();
                export_file.replace_contents (html_data.data, null, true,
                                       FileCreateFlags.NONE, null, null);
            } catch (Error error) {
                stderr.printf ("Error when saving file: %s\n", error.message);
            }
        });
    }
    public void editor_undo () {
        text_buffer.undo ();
    }
    public void editor_redo () {
        text_buffer.redo ();
    }
    public MibiMdEditor (Gtk.Application app) {
        Object (application: app);
        this.set_default_size (WIDTH, HEIGHT);
        // TODO: Let the user choose the markup language
        generator = new Generator_MD ();
        language = new LanguageManager ();
        // TODO: Let the user choose, if he wants to allow html.
        generator.allow_html = true;
        // Configure the sourceview and the sourcebuffer.
        text_buffer.language = language.get_language ("markdown");
        text.wrap_mode = WrapMode.WORD; // Wrap on words
        text_buffer.end_user_action.connect (update_preview);
        // Add actions
        ActionEntry[] action_entries = {
            { "new", new_file },
            { "open", open_file },
            { "export", export_html },
            { "save", save_file },
            { "save-as", save_as_file },
            { "quit", quit }
        };
        add_action_entries (action_entries, this);
        // Buttons
        new_button.clicked.connect (new_file);
        open_button.clicked.connect (open_file);
        export_button.clicked.connect (export_html);
        undo_button.clicked.connect (editor_undo);
        redo_button.clicked.connect (editor_redo);
        // TODO: Handle reloading on the preview
        // Center the handle of hbox
        hbox.set_position(WIDTH/2);
        update_webview ();
        load_preferences ();
        new_file ();
        // Set sensitive of the undo/redo buttons to can_undo and can_redo
        undo_button.sensitive = text_buffer.can_undo;
        redo_button.sensitive = text_buffer.can_redo;
        // Bind properties to disable undo/redo buttons if they should.
        text_buffer.bind_property ("can-undo", undo_button, "sensitive",
                                   BindingFlags.DEFAULT);
        text_buffer.bind_property ("can-redo", redo_button, "sensitive",
                                   BindingFlags.DEFAULT);
    }
}

