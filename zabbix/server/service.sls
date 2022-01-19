{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{%- if z.server.install %}
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

{#- Zabbix server is not selected for installation #}
{%- else %}
zabbix_server_service_notice:
  test.show_notification:
    - name: zabbix_server_service
    - text: |
        Zabbix server is not selected for installation, current value
        for 'zabbix:server:install': {{ z.server.install|string|lower }}, if you want to install Zabbix server
        you need to set it to 'true'.

{%- endif %}
