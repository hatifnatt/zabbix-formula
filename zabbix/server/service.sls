{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{#- Manage on boot service state in dedicated state to ensure watch trigger properly in service.running state #}
zabbix_server_service_{{ z.server.service.on_boot_state }}:
  service.{{ z.server.service.on_boot_state }}:
    - name: {{ z.server.service.name }}

zabbix_server_service_{{ z.server.service.status }}:
  service:
    - name: {{ z.server.service.name }}
    - {{ z.server.service.status }}
    {%- if z.server.service.status == 'running' %}
    - reload: {{ z.server.service.reload }}
    {%- endif %}
    - require:
        - service: zabbix_server_service_{{ z.server.service.on_boot_state }}
    - order: last
