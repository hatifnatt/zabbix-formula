{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- from tplroot ~ "/version.jinja" import version -%}

{%- if z.agent.install %}
include:
  - ..service

  {%- if 'file' in z.agent.config.extra and z.agent.config.extra.file %}
    {%- for id, file in z.agent.config.extra.file|dictsort %}
      {%- set ensure = file.pop('ensure', 'present') %}
      {%- set name = file.pop('name', '') if 'name' in file else id %}
      {#- Remove file if it's marked for removal #}
      {%- if ensure in ('absent') %}
zabbix_agent_config_extra_file_absent_{{ id }}:
  file.absent:
    - name: {{ name }}
    - watch_in:
        service: zabbix_agent_service_{{ z.agent.service.status }}

      {%- elif ensure in ('present') %}
zabbix_agent_config_extra_file_{{ id }}:
  file.managed:
    - name: {{ name }}
    {{- format_kwargs(file) }}
    - watch_in:
        service: zabbix_agent_service_{{ z.agent.service.status }}
      {%- endif %}

    {%- endfor %}

  {%- else %}
zabbix_agent_config_extra_file_notice:
  test.show_notification:
    - name: zabbix_agent_config_extra_file_notice
    - text: |
        No extra configuration files to manage are defined in pillars.

  {%- endif %}

  {%- if 'directory' in z.agent.config.extra and z.agent.config.extra.directory %}
    {%- for id, directory in z.agent.config.extra.directory|dictsort %}
      {%- set ensure = directory.pop('ensure', 'present') %}
      {%- set name = directory.pop('name', '') if 'name' in directory else id %}
      {#- Remove directory if it supposed to be removed #}
      {%- if ensure in ('absent') %}
zabbix_agent_config_extra_directory_absent_{{ id }}:
  file.absent:
    - name: {{ name }}
    - watch_in:
        service: zabbix_agent_service_{{ z.agent.service.status }}

      {%- elif ensure in ('present') %}
zabbix_agent_config_extra_directory_{{ id }}:
  file.recurse:
    - name: {{ name }}
    {{- format_kwargs(directory) }}
    - watch_in:
        service: zabbix_agent_service_{{ z.agent.service.status }}
      {%- endif %}

    {%- endfor %}

  {%- else %}
zabbix_agent_config_extra_directory_notice:
  test.show_notification:
    - name: zabbix_agent_config_extra_directory_notice
    - text: |
        No extra directories are defined in pillars.

  {%- endif %}

{#- Zabbix agent is not selected for installation #}
{%- else %}
zabbix_agent_config_extra_notice:
  test.show_notification:
    - name: zabbix_agent_config_extra
    - text: |
        Zabbix agent is not selected for installation, current value
        for 'zabbix:agent:install': {{ z.agent.install|string|lower }}, if you want to install Zabbix agent
        you need to set it to 'true'. You need to install Zabbix agent firts before managing it's configuration.

{%- endif %}
