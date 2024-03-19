# Базовый образ Ruby
FROM ruby:3.1.3

# Установка зависимостей
RUN apt-get update -qq
RUN apt-get install -y postgresql-client netcat

# Установка рабочей директории в контейнере
WORKDIR /car_rent_api

# Копирование Gemfile и Gemfile.lock в рабочую директорию
COPY Gemfile /car_rent_api/Gemfile
COPY Gemfile.lock /car_rent_api/Gemfile.lock

# Установка гемов
RUN bundle install

# Копирование кода приложения в рабочую директорию
COPY . /car_rent_api

# Добавление скрипта для запуска сервера
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
