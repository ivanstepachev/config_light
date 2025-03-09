#!/bin/bash

#Установить доступ без пароля для передачи логов
apt-get install sshpass

#Сохранение ключа от сервера хранилища логов
ssh-keyscan storage.quantech.cc >> ~/.ssh/known_hosts
ssh-keyscan storage2.quantech.cc >> ~/.ssh/known_hosts

# Создание директории для Xray
mkdir -p /etc/xray

# Установка Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Удаление стандартного конфигурационного файла Xray
cd /usr/local/etc/xray && rm -f config.json

# Загрузка конфигурационного файла Xray
curl -o config.json https://raw.githubusercontent.com/ivanstepachev/config_light/main/config_plus.json

# Создавние файлов логгирования
mkdir -p /var/log/Xray/ && touch /var/log/Xray/access.log && touch /var/log/Xray/error.log

# Создание доступа для Xray к файлам логгирования
chown -R nobody:nogroup /var/log/Xray/

# Настройка прав доступа файлам логгирования для записи
chmod 0664 /var/log/Xray/access.log && chmod 0664 /var/log/Xray/error.log

# Удаление стандартного конфигурационного файла sysctl
cd /etc && rm -f sysctl.conf

# Скачивание оптимизированного конфига сетевых настроек
curl -o /etc/sysctl.conf https://raw.githubusercontent.com/ivanstepachev/config/main/sysctl.conf

# Внесение изменений в настройки
sysctl -p

# Включение и запуск Xray
systemctl enable xray && systemctl start xray

# Первое выключение
systemctl stop xray

# Повторное включение
systemctl start xray

# Блокировка доступа с посторонних IP на 22 порт
sudo iptables -A INPUT -p tcp -s 176.114.70.94 --dport 22 -j ACCEPT && sudo iptables -A INPUT -p tcp -s 217.18.62.68 --dport 22 -j ACCEPT && sudo iptables -A INPUT -p tcp -s 185.154.192.31 --dport 22 -j ACCEPT && sudo iptables -A INPUT -p tcp -s 147.45.133.251 --dport 22 -j ACCEPT  &&  sudo iptables -A INPUT -p tcp --dport 22 -j DROP  && sudo iptables-save | sudo tee /etc/iptables/rules.v4

echo "Настройка Xray завершена"
