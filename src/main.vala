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
using Adw;

public static int main (string[] args) {
    Gtk.init ();
    Adw.init ();
    GtkSource.init ();
    var app = new Gtk.Application ("io.github.mibi88.MibiMdEditor",
                                   GLib.ApplicationFlags.FLAGS_NONE);
    app.activate.connect (() => {
        var window = new MibiMdEditor (app);
        try {
            //window.set_icon (new Pixbuf.from_resource (window.APPICON));
        } catch (Error error) {
            stderr.printf ("Error when setting app icon: %s\n", error.message);
        }
        window.close_request.connect (() => {
            window.quit();
            return true;
        });
        window.present ();
    });
    return app.run (args);
}

