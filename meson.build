project('MibiMdEditor', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.62.0',
  default_options: [ 'warning_level=2', 'werror=false', ],
)

schemas_dir = get_option('prefix')/get_option('datadir')/'glib-2.0'/'schemas'
settings_schemas = [ 'io.github.mibi88.MibiMdEditor.gschema.xml' ]

install_data(settings_schemas, install_dir: schemas_dir)

gnome = import('gnome')

gnome.compile_schemas(
    depend_files: files(settings_schemas))
mibimdeditor_sources = gnome.compile_resources(
    'mibimdeditor-resources',
    'data/gresource.xml',
    source_dir: 'data',
)

meson.add_install_script(find_program('glib-compile-schemas'), schemas_dir)

subdir('src')
