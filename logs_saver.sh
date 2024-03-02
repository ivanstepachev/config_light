#!/bin/sh

# Проверяем количество переданных аргументов
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 serverID password"
    exit 1
fi

# Идентификатор сервера и пароль передаются в качестве аргументов
serverID=$1
password=$2

# Получите текущую дату в формате день-месяц-год
currentDate=$(date -u +"%d-%m-%Y")

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

# Удалить архив
rm access.log.gz

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
