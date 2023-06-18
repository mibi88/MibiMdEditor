project('mibimdeditor', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.62.0',
  default_options: [ 'warning_level=2', 'werror=false', ],
)

gnome = import('gnome')

mibimdeditor_sources = gnome.compile_resources(
    'mibimdeditor-resources',
    'data/gresource.xml',
    source_dir: 'data',
)

subdir('src')
