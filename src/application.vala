/* application.vala
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
using Adw;

class MibiMdEditorApplication : Gtk.Application {
    public MibiMdEditorApplication () {
        Object (application_id: "io.github.mibi88.MibiMdEditor",
                flags: ApplicationFlags.DEFAULT_FLAGS);
        ActionEntry[] action_entries = {
            { "new-window", this.new_window },
            { "about", this.about_dialog },
            { "preferences", this.preferences_dialog },
        };
        this.add_action_entries (action_entries, this);
        this.set_accels_for_action ("app.preferences", {"<primary>comma"});
        set_accels_for_action ("app.new-window", {"<primary><Shift>n"});
        set_accels_for_action ("win.new", {"<primary>n"});
        set_accels_for_action ("win.open", {"<primary>o"});
        set_accels_for_action ("win.export", {"<primary>e"});
        set_accels_for_action ("win.save", {"<primary>s"});
        set_accels_for_action ("win.save-as", {"<primary><Shift>s"});
        set_accels_for_action ("win.quit", {"<primary>q"});
    }
    public override void activate () {
        base.activate ();
        new_window ();
    }
    private void new_window () {
        MibiMdEditor window = new MibiMdEditor (this);
        window.close_request.connect (() => {
            window.quit();
            return true;
        });
        window.present ();
        add_window (window);
    }
    private void about_dialog () {
        Adw.AboutDialog dialog = new Adw.AboutDialog ();
        dialog.artists = {"mibi88"};
        dialog.developers = {"mibi88"};
        //dialog.documenters = null;

        // Translators: Please enter your credits here
        // (format: "Name https://example.com" or "Name <email@example.com>", no
        //  quotes, one name per line)
        dialog.translator_credits = _("translator-credits");
        dialog.application_name = MibiMdEditor.TITLE;
        dialog.application_icon = "io.github.mibi88.MibiMdEditor";
        dialog.comments = _("Prepare your texts for the web");
        dialog.copyright = _("Copyright © 2023 mibi88");
        dialog.version = "v.0.4";
        dialog.license_type = Gtk.License.GPL_2_0;
        dialog.website = "https://github.com/mibi88/MibiMdEditor";
        dialog.issue_url = "https://github.com/mibi88/MibiMdEditor/issues/new";
        dialog.present (this.active_window);
    }
    private void preferences_dialog () {
        // Create the dialog
        PreferencesDialog dialog = new PreferencesDialog (this.active_window);
        // Show the dialog
        dialog.present ();
        dialog.close_request.connect(() => {
            // Save
            dialog.save ();
            // Reload the preferences
            get_windows().foreach ((window) => {
                ((MibiMdEditor)window).load_preferences ();
            });
            // Close the window
            dialog.destroy ();
            return true;
        });
        get_windows().foreach ((window) => {
            dialog.refresh_scripts
                  .connect (((MibiMdEditor)window).refresh_scripts_list);
        });
    }
}
