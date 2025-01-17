#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":he:d:f:h" opt; do
        case $opt in
            e)
                ERR_FILE="$OPTARG"
                ;;
            d)
                DIR="$OPTARG"
                ;;
            f)
                FILE_NAME="$OPTARG"
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

# Функция для поиска файла в подкаталогах
find_file_in_dirs() {
    local found_dirs=()
    for dir in "$DIR"/*; do
        if [[ -d "$dir" ]]; then
            if [[ -f "$dir/$FILE_NAME" ]]; then
                found_dirs+=("$dir")
            else
                find_file_in_dirs "$dir"
            fi
        fi
    done
    echo "${found_dirs[@]}"
}

# Функция помощи
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-e FILE] [-d DIR] -f FILE_NAME
-h          Показать эту помощь
-e FILE     Перенаправить сообщения об ошибках в указанный файл
-d DIR      Указать начальный каталог для поиска (по умолчанию текущий каталог)
-f FILE_NAME Имя файла, который нужно найти
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие имени файла
if [[ -z "$FILE_NAME" ]]; then
    echo "Не указано имя файла для поиска." >&2
    usage
    exit 1
fi

# Если каталог не был передан, используем текущий
if [[ -z "$DIR" ]]; then
    DIR=$PWD
fi

# Выполняем задачу
find_file_in_dirs 2>"$ERR_FILE"
