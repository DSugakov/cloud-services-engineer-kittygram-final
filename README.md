#  Проект Kittygram: Деплой с использованием CI/CD

## Описание проекта

Kittygram — это веб-приложение для любителей кошек, позволяющее пользователям делиться фотографиями своих питомцев. Проект состоит из бэкенда на Django, фронтенда на React и использует Nginx в качестве веб-сервера и прокси.

## Архитектура проекта

Приложение разделено на несколько контейнеров:
- **backend** — Django-приложение с REST API
- **frontend** — React-приложение с пользовательским интерфейсом
- **gateway** — Nginx-сервер, который маршрутизирует запросы между фронтендом и бэкендом
- **postgres** — База данных PostgreSQL

## Настройка и запуск проекта

### Локальный запуск

1. Клонируйте репозиторий:
```bash
git clone git@github.com:ваш-логин/cloud-services-engineer-kittygram-final.git
cd cloud-services-engineer-kittygram-final
```

2. Создайте файл `.env` на основе примера `.env.example`:
```bash
cp _env.example .env
```

3. Запустите контейнеры:
```bash
docker-compose up -d
```

4. Выполните миграции и соберите статические файлы:
```bash
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py collectstatic --noinput
```

### Продакшн-запуск

Для продакшна используется файл `docker-compose.production.yml`. CI/CD процесс автоматически деплоит приложение на сервер при пуше в ветку `main`.

## CI/CD процесс

Проект настроен на автоматический деплой с помощью GitHub Actions. Workflow включает следующие этапы:

1. **Тестирование**:
   - Настройка тестовой базы данных PostgreSQL в контейнере
   - Проверка кода бэкенда с помощью flake8
   - Запуск Django тестов для проверки функциональности
   - Отдельные тесты для фронтенда на Node.js

2. **Сборка и публикация Docker-образов**:
   - Раздельная сборка образов для бэкенда, фронтенда и gateway
   - Публикация образов в Docker Hub с тегами `latest` и `build-{номер сборки}`
   - Использование Docker Buildx для оптимизации процесса сборки

3. **Деплой на сервер**:
   - Создание файла с информацией о сборке (.build_info)
   - Копирование необходимых файлов на сервер через SCP
   - Автоматическая очистка системы для освобождения ресурсов
   - Запуск контейнеров с последовательным выполнением операций
   - Применение миграций и сбор статики
   - Проверка статуса контейнеров после деплоя

4. **Уведомление**:
   - Отправка детального уведомления в Telegram о успешном деплое
   - Включение информации о номере сборки, коммите и авторе изменений

## Улучшения в CI/CD

В текущей версии CI/CD процесса реализованы следующие улучшения:

1. **Версионирование образов**:
   - Каждый образ тегируется номером сборки для возможности отката
   - Информация о сборке сохраняется на сервере в файле `.build_info`

2. **Расширенная очистка системы**:
   - Автоматическое удаление неиспользуемых Docker-образов (prune)
   - Очистка кэша npm и apt для оптимизации использования диска
   - Компактирование системных журналов (journalctl)

3. **Детальные уведомления**:
   - Расширенная информация в Telegram-уведомлениях с эмодзи
   - Включение ссылки на коммит для быстрого доступа к изменениям

4. **Надежное SSH-подключение и деплой**:
   - Использование специализированных действий `appleboy/scp-action` для копирования файлов
   - Применение `appleboy/ssh-action` с поддержкой passphrase для выполнения удаленных команд
   - Детальное логирование каждого этапа деплоя для простоты отладки
   - Сохранение и отображение информации о сборке на сервере

## Как проверить работу с помощью автотестов

В корне репозитория создайте файл tests.yml со следующим содержимым:
```yaml
repo_owner: ваш_логин_на_гитхабе
kittygram_domain: полная ссылка (http://<ip-адрес вашей ВМ>) на ваш проект Kittygram
dockerhub_username: ваш_логин_на_докерхабе
```

Для локального запуска тестов создайте виртуальное окружение, установите в него зависимости из backend/requirements.txt и запустите в корневой директории проекта `pytest`.

## Чек-лист для проверки перед отправкой задания

- Проект Kittygram доступен по ссылке, указанной в `tests.yml`.
- Пуш в ветку main запускает тестирование и деплой Kittygram, а после успешного деплоя приходит сообщение в телеграм.
- В корне проекта есть актуальная версия `kittygram_workflow.yml`.
