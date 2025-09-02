# Руководство по развертыванию инфраструктуры Kittygram

Это руководство описывает процесс развертывания инфраструктуры для приложения Kittygram с использованием Terraform и GitHub Actions.

## 🏗️ Архитектура инфраструктуры

### Создаваемые ресурсы:
1. **VPC Network** - облачная сеть для изоляции ресурсов
2. **VPC Subnet** - подсеть с диапазоном 192.168.10.0/24
3. **Security Group** - группа безопасности с правилами:
   - SSH доступ (порт 22)
   - HTTP доступ к gateway (порт 9000)
   - HTTP доступ (порт 80)
   - HTTPS доступ (порт 443)
   - Весь исходящий трафик разрешен
4. **Compute Instance** - виртуальная машина Ubuntu 24.04 LTS
5. **S3 Bucket** - бакет для хранения Terraform state

### Особенности:
- Используется прерываемая ВМ для экономии средств
- Автоматическая установка Docker и Docker Compose через cloud-init
- State файл хранится в S3 с версионированием
- Автоматическая настройка через cloud-init скрипт

## 🚀 Быстрый старт

### 1. Подготовка Yandex Cloud

#### Создание сервисного аккаунта:
```bash
# Создание сервисного аккаунта
yc iam service-account create --name terraform-sa

# Назначение ролей
yc resource-manager folder add-access-binding <folder-id> \
  --role editor \
  --subject serviceAccount:<service-account-id>

yc resource-manager folder add-access-binding <folder-id> \
  --role storage.admin \
  --subject serviceAccount:<service-account-id>

# Создание ключа
yc iam key create --service-account-name terraform-sa -o key.json
```

#### Создание статического ключа для Object Storage:
```bash
yc iam access-key create --service-account-name terraform-sa
```

#### Получение ID облака и папки:
```bash
yc config list
```

### 2. Настройка GitHub Secrets

Добавьте следующие секреты в ваш GitHub репозиторий:

1. **YC_CLOUD_ID** - ID вашего облака
2. **YC_FOLDER_ID** - ID папки в облаке  
3. **YC_SERVICE_ACCOUNT_KEY_FILE** - содержимое JSON ключа сервисного аккаунта
4. **YC_STORAGE_ACCESS_KEY** - Access Key для S3
5. **YC_STORAGE_SECRET_KEY** - Secret Key для S3
6. **SSH_PUBLIC_KEY** - содержимое публичного SSH ключа

### 3. Развертывание инфраструктуры

1. Перейдите в раздел Actions в GitHub
2. Выберите workflow "Terraform Infrastructure"
3. Нажмите "Run workflow"
4. Выберите действие:
   - **plan** - просмотр плана изменений
   - **apply** - создание инфраструктуры
   - **destroy** - удаление инфраструктуры

## 📋 Пошаговое развертывание

### Шаг 1: Планирование (Plan)
```bash
# В GitHub Actions выберите "plan"
# Это покажет, какие ресурсы будут созданы
```

### Шаг 2: Создание инфраструктуры (Apply)
```bash
# В GitHub Actions выберите "apply"
# Будет создана вся инфраструктура
```

### Шаг 3: Деплой приложения
После успешного создания инфраструктуры:
1. Запустите основной workflow для деплоя приложения
2. Приложение будет автоматически развернуто на созданной ВМ

## 🔧 Конфигурация

### Terraform файлы:
- `infra/main.tf` - основные ресурсы инфраструктуры
- `infra/variables.tf` - объявление переменных
- `infra/outputs.tf` - выходные значения
- `infra/providers.tf` - конфигурация провайдеров и backend
- `infra/cloud-init.yml` - скрипт инициализации ВМ

### Backend конфигурация:
```hcl
backend "s3" {
  endpoints = {
    s3 = "https://storage.yandexcloud.net"
  }
  bucket = "kittygram-terraform-state-158160191213"
  region = "ru-central1"
  key    = "tf-state.tfstate"

  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_s3_checksum            = true
}
```

## 🐳 Cloud-init конфигурация

Виртуальная машина автоматически настраивается с помощью cloud-init:

- Обновление системы
- Установка Docker и Docker Compose
- Создание пользователя ubuntu с sudo правами
- Настройка SSH доступа
- Создание рабочих директорий
- Перезагрузка системы

## 📊 Мониторинг и управление

### Просмотр outputs:
После успешного развертывания будут доступны:
- `vm_external_ip` - внешний IP адрес ВМ
- `kittygram_url` - URL для доступа к приложению
- `s3_bucket_name` - имя S3 бакета

### Управление через Terraform:
```bash
# Просмотр состояния
terraform show

# Просмотр outputs
terraform output

# Обновление инфраструктуры
terraform plan
terraform apply
```

## 🧹 Очистка

### Удаление инфраструктуры:
1. В GitHub Actions выберите "destroy"
2. Подтвердите удаление
3. Все ресурсы будут удалены

### Ручное удаление:
```bash
cd infra
terraform destroy
```

## 🔍 Устранение неполадок

### Частые проблемы:

1. **Ошибка "Variables not allowed" в backend**
   - Убедитесь, что в `providers.tf` нет `var.*` в блоке backend
   - Используйте переменные окружения или `-backend-config`

2. **Ошибка аутентификации**
   - Проверьте правильность секретов в GitHub
   - Убедитесь, что сервисный аккаунт имеет необходимые роли

3. **Ошибка создания S3 бакета**
   - Проверьте права на Object Storage
   - Убедитесь, что имя бакета уникально

### Логи и отладка:
- Проверьте логи в GitHub Actions
- Используйте `terraform plan` для диагностики
- Проверьте статус ресурсов в Yandex Cloud Console

## 📚 Дополнительные ресурсы

- [Terraform документация](https://www.terraform.io/docs)
- [Yandex Cloud Terraform провайдер](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart)
- [Cloud-init документация](https://cloudinit.readthedocs.io/)

## 🆘 Поддержка

При возникновении проблем:
1. Проверьте логи GitHub Actions
2. Убедитесь в корректности всех секретов
3. Проверьте права сервисного аккаунта
4. Обратитесь к документации Yandex Cloud
