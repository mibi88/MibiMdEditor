/* main.vala
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

public class MibiMdEditor : Gtk.ApplicationWindow {
    // Some constants of the app
    private const string TITLE = "MibiMdEditor"; // App title
    // Subtitle of the window if no file is opened :
    private const string NOTHING_OPEN_TEXT = "New file";
    //// WIDGETS ////
    // All widgets are in a horizontal box, except the headerbar
    private Paned hbox;
    // TextView that will contain the source text
    private ScrolledWindow textwindow;
    private TextView text;
    // WebView that previews the rendered source text
    private WebView preview;
    // Headerbar
    private HeaderBar headerbar;
    // Headerbar new button
    private Button new_button;
    // Headerbar open button
    private Button open_button;
    // Headerbar save MenuButton
    private MenuButton save_menu;
    // Save Menu
    private GLib.Menu save_popup;
    // Export button
    private Button export_button;
    // Headerbar saved icon
    private Image saved_icon;
    // File chooser dialog
    private FileChooserDialog file_chooser;
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
    // PREVIEW //
    // Generate html from source code
    private void generate_html () {
        html_data = generator.generate_html (text.buffer.text);
    }
    // Update the preview
    private void update_preview () {
        file_saved = false;
        generate_html ();
        preview.load_html (html_data, null);
        update_saved_icon ();
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
    public MibiMdEditor () {
        // TODO: Let the user choose the markup language
        generator = new Generator_MD ();
        // Let the user choose, if he wants to allow html.
        generator.allow_html = true;
        // Create the headerbar
        headerbar = new HeaderBar ();
        // Set the title of the window to the TITLE const
        headerbar.set_title(TITLE);
        // Set the file name to the subtitle
        headerbar.set_subtitle(file_name);
        headerbar.set_show_close_button (true); // Show the close button
        this.set_titlebar (headerbar); // Add the HeaderBar to the window
        // Add buttons to the headerbar
        // New file button
        new_button = new Button.from_icon_name("list-add-symbolic");
        new_button.clicked.connect (new_file);
        // Add the button at the start of the headerbar
        headerbar.pack_start(new_button);
        // Open file button
        open_button = new Button.from_icon_name("document-open-symbolic");
        open_button.clicked.connect (open_file);
        // Add the button at the start of the headerbar
        headerbar.pack_start(open_button);
        // Save file button
        save_menu = new MenuButton();
        save_menu.add(new Gtk.Image.from_icon_name("document-save-symbolic",
                      Gtk.IconSize.BUTTON));
        // Create the popup menu
        save_popup = new GLib.Menu ();
        save_popup.append ("Save", "win.save");
        SimpleAction save_action = new SimpleAction ("save", null);
        save_action.activate.connect (save_file);
        add_action (save_action);
        save_popup.append ("Save as ...", "win.saveas");
        SimpleAction saveas_action = new SimpleAction ("saveas", null);
        saveas_action.activate.connect (save_as_file);
        add_action (saveas_action);
        save_menu.set_menu_model (save_popup); // Set the popup menu
        // Add the button at the start of the headerbar
        headerbar.pack_start(save_menu);
        // Export html button
        export_button = new Button.from_icon_name("x-office-document-symbolic");
        export_button.clicked.connect (export_html);
        headerbar.pack_start(export_button);
        // Saved file icon
        saved_icon = new Gtk.Image ();
        update_saved_icon ();
        headerbar.pack_start(saved_icon);
        // Create the horizontal box
        hbox = new Paned (Orientation.HORIZONTAL);
        // Create the TextView
        textwindow = new ScrolledWindow (null, null);
        text = new TextView (); // Create a scrolled window for the text view
        text.wrap_mode = WrapMode.WORD; // Wrap on words
        text.buffer.changed.connect (update_preview);
        textwindow.add (text);
        hbox.add (textwindow); // Add it to the horizontal box
        // Create the WebView
        preview = new WebView ();
        hbox.add (preview); // Add it to the horizontal box
        // Add the horizontal box to the window
        add (hbox);
        // Center the handle of hbox
        // hbox.set_position(hbox.max_position/2);
    }
    public static int main (string[] args) {
        Gtk.init (ref args);
        var window = new MibiMdEditor ();
        window.destroy.connect (window.quit);
        window.show_all ();
        Gtk.main ();
        return 0;
    }
}

