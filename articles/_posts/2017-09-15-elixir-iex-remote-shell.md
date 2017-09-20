---
title: Подключение к запущенному Elixir-приложению с помощью удалённой оболочки IEx
excerpt: Рассказываем о дебагинге через удалённое подключение к Эликсир-процессу.
author: nadezhda
source_url: http://joeellis.la/iex-remsh-shells/
source_title: Connect to Running Elixir Applications with IEx Remote Shell
source_author: Joe Ellis
tags: [debug]
cover: /assets/images/remote_shell.png
---

> Примечание: при использовании опции `--remsh` на локальном компьютере могут возникнуть проблемы безопасности, о которых лучше бы знать наперёд. Советую обратить внимание на последний пункт статьи, посвящённый данной проблеме.

Недавно я освоил одну любопытную встроенную в IEx опцию под названием `--remsh` (сокращение от «remote shell»). Она создаёт оболочку IEx в контексте Elixir-ноды, что позволяет проводить отладку и воспроизводить ошибки в уже запущенном приложении. Несмотря на своё название, `--remsh` может подключать IEx как к локальным, так и к удалённым нодам или приложениям. Сделать это можно, например, так:

```
# when running Elixir app on a server called example.com...
> iex --name "joe@iex_test" --cookie secret_cookie --remsh "node@example.com"

iex(node@example.com)1> Node.list
[:joe@iex_test]
```

`--remsh` работает в сочетании с двумя другими опциями: —name и —cookie. Первая — обязательная, создаёт оболочку IEx с именем для идентификации в других нодах кластера. Вторая — дополнительная, но обычно необходимая, представляет собой [cookie безопасности](http://erlang.org/doc/reference_manual/distributed.html#id88372) для доступа к ноде (обычно они находятся в корневом каталоге по адресу `~/.erlang.cookie`).

Для простоты использования можно также обернуть всё это в обычный bash-скрипт:

```bash
function reiex() {
 if [ $1 = "staging" ]; then
  iex --name "$(whoami)@reiex" --cookie secret_cookie --remsh "node@staging.example.com"
 elif [ $1 = "prod" ]; then
  iex --name "$(whoami)@reiex" --cookie secret_cookie --remsh "node@prod.example.com"
 else
  echo "Environment not found!"
 fi
}
```

Теперь, чтобы установить соединение с продакшн- или тестовым- серверами, достаточно лишь запустить `reiex <имя среды>`.

## Проблемы безопасности

Существуют некоторые последствия нарушения безопасности, о которых нужно знать, прежде чем пользоваться опцией `--remsh`. Помните, Elixir/Erlang ноды **имеют полный доступ ко всем другим нодам заданного кластера**. Поэтому, подключаясь к нему со своего компьютера через `--remsh`, вы предоставите другим нодам доступ к локальной рабочей станции и разрешите удалённый вызов процедур. Если подключиться с локального компьютера к удалённой ноде, которая подверглась атаке, ваши конфиденциальные данные, в том числе и SSH-ключи, станут доступны кому угодно.

Если вы планируете использовать `remsh` в каких-либо серьёзных проектах, рекомендую прочесть [статью Алекса Вебера](https://broot.ca/erlang-remsh-is-dangerous), где данная проблема рассматривается более подробно. Алекс также предлаегает более безопасное решение: сначала создать SSH-соединение с удалённым компьютером, а затем использовать `remsh` для локального подключения к ноде. Это как минимум предотвратит удалённый вызов процедур по отношению к рабочей станции и установит более безопасное соединение между компьютером и нодой.

Желаю удачного опыта с `--remsh`!