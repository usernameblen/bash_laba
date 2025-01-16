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

# Функция для подсчета количества файлов
count_files() {
    local total_files=0
    for file in "$DIR"/*; do
        if [[ -f "$file" ]]; then
            ((total_files++))
        elif [[ -d "$file" ]]; then
            count_files "$file"
        fi
    done
    echo "Всего файлов: $total_files"
}

# Функция помощи
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-e FILE] [-d DIR]
-h          Показать эту помощь
-e FILE     Перенаправить сообщения об ошибках в указанный файл
-d DIR      Указать каталог для выполнения команды (по умолчанию текущий каталог)
EOF
}

# Парсим аргументы
parse_args "$@"

# Если каталог не был передан, используем текущий
if [[ -z "$DIR" ]]; then
    DIR=$PWD
fi

# Выполняем задачу
count_files 2>"$ERR_FILE"
