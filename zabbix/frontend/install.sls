{#- Install Zabbix frontend via official packages https://www.zabbix.com/download #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{%- set dbtype = z.frontend|traverse('db:type', z.db.type) %}
{#- Merge default package parameters with frontend specific parameters #}
{%- set package = salt['slsutil.merge'](z.package, z.frontend.package) %}
{#- Merge general package parameters with DB specific parameters #}
{%- set package = salt['slsutil.merge'](package, z.frontend[dbtype].package) %}

{%- if z.frontend.install %}
  {#- Install Zabbix frontend from packages #}
include:
  - {{ tplroot }}.repo
  {#- We have some configuration data, lets configure Zabbix after installation #}
  {%- if z.frontend.config.data %}
  - {{ tplroot }}.frontend.config
  {%- endif %}

zabbix_frontend_install:
  pkg.installed:
    - pkgs:
  {%- for pkg in package.pkgs %}
      - {{ pkg }}{% if package.version is defined and 'zabbix' in pkg %}: '{{ package.version }}'{% endif %}
  {%- endfor %}
  {%- if salt['grains.get']('os_family') == 'Debian' %}
    - install_recommends: {{ z.frontend.package.install_recommends }}
  {%- endif %}
    - hold: {{ package.hold }}
    - update_holds: {{ package.update_holds }}
    {# - watch_in:
      - service: zabbix_frontend_service_running #}
    - require:
      - sls: {{ tplroot }}.repo
  {#- We have some configuration data, lets configure Zabbix after installation #}
  {%- if z.frontend.config.data %}
    - require_in:
      - sls: {{ tplroot }}.frontend.config
  {%- endif %}
  {#- TODO restart service after package installed / updated #}

{#- Zabbix frontend is not selected for installation #}
{%- else %}
zabbix_frontend_install_notice:
  test.show_notification:
    - name: zabbix_frontend_install
    - text: |
        Zabbix frontend is not selected for installation, current value
        for 'zabbix:server:install': {{ z.frontend.install|string|lower }}, if you want to install Zabbix frontend
        you need to set it to 'true'.

{%- endif %}
