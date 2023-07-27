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
class ScriptProperties : Gtk.Box {
    [GtkChild]
    private unowned Adw.EntryRow name;
    private GLib.ListModel language_list;
    public ScriptProperties () {
        // Get all available languages and let the user choose between them for
        // the syntax highlighting ComboRow.
        LanguageManager language_manager = new LanguageManager ();
        //language_manager.language_ids;
    }
}

