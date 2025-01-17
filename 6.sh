#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":re:h" opt; do
        case $opt in
            r)
                REMOVE=true
                ;;
            e)
                ERR_FILE="$OPTARG"
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

# Функция для создания жесткой ссылки
create_link() {
    local file="$1"
    local ext=1
    local link_name="${file}.${ext}"

    while [[ -e "$link_name" && $ext -le 9 ]]; do
        ((ext++))
        link_name="${file}.${ext}"
    done

    if [[ $ext -le 9 ]]; then
        ln "$file" "$link_name"
        echo "Создана жесткая ссылка: $link_name"
    else
        echo "Максимум ссылок (.1-.9) достигнут для файла: $file" >&2
    fi
}

# Функция для удаления жестких ссылок
remove_links() {
    local file="$1"
    local ext=1
    local link_name="${file}.${ext}"

    while [[ -e "$link_name" && $ext -le 9 ]]; do
        rm "$link_name"
        echo "Удалена жесткая ссылка: $link_name"
        ((ext++))
        link_name="${file}.${ext}"
    done
}

# Функция помощи
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-e FILE] [-r] ФАЙЛЫ...
-h          Показать эту помощь
-r          Удалять жесткие ссылки с расширениями от .1 до .9
-e FILE     Перенаправить сообщения об ошибках в указанный файл
ФАЙЛЫ...    Список файлов для создания или удаления жестких ссылок
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие файлов
shift $(( OPTIND - 1 ))
if [[ $# == 0 ]]; then
    echo "Не указаны файлы для обработки." >&2
    usage
    exit 1
fi

# Выполнение задачи
if [[ -n "$REMOVE" ]]; then
    for file in "$@"; do
        remove_links "$file" 2>"$ERR_FILE"
    done
else
    for file in "$@"; do
        create_link "$file" 2>"$ERR_FILE"
    done
fi
