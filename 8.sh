#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":hd:e:" opt; do
        case $opt in
            h)
                usage
                exit 0
                ;;
            d)
                DIR="$OPTARG"
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

# Функция для расчета общего размера файлов в подкаталоге
calculate_total_size() {
    local subdir="$1"
    local size=$(du -sb "$subdir" | awk '{print $1}')
    echo "$size $subdir"
}

# Функция для вывода справочной информации
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

# Находим все подкаталоги и сортируем их по размеру
find "$DIR" -mindepth 1 -maxdepth 1 -type d -exec bash -c 'calculate_total_size "$1"' _ {} \; |
sort -nr 2>"$ERR_FILE"
