{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{#- If zabbix:use_official_repo is true official repo will be configured #}
{%- if z.use_official_repo %}

  {#- Install required packages if defined #}
  {%- if z.repo.prerequisites %}
zabbix_repo_install_prerequisites:
  pkg.installed:
    - pkgs: {{ z.repo.prerequisites|tojson }}
  {%- endif %}

  {#- Install keyring / gpg key if provided #}
  {%- if 'keyring' in z.repo and z.repo.keyring %}
    {#- If only one keyring configuration is present - convert it to list #}
    {%- if z.repo.keyring is mapping %}
      {%- set keyrings = [z.repo.keyring] %}
    {%- else %}
      {%- set keyrings = z.repo.keyring %}
    {%- endif %}
    {%- for keyring in keyrings %}
      {#- Install keyring if provided, for Debian based systems only #}
zabbix_repo_install_keyring_{{ loop.index0 }}:
  file.managed:
    - name: {{ keyring.get('dst', '') }}
    - source: {{ keyring.get('src', '') }}
    - skip_verify: {{ keyring.get('skip_verify', false) }}
    {%- endfor %}
  {%- endif %}

  {#- If only one repo configuration is present - convert it to list #}
  {%- if z.repo.config is mapping %}
    {%- set configs = [z.repo.config] %}
  {%- else %}
    {%- set configs = z.repo.config %}
  {%- endif %}
  {%- for config in configs %}
zabbix_repo_install_{{ loop.index0 }}:
  pkgrepo.managed:
    {{- format_kwargs(config) }}
    {%- if 'keyring' in z.repo and z.repo.keyring %}
    - require:
      - file: zabbix_repo_install_keyring_*
    {%- endif %}
  {%- endfor %}

{#- Official repo configuration is not requested #}
{%- else %}
zabbix_repo_install_method:
  test.show_notification:
    - name: zabbix_repo_install_method
    - text: |
        Official repo configuration is not requested.
        If you want to configure repository set 'zabbix:use_official_repo' to true.
        Current value of zabbix:use_official_repo: '{{ z.use_official_repo }}'
{%- endif %}