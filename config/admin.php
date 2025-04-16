<?php

return [
    'prefix' => 'admin',
    'middleware' => ['web'],
    'theme' => 'bootstrap',
    'auth' => [
        'guard' => 'admin',
        'guards' => [
            'admin' => [
                'driver' => 'session',
                'provider' => 'admin_users',
            ],
        ],
        'providers' => [
            'admin_users' => [
                'driver' => 'eloquent',
                'model' => \ZenNavi\LaravelAdmin\Models\AdminUser::class,
            ],
        ],
    ],
];
