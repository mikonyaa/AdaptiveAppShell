# Adaptive App Shell

SwiftUI-оболочка приложения: на iPhone она использует нижний tab bar, а на iPad — sidebar и опциональный inspector. Каждая вкладка хранит свой typed route path в общем app-owned состоянии.

![Adaptive App Shell](Assets/GIFs/adaptive-app-shell.gif)

## Что входит

- Системный `TabView` для компактной ширины
- `NavigationSplitView` для iPad и широких окон
- Независимая история навигации каждой вкладки
- Реакция на добавление, удаление, скрытие и перестановку разделов
- Sidebar-only коллекции без перегруженного tab bar
- Контекстный inspector
- Enum-маршруты для deep links
- Нативный Liquid Glass на iOS 26
- Спокойный fallback для iOS 17–25
- Dynamic Type, VoiceOver и режимы повышенной контрастности
- Три профессиональные темы без градиентов: Classic, Graphite и Stone

## Запуск

Откройте в Xcode:

```text
Examples/AdaptiveShellDemo/AdaptiveShellDemo.xcodeproj
```

Выберите схему `AdaptiveShellDemo` и запустите её на iPhone или iPad Simulator.

## Подключение

Добавьте папку проекта как Local Package, импортируйте модуль и создайте:

1. Enum вкладок.
2. Enum маршрутов.
3. `AdaptiveShellState` в корневом View.
4. Массив `AdaptiveShellSection`.
5. `AdaptiveAppShell` с feature-контентом и destination closure.

Для iPhone используйте не больше пяти элементов с `.tab`. Дополнительные коллекции помечайте `.hidden`: они появятся только в sidebar.

## Почему архитектура устроена так

Shell управляет только presentation и навигацией. Он не знает о сети, базе данных или бизнес-моделях приложения. Благодаря этому шаблон можно перенести в другой проект без удаления демонстрационной архитектуры.

Каждая вкладка получает отдельный route path. Если пользователь открыл detail внутри Projects, перешёл в Search и вернулся, Projects останется на прежнем экране.

Inspector опционален и управляется системной кнопкой. Настройка **Keep inspector open** открывает его при переходе в проект; выключенная настройка позволяет управлять им вручную.

При изменении разделов shell сохраняет допустимый выбор. Если выбранный ID удалён или скрыт в compact, выбирается первый доступный элемент. Пустая конфигурация показывает **No destinations**. Paths удалённых и временно скрытых элементов сохраняются до явной очистки приложением; для повторяющихся ID используется первое вхождение. Публичные initializer’ы сохранены.

В Studio demo кнопка **New project** валидирует название, создаёт локальный проект и открывает его детали. Overview, Projects и Search открывают выбранный проект и в compact, и в regular, независимо от inspector. Tasks, progress и inspector читают один `StudioStore`. Поиск сохраняет query и scope в app-owned состоянии; пустой запрос показывает все данные выбранной категории. Проекты и настройки действуют только в текущей сессии окна.

`adaptiveshell://project/website-qa` открывает известный проект. Неизвестный ID или malformed URL показывает сообщение и сохраняет текущую историю, без подстановки другого fixture.

Требования: Swift 6, Xcode 16.4+, iOS 17+, macOS 14+. Xcode 26+ также собирает ветку с native Liquid Glass. В CI закреплены XcodeGen 2.45.4 и SwiftLint 0.65.0.

## Документация

- [Быстрый старт](Docs/GettingStarted.md)
- [Архитектура](Docs/Architecture.md)
- [Настройка](Docs/Customization.md)
- [App-owned state restoration](Docs/StateRestoration.md)
- [Доступность](Docs/Accessibility.md)
- [Проверка качества](Docs/QualityChecklist.md)
- [Полный demo walkthrough](Examples/AdaptiveShellDemo/README.md)
- [Правила конфигурации и migration](Docs/Migration-1.0.4.md)
- [Проверки и оставшиеся device gates](Docs/Validation.md)

## Проверка

```bash
swift test
swiftlint lint --strict

xcodebuild \
  -project Examples/AdaptiveShellDemo/AdaptiveShellDemo.xcodeproj \
  -scheme AdaptiveShellDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build

Scripts/run_ui_tests.sh iphone
Scripts/run_ui_tests.sh ipad
```

UI-проверки используют собственные временные симуляторы и отдельный consumer, импортирующий только публичный продукт. Проверки на физических устройствах, VoiceOver, hardware keyboard, Stage Manager и реальный adoption pilot отмечаются отдельно; generic build их не заменяет.

Лицензия: MIT.
