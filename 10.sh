#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":hp:m:u:g:a" opt; do
        case $opt in
            h)
                usage
                exit 0
                ;;
            p)
                DEFAULT_PATH="$OPTARG"
                ;;
            m)
                DEFAULT_MODE="$OPTARG"
                ;;
            u)
                DEFAULT_USER="$OPTARG"
                ;;
            g)
                DEFAULT_GROUP="$OPTARG"
                ;;
            a)
                AUTOMATION=true
                ;;
            \?)
                echo "Неправильный ключ: -$OPTARG" >&2
                usage
                exit 1
                ;;
        esac
    done
}

# Функция для получения данных от пользователя
get_user_input() {
    read -p "$1: " value
    echo "${value:-$DEFAULT_VALUE}"
}

# Функция для сохранения настроек в файл
save_settings() {
    echo "$FILE_PATH : $MODE : $USER : $GROUP" >> "$CONFIG_FILE"
}

# Функция для вывода справочной информации
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-p PATH] [-m MODE] [-u USER] [-g GROUP] [-a] DIR
-h          Показать эту помощь
-p PATH     Изменить путь по умолчанию на указанный после ключа
-m MODE     Изменить права доступа по умолчанию на указанные после ключа
-u USER     Изменить пользователя по умолчанию на указанного после ключа
-g GROUP    Изменить группу по умолчанию на указанную после ключа
-a          Автоматически принимать значения по умолчанию
DIR         Каталог, для которого собираются настройки
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие обязательного параметра
if [[ -z "$CONFIG_DIR" ]]; then
    echo "Не указан каталог для сбора настроек." >&2
    usage
    exit 1
fi

# Если файл конфигурации не был передан, используем значение по умолчанию
if [[ -z "$CONFIG_FILE" ]]; then
    CONFIG_FILE=".install-config"
fi

# Устанавливаем значения по умолчанию
DEFAULT_PATH=${DEFAULT_PATH:-$HOME}
DEFAULT_MODE=${DEFAULT_MODE:-0644}
DEFAULT_USER=${DEFAULT_USER:-$(whoami)}
DEFAULT_GROUP=${DEFAULT_GROUP:-$(id -gn)}

# Проходим по всем файлам в каталоге
for FILE in "$CONFIG_DIR"/*; do
    if [[ -f "$FILE" ]]; then
        if [[ -z "$AUTOMATION" ]]; then
            echo "Пожалуйста, введите следующие настройки для файла $FILE:"
            FILE_PATH=$(get_user_input "Конечный каталог ($DEFAULT_PATH)")
            MODE=$(get_user_input "Права доступа ($DEFAULT_MODE)")
            USER=$(get_user_input "Имя пользователя ($DEFAULT_USER)")
            GROUP=$(get_user_input "Группа ($DEFAULT_GROUP)")
        else
            FILE_PATH=$DEFAULT_PATH
            MODE=$DEFAULT_MODE
            USER=$DEFAULT_USER
            GROUP=$DEFAULT_GROUP
        fi
        
        save_settings
    fi
done

echo "Настройки успешно сохранены в $CONFIG_FILE."
