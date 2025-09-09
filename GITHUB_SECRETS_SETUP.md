# Настройка секретов для GitHub Actions

Для корректной работы Terraform workflow необходимо настроить следующие секреты в GitHub репозитории:

## Необходимые секреты

### 1. Yandex Cloud секреты
- `YC_CLOUD_ID` - ID вашего облака в Yandex Cloud
- `YC_FOLDER_ID` - ID папки в облаке
- `YC_KEY_JSON` - JSON ключ сервисного аккаунта (в base64 формате)

### 2. Object Storage секреты
- `YC_ACCESS_KEY` - Access Key для S3 бакета
- `YC_SECRET_KEY` - Secret Key для S3 бакета

### 3. SSH ключ
- `SSH_KEY` - содержимое публичного SSH ключа (без имени файла)

## Как добавить секреты

1. Перейдите в ваш GitHub репозиторий
2. Нажмите на вкладку "Settings"
3. В левом меню выберите "Secrets and variables" → "Actions"
4. Нажмите "New repository secret"
5. Добавьте каждый секрет по отдельности

## Получение значений

### YC_CLOUD_ID и YC_FOLDER_ID
```bash
yc config list
```

### Сервисный аккаунт
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

# Конвертация в base64 для GitHub секрета
base64 -i key.json
```

### Object Storage ключи
```bash
# Создание статического ключа
yc iam access-key create --service-account-name terraform-sa
```

### SSH ключ
```bash
# Если у вас нет SSH ключа
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Скопируйте содержимое публичного ключа
cat ~/.ssh/id_rsa.pub
```

## Проверка настройки

После добавления всех секретов:
1. Перейдите в раздел Actions
2. Выберите workflow "Terraform Infrastructure"
3. Нажмите "Run workflow"
4. Выберите действие "plan"
5. Убедитесь, что workflow выполняется без ошибок
