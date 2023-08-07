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

[CCode(cname="GETTEXT_PACKAGE")]
extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALE_INSTALL_DIR")]
extern const string LOCALE_INSTALL_DIR;

public static int main (string[] args) {
    Gtk.init ();
    Adw.init ();
    GtkSource.init ();
    Intl.setlocale (LocaleCategory.ALL, "");
    Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALE_INSTALL_DIR);
    Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (GETTEXT_PACKAGE);
    var app = new MibiMdEditorApplication ();
    return app.run (args);
}

