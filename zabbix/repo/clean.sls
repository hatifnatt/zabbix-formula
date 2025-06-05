{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import zabbix as z %}

{#- Remove any configured repo form the system #}
{#- If only one repo configuration is present - convert it to list #}
{%- if z.repo.config is mapping %}
  {%- set configs = [z.repo.config] %}
{%- else %}
  {%- set configs = z.repo.config %}
{%- endif %}
{%- for config in configs %}
zabbix_repo_clean_{{ loop.index0 }}:
  {%- if grains.os_family != 'Debian' %}
  pkgrepo.absent:
    - name: {{ config.name | yaml_dquote }}
  {%- else %}
  {#- Due bug in pkgrepo.absent we need to manually remove repository '.list' files
      See https://github.com/saltstack/salt/issues/61602 #}
  file.absent:
    - name: {{ config.file }}
  {%- endif %}
{%- endfor %}

{#- Remove keyring files if present #}
{%- if 'keyring' in z.repo and z.repo.keyring %}
  {#- If only one keyring configuration is present - convert it to list #}
  {%- if z.repo.keyring is mapping %}
    {%- set keyrings = [z.repo.keyring] %}
  {%- else %}
    {%- set keyrings = z.repo.keyring %}
  {%- endif %}
  {%- for keyring in keyrings %}
zabbix_repo_clean_keyring_{{ loop.index0 }}:
  file.absent:
    - name: {{ keyring.get('dst', '') }}
  {%- endfor %}
{%- endif %}
