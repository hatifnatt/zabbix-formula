{#- Create user and group for Zabbix #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

zabbix_user_create_group:
  group.present:
    - name: {{ z.group }}
    - system: true

zabbix_user_create_user:
  user.present:
    - name: {{ z.user }}
    - gid: {{ z.group }}
    - optional_groups: {{ z.user_groups }}
    # Home directory should be created by pkg scripts
    - createhome: False
    - shell: {{ z.shell }}
    - system: true
    - require:
      - group: zabbix_user_create_group
