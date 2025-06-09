{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{#- Merge general db parameters with DB specific parameters #}
{%- set dbtype = z.server|traverse('db:type', z.db.type) %}

{#- Proceed only if dbtype match, this state file is for pgsql #}
{%- if dbtype == 'pgsql' %}
  {%- set db = salt['slsutil.merge'](z.db, z.db[dbtype]) %}

  {%- set dbhost = db.host %}
  {%- set dbname = db.name %}
  {%- set dbuser = db.user %}
  {%- set dbpassword = db.password %}

  {%- set dbroot_user = db.root.user %}
  {%- set dbroot_pass = db.root.password %}

  {%- set sql_file = db.sql_file %}

  {#- Check is DB present
      Check is there any tables in DB
      If DB present and there is no tables - upload schema
      Show error / info messages in other cases #}
  {#- TODO Use slots for DB checks? #}

  {#- Connection args required only if dbroot_user and dbroot_pass defined. #}
  {%- set connection_args = {} %}
  {%- if dbroot_user and dbroot_pass %}
    {%- set connection_args = {'runas': 'nobody', 'host': dbhost, 'user': dbroot_user, 'password': dbroot_pass} %}
  {%- endif %}

  {#- Is schema import requested in pillars? #}
  {%- if db.import_schema %}
    {#- Check is there any tables in database.
        salt.postgres.psql_query return empty result if there is no tables or 'False' on any error i.e. failed auth. #}
    {%- set list_tables = "SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema' LIMIT 1;" %}
    {%- set is_db_empty = True %}
    {#- TODO Use slots or show info that postgresql must be installed first currently formula fails with error
        Rendering SLS 'dev:zabbix.db.pgsql.schema' failed: Jinja variable 'salt.utils.templates.AliasedLoader
        object' has no attribute 'postgres' #}
    {%- if salt.postgres.psql_query(query=list_tables, maintenance_db=dbname, **connection_args) %}
      {%- set is_db_empty = False %}
    {%- endif %}

include:
    {%- if db.manage %}
  - {{ tplroot }}.db.pgsql.prepare
    {%- endif %}
  - {{ tplroot }}.db.pgsql.helper_pkgs

    {#- TODO Allow to provide custom SQL file for import #}
    {#- {%- if 'custom_sql_file' in settings %}
zabbix_db_pgsql_schema_upload_sql_dump:
  file.managed:
    - name: /tmp/{{ salt['file.basename'](custom_sql_file) }}
    - source: {{ custom_sql_file }}
    - makedirs: true
    - require_in:
      - zabbix_db_pgsql_schema_import_sql
  {%- endif %} #}

zabbix_db_pgsql_schema_sql_file:
  file.exists:
    - name: '{{ sql_file }}'
    - failhard: true

zabbix_db_pgsql_schema_check_db:
  test.configurable_test_state:
    - name: Is there any tables in '{{ dbname }}' database?
    - changes: {{ is_db_empty }}
    - result: true
    - comment: If changes is 'True' data import required.

zabbix_db_pgsql_schema_import_sql:
  cmd.run:
    - name: zcat {{ sql_file }} | psql | tail -5
    - runas: {{ z.user }}
    - env:
      - PGUSER: {{ dbuser }}
      - PGPASSWORD: {{ dbpassword }}
      - PGDATABASE: {{ dbname }}
      - PGHOST: {{ dbhost }}
    - require:
      - file: zabbix_db_pgsql_schema_sql_file
    {%- if db.manage %}
      - sls: {{ tplroot }}.db.pgsql.prepare
    {%- endif %}
    - onchanges:
      - test: zabbix_db_pgsql_schema_check_db

  {#- Schema import not requested - show notice #}
  {%- else %}
zabbix_db_pgsql_schema_import_notice:
  test.show_notification:
    - name: zabbix_db_pgsql_schema_import_notice
    - text: |
        Schema import is not enabled in pillars, current value
        for zabbix:db:import_schema: {{ db.import_schema|string|lower }}, if you want this formula to import
        schema for Zabbix DB you need to set it to 'true'.
  {%- endif %}

{#- Current Zabbix DB backend in pillar is not PostgreSQL #}
{%- else %}
zabbix_db_pgsql_schema_notice:
  test.show_notification:
    - name: zabbix_db_pgsql_schema_notice
    - text: |
        Zabbix DB backend in pillar is not PostgreSQL, current value
        for zabbix:db:type: {{ db.type|string }}, if you want to use PostgreSQL
        you need to set it to 'pgsql'.
{%- endif %}
