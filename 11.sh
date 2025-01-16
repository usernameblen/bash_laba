#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":hm:Mug:G" opt; do
        case $opt in
            h)
                usage
                exit 0
                ;;
            m)
                DEFAULT_MODE="$OPTARG"
                ;;
            M)
                NEW_MODE="$OPTARG"
                ;;
            u)
                DEFAULT_USER="$OPTARG"
                ;;
            U)
                NEW_USER="$OPTARG"
                ;;
            g)
                DEFAULT_GROUP="$OPTARG"
                ;;
            G)
                NEW_GROUP="$OPTARG"
                ;;
            \?)
                echo "Неправильный ключ: -$OPTARG" >&2
                usage
                exit 1
                ;;
        esac
    done
}

# Функция для чтения и обработки файла
process_file() {
    local path="$1"
    local mode="$2"
    local user="$3"
    local group="$4"

    if [[ -z "$mode" ]]; then
        mode="0644"
    fi
    if [[ -z "$user" ]]; then
        user=$(whoami)
    fi
    if [[ -z "$group" ]]; then
        group=$(id -gn)
    fi

    chmod "$mode" "$path"
    chown "$user:$group" "$path"
}

# Функция для вывода справочной информации
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-m MODE] [-M MODE] [-u USER] [-U USER] [-g GROUP] [-G GROUP] FILE
-h          Показать эту помощь
-m MODE     Установить права доступа по умолчанию на MODE
-M MODE     Применить права доступа MODE ко всем файлам
-u USER     Установить пользователя по умолчанию на USER
-U USER     Применить пользователя USER ко всем файлам
-g GROUP    Установить группу по умолчанию на GROUP
-G GROUP    Применить группу GROUP ко всем файлам
FILE        Файл с описанием файлов и прав доступа
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие файла
if [[ -z "$CONFIG_FILE" ]]; then
    echo "Не указан файл с настройками." >&2
    usage
    exit 1
fi

# Устанавливаем значения по умолчанию
DEFAULT_MODE=${DEFAULT_MODE:-0644}
DEFAULT_USER=${DEFAULT_USER:-$(whoami)}
DEFAULT_GROUP=${DEFAULT_GROUP:-$(id -gn)}

NEW_MODE=${NEW_MODE:-$DEFAULT_MODE}
NEW_USER=${NEW_USER:-$DEFAULT_USER}
NEW_GROUP=${NEW_GROUP:-$DEFAULT_GROUP}

# Открываем файл и обрабатываем каждую строку
while IFS=' :' read -r line; do
    IFS=' '
    read -ra params <<< "$line"
    if [[ -z "$params" ]]; then
        continue
    fi
    process_file "${params[0]}" "${params[1]}" "${params[2]}" "${params[3]}"
done < "$CONFIG_FILE"

echo "Все файлы были обработаны."
