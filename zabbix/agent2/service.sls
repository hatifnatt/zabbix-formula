{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{%- if z.agent2.install %}
  {#- Manage on boot service state in dedicated state to ensure watch trigger properly in service.running state #}
zabbix_agent2_service_{{ z.agent2.service.on_boot_state }}:
  service.{{ z.agent2.service.on_boot_state }}:
    - name: {{ z.agent2.service.name }}

zabbix_agent2_service_{{ z.agent2.service.status }}:
  service:
    - name: {{ z.agent2.service.name }}
    - {{ z.agent2.service.status }}
  {%- if z.agent2.service.status == 'running' %}
    - reload: {{ z.agent2.service.reload }}
  {%- endif %}
    - require:
        - service: zabbix_agent2_service_{{ z.agent2.service.on_boot_state }}

{#- Zabbix agent2 is not selected for installation #}
{%- else %}
zabbix_agent2_service_notice:
  test.show_notification:
    - name: zabbix_agent2_service
    - text: |
        Zabbix agent2 is not selected for installation, current value
        for 'zabbix:agent2:install': {{ z.agent2.install|string|lower }}, if you want to install Zabbix agent2
        you need to set it to 'true'. You need to install Zabbix agent2 firts before managing it's service.

{%- endif %}
