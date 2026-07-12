# Adaptive App Shell

Готовая SwiftUI-оболочка приложения: на iPhone она использует нижний tab bar, а на iPad — sidebar и опциональный inspector. Навигационное состояние остаётся общим и не теряется при изменении размера окна.

![Adaptive App Shell](Assets/GIFs/adaptive-app-shell.gif)

## Что входит

- Системный `TabView` для компактной ширины
- `NavigationSplitView` для iPad и широких окон
- Независимая история навигации каждой вкладки
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

Inspector изначально закрыт, чтобы в portrait-режиме iPad не вытеснять sidebar. На широком экране он открывается системной кнопкой.

## Документация

- [Быстрый старт](Docs/GettingStarted.md)
- [Архитектура](Docs/Architecture.md)
- [Настройка](Docs/Customization.md)
- [App-owned state restoration](Docs/StateRestoration.md)
- [Доступность](Docs/Accessibility.md)
- [Проверка качества](Docs/QualityChecklist.md)

## Проверка

```bash
swift test

xcodebuild \
  -project Examples/AdaptiveShellDemo/AdaptiveShellDemo.xcodeproj \
  -scheme AdaptiveShellDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Лицензия: MIT.
