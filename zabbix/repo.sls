{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{%- if z.repo.prerequisites and z.use_official_repo %}
zabbix_repo_prerequisites:
  pkg.installed:
    - pkgs: {{ z.repo.prerequisites|tojson }}
    {# - require_in:
      - pkgrepo: zabbix_repo #}
{%- endif %}

{#- If zabbix:use_official_repo is 'true' official repo will be configured
    in other cases repo will be removed from the system #}
{#- If only one repo configuration is present - convert it to list #}
{%- if z.repo.config is mapping %}
  {%- set configs = [z.repo.config] %}
{%- else %}
  {%- set configs = z.repo.config %}
{%- endif %}
{%- for config in configs %}
zabbix_repo_{{ loop.index0 }}:
  pkgrepo:
  {%- if z.use_official_repo %}
    - managed
    {{- format_kwargs(config) }}
  {%- else %}
    - absent
    - name: {{ config.name }}
  {%- endif %}
{%- endfor %}
