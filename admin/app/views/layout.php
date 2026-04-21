<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $title ?? 'SkillLink Admin'; ?></title>
    <!-- Google Fonts: Plus Jakarta Sans & Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary: #000c47; /* Deep Sea */
            --secondary: #ffddb8; /* Golden Hour */
            --surface: #f8f9fc;
            --on-surface: #1a1c1e;
            --outline: #74777f;
            --sidebar-width: 280px;
            --glass: rgba(255, 255, 255, 0.7);
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--surface);
            color: var(--on-surface);
            margin: 0;
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--primary);
            color: white;
            display: flex;
            flex-direction: column;
            padding: 24px;
            position: fixed;
            height: 100vh;
            left: 0;
            top: 0;
        }

        .logo-container {
            margin-bottom: 48px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-text {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 800;
            font-size: 24px;
            letter-spacing: -0.5px;
        }

        .nav-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .nav-item {
            padding: 12px 16px;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 12px;
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
        }

        .nav-item:hover {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .nav-item.active {
            background-color: var(--secondary);
            color: var(--primary);
            font-weight: 600;
        }

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            flex: 1;
            padding: 40px;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
        }

        h1 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 700;
            font-size: 32px;
            margin: 0;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .avatar {
            width: 40px;
            height: 40px;
            background-color: var(--secondary);
            border-radius: 50%;
        }

        /* Dashboard specific styles will be here or in view files */
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="logo-container">
            <div class="logo-text">SkillLink</div>
        </div>
        
        <nav>
            <ul class="nav-list">
                <li><a href="/SkillLink/admin/" class="nav-item active">Dashboard</a></li>
                <li><a href="/SkillLink/admin/users" class="nav-item">Users & Artisans</a></li>
                <li><a href="/SkillLink/admin/bookings" class="nav-item">Bookings</a></li>
                <li><a href="/SkillLink/admin/payments" class="nav-item">Payments</a></li>
                <li><a href="/SkillLink/admin/settings" class="nav-item">Settings</a></li>
            </ul>
        </nav>
    </aside>

    <main class="main-content">
        <header>
            <h1><?php echo $title; ?></h1>
            <div class="user-profile">
                <span>Admin User</span>
                <div class="avatar"></div>
            </div>
        </header>

        <div class="content">
            <?php include $view_file; ?>
        </div>
    </main>
</body>
</html>
