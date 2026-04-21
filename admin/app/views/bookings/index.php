<!-- Booking Management Log -->
<div class="premium-table-card animate-fade-in">
    <div class="card-header">
        <div>
            <h3 class="text-sm">Global Booking Registry</h3>
            <p class="text-xs text-muted mt-1">Monitoring all service requests and fulfillment status across the platform.</p>
        </div>
        <div class="flex-row gap-3">
            <select class="admin-input" style="width: 180px;" onchange="window.location.href='/SkillLink/admin/booking?status=' + this.value">
                <option value="">All Fulfillment Statuses</option>
                <option value="pending" <?php echo $status_filter === 'pending' ? 'selected' : ''; ?>>Pending</option>
                <option value="confirmed" <?php echo $status_filter === 'confirmed' ? 'selected' : ''; ?>>Confirmed</option>
                <option value="in_progress" <?php echo $status_filter === 'in_progress' ? 'selected' : ''; ?>>In Progress</option>
                <option value="completed" <?php echo $status_filter === 'completed' ? 'selected' : ''; ?>>Completed</option>
                <option value="cancelled" <?php echo $status_filter === 'cancelled' ? 'selected' : ''; ?>>Cancelled</option>
            </select>
            <div style="position: relative;">
                <input type="text" placeholder="Search by Ref #..." class="admin-input" style="width: 220px; padding-left: 2.5rem;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); opacity: 0.4;"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>
        </div>
    </div>
    
    <div class="table-responsive">
        <table class="premium-table">
            <thead>
                <tr>
                    <th>Ref Number</th>
                    <th>Customer</th>
                    <th>Assigned Artisan</th>
                    <th>Category</th>
                    <th>Schedule</th>
                    <th>Price</th>
                    <th>Status</th>
                    <th style="text-align: right;">Registry</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($bookings)): ?>
                    <tr><td colspan="8" class="text-center" style="padding: 5rem; color: var(--text-muted);">No booking logs found in the registry.</td></tr>
                <?php else: ?>
                    <?php foreach($bookings as $b): ?>
                    <tr>
                        <td><code class="text-sm font-bold" style="color: var(--primary);"><?php echo htmlspecialchars($b['booking_number']); ?></code></td>
                        <td><strong class="text-sm"><?php echo htmlspecialchars($b['customer_name']); ?></strong></td>
                        <td>
                            <div class="text-sm"><?php echo htmlspecialchars($b['artisan_name']); ?></div>
                        </td>
                        <td>
                            <span class="text-xs text-muted"><?php echo htmlspecialchars($b['category']); ?></span>
                        </td>
                        <td>
                            <div class="text-sm font-bold"><?php echo date('M d, Y', strtotime($b['scheduled_at'])); ?></div>
                            <div class="text-xs text-muted"><?php echo date('h:i A', strtotime($b['scheduled_at'])); ?></div>
                        </td>
                        <td><strong class="text-sm" style="color: var(--primary);">₦<?php echo number_format($b['price'], 2); ?></strong></td>
                        <td>
                            <span class="status-badge <?php 
                                echo match($b['status']) {
                                    'confirmed' => 'badge-success',
                                    'in_progress' => 'badge-warning',
                                    'completed' => 'badge-success',
                                    'cancelled' => 'badge-danger',
                                    default => 'badge-warning'
                                };
                            ?>">
                                <?php echo ucfirst(str_replace('_', ' ', $b['status'])); ?>
                            </span>
                        </td>
                        <td style="text-align: right;">
                             <button class="btn-premium btn-outline btn-icon-only" title="View Details">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                             </button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
    
    <?php if ($total > $limit): ?>
    <div class="card-header justify-between py-3" style="background: var(--surface);">
        <p class="text-xs text-muted">Displaying <?php echo count($bookings); ?> of <?php echo $total; ?> active records</p>
        <div class="flex-row gap-2">
            <?php for($i = 1; $i <= ceil($total / $limit); $i++): ?>
                <a href="/SkillLink/admin/booking?page=<?php echo $i; ?>&status=<?php echo $status_filter; ?>" 
                   class="btn-premium <?php echo $i === $current_page ? 'btn-primary' : 'btn-outline'; ?> btn-sm"
                   style="min-width: 38px; justify-content: center;">
                    <?php echo $i; ?>
                </a>
            <?php endfor; ?>
        </div>
    </div>
    <?php endif; ?>
</div>
