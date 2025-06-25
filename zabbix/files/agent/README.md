# Templating Zabbix Agent configuration

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
^# Default:(.*)\n# (\w+)=(.*)?\n\n?
```

Replace regex, note lower case transformation with `\L`

```
# Default:$1
# $2=$3
{% if '\L$2' in lcfg %}
$2={{ lcfg.\L$2 }}
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

After `# Server=` replace `{% if %} ... {% endif %}` block with

```
{% if 'server' in lcfg %}
    {%- if lcfg.server|is_list %}
Server={{ lcfg.server|join(',') }}
    {%- else %}
Server={{ lcfg.server }}
    {%- endif %}
{% endif %}
```

After `# ServerActive=` replace `{% if %} ... {% endif %}` block with

```
{% if 'serveractive' in lcfg %}
    {%- if lcfg.serveractive|is_list %}
ServerActive={{ lcfg.serveractive|join(',') }}
    {%- else %}
ServerActive={{ lcfg.serveractive }}
    {%- endif %}
{% endif %}
```

After `# TLSAccept=` replace `{% if %} ... {% endif %}` block with

```
{% if 'tlsaccept' in lcfg %}
    {%- if lcfg.tlsaccept|is_list %}
TLSAccept={{ lcfg.tlsaccept|join(',') }}
    {%- else %}
TLSAccept={{ lcfg.tlsaccept }}
    {%- endif %}
{% endif %}
```

Since version 5.2
After `Hostname=` replace `{% if %} ... {% endif %}` block with

```
{% if 'hostname' in lcfg %}
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
{%- if 'alias' in lcfg and lcfg['alias'] is string %}
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

After `# UserParameter=` replace `{% if %} ... {% endif %}` block with

```
{%- if 'userparameter' in lcfg and lcfg['userparameter'] is string %}
    {%- do lcfg.update({'userparameters': [lcfg['userparameter']]}) %}
{%- endif %}
{% if 'userparameters' in lcfg %}
    {%- for userparameter in lcfg.get('userparameters',[]) %}
UserParameter={{ userparameter }}
    {%- endfor %}
{% endif %}
```
