# Templating Zabbix Frontend configuration

Insert header after `<?php`

```
{#- Convert all configuration keys to lowercase #}
{%- set lcfg = cfg|change_dict_case('lower', process='keys') %}
// Managed by SaltStack zabbix-formula. Do not edit by hand.
```

Template regular expressions

First

```
# search
^\$(\w+)\['(\w+)'\](\s+)= ('?)(.*?)('?);

# replace
# for vscode
$$$1['$2']$3= $4{{ lcfg.\L$1.\L$2 }}$6;

# for regex101
\$$1['$2']$3= $4{{ lcfg.\L$1.\L$2\E }}$6;
```

Second

```
# search
^\$(Z\w+)(\s+)= ('?)(.*?)('?);

# replace
# for vscode
$$$1$2= $3{{ lcfg.\L$1 }}$5;

# for regex101
\$$1$2= $3{{ lcfg.\L$1\E }}$5;

```

For boolean paramerts, if present, add `|string|lower` filters

<!-- markdownlint-disable MD010 -->
```
$DB['ENCRYPTION']		= {{ lcfg.db.encryption|string|lower }};
$DB['VERIFY_HOST']		= {{ lcfg.db.verify_host|string|lower }};
$DB['DOUBLE_IEEE754']	= {{ lcfg.db.double_ieee754|string|lower }};
```
