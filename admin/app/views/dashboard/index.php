<!-- Dashboard Executive Overview -->
<div class="stats-container">
    <!-- Stat Card: Total Users -->
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Total Users</span>
                <div class="value"><?php echo number_format($total_users); ?></div>
            </div>
            <div class="stat-icon" style="background: var(--info-bg); color: var(--info);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="font-bold" style="color: var(--success);">+12%</span>
            <span class="text-muted">from last month</span>
        </div>
    </div>

    <!-- Stat Card: Active Artisans -->
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Active Artisans</span>
                <div class="value"><?php echo number_format($active_artisans); ?></div>
            </div>
            <div class="stat-icon" style="background: var(--warning-bg); color: var(--warning);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="font-bold" style="color: var(--success);">Verified</span>
            <span class="text-muted">Service providers</span>
        </div>
    </div>

    <!-- Stat Card: Daily Bookings -->
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Daily Bookings</span>
                <div class="value"><?php echo $recent_bookings; ?></div>
            </div>
            <div class="stat-icon" style="background: var(--info-bg); color: var(--info);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="text-muted">Requests made today</span>
        </div>
    </div>

    <!-- Stat Card: Revenue -->
    <div class="stat-card" style="border-left: 4px solid var(--accent);">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Platform Revenue</span>
                <div class="value" style="color: var(--success);"><?php echo $revenue; ?></div>
            </div>
            <div class="stat-icon" style="background: var(--success-bg); color: var(--success);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="text-muted">Net platform fees (MTD)</span>
        </div>
    </div>
</div>

<!-- Recent Activity Section -->
<div class="premium-table-card">
    <div class="card-header">
        <h3>Recent Artisan Requests</h3>
        <a href="<?php echo admin_url('user'); ?>" class="btn-premium btn-outline">View All</a>
    </div>
    
    <div class="table-responsive">
        <table class="premium-table">
            <thead>
                <tr>
                    <th>Artisan Name</th>
                    <th>Skill / Category</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th style="text-align: right;">Action</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($pending_artisans)): ?>
                    <tr>
                        <td colspan="5" class="text-center" style="padding: 4rem;">
                            <div class="mb-3" style="opacity: 0.5;">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            </div>
                            <span class="text-muted">No pending artisan applications at the moment.</span>
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach($pending_artisans as $a): ?>
                    <tr>
                        <td>
                            <div class="flex-row gap-3">
                                <div class="avatar-circle" style="width: 32px; height: 32px; font-size: 11px;">
                                    <?php echo strtoupper(substr($a['name'], 0, 1)); ?>
                                </div>
                                <strong class="text-sm"><?php echo htmlspecialchars($a['name']); ?></strong>
                            </div>
                        </td>
                        <td><span class="text-sm"><?php echo htmlspecialchars(($a['skills'] ?: $a['skill']) ?: 'Uncategorized'); ?></span></td>
                        <td>
                            <div class="flex-row gap-2 text-muted text-sm">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                                <?php echo htmlspecialchars($a['location_name'] ?: 'N/A'); ?>
                            </div>
                        </td>
                        <td>
                            <span class="status-badge <?php 
                                echo match($a['status']) {
                                    'approved' => 'badge-success',
                                    'pending' => 'badge-warning',
                                    'rejected' => 'badge-danger',
                                    default => 'badge-muted'
                                };
                            ?>">
                                <?php echo ucfirst($a['status']); ?>
                            </span>
                        </td>
                        <td style="text-align: right;">
                            <a href="<?php echo admin_url('user/details?id=' . $a['id']); ?>" class="btn-premium btn-primary btn-sm">Review</a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>
