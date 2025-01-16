#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":hs:e:o:d:" opt; do
        case $opt in
            s)
                SYMLINKS=true
                ;;
            e)
                ERR_FILE="$OPTARG"
                ;;
            o)
                OUTPUT_DIR="$OPTARG"
                ;;
            d)
                SEARCH_DIR="$OPTARG"
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

# Функция для поиска файлов с заданной строкой
find_files_with_string() {
    grep -rl "$SEARCH_STRING" "$SEARCH_DIR" | while read file; do
        if [[ -f "$file" ]]; then
            create_link "$file"
        fi
    done
}

# Функция для создания ссылки
create_link() {
    local file="$1"
    local link_type="ln"
    if [[ -n "$SYMLINKS" ]]; then
        link_type="ln -s"
    fi
    $link_type "$file" "$OUTPUT_DIR/${file##*/}" 2>"$ERR_FILE"
    echo "Создана ссылка: ${file##*/}"
}

# Функция помощи
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-e FILE] [-s] [-o DIR] -d DIR STRING
-h          Показать эту помощь
-s          Создавать символические ссылки вместо жёстких
-e FILE     Перенаправить сообщения об ошибках в указанный файл
-o DIR      Директория для размещения ссылок (по умолчанию текущая)
-d DIR      Каталог для поиска файлов
STRING      Строка для поиска в файлах
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие обязательных параметров
if [[ -z "$SEARCH_DIR" || -z "$SEARCH_STRING" ]]; then
    echo "Не указаны обязательные параметры: каталог для поиска (-d) и строка для поиска." >&2
    usage
    exit 1
fi

# Устанавливаем переменные
SEARCH_STRING="$*"
SEARCH_STRING=${SEARCH_STRING%$SEARCH_DIR*}
SEARCH_STRING=${SEARCH_STRING#*-d }

# Если каталог для ссылок не указан, используем текущий
if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR=$PWD
fi

# Выполняем задачу
find_files_with_string 2>"$ERR_FILE"
