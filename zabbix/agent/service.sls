{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{%- if z.agent.install %}
  {#- Manage on boot service state in dedicated state to ensure watch trigger properly in service.running state #}
zabbix_agent_service_{{ z.agent.service.on_boot_state }}:
  service.{{ z.agent.service.on_boot_state }}:
    - name: {{ z.agent.service.name }}

zabbix_agent_service_{{ z.agent.service.status }}:
  service:
    - name: {{ z.agent.service.name }}
    - {{ z.agent.service.status }}
  {%- if z.agent.service.status == 'running' %}
    - reload: {{ z.agent.service.reload }}
  {%- endif %}
    - require:
        - service: zabbix_agent_service_{{ z.agent.service.on_boot_state }}

{#- Zabbix agent is not selected for installation #}
{%- else %}
zabbix_agent_service_notice:
  test.show_notification:
    - name: zabbix_agent_service
    - text: |
        Zabbix agent is not selected for installation, current value
        for 'zabbix:agent:install': {{ z.agent.install|string|lower }}, if you want to install Zabbix agent
        you need to set it to 'true'. You need to install Zabbix agent firts before managing it's service.

{%- endif %}
