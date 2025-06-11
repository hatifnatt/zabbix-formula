{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{#- Create user and database #}

{#- Merge general db parameters with DB specific parameters #}
{%- set dbtype = z.server|traverse('db:type', z.db.type) %}

{#- Proceed only if dbtype match, current state file is for pgsql #}
{%- if dbtype == 'pgsql' %}
  {%- set db = salt['slsutil.merge'](z.db, z.db[dbtype]) %}

  {%- set dbhost = db.host %}
  {%- set dbname = db.name %}
  {%- set dbuser = db.user %}
  {%- set dbpassword = db.password %}

  {%- set dbroot_user = db.root.user %}
  {%- set dbroot_pass = db.root.password %}

  {#- use 'scram-sha-256' encryption by default #}
  {%- set dbpassword_encryption = db.password_encryption if db.get('password_encryption', '') in ('md5', 'scram-sha-256')
          else 'scram-sha-256' %}

  {%- if db.manage %}
include:
  - {{ tplroot }}.db.pgsql.helper_pkgs

zabbix_db_pgsql_prepare_create_user:
  postgres_user.present:
    - name: {{ dbuser }}
    - password: {{ dbpassword }}
    - encrypted: {{ dbpassword_encryption }}
    - login: true
    {%- if dbroot_user and dbroot_pass %}
    - db_host: {{ dbhost }}
    - db_user: {{ dbroot_user }}
    - db_password: {{ dbroot_pass }}
    {%- endif %}
    - require:
      - sls: {{ tplroot }}.db.pgsql.helper_pkgs

zabbix_db_pgsql_prepare_create_db:
  postgres_database.present:
    - name: {{ dbname }}
    - owner: {{ dbuser }}
    {%- if dbroot_user and dbroot_pass %}
    - db_host: {{ dbhost }}
    - db_user: {{ dbroot_user }}
    - db_password: {{ dbroot_pass }}
    {%- endif %}
    - require:
      - sls: {{ tplroot }}.db.pgsql.helper_pkgs
      - postgres_user: zabbix_db_pgsql_prepare_create_user

  {%- else %}
zabbix_db_pgsql_prepare_manage_notice:
  test.show_notification:
    - name: zabbix_db_pgsql_prepare_manage_notice
    - text: |
        Zabbix DB management is not enabled in pillars, current value
        for zabbix:db:manage: {{ db.manage|string|lower }}, if you want this formula to create
        PostgreSQL user and DB for Zabbix you need to set it to 'true'.

  {%- endif %}

{#- Current Zabbix DB backend in pillar is not PostgreSQL #}
{%- else %}
zabbix_db_pgsql_prepare_notice:
  test.show_notification:
    - name: zabbix_db_pgsql_prepare_notice
    - text: |
        Zabbix DB backend in pillar is not PostgreSQL, current value
        for zabbix:db:type: {{ db.type|string }}, if you want to use PostgreSQL
        you need to set it to 'pgsql'.
{%- endif %}
