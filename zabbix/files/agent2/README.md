# Templating Zabbix Agent2 configuration

Add 'header' part, don't forget to sync `_utils` by running `salt \* saltutil.sync_utils`

```
# Managed by SaltStack zabbix-formula. Do not edit by hand.
{#- Convert all configuration keys to lowercase #}
{%- set lcfg = salt.zabbix_formula.change_case(cfg, 'lower', process='keys') %}
```

Cleanup regex - will remove any exising options

```
^([\w\.\*]+)=(.*)?\n\n
```

Search regex for agent2 plugins

```
^# Default:(.*)\n# ([\w\.\*]+)=(.*)?\n\n?
```

Replace regex for agent2 plugins, note lower case transformation with `\L`

```
# Default:$1
# $2=$3
{% if salt.zabbix_formula.traverse_dict_keys(lcfg, '\L$2', delimiter='.') %}
$2={{ lcfg|traverse('\L$2', delimiter='.') }}
{% endif %}\n
```

## Parameters which can have comma delimited value

After `# ListenIP=...` replace `{% if %} ... {% endif %}` block with

```
{% if salt.zabbix_formula.traverse_dict_keys(lcfg, 'listenip', delimiter='.') %}
    {%- if lcfg.listenip|is_list %}
ListenIP={{ lcfg.listenip|join(',') }}
    {%- else %}
ListenIP={{ lcfg.listenip }}
    {%- endif %}
{% endif %}
```

After `# Server=` replace `{% if %} ... {% endif %}` block with

```
{% if salt.zabbix_formula.traverse_dict_keys(lcfg, 'server', delimiter='.') %}
    {%- if lcfg.server|is_list %}
Server={{ lcfg.server|join(',') }}
    {%- else %}
Server={{ lcfg.server }}
    {%- endif %}
{% endif %}
```

After `# ServerActive=` replace `{% if %} ... {% endif %}` block with

```
{% if salt.zabbix_formula.traverse_dict_keys(lcfg, 'serveractive', delimiter='.') %}
    {%- if lcfg.serveractive|is_list %}
ServerActive={{ lcfg.serveractive|join(',') }}
    {%- else %}
ServerActive={{ lcfg.serveractive }}
    {%- endif %}
{% endif %}
```

Since version 5.2
After `Hostname=` replace `{% if %} ... {% endif %}` block with

```
{% if salt.zabbix_formula.traverse_dict_keys(lcfg, 'hostname', delimiter='.') %}
    {%- if lcfg.hostname|is_list %}
Hostname={{ lcfg.hostname|join(',') }}
    {%- else %}
Hostname={{ lcfg.hostname }}
    {%- endif %}
{% endif %}
```

## Parameters that can be provided multiple times

After `### Option: Alias ... # Default:` add

```
{%- if salt.zabbix_formula.traverse_dict_keys(lcfg, 'alias', delimiter='.') and lcfg['alias'] is string %}
    {%- do lcfg.update({'aliases': [lcfg['alias']]}) %}
{%- endif %}
{% if 'aliases' in lcfg %}
    {%- for alias in lcfg.get('aliases',[]) %}
Alias={{ alias }}
    {%- endfor %}
{% endif %}
```

After `# Include=` replace `{% if %} ... {% endif %}` block with

```
{%- if salt.zabbix_formula.traverse_dict_keys(lcfg, 'include', delimiter='.') and lcfg['include'] is string %}
    {%- do lcfg.update({'includes': [lcfg['include']]}) %}
{%- endif %}
{% if salt.zabbix_formula.traverse_dict_keys(lcfg, 'includes', delimiter='.') %}
    {%- for include in lcfg.get('includes',[]) %}
Include={{ include }}
    {%- endfor %}
{% endif %}
```

After `# UserParameter=` replace `{% if %} ... {% endif %}` block with

```
{%- if salt.zabbix_formula.traverse_dict_keys(lcfg, 'userparameter', delimiter='.') and lcfg['userparameter'] is string %}
    {%- do lcfg.update({'userparameters': [lcfg['userparameter']]}) %}
{%- endif %}
{% if salt.zabbix_formula.traverse_dict_keys(lcfg, 'userparameters', delimiter='.') %}
    {%- for userparameter in lcfg.get('userparameters',[]) %}
UserParameter={{ userparameter }}
    {%- endfor %}
{% endif %}
```
