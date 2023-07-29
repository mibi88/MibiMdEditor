mibimdeditor_sources += [
  'ui/window.vala',
  'main.vala',
  'ui/preferencesswitch.vala',
  'ui/script_properties.vala',
  'ui/preferences.vala',
  'application.vala',
]

mibimdeditor_deps = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gtk4'),
  dependency('webkitgtk-6.0'),
  dependency('gtksourceview-5'),
  dependency('libadwaita-1'),
]

executable('mibimdeditor', mibimdeditor_sources,
  vala_args: '--target-glib=2.58',  dependencies: mibimdeditor_deps,
  install: true,
)

