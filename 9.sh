#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":hl:e:" opt; do
        case $opt in
            h)
                usage
                exit 0
                ;;
            l)
                LIST_FILE="$OPTARG"
                ;;
            e)
                ERR_FILE="$OPTARG"
                ;;
            \?)
                echo "Неправильный ключ: -$OPTARG" >&2
                usage
                exit 1
                ;;
        esac
    done
}

# Функция для удаления файлов
delete_files() {
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            rm "$file"
            echo "Файл удалён: $file"
        else
            echo "Файл не существует: $file" >&2
        fi
    done < "$LIST_FILE"
}

# Функция для вывода справочной информации
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-e FILE] -l LIST_FILE
-h          Показать эту помощь
-l LIST_FILE Файл со списком файлов для удаления
-e FILE     Перенаправить сообщения об ошибках в указанный файл
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие обязательного параметра
if [[ -z "$LIST_FILE" ]]; then
    echo "Не указан файл со списком файлов для удаления." >&2
    usage
    exit 1
fi

# Выполняем задачу
delete_files 2>"$ERR_FILE"
