# iME Weather 🌤️

> Full-stack Turkmenistan weather app — Flutter Liquid Glass mobile app (Direct Open-Meteo API out-of-the-box) + optional Node.js/Fastify caching proxy for VPS.

---

## ⚡ Режим работы приложения (Без сервера / С сервером)

Приложение **«iME Weather»** работает **в двух режимах**:

1. **Standalone / Прямой режим (ПО УМОЛЧАНИЮ):**
   - **Сервер / VPS НЕ ТРЕБУЕТСЯ!**
   - Мобильное приложение делает запросы **напрямую в Open-Meteo API** (`https://api.open-meteo.com/v1/forecast`).
   - Все 6 городов Туркменистана (Ашхабад, Мары, Туркменабат, Дашогуз, Балканабат, Туркменбаши) со своими точными координатами и названиями на 3 языках вшиты прямо в приложение.
   - Тестируйте на телефоне или эмуляторе (через VPN при необходимости).
   - Офлайн-кэш (Hive) сохраняет погоду на устройстве, чтобы приложение открывалось мгновенно.

2. **Proxy-режим (Для деплоя на собственный VPS в будущем):**
   - Включается установкой `kUseDirectOpenMeteo = false` в `mobile/lib/core/constants/api.dart` (или флагом `--dart-define=USE_DIRECT_API=false`).
   - Направляет запросы через Fastify-прокси с кэшированием на сервере.

---

## Project Structure

```
iME Weather/
├── mobile/           # Flutter app (iOS + Android) — работает независимо
├── backend/          # Node.js + Fastify proxy API (опционально для VPS)
├── deploy/           # VPS deploy scripts (Dockerfile, compose, bash, nginx)
└── README.md
```

---

## 1. Запуск мобильного приложения (Direct Mode)

### Требования
- Flutter SDK ≥ 3.19 (`flutter --version`)
- Эмулятор Android / iOS или физическое устройство
- Подключение к интернету / VPN (для доступа к `api.open-meteo.com`)

### Установка зависимостей и запуск

```bash
cd mobile

# 1. Скачать пакеты
flutter pub get

# 2. Сгенерировать локализацию (EN, RU, TK)
flutter gen-l10n

# 3. Запустить на подключенном устройстве/эмуляторе
flutter run
```

### Сборка релизного APK
```bash
cd mobile
flutter build apk --release
```

Файл будет готов в: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 2. Города Туркменистана в приложении

Все города зашиты локально в [`mobile/lib/cities/turkmenistan_cities.dart`](mobile/lib/cities/turkmenistan_cities.dart) и доступны сразу без сети:

| Город (RU) | Şäher (TK) | City (EN) | Широта (Lat) | Долгота (Lon) |
|---|---|---|---|---|
| **Ашхабад** | Aşgabat | Ashgabat | 37.9601 | 58.3261 |
| **Мары** | Mary | Mary | 37.6006 | 61.8311 |
| **Туркменабат** | Türkmenabat | Turkmenabat | 39.0833 | 63.5667 |
| **Дашогуз** | Daşoguz | Dashoguz | 41.8361 | 59.9639 |
| **Балканабат** | Balkanabat | Balkanabat | 39.5117 | 54.3694 |
| **Туркменбаши** | Türkmenbaşy | Turkmenbasy | 40.0000 | 52.9667 |

Также поддерживается **автоопределение по GPS** («Моё место» / «Meniň ýerim» / «My Location»).

---

## 3. Переключение между Direct API и VPS Proxy

Конфигурация находится в [`mobile/lib/core/constants/api.dart`](mobile/lib/core/constants/api.dart):

```dart
// По умолчанию true — запросы идут напрямую в open-meteo.com
const bool kUseDirectOpenMeteo = bool.fromEnvironment(
  'USE_DIRECT_API',
  defaultValue: true,
);

// Адрес вашего будущего VPS бэкенда
const String kCustomBackendBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://YOUR_VPS_IP:3000',
);
```

Если захотите переключиться на свой сервер без изменения кода:
```bash
flutter run --dart-define=USE_DIRECT_API=false --dart-define=API_BASE_URL=http://185.xxx.xxx.xxx:3000
```

---

## 4. Опционально: Бэкенд и деплой на VPS (когда появится сервер)

Код бэкенда полностью готов, протестирован (11/11 тестов) и ожидает деплоя в папке `backend/`.

### Локальное тестирование бэкенда:
```bash
cd backend
npm install
npm test      # запуск Jest тестов (11 passed)
npm start     # запуск на порту 3000
```

### Автоматический деплой на VPS:
1. Откройте `deploy/deploy.sh` и укажите `VPS_USER` и `VPS_HOST`.
2. Выполните:
   ```bash
   bash deploy/deploy.sh
   ```
3. Скрипт сам синхронизирует проект, соберет Docker-контейнер и проверит `/api/health`.

---

## 5. Возможности мобильного приложения

- 💎 **Liquid Glass UI (iOS Glassmorphism)**: Глубокое размытие `BackdropFilter` (22px), полупрозрачные карточки (`rgba(255, 255, 255, 0.15)`), тонкие светлые границы (25% opacity) и мягкие тени.
- 🎨 **Динамический фон в реальном времени**:
  - День (ясно): лазурный градиент со свечением солнца.
  - День (пасмурно/дождь): холодный серо-стальной градиент.
  - Ночь: глубокий индиго градиент с мерцающими звёздами и лунным свечением.
  - Анимированные переходы (1200ms) при смене погоды.
- 🕒 **Почасовой прогноз на 24 часа**: Горизонтальный скролл с отметкой текущего часа «Now».
- 📅 **7-дневный прогноз**: iOS-стиль с температурной градиентной полосой min/max.
- 📊 **Сетка параметров 2x2**: УФ-индекс (с цветовым статусом), Влажность, Ветер (км/ч), Ощущается как.
- 🌐 **3 языка локализации**:
  - Türkmen dili (TK)
  - Русский (RU)
  - English (EN)
  - Полный перевод всех 24 погодных кодов WMO.
- 💾 **Офлайн-кэш (Hive)**: Сохранение последнего успешного прогноза. Приложение открывается моментально даже без интернета, без белых экранов.

---

## License

MIT — iME Weather
