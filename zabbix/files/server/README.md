# Templating Zabbix Server configuration

Add 'header' part

```
# Managed by SaltStack zabbix-formula. Do not edit by hand.
{#- Convert all configuration keys to lowercase #}
{%- set lcfg = {} %}
{%- for k, v in cfg.items() %}
    {%- do lcfg.update({k|lower: v}) %}
{%- endfor %}
```

Cleanup regex - will remove any exising options

```
^([\w\.\*]+)=(.*)?\n\n
```

Search regex

```
^# Default: ?\n# (\w+)=(.*)?\n\n?
```

Replace regex, note lower case transformation with `\L`

```
# Default:
# $1=$2
{% if '\L$1' in lcfg %}
$1={{ lcfg.\L$1 }}
{% endif %}\n
```

## Parameters which can have comma delimited value

After `# ListenIP=...` replace `{% if %} ... {% endif %}` block with

```
{% if 'listenip' in lcfg %}
    {%- if lcfg.listenip|is_list %}
ListenIP={{ lcfg.listenip|join(',') }}
    {%- else %}
ListenIP={{ lcfg.listenip }}
    {%- endif %}
{% endif %}
```

After `# HistoryStorageTypes=...` replace `{% if %} ... {% endif %}` block with

```
{% if 'historystoragetypes' in lcfg %}
    {%- if lcfg.historystoragetypes|is_list %}
HistoryStorageTypes={{ lcfg.historystoragetypes|join(',') }}
    {%- else %}
HistoryStorageTypes={{ lcfg.historystoragetypes }}
    {%- endif %}
{% endif %}
```

After `# StatsAllowedIP=...` replace `{% if %} ... {% endif %}` block with

```
{% if 'statsallowedip' in lcfg %}
    {%- if lcfg.statsallowedip|is_list %}
StatsAllowedIP={{ lcfg.statsallowedip|join(',') }}
    {%- else %}
StatsAllowedIP={{ lcfg.statsallowedip }}
    {%- endif %}
{% endif %}
```

### Parameters that can be provided multiple times

After `# Include=` replace `{% if %} ... {% endif %}` block with

```
{%- if 'include' in lcfg and lcfg['include'] is string %}
    {%- do lcfg.update({'includes': [lcfg['include']]}) %}
{%- endif %}
{% if 'includes' in lcfg %}
    {%- for include in lcfg.get('includes',[]) %}
Include={{ include }}
    {%- endfor %}
{% endif %}
```

After `# LoadModule=` replace `{% if %} ... {% endif %}` block with

```
{%- if 'loadmodule' in lcfg and lcfg['loadmodule'] is string %}
    {%- do lcfg.update({'loadmodules': [lcfg['loadmodule']]}) %}
{%- endif %}
{% if 'loadmodules' in lcfg %}
    {%- for loadmodule in lcfg.get('loadmodules',[]) %}
LoadModule={{ loadmodule }}
    {%- endfor %}
{% endif %}
```
