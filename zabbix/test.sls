{#- Install zabbix server via official packages https://www.zabbix.com/download #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- from tplroot ~ "/version.jinja" import version -%}


{%- set dbtype = z.server|traverse('db:type', z.db.type) %}
{#- Merge general package parameters with DB specific parameters  #}
{%- set package = salt['slsutil.merge'](z.server.package, z.server[dbtype].package) %}
{%- set db = salt['slsutil.merge'](z.db, z.db[dbtype]) %}

{%- set lcfg = {} %}
{%- for k, v in z.frontend.config.data.items() %}
  {%- do lcfg.update({k|lower: v}) %}
  {%- if v is mapping %}
    {%- for k1, v1 in v.items()|list %}
      {%- do v.pop(k1) %}
      {%- do v.update({k1|lower: v1}) %}
    {%- endfor %}
  {%- endif %}
{%- endfor %}

print_dict:
  test.configurable_test_state:
    - name: Print some dict
    - result: true
    - changes: False
    - comment: |
        {{ lcfg|yaml(False)|indent(width=8) }}
