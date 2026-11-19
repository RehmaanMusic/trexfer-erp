FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Karachi

# Install system dependencies + PHP 8.2
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    unzip \
    supervisor \
    software-properties-common \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update && apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-bcmath \
    php8.2-curl \
    php8.2-gd \
    php8.2-zip \
    php8.2-intl \
    php8.2-sodium \
    php8.2-opcache \
    php8.2-pcntl \
    php8.2-exif \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Clone Trexfer ERP core
RUN git clone --depth 1 https://github.com/RehmaanMusic/trexfer-erp-core .

# Clone all ZerpPackages modules
RUN mkdir -p /var/www/ZerpPackages && \
    cd /var/www/ZerpPackages && \
    git clone --depth 1 https://github.com/zerp-pk/account && \
    git clone --depth 1 https://github.com/zerp-pk/aiassistant && \
    git clone --depth 1 https://github.com/zerp-pk/budget-planner && \
    git clone --depth 1 https://github.com/zerp-pk/calendar && \
    git clone --depth 1 https://github.com/zerp-pk/contract && \
    git clone --depth 1 https://github.com/zerp-pk/double-entry && \
    git clone --depth 1 https://github.com/zerp-pk/form-builder && \
    git clone --depth 1 https://github.com/zerp-pk/goal && \
    git clone --depth 1 https://github.com/zerp-pk/google-captcha && \
    git clone --depth 1 https://github.com/zerp-pk/google-meet && \
    git clone --depth 1 https://github.com/zerp-pk/hrm && \
    git clone --depth 1 https://github.com/zerp-pk/jitsi && \
    git clone --depth 1 https://github.com/zerp-pk/landing-page && \
    git clone --depth 1 https://github.com/zerp-pk/lead && \
    git clone --depth 1 https://github.com/zerp-pk/paypal && \
    git clone --depth 1 https://github.com/zerp-pk/performance && \
    git clone --depth 1 https://github.com/zerp-pk/pos && \
    git clone --depth 1 https://github.com/zerp-pk/product-service && \
    git clone --depth 1 https://github.com/zerp-pk/quotation && \
    git clone --depth 1 https://github.com/zerp-pk/real-estate && \
    git clone --depth 1 https://github.com/zerp-pk/recruitment && \
    git clone --depth 1 https://github.com/zerp-pk/restaurant && \
    git clone --depth 1 https://github.com/zerp-pk/slack && \
    git clone --depth 1 https://github.com/zerp-pk/stripe && \
    git clone --depth 1 https://github.com/zerp-pk/support-ticket && \
    git clone --depth 1 https://github.com/zerp-pk/taskly && \
    git clone --depth 1 https://github.com/zerp-pk/telegram && \
    git clone --depth 1 https://github.com/zerp-pk/timesheet && \
    git clone --depth 1 https://github.com/zerp-pk/training && \
    git clone --depth 1 https://github.com/zerp-pk/twilio && \
    git clone --depth 1 https://github.com/zerp-pk/webhook

# Create .env from example
RUN cp .env.example .env

# Install PHP dependencies
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --ignore-platform-reqs

# Install Node dependencies and build frontend
RUN npm ci && npm run build

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Copy configs
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 10000

CMD ["/start.sh"]
