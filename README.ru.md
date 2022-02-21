<!-- omit in toc -->
# zabbix formula

Формула для установки Zabbix Server, Frontend, Agent и Proxy

<!-- omit in toc -->
## Создание шаблонов для конфигурационных файлов

Для подробностей См. README файлы

* [Agent](zabbix/files/agent/README.md)
* [Agent2](zabbix/files/agent2/README.md)
* [Frontend](zabbix/files/frontend/README.md)
* WIP [Proxy](zabbix/files/proxy/README.md)
* [Server](zabbix/files/server/README.md)

<!-- omit in toc -->
## Доступные стейты

* [zabbix.repo](#zabbixrepo)
* [zabbix.user](#zabbixuser)
* [zabbix.agent](#zabbixagent)
* [zabbix.agent.config](#zabbixagentconfig)
* [zabbix.agent.install](#zabbixagentinstall)
* [zabbix.agent.service](#zabbixagentservice)
* [zabbix.agent2](#zabbixagent2)
* [zabbix.agent2.config](#zabbixagent2config)
* [zabbix.agent2.install](#zabbixagent2install)
* [zabbix.agent2.service](#zabbixagent2service)
* [zabbix.db.mysql](#zabbixdbmysql)
* [zabbix.db.pgsql](#zabbixdbpgsql)
* [zabbix.db.pgsql.helper_pkgs](#zabbixdbpgsqlhelper_pkgs)
* [zabbix.db.pgsql.prepare](#zabbixdbpgsqlprepare)
* [zabbix.db.pgsql.schema](#zabbixdbpgsqlschema)
* [zabbix.frontend.config](#zabbixfrontendconfig)
* [zabbix.frontend.install](#zabbixfrontendinstall)
* [zabbix.frontend.service](#zabbixfrontendservice)
* [zabbix.proxy.config](#zabbixproxyconfig)
* [zabbix.proxy.install](#zabbixproxyinstall)
* [zabbix.proxy.service](#zabbixproxyservice)
* [zabbix.server.config](#zabbixserverconfig)
* [zabbix.server.install](#zabbixserverinstall)
* [zabbix.server.service](#zabbixserverservice)

### zabbix.repo

Данный стейт настроит или удалит из системы официальный репозиторий Zabbix в зависимости от значения пиллара `zabbix:use_official_repo`.

### zabbix.user

Создание пользователя и группы `zabbix`, выполняется после установки пакетов, что позволяет установщику создать пользователя и группу до выполнения степйта.

### zabbix.agent

Мета стейт, отвечает за устновку Zabbix agent-а.

### zabbix.agent.config

Управляет конфигурационным файловм агента

### zabbix.agent.install

Отвечет за установку Zabbix агента

### zabbix.agent.service

Управляет состоянием службы Zabbix агента

### zabbix.agent2

Мета стейт, отвечает за устновку Zabbix agent-а.

### zabbix.agent2.config

Управляет конфигурационным файловм агента

### zabbix.agent2.install

Отвечет за установку Zabbix агента

### zabbix.agent2.service

Управляет состоянием службы Zabbix агента

### zabbix.db.mysql

Мета стейт по настройке БД MySQL

### zabbix.db.pgsql

Мета стейт по настройке БД PostgreSQL

### zabbix.db.pgsql.helper_pkgs

Стейт для установки вспомогательных пакетовы, необходимых Salt Stack для работы с PostgreSQL.

### zabbix.db.pgsql.prepare

Стейт для подготовки БД PostgreSQL, если включено в пилларах `zabbix:db:manage: true` - создаст пользователя и БД для Zabbix

### zabbix.db.pgsql.schema

Стейт отвечает за загрузку схемы в БД

### zabbix.frontend.config

Стейт для настройки zabbix-frontend

### zabbix.frontend.install

Стейт для установки zabbix-frontend

### zabbix.frontend.service

### zabbix.proxy.config

### zabbix.proxy.install

### zabbix.proxy.service

### zabbix.server.config

Стейт для настройки zabbix-server

### zabbix.server.install

Стейт для установки zabbix-server

### zabbix.server.service

Стейт для управления службой zabbix-server
