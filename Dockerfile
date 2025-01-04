# Composer kurulum aşaması
FROM composer:2.6 AS composer

# Çalışma dizinini ayarla
WORKDIR /app

# Sadece composer dosyalarını kopyala
COPY composer.* ./

# Composer bağımlılıklarını kopyala ve kur
RUN composer install \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist \
    --optimize-autoloader

# Ana imaj aşaması
FROM vitodeploy/vito:1.x AS app

# Çalışma dizinini ayarla
WORKDIR /var/www/html

# Tüm proje dosyalarını kopyala
COPY . .

# Composer vendor klasörünü kopyala
COPY --from=composer /app/vendor ./vendor

# Storage ve cache dizinleri için izinleri ayarla
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && mkdir -p /var/www/html/storage/framework/{sessions,views,cache} \
    && chmod -R 775 /var/www/html/storage/framework

# İmaj meta bilgilerini ekle
LABEL org.opencontainers.image.maintainer="Erhan ÜRGÜN <erho@duck.com>"
LABEL org.opencontainers.image.description="Özelleştirilmiş Vito deployment imajı"
LABEL org.opencontainers.image.source="https://github.com/erhanurgun/erho-deploy"
LABEL org.opencontainers.image.title="Erho Deploy"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.vendor="Erhan ÜRGÜN"
LABEL org.opencontainers.image.licenses="MIT"

# Sağlık kontrolü
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Port ayarı
EXPOSE 80

# Çalıştırma komutu
CMD ["php-fpm"]