mibimdeditor_sources = [
  'main.vala',
  'generator.vala',
  'generator_markdown.vala',
]

mibimdeditor_deps = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gtk+-3.0'),
  dependency('webkit2gtk-4.0'),
]

executable('mibimdeditor', mibimdeditor_sources,
  vala_args: '--target-glib=2.58',  dependencies: mibimdeditor_deps,
  install: true,
)

