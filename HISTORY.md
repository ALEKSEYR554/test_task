# История разработки (LLM Chat History)

## Задание
Разработать API модуля трекера задач для медицинской информационной системы (МИС). Врачи и администраторы ставят себе рабочие задачи: провести операцию, связаться с клиентом, сделать обход пациентов и т.д.

## Этап 1: Анализ требований

### Исходные материалы
- `task.txt` — описание задачи с важными моментами реализации
- `task.pdf` — полное ТЗ (извлечено через PyPDF2)

### Ключевые требования
1. Базовая авторизация для множества пользователей за одним ПК
2. Теги для задач (глобальные обязательные + пользовательские)
3. Календарь с переключением неделя/месяц
4. Цветовая кодировка дней по тегам задач
5. Периодичность: ежедневная, ежемесячная, на конкретные даты, чётные/нечётные дни
6. REST API с Swagger документацией

### Уточнения с пользователем
- Теги: name, color, ссылки на другие таблицы (от categories отказались)
- Периодичность: все типы из PDF
- Требуемые теги: глобальные, с предопределёнными цветами
- Фронтенд: Rails views + Hotwire (не отдельное SPA)

---

## Этап 2: Инициализация проекта

### Выполнено
- Раскомментирован bcrypt в Gemfile
- Настроен PostgreSQL (username: postgres, password: ALEKSEYR554)
- Создана база данных и запущены миграции
- Создан admin пользователь и обязательные теги через seeds

### Проблемы и решения
- PostgreSQL на Windows требует явного указания username/password в database.yml
- PyPDF2 на Windows выдаёт ошибку cp932 — решение: запись в файл с UTF-8
- Rails 8.1 генерирует дублирующие маршруты — нужно чистить routes.rb после generate

---

## Этап 3: Реализация аутентификации

### Модель User
- `has_secure_password` (bcrypt)
- Поля: name, email, password_digest, role, auth_token
- Валидации: уникальность email, включение role в [admin, user]
- `auth_token` генерируется через `SecureRandom.hex(20)` при создании

### Контроллеры
- `SessionsController` — вход/выход через сессию
- `Admin::UsersController` — управление пользователями (только для admin)
- `ApplicationController` — хелперы `current_user`, `logged_in?`, `require_login`

---

## Этап 4: CRUD задач

### Модель Task
- Enum статусы: new, in_progress, completed, cancelled
- Enum типы: one_time, periodic
- Enum периодичность: daily, monthly, specific_dates, even_odd
- Скоупы: `for_date_range`, `for_status`

### Контроллер TasksController
- Фильтрация по диапазону дат и статусу
- Привязка тегов через `sync_tags`
- Обработка periodicity_config (JSONB): интервал, тип дней, список дат

---

## Этап 5: Система тегов

### Модель Tag
- `user_id` nullable для глобальных тегов
- `is_required` — флаг обязательных тегов
- Валидация: уникальность name в рамках user_id

