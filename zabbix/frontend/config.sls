{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- from tplroot ~ "/version.jinja" import version -%}

{#- Frontend will use same DB type as the server  #}
{%- set dbtype = z.server|traverse('db:type', z.db.type) %}
{#- Merge generic DB parameters with selected DB type specific parameters #}
{%- set db = salt['slsutil.merge'](z.db, z.db[dbtype]) %}
{#- Merge generic configuration parameters with DB specific parameters #}
{%- set config = salt['slsutil.merge'](z.frontend.config, z.frontend[dbtype].config) %}

{#- Set database, user, password, schema from db.name, db.user, db.password, db.schema
    if those values are not defined in frontend configuration data #}
{%- do config.data.db.update({'database': db.name}) if 'database' not in config.data.db %}
{%- do config.data.db.update({'user': db.user}) if 'user' not in config.data.db %}
{%- do config.data.db.update({'password': db.password}) if 'password' not in config.data.db %}
{%- do config.data.db.update({'schema': db.schema}) if 'schema' not in config.data.db %}


{%- set config_file_dir = salt.file.dirname(config.file) -%}

{%- if z.frontend.install %}
  {#- Fix permissions to allow to php-fpm include zabbix frontend config file
      which is usually located under /etc/zabbix #}
zabbix_frontend_config_dir:
  file.directory:
    - name: {{ config_file_dir }}
    - mode: 755
    - makedirs: true

zabbix_frontend_config_file:
  file.managed:
    - name: {{ config.file }}
    - source:
      - salt://{{ tplroot }}/files/frontend/{{ version.repo.no_dot }}_zabbix.conf.php
      - salt://{{ tplroot }}/files/frontend/zabbix.conf.php
      - salt://{{ tplroot }}/files/frontend/{{ version.repo.no_dot }}_zabbix.conf.php.jinja
      - salt://{{ tplroot }}/files/frontend/zabbix.conf.php.jinja
    - template: jinja
    - context:
        cfg: {{ config.data|tojson }}

{#- Zabbix frontend is not selected for installation #}
{%- else %}
zabbix_frontend_config_notice:
  test.show_notification:
    - name: zabbix_frontend_config
    - text: |
        Zabbix frontend is not selected for installation, current value
        for 'zabbix:server:install': {{ z.frontend.install|string|lower }}, if you want to install Zabbix frontend
        you need to set it to 'true'.

{%- endif %}
