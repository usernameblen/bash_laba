#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":he:d:h" opt; do
        case $opt in
            e)
                ERR_FILE="$OPTARG"
                ;;
            d)
                DIR="$OPTARG"
                ;;
            h)
                usage
                exit 0
                ;;
            \?)
                echo "Неправильный ключ: -$OPTARG" >&2
                usage
                exit 1
                ;;
        esac
    done
}

# Функция для подсчета количества строк
count_lines() {
    local total_lines=0
    for file in "$@"; do
        lines_in_file=$(wc -l < "$file")
        ((total_lines += lines_in_file))
    done
    echo "Всего строк: $total_lines"
}

# Функция помощи
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-e FILE] [-d DIR] ФАЙЛЫ...
-h          Показать эту помощь
-e FILE     Перенаправить сообщения об ошибках в указанный файл
-d DIR      Указать каталог для выполнения команды (по умолчанию текущий каталог)
ФАЙЛЫ...    Список файлов для подсчета строк
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие файлов
shift $(( OPTIND - 1 ))
if [[ $# == 0 ]]; then
    echo "Не указаны файлы для подсчета строк." >&2
    usage
    exit 1
fi

# Выполняем задачу
count_lines "$@" 2>"$ERR_FILE"
