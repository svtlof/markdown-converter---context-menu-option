# Convert to Markdown

Утилита для конвертации файлов в Markdown через контекстное меню Windows.

## Что это делает

Добавляет пункт "Convert to Markdown" в контекстное меню файлов в проводнике Windows. При выборе этого пункта файл конвертируется в Markdown с помощью Claude API.

## Установка

### Быстрая установка

1. Скачайте проект:
```bash
git clone https://github.com/ваш-username/convert-to-markdown.git
cd convert-to-markdown
```

2. Запустите установщик:
```bash
install.bat
```

### Что происходит при установке

- Скрипты копируются в `%APPDATA%\ConvertToMarkdown`
- Добавляется пункт в контекстное меню через реестр Windows
- Создается ярлык для быстрого доступа к настройкам

## Использование

1. Кликните правой кнопкой мыши на любом файле
2. Выберите "Convert to Markdown"
3. Файл будет конвертирован с помощью Claude API

## Удаление

Запустите:
```bash
uninstall.bat
```

## Требования

- Windows 10 или выше
- PowerShell 5.1 или выше
- API ключ Claude (Anthropic)

## Конфигурация

API ключ и другие настройки хранятся в `%APPDATA%\ConvertToMarkdown\config.json`

## Лицензия

MIT
