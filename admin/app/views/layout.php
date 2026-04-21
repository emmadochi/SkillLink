<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $title ?? 'SkillLink Admin'; ?> | Administrative Portal</title>
    
    <!-- Design System -->
    <link rel="stylesheet" href="/SkillLink/admin/public/css/admin.css">
    
    <!-- Favicon (Fallback) -->
    <link rel="icon" type="image/png" href="https://img.icons8.com/fluency/48/000000/worker-male.png">
</head>
<body>
    <?php
    $request_uri = $_SERVER['REQUEST_URI'] ?? '/';
    $base_path   = '/SkillLink/admin/';
    $path        = str_replace($base_path, '', $request_uri);
    $active_section = strtok(trim($path, '/'), '/') ?: 'dashboard';
    ?>
    
    <div class="app-container">
        <!-- Sidebar Navigation -->
        <aside class="sidebar">
            <div class="logo-section">
                <img src="/SkillLink/logo1.png" alt="SkillLink Logo" class="brand-logo">
                <div class="logo-text">SkillLink</div>
            </div>
            
            <nav>
                <ul class="nav-links">
                    <li>
                        <a href="/SkillLink/admin/" class="nav-link <?php echo $active_section === 'dashboard' ? 'active' : ''; ?>">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/></svg>
                            Dashboard
                        </a>
                    </li>
                    <li>
                        <a href="/SkillLink/admin/user" class="nav-link <?php echo ($active_section === 'user' || $active_section === 'users') ? 'active' : ''; ?>">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            Users & Artisans
                        </a>
                    </li>
                    <li>
                        <a href="/SkillLink/admin/booking" class="nav-link <?php echo $active_section === 'booking' ? 'active' : ''; ?>">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="11" y2="10"/></svg>
                            Bookings
                        </a>
                    </li>
                    <li>
                        <a href="/SkillLink/admin/dispute" class="nav-link <?php echo $active_section === 'dispute' ? 'active' : ''; ?>">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                            Disputes
                        </a>
                    </li>
                    <li>
                        <a href="/SkillLink/admin/payment" class="nav-link <?php echo $active_section === 'payment' ? 'active' : ''; ?>">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                            Payments
                        </a>
                    </li>
                    <li>
                        <a href="/SkillLink/admin/settings" class="nav-link <?php echo $active_section === 'settings' ? 'active' : ''; ?>">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                            Settings
                        </a>
                    </li>
                </ul>
            </nav>

            <div class="sidebar-footer">
                <a href="/SkillLink/admin/logout" class="nav-link" style="color: #ff8a8a;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    Logout
                </a>
            </div>
        </aside>

        <!-- Main Wrapper -->
        <div class="main-wrapper">
            <header class="top-header">
                <div class="flex-row gap-3">
                    <button id="sidebarToggle" class="btn-premium btn-outline btn-icon-only hide-on-desktop" style="display: none;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
                    </button>
                    <div class="page-title">
                        <h2><?php echo $title ?? 'Administration'; ?></h2>
                    </div>
                </div>
                
                <div class="header-actions">
                    <div class="profile-trigger">
                        <div class="profile-info">
                            <span class="profile-name"><?php echo htmlspecialchars($_SESSION['admin_name'] ?? 'Administrator'); ?></span>
                            <span class="profile-role">Platform Admin</span>
                        </div>
                        <div class="avatar-circle">
                            <?php echo strtoupper(substr($_SESSION['admin_name'] ?? 'A', 0, 1)); ?>
                        </div>
                    </div>
                </div>
            </header>

            <main class="view-content animate-fade-in">
                <?php include $view_file; ?>
            </main>
        </div>
    </div>

    <!-- Premium Modal System -->
    <div id="modalOverlay" class="modal-overlay">
        <div class="modal-content" id="modalContent">
            <div class="modal-header">
                <h3>Heading</h3>
                <button class="modal-close" onclick="SkillLinkModal.hide()">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 6 6 18M6 6l12 12"/></svg>
                </button>
            </div>
            <div class="modal-body">
                <!-- Body injected by JS -->
            </div>
            <div class="modal-footer">
                <!-- Footer injected by JS -->
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="/SkillLink/admin/public/js/admin.js"></script>
</body>
</html>
