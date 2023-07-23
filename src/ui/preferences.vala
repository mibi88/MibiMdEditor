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
using Hdy;

public class PreferencesDialog : Hdy.PreferencesWindow {
    // Editor settings
    private PreferencesPage editor;
    public PreferencesGroup text_edition;
    public PreferencesSwitch bg_grid;
    public PreferencesSwitch lhighlight;
    public PreferencesSwitch auto_indent;
    public PreferencesSwitch mono_font;
    // Generator settings
    private PreferencesPage generator;
    // Settings saving
    private GLib.Settings settings;
    public PreferencesDialog (Gtk.Window window) {
        settings = new GLib.Settings ("io.github.mibi88.MibiMdEditor");
        transient_for = window;
        modal = true;
        destroy_with_parent = true;
        set_default_size (320, 240);
        editor = new PreferencesPage();
        editor.title = "Editor";
        editor.icon_name = "text-editor-symbolic";
        // Editor page content
        text_edition = new PreferencesGroup ();
        text_edition.title = "Text edition";
        // Text edition group content
        bg_grid = new PreferencesSwitch ("Grid background",
                                         settings.get_boolean ("bg-grid"));
        text_edition.add (bg_grid);
        lhighlight = new PreferencesSwitch ("Line highlight",
                                         settings.get_boolean ("lhighlight"));
        text_edition.add (lhighlight);
        auto_indent = new PreferencesSwitch ("Auto indent",
                                         settings.get_boolean ("auto-indent"));
        text_edition.add (auto_indent);
        mono_font = new PreferencesSwitch ("Monospace font",
                                         settings.get_boolean ("mono-font"));
        text_edition.add (mono_font);
        // Add the text edition group
        editor.add (text_edition);
        // Add the editor page
        add(editor);
        generator = new PreferencesPage();
        generator.title = "Generator";
        generator.icon_name = "x-office-document-symbolic";
        add(generator);
    }
    public void save () {
        settings.set_boolean ("bg-grid", bg_grid.gswitch.state);
        settings.set_boolean ("lhighlight", lhighlight.gswitch.state);
        settings.set_boolean ("auto-indent", auto_indent.gswitch.state);
        settings.set_boolean ("mono-font", mono_font.gswitch.state);
    }
}

