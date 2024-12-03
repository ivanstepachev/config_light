#!/bin/sh

# Проверяем количество переданных аргументов
if [ "$#" -lt 2 ]; then
    echo "Использование: $0 serverID password [currentDate]"
    exit 1
fi

# Идентификатор сервера и пароль передаются в качестве аргументов
serverID=$1
password=$2

# Проверяем, передан ли третий аргумент (дата)
if [ -n "$3" ]; then
    currentDate=$3
else
    # Используем текущую дату, если она не передана
    currentDate=$(date -u +"%d-%m-%Y")
fi

# Имя файла архива
archiveFileName="${serverID}.${currentDate}.tar.gz"

# Перейдите в директорию с логами
cd /var/log/Xray || exit

# Создайте копию файла access.log
cp access.log access.log.tmp

# Сжимите копию файла, добавив в название текущую дату и ID сервера
tar -czf "$archiveFileName" access.log.tmp

# Очистите оригинальный файл access.log, не удаляя его
truncate -s 0 access.log

# Удалите временную копию файла
rm access.log.tmp

# Удалить архив, если существует
if [ -f access.log.gz ]; then
    rm access.log.gz
fi

# Передача файла на другой сервер
sshpass -p "$password" scp "$archiveFileName" root@storage.quantech.cc:/home/logs/

# Проверяем статус выполнения предыдущей команды
if [ "$?" -eq 0 ]; then
    echo "Файл успешно передан."
    # Удаление архива после успешной передачи
    rm "$archiveFileName"
else
    echo "Ошибка при передаче файла."
fi
