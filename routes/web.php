<?php

use Illuminate\Support\Facades\Route;
use ZenNavi\LaravelAdmin\Http\Controllers\AdminAuthController;

Route::group([
    'prefix' => config('admin.prefix'),
    'middleware' => ['web'],
    'as' => 'admin.',
], function () {
    Route::get('login', [AdminAuthController::class, 'showLoginForm'])->name('login');
    Route::post('login', [AdminAuthController::class, 'login']);
    Route::post('logout', [AdminAuthController::class, 'logout'])->name('logout');

    Route::middleware('admin.auth')->group(function () {
        Route::get('/', function () {
            return view('laravel-admin::dashboard');
        })->name('dashboard');
    });
});
