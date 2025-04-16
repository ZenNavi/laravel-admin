<?php

namespace ZenNavi\LaravelAdmin;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Auth;

class LaravelAdminServiceProvider extends ServiceProvider
{
    public function boot()
    {
        $this->publishes([
            __DIR__ . '/../config/admin.php' => config_path('admin.php'),
            __DIR__ . '/../resources/views' => resource_path('views/vendor/laravel-admin'),
            __DIR__ . '/../database/migrations' => database_path('migrations'),
            __DIR__ . '/../public' => public_path('vendor/laravel-admin'),
        ], 'public');

        $this->loadRoutesFrom(__DIR__ . '/../routes/web.php');
        $this->loadViewsFrom(__DIR__ . '/../resources/views', 'laravel-admin');

        $this->app['router']->aliasMiddleware('admin.auth', \ZenNavi\LaravelAdmin\Http\Middleware\AdminAuthenticate::class);

        if ($this->app->runningInConsole()) {
            $this->commands([
                \ZenNavi\LaravelAdmin\Console\Commands\MakeCrudCommand::class,
            ]);
        }

        $this->registerAuth();
    }

    public function register()
    {
        $this->mergeConfigFrom(__DIR__ . '/../config/admin.php', 'admin');
    }

    protected function registerAuth()
    {
        config([
            'auth.guards' => array_merge(config('auth.guards', []), config('admin.auth.guards', [])),
            'auth.providers' => array_merge(config('auth.providers', []), config('admin.auth.providers', [])),
        ]);
    }
}
