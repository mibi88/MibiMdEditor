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
using Gdk;
using WebKit;
using Hdy;

[GtkTemplate (ui = "/MibiMdEditor/window.ui")]
public class MibiMdEditor : Hdy.ApplicationWindow {
    // Some constants of the app
    public const string TITLE = "MibiMdEditor"; // App title
    public const string APPICON =
        "/MibiMdEditor/icons/hicolor/scalable/apps/MibiMdEditor.svg";
    private const int WIDTH = 640;
    private const int HEIGHT = 480;
    // Subtitle of the window if no file is opened :
    private const string NOTHING_OPEN_TEXT = "New file";
    //// WIDGETS ////
    // Box that contains everything
    [GtkChild]
    private unowned Gtk.Box vbox;
    // All widgets are in a horizontal box, except the headerbar
    [GtkChild]
    private unowned Gtk.Paned hbox;
    // SourceView that will contain the source text
    private ScrolledWindow textwindow;
    private SourceLanguageManager language;
    [GtkChild]
    private unowned SourceBuffer text_buffer;
    [GtkChild]
    private unowned SourceView text;
    // WebView that previews the rendered source text
    [GtkChild]
    private unowned WebView preview;
    // Headerbar
    [GtkChild]
    private unowned Hdy.HeaderBar headerbar;
    // Headerbar new button
    [GtkChild]
    private unowned Button new_button;
    // Headerbar open button
    [GtkChild]
    private unowned Button open_button;
    // Headerbar save MenuButton
    [GtkChild]
    private unowned MenuButton save_menu;
    // Export button
    [GtkChild]
    private unowned Button export_button;
    // Headerbar saved icon
    [GtkChild]
    private unowned Image saved_icon;
    // File chooser dialog
    private FileChooserDialog file_chooser;
    // Undo Button
    [GtkChild]
    private unowned Button undo_button;
    // Redo Button
    [GtkChild]
    private unowned Button redo_button;
    // Headerbar burger
    [GtkChild]
    private unowned MenuButton burger_menu;
    // Burger Menu
    private GLib.Menu burger_popup;
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
    private File file = null;
    // The html generator
    private Generator generator;
    //// METHODS ////
    // DIALOGS //
    private void about_dialog () {
        Gtk.AboutDialog dialog = new Gtk.AboutDialog ();
        dialog.transient_for = this;
        dialog.modal = true;
        dialog.destroy_with_parent = true;
        dialog.artists = {"mibi88"};
        dialog.authors = {"mibi88"};
        dialog.documenters = null;
        dialog.translator_credits = null;
        dialog.program_name = TITLE;
        try {
            dialog.logo = new Pixbuf.from_resource (APPICON);
        } catch (Error error) {
            stderr.printf ("Error when loading icon: %s\n", error.message);
        }
        dialog.comments = "Prepare your texts for the web";
        dialog.copyright = "Copyright © 2023 mibi88";
        dialog.version = "v.0.4";
        dialog.license_type = Gtk.License.GPL_2_0;
        dialog.wrap_license = false;
        dialog.website = "https://github.com/mibi88/MibiMdEditor";
        dialog.website_label = "GitHub repository";
        dialog.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.CANCEL ||
                response_id == Gtk.ResponseType.DELETE_EVENT) {
                dialog.hide_on_delete ();
            }
        });
        dialog.present ();
    }
    private void preferences_dialog () {
        // Create the dialog
        PreferencesDialog dialog = new PreferencesDialog (this);
        // Show the dialog
        dialog.show_all ();
        dialog.destroy.connect(() => {
            // Save
            dialog.save ();
            // Reload the preferences
            load_preferences ();
        });
    }
    // WINDOW //
    public void quit() {
        stdout.puts ("User tried to quit.\n");
        if (!file_saved) {
            Gtk.MessageDialog cancel_dialog = new Gtk.MessageDialog (
                    this, Gtk.DialogFlags.MODAL,
                    Gtk.MessageType.WARNING,
                    Gtk.ButtonsType.OK_CANCEL,
                    """Your file isn't saved!
Do you really want to quit?""");
            cancel_dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:
                        Gtk.main_quit();
                        break;
                    case Gtk.ResponseType.CANCEL:
                        stdout.puts ("Quit cancelled\n");
                        break;
                }
                cancel_dialog.destroy();
            });
            cancel_dialog.show ();
        } else {
            Gtk.main_quit();
        }
    }
    // WIDGETS ///
    private void load_preferences () {
        GLib.Settings settings =
            new GLib.Settings ("io.github.mibi88.MibiMdEditor");
        text.background_pattern = settings.get_boolean ("bg-grid") ?
                                  SourceBackgroundPatternType.GRID :
                                  SourceBackgroundPatternType.NONE;
        text.highlight_current_line = settings.get_boolean ("lhighlight");
        text.auto_indent = settings.get_boolean ("auto-indent");
        text.monospace = settings.get_boolean ("mono-font");
    }
    private void update_saved_icon () {
        if (file_saved) {
            saved_icon.set_from_icon_name("drive-harddisk-symbolic",
                                          Gtk.IconSize.BUTTON);
        } else {
            saved_icon.set_from_icon_name("document-edit-symbolic",
                                          Gtk.IconSize.BUTTON);
        }
    }
    private void update_subtitle () {
        if (file != null) {
            file_name = file.get_path ();
        }
        headerbar.set_subtitle (file_name);
    }
    private void update_undo_redo_buttons () {
        if (text_buffer.can_undo) {
            undo_button.set_sensitive (true);
        } else {
            undo_button.set_sensitive (false);
        }
        if (text_buffer.can_redo) {
            redo_button.set_sensitive (true);
        } else {
            redo_button.set_sensitive (false);
        }
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
        update_undo_redo_buttons ();
    }
    private void update_preview () {
        file_saved = false;
        update_webview ();
    }
    // FILE //
    // Create a new file
    public void new_file () {
        if (!file_saved) {
            Gtk.MessageDialog cancel_dialog = new Gtk.MessageDialog (
                    this, Gtk.DialogFlags.MODAL,
                    Gtk.MessageType.WARNING,
                    Gtk.ButtonsType.OK_CANCEL,
                    """Your file isn't saved!
Do you really want to create a new file?""");
            cancel_dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:
                        text.buffer.text = "";
                        file_open = false;
                        file_saved = true;
                        file_name = NOTHING_OPEN_TEXT;
                        file = null;
                        update_webview ();
                        break;
                    case Gtk.ResponseType.CANCEL:
                        stdout.puts ("New file creation cancelled\n");
                        break;
                }
                cancel_dialog.destroy();
            });
            cancel_dialog.show ();
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
    public void open_file () {
        if (!file_saved) {
            Gtk.MessageDialog cancel_dialog = new Gtk.MessageDialog (
                    this, Gtk.DialogFlags.MODAL,
                    Gtk.MessageType.WARNING,
                    Gtk.ButtonsType.OK_CANCEL,
                    """Your file isn't saved!
Do you really want to open a file?""");
            cancel_dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:
                        file_chooser = new Gtk.FileChooserDialog (
                                    "Select a file to open",
                                    this, Gtk.FileChooserAction.OPEN,
                                    "Cancel", Gtk.ResponseType.CANCEL,
                                    "Open", Gtk.ResponseType.ACCEPT);
                        // The user can only open one file
                        file_chooser.select_multiple = false;
                        file_chooser.run ();
                        file_chooser.close ();
                        if (file_chooser.get_file () != null) {
                            try {
                                uint8[] contents;
                                string etag_out;
                                file = file_chooser.get_file ();
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
                        } else {
                            stdout.puts ("Action cancelled !\n");
                        }
                        break;
                    case Gtk.ResponseType.CANCEL:
                        stdout.puts ("New file creation cancelled\n");
                        break;
                }
                cancel_dialog.destroy();
            });
            cancel_dialog.show ();
        } else {
            file_chooser = new Gtk.FileChooserDialog (
                                    "Select a file to open",
                                    this, Gtk.FileChooserAction.OPEN,
                                    "Cancel", Gtk.ResponseType.CANCEL,
                                    "Open", Gtk.ResponseType.ACCEPT);
            // The user can only open one file
            file_chooser.select_multiple = false;
            file_chooser.run ();
            file_chooser.close ();
            if (file_chooser.get_file () != null) {
                try {
                    uint8[] contents;
                    string etag_out;
                    file = file_chooser.get_file ();
                    file.load_contents (null, out contents, out etag_out);
                    text.buffer.text = (string) contents;
                    file_open = true;
                    file_saved = true;
                    update_webview ();
                } catch (Error error) {
                    stderr.printf ("Error when loading file: %s\n",
                                   error.message);
                }
            } else {
                stdout.puts ("Action cancelled !\n");
            }
        }
        update_saved_icon ();
        update_subtitle ();
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
        file_chooser = new Gtk.FileChooserDialog (
                                    "Save",
                                    this, Gtk.FileChooserAction.SAVE,
                                    "Cancel", Gtk.ResponseType.CANCEL,
                                    "Save", Gtk.ResponseType.ACCEPT);
        // The user can only open one file
        file_chooser.select_multiple = false;
        file_chooser.do_overwrite_confirmation = true;
        file_chooser.run ();
        file_chooser.close ();
        if (file_chooser.get_file () != null) {
            try {
                file = file_chooser.get_file ();
                file.replace_contents (text.buffer.text.data, null, true,
                                       FileCreateFlags.NONE, null, null);
                file_open = true;
                file_saved = true;
            } catch (Error error) {
                stderr.printf ("Error when saving file: %s\n", error.message);
            }
        } else {
            stdout.puts ("Action cancelled !\n");
        }
        update_saved_icon ();
        update_subtitle ();
    }
    public void export_html () {
        file_chooser = new Gtk.FileChooserDialog (
                                    "Export",
                                    this, Gtk.FileChooserAction.SAVE,
                                    "Cancel", Gtk.ResponseType.CANCEL,
                                    "Export", Gtk.ResponseType.ACCEPT);
        // The user can only open one file
        file_chooser.select_multiple = false;
        file_chooser.do_overwrite_confirmation = true;
        file_chooser.run ();
        file_chooser.close ();
        if (file_chooser.get_file () != null) {
            try {
                File export_file = file_chooser.get_file ();
                generate_html ();
                export_file.replace_contents (html_data.data, null, true,
                                       FileCreateFlags.NONE, null, null);
            } catch (Error error) {
                stderr.printf ("Error when saving file: %s\n", error.message);
            }
        } else {
            stdout.puts ("Action cancelled !\n");
        }
        update_saved_icon ();
        update_subtitle ();
    }
    public void editor_undo () {
        text.undo ();
        update_undo_redo_buttons ();
    }
    public void editor_redo () {
        text.redo ();
        update_undo_redo_buttons ();
    }
    public MibiMdEditor () {
        this.set_default_size (WIDTH, HEIGHT);
        // TODO: Let the user choose the markup language
        generator = new Generator_MD ();
        language = new SourceLanguageManager ();
        // TODO: Let the user choose, if he wants to allow html.
        generator.allow_html = true;
        // Configure the sourceview and the sourcebuffer.
        text_buffer.language = language.get_language ("markdown");
        text.wrap_mode = WrapMode.WORD; // Wrap on words
        text_buffer.end_user_action.connect (update_preview);
        // Add actions
        // Save menu
        SimpleAction save_action = new SimpleAction ("save", null);
        save_action.activate.connect (save_file);
        add_action (save_action);
        SimpleAction save_as_action = new SimpleAction ("save-as", null);
        save_as_action.activate.connect (save_as_file);
        add_action (save_as_action);
        // Burger menu
        SimpleAction preferences_action = new SimpleAction ("preferences",
                                                            null);
        preferences_action.activate.connect (preferences_dialog);
        add_action (preferences_action);
        SimpleAction about_action = new SimpleAction ("about", null);
        about_action.activate.connect (about_dialog);
        add_action (about_action);
        // Buttons
        new_button.clicked.connect (new_file);
        open_button.clicked.connect (open_file);
        export_button.clicked.connect (export_html);
        undo_button.clicked.connect (editor_undo);
        redo_button.clicked.connect (editor_redo);
        // Center the handle of hbox
        hbox.set_position(WIDTH/2);
        update_undo_redo_buttons ();
        update_webview ();
        load_preferences ();
        new_file ();
    }
}

