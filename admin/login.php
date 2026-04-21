<?php
/**
 * SkillLink Admin Login
 * Authenticates admin users using a POST form and PHP sessions.
 */
session_start();

// If already logged in, go to dashboard
if (!empty($_SESSION['admin_id'])) {
    header('Location: /SkillLink/admin/');
    exit;
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email    = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    if ($email && $password) {
        require_once __DIR__ . '/config/db.php';
        $db   = getDB();
        $stmt = $db->prepare(
            "SELECT id, name, password_hash FROM users WHERE email = ? AND role = 'admin' LIMIT 1"
        );
        $stmt->bind_param('s', $email);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows === 1) {
            $admin = $result->fetch_assoc();
            if (password_verify($password, $admin['password_hash'])) {
                $_SESSION['admin_id']   = $admin['id'];
                $_SESSION['admin_name'] = $admin['name'];
                session_regenerate_id(true);
                header('Location: ' . admin_url());
                exit;
            }
        }
        $error = 'Invalid email or password.';
    } else {
        $error = 'Please enter both email and password.';
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | SkillLink Admin</title>
    <meta name="description" content="Secure administrative portal for the SkillLink artisan marketplace platform.">
    
    <!-- Shared Design System -->
    <link rel="stylesheet" href="<?php echo admin_url('public/css/admin.css'); ?>">
</head>
<body class="login-body">
    <div class="login-blob" style="top: -200px; right: -200px;"></div>
    <div class="login-blob" style="bottom: -200px; left: -200px; animation-delay: -5s;"></div>

    <div class="login-card">
        <div class="login-logo-badge">
            <img src="<?php echo asset_url('logo1.png'); ?>" alt="SkillLink Logo" style="width: 32px; height: 32px; object-fit: contain;">
        </div>
        
        <h1 class="login-title">SkillLink</h1>
        <p class="login-subtitle">Administrative Portal — Secure Access</p>

        <?php if ($error): ?>
        <div class="error-alert">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <?php echo htmlspecialchars($error); ?>
        </div>
        <?php endif; ?>

        <form action="<?php echo admin_url('login.php'); ?>" method="POST" autocomplete="on" class="flex-column gap-4">
            <div class="flex-column gap-2">
                <label for="admin-email" class="input-label">Email Address</label>
                <input
                    type="email"
                    id="admin-email"
                    name="email"
                    class="admin-input"
                    placeholder="admin@skilllink.com"
                    value="<?php echo htmlspecialchars($_POST['email'] ?? ''); ?>"
                    required
                    autofocus
                >
            </div>

            <div class="flex-column gap-2">
                <div class="flex-row justify-between">
                    <label for="admin-password" class="input-label">Password</label>
                    <a href="#" class="text-xs text-muted font-bold" style="text-decoration: none;">Forgot?</a>
                </div>
                <input
                    type="password"
                    id="admin-password"
                    name="password"
                    class="admin-input"
                    placeholder="••••••••"
                    required
                >
            </div>

            <button type="submit" class="btn-premium btn-primary" style="width: 100%; justify-content: center; padding: 1rem; margin-top: 1rem;">
                Sign In to Dashboard
            </button>
        </form>

        <div class="text-center mt-4" style="text-align: center; margin-top: 2rem;">
            <p class="text-xs text-muted">© <?php echo date('Y'); ?> SkillLink Artisan Network</p>
        </div>
    </div>
</body>
</html>