### Обязательные теги (seed)
- отчетность (#FF6B6B)
- операции (#4ECDC4)
- звонок (#45B7D1)

### Защита
- Нельзя удалять/редактировать обязательные теги (проверка `required?`)

---

## Этап 6: Периодические задачи

### Архитектура
- Задача хранит **правило** периодичности (одна запись в БД)
- Вхождения генерируются «на лету» для запрошенного временного окна
- Каждое вхождение может иметь независимый статус через `periodic_exceptions`

### PeriodicTaskService
- `daily_occurrences` — каждые N дней
- `monthly_occurrences` — определённое число месяца
- `specific_dates_occurrences` — список конкретных дат
- `even_odd_occurrences` — чётные/нечётные числа месяца

### Управление вхождениями
- **Отмена**: создание `PeriodicException` со статусом `cancelled`
- **Редактирование**: создание новой разовой задачи + `PeriodicException` с `one_time_task_id`
- Предотвращение дублирования: отменённые и отсоединённые вхождения пропускаются

---

## Этап 7: Календарь

### Контроллер CalendarController
- Неделя: `beginning_of_week(:monday)` — начало с понедельника
- Месяц: стандартный网格 с пустыми ячейками
- Дневной вид: список задач, отсортированных по времени

### Особенности
- Каждый день окрашен в цвета тегов задач
- Тултипы на кружках тегов (название тега при наведении)
- Клик по задаче в календаре → дневной вид с возможностью отмены/редактирования вхождения

---

## Этап 8: API

### Эндпоинты
- `POST /api/v1/auth/token` — получение токена
- CRUD для tasks и tags в namespace `api/v1`

### Авторизация
- Токен-based: `Authorization: Bearer <auth_token>`
- `Api::BaseController` — пропуск CSRF, проверка токена

### Swagger (rswag)
- OpenAPI 3.0 спецификация в `swagger/v1/swagger.yaml`
- Доступ: `http://localhost:3000/api-docs`
- Поддержка Authorize для передачи токена

---

## Этап 9: Локализация

### Переведено на русский
- Весь интерфейс: навигация, формы, таблицы, flash-сообщения
- Метки статусов: Новая, В работе, Завершена, Отменена
- Метки типов: Разовая, Периодичная
- Метки периодичности: Ежедневная, Ежемесячная, На конкретные даты, Чётные/нечётные дни
- Дни недели: Пн, Вт, Ср, Чт, Пт, Сб, Вс
- Месяцы: Январь, Февраль, ..., Декабрь

---

## Этап 10: Docker

### Файлы
- `Dockerfile` — multi-stage сборка для продакшена
- `docker-compose.yml` — dev окружение с PostgreSQL 16 + healthcheck
- `config/database.yml` — поддержка переменных окружения
- `bin/docker-entrypoint` — автоматический `db:prepare` при старте

### Запуск
```bash
docker-compose up --build
```

---

## Исправленные ошибки

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `undefined method 'one_time'` | Enum с `prefix: true` создаёт `task_type_one_time?` | Добавленыvenience методы `periodic?`, `one_time?` |
| `undefined method 'periodic?'` | То же | Добавлен делегат на `task_type_periodic?` |
| `String can't be coerced into Integer` | interval из JSONB — строка | Добавлен `.to_i` |
| `Не авторизован` в Swagger | Нет схемы безопасности | Добавлен `securitySchemes` с bearerAuth |
| Теги не отображаются при редактировании | Turbo не перевыполняет JS | Добавлен обработчик `turbo:load` |
| Секунды в поле даты | `datetime_field` показывает секунды | Заменён на `datetime_local_field` |
| Дублирование в календаре | Отсоединённые вхождения показывались дважды | Фильтрация по `one_time_task_id` в `PeriodicException` |

---

## Файловая структура

```
app/
├── controllers/
│   ├── api/v1/
│   │   ├── auth_controller.rb
│   │   ├── base_controller.rb
│   │   ├── tasks_controller.rb
│   │   └── tags_controller.rb
│   ├── admin/users_controller.rb
│   ├── calendar_controller.rb
│   ├── periodic_occurrence_controller.rb
│   ├── sessions_controller.rb
│   ├── tasks_controller.rb
│   └── tags_controller.rb
├── models/
│   ├── user.rb
│   ├── task.rb
│   ├── tag.rb
│   ├── task_tag.rb
│   └── periodic_exception.rb
├── services/
│   └── periodic_task_service.rb
└── views/
    ├── layouts/application.html.erb
    ├── calendar/ (show, day)
    ├── tasks/ (index, show, new, edit, _form)
    ├── tags/ (index, show, new, edit, _form)
    ├── admin/users/ (index, show, new, edit, _form)
    ├── sessions/ (new)
    └── periodic_occurrence/ (edit)

config/
├── routes.rb
├── database.yml
└── initializers/rswag_*.rb

swagger/v1/swagger.yaml
db/seeds.rb
docker-compose.yml
Dockerfile
```
