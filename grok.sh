# 디렉토리 구조 생성
   mkdir -p src/Console/Commands src/Http/Controllers src/Http/Middleware src/Models config routes resources/views/auth database/migrations public/css tests/Feature

   # composer.json
   cat <<EOL > composer.json
{
    "name": "your-vendor/laravel-admin",
    "description": "A Laravel Admin Panel Package",
    "type": "library",
    "require": {
        "php": "^8.0",
        "illuminate/support": "^10.0"
    },
    "autoload": {
        "psr-4": {
            "ZenNavi\\\\LaravelAdmin\\\\": "src/"
        }
    },
    "extra": {
        "laravel": {
            "providers": [
                "ZenNavi\\\\LaravelAdmin\\\\LaravelAdminServiceProvider"
            ]
        }
    },
    "license": "MIT"
}
EOL

   # src/Console/Commands/MakeCrudCommand.php
   cat <<EOL > src/Console/Commands/MakeCrudCommand.php
<?php

namespace ZenNavi\LaravelAdmin\Console\Commands;

use Illuminate\Console\Command;

class MakeCrudCommand extends Command
{
    protected \$signature = 'admin:make-crud {name}';
    protected \$description = 'Create a new CRUD for Laravel Admin';

    public function handle()
    {
        \$name = \$this->argument('name');
        \$this->info("Creating CRUD for {\$name}...");
    }
}
EOL

   # src/Http/Controllers/AdminAuthController.php
   cat <<EOL > src/Http/Controllers/AdminAuthController.php
<?php

namespace ZenNavi\LaravelAdmin\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Routing\Controller;

class AdminAuthController extends Controller
{
    public function showLoginForm()
    {
        return view('laravel-admin::auth.login');
    }

    public function login(Request \$request)
    {
        \$credentials = \$request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::guard('admin')->attempt(\$credentials, \$request->filled('remember'))) {
            \$request->session()->regenerate();
            return redirect()->route('admin.dashboard');
        }

        return back()->withErrors([
            'email' => 'The provided credentials do not match our records.',
        ])->onlyInput('email');
    }

    public function logout(Request \$request)
    {
        Auth::guard('admin')->logout();
        \$request->session()->invalidate();
        \$request->session()->regenerateToken();
        return redirect()->route('admin.login');
    }
}
EOL

   # src/Http/Controllers/CrudController.php
   cat <<EOL > src/Http/Controllers/CrudController.php
<?php

namespace ZenNavi\LaravelAdmin\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

class CrudController extends Controller
{
    public function index()
    {
        return view('laravel-admin::crud.index');
    }

    public function create()
    {
        return view('laravel-admin::crud.create');
    }
}
EOL

   # src/Http/Middleware/AdminAuthenticate.php
   cat <<EOL > src/Http/Middleware/AdminAuthenticate.php
<?php

namespace ZenNavi\LaravelAdmin\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminAuthenticate
{
    public function handle(Request \$request, Closure \$next)
    {
        if (!Auth::guard('admin')->check()) {
            return redirect()->route('admin.login');
        }

        if (!Auth::guard('admin')->user()->is_active) {
            Auth::guard('admin')->logout();
            return redirect()->route('admin.login')->withErrors(['email' => 'Your account is inactive.']);
        }

        return \$next(\$request);
    }
}
EOL

   # src/Models/AdminUser.php
   cat <<EOL > src/Models/AdminUser.php
<?php

namespace ZenNavi\LaravelAdmin\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class AdminUser extends Authenticatable
{
    use Notifiable;

    protected \$table = 'admin_users';

    protected \$fillable = [
        'name', 'email', 'password', 'is_active',
    ];

    protected \$hidden = [
        'password', 'remember_token',
    ];

    protected \$casts = [
        'is_active' => 'boolean',
    ];
}
EOL

   # src/LaravelAdminServiceProvider.php
   cat <<EOL > src/LaravelAdminServiceProvider.php
<?php

namespace ZenNavi\LaravelAdmin;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Auth;

