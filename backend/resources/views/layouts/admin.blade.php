<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Dashboard') | SkillLink Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
        :root {
            --primary: #000c47;
            --secondary: #ffddb8;
            --accent: #ffddb8;
            --surface: #f8f9fc;
            --text-main: #1a1f36;
            --sidebar-width: 280px;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--surface);
            margin: 0;
            display: flex;
            color: var(--text-main);
        }

        /* Sidebar Styles */
        .sidebar {
            width: var(--sidebar-width);
            background: var(--primary);
            height: 100vh;
            position: fixed;
            color: white;
            padding: 40px 24px;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
        }

        .logo {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 800;
            font-size: 24px;
            margin-bottom: 48px;
            color: var(--secondary);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 14px 16px;
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            border-radius: 12px;
            margin-bottom: 8px;
            transition: all 0.2s;
        }

        .nav-item:hover, .nav-item.active {
            background: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .nav-item.active {
            background: var(--secondary);
            color: var(--primary);
            font-weight: 600;
        }

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            flex: 1;
            padding: 40px;
            min-height: 100vh;
            box-sizing: border-box;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
        }

        .page-title h1 {
            margin: 0;
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 28px;
            color: var(--primary);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            background: white;
            padding: 8px 16px;
            border-radius: 50px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        .avatar {
            width: 32px;
            height: 32px;
            background: var(--primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 14px;
            font-weight: 600;
        }
    </style>
    @yield('styles')
</head>
<body>
    <aside class="sidebar">
        <div class="logo">
            <span class="material-icons-outlined">handyman</span>
            SkillLink
        </div>

        <nav>
            <a href="{{ route('admin.dashboard') }}" class="nav-item @if(Route::is('admin.dashboard')) active @endif">
                <span class="material-icons-outlined">dashboard</span>
                Dashboard
            </a>
            <a href="{{ route('admin.artisans') }}" class="nav-item @if(Route::is('admin.artisans')) active @endif">
                <span class="material-icons-outlined">people</span>
                Artisans
            </a>
            <a href="{{ route('admin.bookings') }}" class="nav-item @if(Route::is('admin.bookings')) active @endif">
                <span class="material-icons-outlined">calendar_today</span>
                Bookings
            </a>
            <a href="#" class="nav-item">
                <span class="material-icons-outlined">payments</span>
                Payments
            </a>
            <a href="#" class="nav-item">
                <span class="material-icons-outlined">settings</span>
                Settings
            </a>
        </nav>

        <div style="margin-top: auto;">
            <form action="{{ route('logout') }}" method="POST">
                @csrf
                <button type="submit" class="nav-item" style="background: none; border: none; width: 100%; cursor: pointer;">
                    <span class="material-icons-outlined">logout</span>
                    Logout
                </button>
            </form>
        </div>
    </aside>

    <main class="main-content">
        <header>
            <div class="page-title">
                @yield('header')
            </div>
            <div class="user-profile">
                <div class="avatar">A</div>
                <span style="font-weight: 600; font-size: 14px;">Admin</span>
            </div>
        </header>

        @yield('content')
    </main>

    @yield('scripts')
</body>
</html>
