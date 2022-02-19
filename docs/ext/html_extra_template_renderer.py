import os.path


def render_html_extra_templates(app):
    if app.builder.format != 'html':
        # Les constructeurs non-HTML ne fournissent pas .templates.render_string(). Notez qu'un code HTML
        # builder est toujours utilisé lors de la création d'autres formats comme json ou epub.
        return

    for input_path, template_config in app.config.html_extra_templates.items():
        # Exiger des chemins absolus simplifie la mise en œuvre.
        if not os.path.isabs(input_path):
            raise RuntimeError(f"Template input path is not absolute: {input_path}")
        if not os.path.isabs(template_config['target']):
            raise RuntimeError(f"Template target path is not absolute: {template_config['target']}")

        with open(input_path, 'r', encoding='utf8') as input_file:
            # Exécute Jinja2, qui prend en charge le rendu des balises {{ }} entre autres.
            rendered_template = app.builder.templates.render_string(
                input_file.read(),
                template_config['context'],
            )

        with open(template_config['target'], 'w', encoding='utf8') as target_file:
            target_file.write(rendered_template)

        app.config.html_extra_path.append(template_config['target'])


def setup(app):
    app.add_config_value('html_extra_templates', default={}, rebuild='', types=dict)

    # Enregistrez un gestionnaire pour l'événement env-before-read-docs. Tout événement déclenché avant que les fichiers statique
    # soit copiés suffiraient.
    app.connect(
        'env-before-read-docs',
        lambda app, env, docnames: render_html_extra_templates(app)
    )

    return {
        # NOTE: Besoin d'accéder à _raw_config ici car setup() s'exécute avant que app.config ne soit prêt.
        'version': app.config._raw_config['version'],  # pylint: disable=protected-access
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
