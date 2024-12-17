#!/bin/bash

clear
echo -e "\n--- Налаштування статичної IP-адреси ---\n"

# Запитуємо IP-адресу та шлюз у користувача
read -p "Введіть IP-адресу з маскою (наприклад, 192.168.0.200/24): " IP_ADDRESS
read -p "Введіть шлюз (наприклад, 192.168.0.1): " GATEWAY

# Перевірка правильності формату IP-адреси з маскою
if [[ ! "$IP_ADDRESS" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]{1,2})$ ]]; then
  echo -e "\nПомилка: Невірний формат IP-адреси або маски підмережі. Приклад: 192.168.0.200/24.\n"
  exit 1
fi

# Перевірка на правильність значень IP-адреси та маски
IP=$(echo $IP_ADDRESS | cut -d'/' -f1)
MASK=$(echo $IP_ADDRESS | cut -d'/' -f2)

# Перевіряємо, чи маска в діапазоні від 0 до 32
if [ "$MASK" -lt 0 ] || [ "$MASK" -gt 32 ]; then
  echo -e "\nПомилка: Маска підмережі повинна бути між 0 та 32.\n"
  exit 1
fi

# Перевірка, чи всі октети IP-адреси знаходяться в межах від 0 до 255
IFS='.' read -r -a octets <<< "$IP"
for octet in "${octets[@]}"; do
  if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
    echo -e "\nПомилка: Октет IP-адреси повинен бути між 0 та 255.\n"
    exit 1
  fi
done

# Перевірка шлюзу
if [[ ! "$GATEWAY" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo -e "\nПомилка: Невірний формат шлюзу. Приклад: 192.168.0.1.\n"
  exit 1
fi

CONFIG_FILE="/etc/netplan/01-netcfg.yaml"

# Створюємо конфігураційний файл
cat <<EOF > $CONFIG_FILE
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - $IP_ADDRESS
      gateway4: $GATEWAY
      nameservers:
        addresses:
          - 8.8.8.8
EOF

# Підтвердження збереження та застосування змін
echo -e "\nКонфігурація збережена в $CONFIG_FILE. Застосовуємо зміни...\n"
sudo netplan apply
sleep 2
clear
echo -e "\n--- Перевірка налаштувань мережевого інтерфейсу ---\n"
ip a | grep -A 2 "enp0s3"
echo -e "\nНалаштування завершено.\n"
