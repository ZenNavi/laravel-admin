# Laravel Admin Package

A Laravel package for creating an admin panel with authentication.

## Installation

1. Install via Composer:
   ```bash
   composer require your-vendor/laravel-admin
   ```

2. Publish assets:
   ```bash
   php artisan vendor:publish --provider="YourVendor\LaravelAdmin\LaravelAdminServiceProvider"
   ```

3. Run migrations:
   ```bash
   php artisan migrate
   ```

## Usage

- Access the admin panel at `/admin`.
- Login using the provided authentication system.

## License

MIT
