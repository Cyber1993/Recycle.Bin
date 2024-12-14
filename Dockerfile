FROM ubuntu:22.04
# Оновлюємо систему та встановлюємо Apache2
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean
# Копіюємо файли сайту до каталогу Apache
COPY ./public-html /var/www/html
# Відкриваємо порт 80 для HTTP
EXPOSE 80
# Вказуємо команду для запуску Apache2
CMD ["apachectl", "-D", "FOREGROUND"]


*********************************************


# Використовуємо базовий образ Alpine Linux
FROM alpine:3.18
# Встановлюємо Apache2
RUN apk add --no-cache apache2 && \
    mkdir -p /run/apache2
# Копіюємо файли сайту в каталог Apache
COPY ./public-html /var/www/localhost/htdocs
# Відкриваємо порт 80 для HTTP-запитів
EXPOSE 80
# Запускаємо Apache2
CMD ["httpd", "-D", "FOREGROUND"]

----------------

Що відбувається:
Базовий образ:
alpine:3.18 — легкий образ Linux.

Встановлення Apache2:

Використовуємо пакетний менеджер apk для встановлення Apache2.
Створюємо папку /run/apache2, яка потрібна для роботи Apache.
Копіювання файлів сайту:
Файли вашого сайту копіюються з локальної папки public-html у 
стандартний каталог Apache /var/www/localhost/htdocs.

Запуск Apache2:
Запускаємо сервер у фоновому режимі за допомогою команди httpd -D FOREGROUND.


project/
├── Dockerfile
└── public-html/
    └── index.html


docker build -t my-alpine-apache .

docker run -d -p 8080:80 my-alpine-apache

Перевірити сайт:
Відкрий у браузері http://localhost:8080.
