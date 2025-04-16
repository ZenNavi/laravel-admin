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
                    <span>{{ $message }}</span>
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
