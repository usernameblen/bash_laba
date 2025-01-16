#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":hw:e:d:" opt; do
        case $opt in
            w)
                WORD_COUNT="$OPTARG"
                ;;
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

# Функция для проверки количества слов в файле
check_words() {
    local file_path="$1"
    local word_count=$(wc -w < "$file_path")
    if [[ $word_count -gt $WORD_COUNT ]]; then
        echo "$file_path"
    fi
}

# Функция помощи
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-e FILE] [-w COUNT] ДИРЕКТОРИИ...
-h          Показать эту помощь
-w COUNT    Минимальное количество слов в файле
-e FILE     Перенаправить сообщения об ошибках в указанный файл
ДИРЕКТОРИИ... Каталоги для проверки
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие директорий
shift $(( OPTIND - 1 ))
if [[ $# == 0 ]]; then
    echo "Не указаны каталоги для проверки." >&2
    usage
    exit 1
fi

# Проверяем наличие минимального количества слов
if [[ -z "$WORD_COUNT" ]]; then
    echo "Не указано минимальное количество слов." >&2
    usage
    exit 1
fi

# Проходим по каждому каталогу
for directory in "$@"; do
    find "$directory" -type f -exec bash -c 'check_words "$1"' _ {} \; 2>"$ERR_FILE"
done
