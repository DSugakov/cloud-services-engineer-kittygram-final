# Terraform Troubleshooting Guide

## Проблема: S3 Backend Authentication Error

### Описание ошибки
```
Error: error configuring S3 Backend: no valid credential sources for S3 Backend found.
Error: NoCredentialProviders: no valid providers in chain.
```

### Причина
Terraform использует S3-совместимый backend для Yandex Cloud Storage, но в шаге "Get outputs" не были установлены переменные окружения AWS, необходимые для аутентификации.

### Решение

#### 1. Исправление GitHub Actions Workflow
Добавлены переменные окружения AWS в шаг "Get outputs":

```yaml
- name: Get outputs
  if: ${{ github.event.inputs.action == 'apply' }}
  run: |
    echo "Получение outputs Terraform..."
    echo "VM External IP: $(terraform output -raw vm_external_ip)"
    echo "Kittygram URL: $(terraform output -raw kittygram_url)"
    echo "Outputs успешно получены"
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.YC_STORAGE_ACCESS_KEY }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.YC_STORAGE_SECRET_KEY }}
    AWS_DEFAULT_REGION: ru-central1
    AWS_S3_FORCE_PATH_STYLE: 'true'
```

#### 2. Исправление конфигурации Terraform Backend
Исправлено имя бакета в `infra/providers.tf`:

```hcl
backend "s3" {
  endpoint = "https://storage.yandexcloud.net"
  bucket = "kittygram-terraform-state"  # Исправлено с "ц"
  region = "ru-central1"
  key    = "tf-state.tfstate"

  skip_region_validation      = true
  skip_credentials_validation = true
}
```

#### 3. Улучшения DevOps практик
- Добавлен флаг `-upgrade` в `terraform init` для обновления провайдеров
- Добавлены информативные сообщения в логах
- Улучшена обработка ошибок

### Требуемые GitHub Secrets
Убедитесь, что в настройках репозитория установлены следующие secrets:

- `YC_SERVICE_ACCOUNT_KEY_FILE` - JSON ключ сервисного аккаунта Yandex Cloud
- `YC_CLOUD_ID` - ID облака Yandex Cloud
- `YC_FOLDER_ID` - ID папки Yandex Cloud
- `YC_STORAGE_ACCESS_KEY` - Access Key для Yandex Object Storage
- `YC_STORAGE_SECRET_KEY` - Secret Key для Yandex Object Storage
- `EXISTING_NETWORK_ID` - ID существующей сети (опционально)
- `EXISTING_SUBNET_ID` - ID существующей подсети (опционально)
- `EXISTING_SECURITY_GROUP_ID` - ID существующей группы безопасности (опционально)
- `EXISTING_INSTANCE_ID` - ID существующей ВМ (опционально)

### Проверка решения
После применения исправлений:
1. Запустите workflow с action "apply"
2. Проверьте, что шаг "Get outputs" выполняется без ошибок
3. Убедитесь, что выводятся корректные IP адреса и URL

### Дополнительные рекомендации
1. Используйте Terraform Cloud или другие state management решения для production
2. Настройте автоматическое обновление провайдеров
3. Добавьте проверки безопасности в CI/CD pipeline
4. Используйте least privilege принцип для сервисных аккаунтов
