{#- Install Zabbix server via official packages https://www.zabbix.com/download #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{#- Merge default package parameters with agent2 specific parameters #}
{%- set package = salt['slsutil.merge'](z.package, z.agent2.package) %}

{%- if z.agent2.install %}
  {#- Install Zabbix agent2 from packages #}
include:
  - {{ tplroot }}.repo
  - {{ tplroot }}.user
  {#- We have some configuration data, lets configure Zabbix after installation #}
  {%- if z.agent2.config.data %}
  - {{ tplroot }}.agent2.config
  {%- endif %}
  - {{ tplroot }}.agent2.service

  {%- if 'pkgs_extra' in package and package.pkgs_extra %}
zabbix_agent2_install_extra:
  pkg.installed:
    - pkgs: {{ package.pkgs_extra|tojson }}
    - require_in:
      - pkg: zabbix_agent2_install
  {%- endif %}

zabbix_agent2_install:
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
      - service: zabbix_agent2_service_{{ z.agent2.service.status }}
    - require:
      - sls: {{ tplroot }}.repo
    - require_in:
      - sls: {{ tplroot }}.user
      - service: zabbix_agent2_service_{{ z.agent2.service.on_boot_state }}
  {#- We have some configuration data, lets configure Zabbix after installation #}
  {%- if z.agent2.config.data %}
      - sls: {{ tplroot }}.agent2.config
  {%- endif %}

{#- Zabbix agent2 is not selected for installation #}
{%- else %}
zabbix_agent2_install_notice:
  test.show_notification:
    - name: zabbix_agent2_install
    - text: |
        Zabbix agent2 is not selected for installation, current value
        for 'zabbix:agent2:install': {{ z.agent2.install|string|lower }}, if you want to install Zabbix agent2
        you need to set it to 'true'.

{%- endif %}