class LaravelAdminServiceProvider extends ServiceProvider
{
    public function boot()
    {
        \$this->publishes([
            __DIR__ . '/../config/admin.php' => config_path('admin.php'),
            __DIR__ . '/../resources/views' => resource_path('views/vendor/laravel-admin'),
            __DIR__ . '/../database/migrations' => database_path('migrations'),
            __DIR__ . '/../public' => public_path('vendor/laravel-admin'),
        ], 'public');

        \$this->loadRoutesFrom(__DIR__ . '/../routes/web.php');
        \$this->loadViewsFrom(__DIR__ . '/../resources/views', 'laravel-admin');

        \$this->app['router']->aliasMiddleware('admin.auth', \ZenNavi\LaravelAdmin\Http\Middleware\AdminAuthenticate::class);

        if (\$this->app->runningInConsole()) {
            \$this->commands([
                \ZenNavi\LaravelAdmin\Console\Commands\MakeCrudCommand::class,
            ]);
        }

        \$this->registerAuth();
    }

    public function register()
    {
        \$this->mergeConfigFrom(__DIR__ . '/../config/admin.php', 'admin');
    }

    protected function registerAuth()
    {
        config([
            'auth.guards' => array_merge(config('auth.guards', []), config('admin.auth.guards', [])),
            'auth.providers' => array_merge(config('auth.providers', []), config('admin.auth.providers', [])),
        ]);
    }
}
EOL

   # config/admin.php
   cat <<EOL > config/admin.php
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
EOL

   # routes/web.php
   cat <<EOL > routes/web.php
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
EOL

   # resources/views/auth/login.blade.php
   cat <<EOL > resources/views/auth/login.blade.php
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login</title>
    <link href="{{ asset('vendor/laravel-admin/css/admin.css') }}" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h2>Admin Login</h2>
        <form method="POST" action="{{ route('admin.login') }}">
            @csrf
            <div>
                <label for="email">Email</label>
                <input type="email" name="email" id="email" value="{{ old('email') }}" required>
                @error('email')
                    <span>{{ \$message }}</span>
                @enderror
            </div>
            <div>
                <label for="password">Password</label>
                <input type="password" name="password" id="password" required>
            </div>
            <div>
                <label>
                    <input type="checkbox" name="remember"> Remember me
                </label>
            </div>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
EOL

   # resources/views/dashboard.blade.php
   cat <<EOL > resources/views/dashboard.blade.php
<!DOCTYPE html>
<html>
<head>
    <title>Laravel Admin Dashboard</title>
    <link href="{{ asset('vendor/laravel-admin/css/admin.css') }}" rel="stylesheet">
</head>
<body>
    <h1>Welcome, {{ Auth::guard('admin')->user()->name }}!</h1>
    <form method="POST" action="{{ route('admin.logout') }}">
        @csrf
        <button type="submit">Logout</button>
    </form>
</body>
</html>
EOL

   # database/migrations/2023_01_01_000000_create_admin_tables.php
   cat <<EOL > database/migrations/2023_01_01_000000_create_admin_tables.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAdminTables extends Migration
{
    public function up()
    {
        Schema::create('admin_users', function (Blueprint \$table) {
            \$table->id();
            \$table->string('name');
            \$table->string('email')->unique();
            \$table->string('password');
            \$table->boolean('is_active')->default(true);
            \$table->rememberToken();
            \$table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('admin_users');
    }
}
EOL

   # public/css/admin.css
   cat <<EOL > public/css/admin.css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    background-color: #f4f4f4;
}

.container {
    width: 400px;
    margin: 50px auto;
    padding: 20px;
    background: #fff;
    border-radius: 5px;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}

h2 {
    text-align: center;
}

div {
    margin-bottom: 15px;
}

label {
    display: block;
    margin-bottom: 5px;
}

input[type="email"], input[type="password"] {
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
}

button {
    width: 100%;
    padding: 10px;
    background: #007bff;
    border: none;
    color: #fff;
    border-radius: 4px;
    cursor: pointer;
}

button:hover {
    background: #0056b3;
}

span {
    color: red;
    font-size: 0.9em;
}
EOL

   # tests/Feature/AdminPanelTest.php
   cat <<EOL > tests/Feature/AdminPanelTest.php
<?php

namespace ZenNavi\LaravelAdmin\Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPanelTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_dashboard_is_accessible()
    {
        \$response = \$this->get('/admin');
        \$response->assertStatus(200);
    }
}
EOL
