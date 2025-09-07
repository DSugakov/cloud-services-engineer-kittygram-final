#!/usr/bin/env python3
"""
Скрипт для диагностики содержимого секрета YC_SERVICE_ACCOUNT_KEY_FILE
"""
import json
import re
import sys

def analyze_secret():
    print("=== ДИАГНОСТИКА СЕКРЕТА YC_SERVICE_ACCOUNT_KEY_FILE ===")
    print()
    
    # Получаем содержимое из переменной окружения
    secret_content = input("Вставьте содержимое секрета и нажмите Enter: ")
    
    if not secret_content:
        print("Ошибка: Секрет пустой")
        return
    
    print(f"Длина секрета: {len(secret_content)} символов")
    print()
    
    # Показываем первые 200 символов
    print("Первые 200 символов:")
    print(repr(secret_content[:200]))
    print()
    
    # Показываем последние 200 символов
    print("Последние 200 символов:")
    print(repr(secret_content[-200:]))
    print()
    
    # Анализируем проблемные символы
    print("Анализ проблемных символов:")
    for i, char in enumerate(secret_content):
        if ord(char) < 32 and char not in '\n\r\t':
            print(f"  Позиция {i}: недопустимый символ {repr(char)} (код {ord(char)})")
        elif ord(char) > 126:
            print(f"  Позиция {i}: не-ASCII символ {repr(char)} (код {ord(char)})")
    
    print()
    
    # Пытаемся найти JSON структуру
    print("Поиск JSON полей:")
    fields = [
        'service_account_id',
        'id', 
        'private_key',
        'public_key',
        'created_at'
    ]
    
    for field in fields:
        pattern = rf'"{field}":\s*"([^"]*)"'
        match = re.search(pattern, secret_content)
        if match:
            value = match.group(1)
            print(f"  {field}: найдено (длина: {len(value)})")
            if field == 'private_key':
                # Показываем начало и конец private_key
                print(f"    Начало: {repr(value[:50])}")
                print(f"    Конец: {repr(value[-50:])}")
                # Проверяем на проблемные символы
                problem_chars = [c for c in value if ord(c) < 32 and c not in '\n\r\t']
                if problem_chars:
                    print(f"    Проблемные символы: {set(problem_chars)}")
        else:
            print(f"  {field}: НЕ найдено")
    
    print()
    
    # Пытаемся исправить JSON
    print("Попытка исправления JSON:")
    try:
        # Очищаем управляющие символы
        cleaned = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', secret_content)
        
        # Парсим JSON
        data = json.loads(cleaned)
        print("  ✅ JSON валиден после очистки управляющих символов")
        
        # Сохраняем исправленный JSON
        with open('fixed_key.json', 'w') as f:
            json.dump(data, f, indent=2)
        print("  ✅ Исправленный JSON сохранен в fixed_key.json")
        
    except json.JSONDecodeError as e:
        print(f"  ❌ JSON невалиден: {e}")
        print(f"  Позиция ошибки: {e.pos}")
        print(f"  Проблемный фрагмент: {repr(cleaned[max(0, e.pos-50):e.pos+50])}")
        
        # Пытаемся радикальную очистку
        try:
            ultra_cleaned = re.sub(r'[^\x20-\x7E\n\r\t]', '', secret_content)
            data = json.loads(ultra_cleaned)
            print("  ✅ JSON валиден после радикальной очистки")
            
            with open('ultra_fixed_key.json', 'w') as f:
                json.dump(data, f, indent=2)
            print("  ✅ Радикально исправленный JSON сохранен в ultra_fixed_key.json")
            
        except json.JSONDecodeError as e2:
            print(f"  ❌ Радикальная очистка не помогла: {e2}")

if __name__ == '__main__':
    analyze_secret()
