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

public class PreferencesDialog : Gtk.Dialog {
    private HeaderBar dialogbar;
    private Stack stack;
    private ScrolledWindow scroll;
    // Editor settings
    private Box editor;
    public LabelSwitch bg_grid;
    public LabelSwitch lhighlight;
    public LabelSwitch indent;
    public LabelSwitch mono_font;
    // Generator settings
    private Box generator;
    private StackSwitcher switcher;
    public PreferencesDialog (Gtk.Window window) {
        transient_for = window;
        modal = true;
        destroy_with_parent = true;
        set_default_size (320, 240);
        scroll = new ScrolledWindow (null, null);
        stack = new Stack ();
        scroll.add (stack);
        get_content_area ().add (scroll);
        // Add a headerbar with a stackswitcher
        dialogbar = new HeaderBar ();
        dialogbar.show_close_button = true;
        set_titlebar (dialogbar);
        // Editor stack child
        editor = new Box (Orientation.VERTICAL, 4);
        stack.add_titled (editor, "editor", "Editor");
        bg_grid = new LabelSwitch ("Grid background", true);
        lhighlight = new LabelSwitch ("Line highlight", true);
        indent = new LabelSwitch ("Auto indent", true);
        mono_font = new LabelSwitch ("Monospace font", true);
        editor.add (bg_grid);
        editor.add (lhighlight);
        editor.add (indent);
        editor.add (mono_font);
        editor.expand = true;
        // Generator stack child
        generator = new Box (Orientation.VERTICAL, 4);
        generator.expand = true;
        stack.add_titled (generator, "generator", "Generator");
        switcher = new StackSwitcher ();
        switcher.set_stack (stack);
        dialogbar.set_custom_title (switcher);
    }
}

