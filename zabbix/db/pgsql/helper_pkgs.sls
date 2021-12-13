{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{#- Merge general db parameters with DB specific parameters #}
{%- set dbtype = z.server|traverse('db:type', z.db.type) %}

{%- if dbtype == 'pgsql' %}
  {#- Install packages required for Salt postgres module #}
  {%- if z.db[dbtype].helper_pkgs and z.db[dbtype].helper_pkgs_install %}
zabbix_db_pgsql_helper_pkgs:
  pkg.installed:
    - pkgs: {{ z.db[dbtype].helper_pkgs|tojson }}

  {%- elif not z.db[dbtype].helper_pkgs_install %}
zabbix_db_pgsql_helper_pkgs:
  test.configurable_test_state:
    - name: You skipped installation of packages required for Salt postgres module.
    - changes: False
    - result: true

  {%- else %}
zabbix_db_pgsql_helper_pkgs_warning:
  test.configurable_test_state:
    - name: Packages required for Salt postgres module are not defined
    - changes: false
    - result: false
    - comment: |
        Additional packages are required to manage the PostgreSQL database.
        Please specify them in pillar as list.
        Tip: you need postgresql-client packages, like:
        zabbix:
          db:
            pgsql:
              helper_pkgs_install: true
              helper_pkgs:
                - postgresql-client-common
                - postgresql-client
        Or you can skip installing them, but formula likely fail without them.
        zabbix:
          db:
            pgsql:
              helper_pkgs_install: false
  {%- endif %}

{#- Current Zabbix DB backend in pillar is not PostgreSQL #}
{%- else %}
zabbix_db_pgsql_helper_pkgs_notice:
  test.show_notification:
    - name: zabbix_db_pgsql_pkgs_notice
    - text: |
        Zabbix DB backend in pillar is not PostgreSQL, current value
        for zabbix:db:type: {{ z.db.type|string }}, if you want to use PostgreSQL
        you need to set it to 'pgsql'.
{%- endif %}
