{#- Install Zabbix server via official packages https://www.zabbix.com/download #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{%- set dbtype = z.server|traverse('db:type', z.db.type) %}
{#- Merge default package parameters with server specific parameters #}
{%- set package = salt['slsutil.merge'](z.package, z.server.package) %}
{#- Merge general package parameters with DB specific parameters #}
{%- set package = salt['slsutil.merge'](package, z.server[dbtype].package) %}

{%- if z.server.install %}
  {#- Install Zabbix server from packages #}
include:
  - {{ tplroot }}.repo
  - {{ tplroot }}.user
  {#- We have some configuration data, lets configure Zabbix after installation #}
  {%- if z.server.config.data %}
  - {{ tplroot }}.server.config
  {%- endif %}
  {#- DB schema import requested #}
  {%- if z.db.import_schema %}
  - {{ tplroot }}.db.{{ dbtype }}.schema
  {%- endif %}
  - {{ tplroot }}.server.service

  {%- if 'pkgs_extra' in package and package.pkgs_extra %}
zabbix_server_install_extra:
  pkg.installed:
    - pkgs: {{ package.pkgs_extra|tojson }}
    - require_in:
      - pkg: zabbix_server_install
  {%- endif %}

zabbix_server_install:
  pkg.installed:
    - pkgs:
  {%- for pkg in package.pkgs %}
      - {{ pkg }}{% if package.version is defined and 'zabbix' in pkg %}: '{{ package.version }}'{% endif %}
  {%- endfor %}
    - hold: {{ package.hold }}
    - update_holds: {{ package.update_holds }}
  {%- if salt['grains.get']('os_family') == 'Debian' %}
    - install_recommends: {{ package.install_recommends }}
  {%- endif %}
    - watch_in:
      - service: zabbix_server_service_{{ z.server.service.status }}
    - require:
      - sls: {{ tplroot }}.repo
    - require_in:
      - sls: {{ tplroot }}.user
  {#- We have some configuration data, lets configure Zabbix after installation #}
  {%- if z.server.config.data %}
      - sls: {{ tplroot }}.server.config
  {%- endif %}
  {#- DB schema import requested #}
  {%- if z.db.import_schema %}
      - sls: {{ tplroot }}.db.{{ dbtype }}.schema
  {%- endif %}
      - service: zabbix_server_service_{{ z.server.service.on_boot_state }}

{#- Zabbix server is not selected for installation #}
{%- else %}
zabbix_server_install_notice:
  test.show_notification:
    - name: zabbix_server_install
    - text: |
        Zabbix server is not selected for installation, current value
        for 'zabbix:server:install': {{ z.server.install|string|lower }}, if you want to install Zabbix server
        you need to set it to 'true'.

{%- endif %}
