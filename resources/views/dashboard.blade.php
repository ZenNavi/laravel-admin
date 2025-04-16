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
