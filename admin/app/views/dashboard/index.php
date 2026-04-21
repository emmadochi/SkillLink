<!-- Dashboard View -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-label">Total Users</div>
        <div class="stat-value"><?php echo number_format($total_users); ?></div>
        <div class="stat-desc">+12% from last month</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Active Artisans</div>
        <div class="stat-value"><?php echo number_format($active_artisans); ?></div>
        <div class="stat-desc">85% online now</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Daily Bookings</div>
        <div class="stat-value"><?php echo $recent_bookings; ?></div>
        <div class="stat-desc">+5 today</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Revenue (MTD)</div>
        <div class="stat-value"><?php echo $revenue; ?></div>
        <div class="stat-desc">Target: ₦2.0M</div>
    </div>
</div>

<div class="recent-sections">
    <div class="recent-card glass">
        <h3>Recent Artisan Requests</h3>
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Skill</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Chukwudi Adeyemi</td>
                    <td>Plumbing</td>
                    <td>Ikeja</td>
                    <td><span class="badge warning">Pending</span></td>
                    <td><button class="btn btn-sm">Review</button></td>
                </tr>
                <tr>
                    <td>Grace Okoro</td>
                    <td>Catering</td>
                    <td>Lekki</td>
                    <td><span class="badge success">Approved</span></td>
                    <td><button class="btn btn-sm">View</button></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<style>
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 24px;
        margin-bottom: 40px;
    }

    .stat-card {
        background-color: white;
        padding: 24px;
        border-radius: 20px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.03);
    }

    .stat-label {
        font-size: 14px;
        color: var(--outline);
        margin-bottom: 8px;
    }

    .stat-value {
        font-family: 'Plus Jakarta Sans', sans-serif;
        font-weight: 700;
        font-size: 28px;
        color: var(--primary);
    }

    .stat-desc {
        font-size: 12px;
        color: #2e7d32;
        margin-top: 8px;
    }

    .glass {
        background: var(--glass);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .recent-card {
        padding: 32px;
        border-radius: 24px;
    }

    .admin-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 16px;
    }

    .admin-table th {
        text-align: left;
        padding: 12px;
        border-bottom: 1px solid #eee;
        color: var(--outline);
        font-weight: 500;
        font-size: 14px;
    }

    .admin-table td {
        padding: 16px 12px;
        border-bottom: 1px solid #f5f5f5;
        font-size: 14px;
    }

    .badge {
        padding: 4px 10px;
        border-radius: 100px;
        font-size: 11px;
        font-weight: 600;
    }

    .badge.warning { background: #fff3e0; color: #ef6c00; }
    .badge.success { background: #e8f5e9; color: #2e7d32; }

    .btn {
        padding: 8px 16px;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        font-weight: 500;
        background: var(--primary);
        color: white;
    }

    .btn-sm { padding: 6px 12px; font-size: 12px; }
</style>
