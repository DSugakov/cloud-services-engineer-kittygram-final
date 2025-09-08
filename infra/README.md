# Terraform инфраструктура для Kittygram

Этот репозиторий содержит Terraform конфигурацию для развертывания инфраструктуры приложения Kittygram в Yandex Cloud.

## Структура файлов

- `main.tf` - основные ресурсы инфраструктуры
- `variables.tf` - объявление переменных
- `outputs.tf` - выходные значения
- `providers.tf` - конфигурация провайдеров и backend
- `cloud-init.yml` - скрипт инициализации виртуальной машины
- `terraform.tfvars.example` - пример файла с переменными

## Создаваемые ресурсы

1. **VPC Network** - облачная сеть для приложения
2. **VPC Subnet** - подсеть с диапазоном 192.168.10.0/24
3. **Security Group** - группа безопасности с правилами:
   - SSH доступ (порт 22)
   - HTTP доступ к gateway (порт 9000)
   - HTTP доступ (порт 80) 
   - HTTPS доступ (порт 443)
   - Весь исходящий трафик разрешен
4. **Compute Instance** - виртуальная машина Ubuntu 24.04 LTS
5. **S3 Bucket** - бакет для хранения Terraform state

## Подготовка к развертыванию

### 1. Создание сервисного аккаунта

Создайте сервисный аккаунт в Yandex Cloud с ролями:
- `editor` - для управления ресурсами
- `storage.admin` - для работы с Object Storage

### 2. Создание S3 бакета

Сначала нужно создать S3 бакет для хранения Terraform state:

```bash
# Создайте бакет через веб-интерфейс Yandex Cloud или CLI
yc storage bucket create --name kittygram-terraform-state
```

### 3. Настройка переменных

Скопируйте файл с примером переменных:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Заполните значения в файле `terraform.tfvars`:

```hcl
cloud_id  = "b1g..."
folder_id = "b1g..."
service_account_key_file = "key.json"
storage_access_key = "AKIA..."
storage_secret_key = "your-secret-key"
```

### 4. Создание SSH ключа

Если у вас нет SSH ключа, создайте его:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

## Локальное развертывание

### Инициализация

```bash
cd infra
terraform init
```

### Планирование

```bash
terraform plan
```

### Применение изменений

```bash
terraform apply
```

### Уничтожение инфраструктуры

```bash
terraform destroy
```

## Развертывание через GitHub Actions

Workflow `terraform.yml` позволяет управлять инфраструктурой через GitHub Actions.

### Настройка secrets

Добавьте следующие secrets в GitHub репозиторий:

- `YC_CLOUD_ID` - ID облака
- `YC_FOLDER_ID` - ID папки
- `YC_SERVICE_ACCOUNT_KEY_FILE` - JSON ключ сервисного аккаунта
- `YC_STORAGE_ACCESS_KEY` - Access Key для S3
- `YC_STORAGE_SECRET_KEY` - Secret Key для S3

### Запуск workflow

1. Перейдите в раздел Actions в GitHub
2. Выберите workflow "Terraform Infrastructure"
3. Нажмите "Run workflow"
4. Выберите действие: plan, apply или destroy

## Outputs

После успешного развертывания будут доступны следующие outputs:

- `vm_external_ip` - внешний IP адрес виртуальной машины
- `vm_internal_ip` - внутренний IP адрес
- `vm_fqdn` - полное доменное имя
- `kittygram_url` - URL для доступа к приложению
- `security_group_id` - ID группы безопасности
- `network_id` - ID сети
- `subnet_id` - ID подсети

## Cloud-init

Виртуальная машина автоматически настраивается с помощью cloud-init скрипта, который:

- Обновляет систему
- Устанавливает Docker и Docker Compose
- Создает пользователя ubuntu с sudo правами
- Настраивает SSH доступ
- Создает рабочие директории
- Перезагружает систему

После развертывания виртуальная машина готова для деплоя приложения Kittygram.

## Особенности

- Используется прерываемая ВМ для экономии средств
- State файл хранится в S3 с версионированием
- Автоматическая установка Docker через cloud-init
- Группа безопасности настроена согласно требованиям приложения 

## Использование существующей VPC сети

Если квота на количество сетей в Yandex Cloud исчерпана или вы хотите развернуть инфраструктуру в уже существующей сети, укажите её ID в переменной `existing_network_id`. В этом случае Terraform не будет создавать новую сеть и использует указанную.

Пример в `terraform.tfvars`:

```hcl
existing_network_id = "enp**************"
```

Если `existing_network_id` не задан, Terraform создаст сеть `kittygram-network` автоматически.