{#- Install zabbix server via official packages https://www.zabbix.com/download #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- from tplroot ~ "/version.jinja" import version -%}

{%- set dbtype = z.server|traverse('db:type', z.db.type) %}
{#- Merge generic DB parameters with selected DB type specific parameters #}
{%- set db = salt['slsutil.merge'](z.db, z.db[dbtype]) %}
{#- Merge generic configuration parameters with DB specific parameters #}
{%- set config = salt['slsutil.merge'](z.server.config, z.server[dbtype].config) %}


{#- Set dbname, dbuser, dbpassword from db.name, db.user, db.password, db.schema
    if those values are not defined in server configuration data #}
{%- do config.data.update({'dbname': db.name}) if 'dbname' not in config.data %}
{%- do config.data.update({'dbuser': db.user}) if 'dbuser' not in config.data %}
{%- do config.data.update({'dbpassword': db.password}) if 'dbpassword' not in config.data %}
{%- do config.data.update({'dbschema': db.schema}) if 'dbschema' not in config.data and db.schema %}

{%- if z.server.install %}
include:
  - .service

# TODO manage SELinux policies or add it to install state file?

zabbix_server_config_file:
  file.managed:
    - name: {{ z.server.config.file }}
    - source:
      - salt://{{ tplroot }}/files/server/{{ version.repo.no_dot }}_zabbix_server.conf
      - salt://{{ tplroot }}/files/server/zabbix_server.conf
      - salt://{{ tplroot }}/files/server/{{ version.repo.no_dot }}_zabbix_server.conf.jinja
      - salt://{{ tplroot }}/files/server/zabbix_server.conf.jinja
      - salt://{{ tplroot }}/files/server/{{ version.lts.no_dot }}_zabbix_server.conf
      - salt://{{ tplroot }}/files/server/zabbix_server.conf
      - salt://{{ tplroot }}/files/server/{{ version.lts.no_dot }}_zabbix_server.conf.jinja
      - salt://{{ tplroot }}/files/server/zabbix_server.conf.jinja
    - template: jinja
    - context:
        cfg: {{ config.data|tojson }}
    - watch_in:
        service: zabbix_server_service_{{ z.server.service.status }}

{#- Zabbix server is not selected for installation #}
{%- else %}
zabbix_server_config_notice:
  test.show_notification:
    - name: zabbix_server_config
    - text: |
        Zabbix server is not selected for installation, current value
        for 'zabbix:server:install': {{ z.server.install|string|lower }}, if you want to install Zabbix server
        you need to set it to 'true'.

{%- endif %}
