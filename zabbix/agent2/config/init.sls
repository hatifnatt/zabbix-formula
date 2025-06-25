{#- Install zabbix server via official packages https://www.zabbix.com/download #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- from tplroot ~ "/version.jinja" import version -%}

{%- if z.agent2.install %}
include:
  - .extra
  - ..service

# TODO provide templates to manage additional config files for Agent2 plugins?
# TODO upload custom scripts for userparamaters?
# TODO manage SELinux policies or add it to install state file?

zabbix_agent2_config_file:
  file.managed:
    - name: {{ z.agent2.config.file }}
    - source:
      - salt://{{ tplroot }}/files/agent2/{{ version.repo.no_dot }}_zabbix_agent2.conf
      - salt://{{ tplroot }}/files/agent2/zabbix_agent2.conf
      - salt://{{ tplroot }}/files/agent2/{{ version.repo.no_dot }}_zabbix_agent2.conf.jinja
      - salt://{{ tplroot }}/files/agent2/zabbix_agent2.conf.jinja
      - salt://{{ tplroot }}/files/agent2/{{ version.lts.no_dot }}_zabbix_agent2.conf
      - salt://{{ tplroot }}/files/agent2/zabbix_agent2.conf
      - salt://{{ tplroot }}/files/agent2/{{ version.lts.no_dot }}_zabbix_agent2.conf.jinja
      - salt://{{ tplroot }}/files/agent2/zabbix_agent2.conf.jinja
    - template: jinja
    - context:
        cfg: {{ z.agent2.config.data|tojson }}
        cfg_raw: {{ z.agent2.config.raw|tojson }}
    - watch_in:
        service: zabbix_agent2_service_{{ z.agent2.service.status }}

{#- Zabbix agent2 is not selected for installation #}
{%- else %}
zabbix_agent2_config_notice:
  test.show_notification:
    - name: zabbix_agent2_config
    - text: |
        Zabbix agent2 is not selected for installation, current value
        for 'zabbix:agent2:install': {{ z.agent2.install|string|lower }}, if you want to install Zabbix agent2
        you need to set it to 'true'. You need to install Zabbix agent2 firts before managing it's configuration.

{%- endif %}
