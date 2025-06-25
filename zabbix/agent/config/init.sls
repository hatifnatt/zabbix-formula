{#- Install zabbix server via official packages https://www.zabbix.com/download #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- from tplroot ~ "/version.jinja" import version -%}

{%- if z.agent.install %}
include:
  - .extra
  - ..service

# TODO upload custom scripts for userparamaters?
# TODO manage SELinux policies or add it to install state file?

zabbix_agent_config_file:
  file.managed:
    - name: {{ z.agent.config.file }}
    - source:
      - salt://{{ tplroot }}/files/agent/{{ version.repo.no_dot }}_zabbix_agentd.conf
      - salt://{{ tplroot }}/files/agent/zabbix_agentd.conf
      - salt://{{ tplroot }}/files/agent/{{ version.repo.no_dot }}_zabbix_agentd.conf.jinja
      - salt://{{ tplroot }}/files/agent/zabbix_agentd.conf.jinja
      - salt://{{ tplroot }}/files/agent/{{ version.lts.no_dot }}_zabbix_agentd.conf
      - salt://{{ tplroot }}/files/agent/zabbix_agentd.conf
      - salt://{{ tplroot }}/files/agent/{{ version.lts.no_dot }}_zabbix_agentd.conf.jinja
      - salt://{{ tplroot }}/files/agent/zabbix_agentd.conf.jinja
    - template: jinja
    - context:
        cfg: {{ z.agent.config.data|tojson }}
        cfg_raw: {{ z.agent.config.raw|tojson }}
    - watch_in:
        service: zabbix_agent_service_{{ z.agent.service.status }}

{#- Zabbix agent is not selected for installation #}
{%- else %}
zabbix_agent_config_notice:
  test.show_notification:
    - name: zabbix_agent_config
    - text: |
        Zabbix agent is not selected for installation, current value
        for 'zabbix:agent:install': {{ z.agent.install|string|lower }}, if you want to install Zabbix agent
        you need to set it to 'true'. You need to install Zabbix agent firts before managing it's configuration.

{%- endif %}
