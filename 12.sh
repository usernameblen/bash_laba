#!/bin/bash

# Функция для обработки аргументов
parse_args() {
    while getopts ":hs:" opt; do
        case $opt in
            h)
                usage
                exit 0
                ;;
            s)
                SIGNAL="$OPTARG"
                ;;
            \?)
                echo "Неправильный ключ: -$OPTARG" >&2
                usage
                exit 1
                ;;
        esac
    done
}

# Функция для завершения процессов по их именам
kill_processes() {
    PIDS=$(pgrep -x "$1")
    if [[ -z "$PIDS" ]]; then
        echo "Процессы с именем \"$1\" не найдены." >&2
        return 1
    fi
    echo "Завершаем процессы с именами \"$1\": $PIDs
kill -$SIGNAL $PIDS
echo "Убиваем процессы с именами \"$1\"."
}

# Функция для вывода справочной информации
usage() {
    cat << EOF
Использование: $(basename "$0") [-h] [-s SIGNAL] PROCESS_NAMES
-h          Показать эту помощь
-s SIGNAL    Посылка сигнала SIGNAL вместо SIGTERM
PROCESS_NAMES Имена процессов, которые нужно завершить
EOF
}

# Парсим аргументы
parse_args "$@"

# Проверяем наличие обязательного параметра
if [[ -z "$PROCESS_NAMES" ]]; then
    echo "Не указаны имена процессов для завершения." >&2
    usage
    exit 1
fi

# Устанавливаем значения по умолчанию
SIGNAL=${SIGNAL:-15}

# Завершаем процессы
kill_processes "$PROCESS_NAMES"

echo "Процесс завершен."

### Запуск скрипта:

Скрипт можно запустить следующим образом:

```bash
./killall_by_name.sh -s 9 proc1 proc2
