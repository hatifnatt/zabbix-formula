{#- Install Zabbix frontend via official packages https://www.zabbix.com/download #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{%- if z.frontend.install %}

  {#- Proceed only if configuration for phpfpm is provided #}
  {%- if 'phpfpm' in z.frontend
      and z.frontend.phpfpm is mapping
      and z.frontend.phpfpm.get('configure', false) %}
    {%- set dbtype = z.frontend|traverse('db:type', z.db.type) %}
    {%- set phpfpm = z.frontend.get('phpfpm', {}) %}
    {#- Merge general frontend.phpfpm parameters with DB specific phpfpm parameters (if present) #}
    {%- set phpfpm = salt['slsutil.merge'](phpfpm, z.frontend[dbtype].get('phpfpm', {})) %}

    {#- Install php-fpm packages #}
zabbix_frontend_phpfpm_pkg:
  pkg.installed:
    - pkgs: {{ phpfpm.pkgs|tojson }}

    {#- Create config file for php-fpm pool #}
zabbix_frontend_phpfpm_pool_config_file:
  file.managed:
    - name: {{ phpfpm.pool.config_file }}
    - source: {{ phpfpm.pool.config_template }}
    - template: jinja
    - context:
        config: {{ phpfpm.pool.config|tojson }}
    - watch_in:
      - service: zabbix_frontend_phpfpm_service_running

    {#- Create symlink for config file in php-fpm pool.d directory #}
zabbix_frontend_phpfpm_pool_config_file_symlink:
  file.symlink:
    - name: {{ phpfpm.pool.config_file_symlink }}
    - target: {{ phpfpm.pool.config_file }}

    {#- Restart php-fpm service #}
zabbix_frontend_phpfpm_service_running:
  service.running:
    - name: {{ phpfpm.service.name }}
    - reload: {{ phpfpm.service.reload }}

  {#- No phpfpm configuration provided, or configuration of php-fpm is disabled - show notification #}
  {%- else %}
zabbix_frontend_phpfpm_empty_config_notice:
  test.show_notification:
    - name: zabbix_frontend_phpfpm_empty_config
    - text: |
        To install php-fpm and create pool configuration for Zabbix
        you need provide configuration in 'zabbix:frontend:phpfpm' via pillars
        And set 'zabbix:frontend:phpfpm:configure' to 'true', current value is {{ z.frontend.phpfpm.get('configure', '')|string|lower }}

  {%- endif %}

{#- Zabbix frontend is not selected for installation #}
{%- else %}
zabbix_frontend_phpfpm_notice:
  test.show_notification:
    - name: zabbix_frontend_phpfpm
    - text: |
        Zabbix frontend is not selected for installation, current value
        for 'zabbix:frontend:install': {{ z.frontend.install|string|lower }}, if you want to install Zabbix frontend
        you need to set it to 'true'.

{%- endif %}
