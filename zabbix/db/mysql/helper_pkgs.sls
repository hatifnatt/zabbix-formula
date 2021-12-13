{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{%- set dbtype = z.db.type %}

{%- if dbtype == 'mysql' %}
  {#- Install packages required for Salt mysql module #}
  {%- if z.db[dbtype].helper_pkgs and z.db[dbtype].helper_pkgs_install %}
zabbix_db_mysql_helper_pkgs:
  pkg.installed:
    - pkgs: {{ z.db[dbtype].helper_pkgs|tojson }}

  {%- elif not z.db[dbtype].helper_pkgs_install %}
zabbix_db_mysql_helper_pkgs:
  test.configurable_test_state:
    - name: You skipped installation of packages required for Salt mysql module.
    - changes: False
    - result: true

  {%- else %}
zabbix_db_mysql_helper_pkgs_info:
  test.configurable_test_state:
    - name: Packages required for Salt mysql module are not defined
    - changes: false
    - result: false
    - comment: |
        Additional packages are required to manage the MySQL database.
        Please specify them in pillar as list.
        Tip: you need postgresql-client packages, like:
        zabbix:
          db:
            mysql:
              helper_pkgs_install: true
              helper_pkgs:
                - postgresql-client-common
                - postgresql-client
        Or you can skip installing them, but formula likely fail without them.
        zabbix:
          db:
            mysql:
              helper_pkgs_install: false
  {%- endif %}

{#- Current Zabbix DB backend in pillar is not MySQL #}
{%- else %}
zabbix_db_mysql_helper_pkgs_notice:
  test.show_notification:
    - name: zabbix_db_mysql_helper_pkgs_notice
    - text: |
        Zabbix DB backend in pillar is not MySQL, current value
        for zabbix:db:type: {{ z.db.type|string }}, if you want to use MySQL
        you need to set it to 'mysql'.
{%- endif %}
