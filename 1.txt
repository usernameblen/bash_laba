#!/bin/bash

# Функция для вывода заголовков столбцов
print_headers() {
    printf "%10s" ""
    for i in {1..9}; do
        printf "%10d" $i
    done
    printf "\n"
}

# Функция для вычисления и вывода степеней числа
print_powers() {
    power=$1
    printf "%10s" "^$power"
    for base in {1..9}; do
        result=$((base**power))
        printf "%10d" $result
    done
    printf "\n"
}

# Выводим заголовки столбцов
print_headers

# Выводим строки со степенями
for power in {0..6}; do
    print_powers $power
done
