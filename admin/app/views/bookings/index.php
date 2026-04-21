<!-- Booking Management Log -->
<div class="glass p-5 rounded-3xl">
    <div class="flex-row justify-between mb-5">
        <div>
            <h2 class="mb-1">Platform Activity</h2>
            <p class="text-sm text-outline">Manage and track all service requests across SkillLink.</p>
        </div>
        <div class="flex-row gap-3">
            <select class="admin-input" style="width: 160px;">
                <option>All Statuses</option>
                <option>Confirmed</option>
                <option>In Progress</option>
                <option>Completed</option>
                <option>Cancelled</option>
            </select>
            <input type="text" placeholder="Search by ID or Name..." class="admin-input">
        </div>
    </div>
    
    <table class="admin-table">
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Customer</th>
                <th>Artisan</th>
                <th>Service</th>
                <th>Scheduled For</th>
                <th>Price</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach($bookings as $b): ?>
            <tr>
                <td><code class="text-primary"><?php echo $b['id']; ?></code></td>
                <td><strong><?php echo $b['customer']; ?></strong></td>
                <td><?php echo $b['artisan']; ?></td>
                <td><?php echo $b['service']; ?></td>
                <td>
                    <div class="text-sm"><?php echo $b['date']; ?></div>
                    <div class="text-xs text-outline"><?php echo $b['time']; ?></div>
                </td>
                <td><strong><?php echo $b['price']; ?></strong></td>
                <td>
                    <span class="badge <?php 
                        echo match($b['status']) {
                            'Confirmed' => 'primary-light',
                            'In Progress' => 'warning',
                            'Completed' => 'success',
                            default => 'outline'
                        };
                    ?>">
                        <?php echo $b['status']; ?>
                    </span>
                </td>
                <td>
                    <button class="btn-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/></svg>
                    </button>
                </td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    
    <div class="mt-5 flex-row justify-between">
        <p class="text-sm text-outline">Showing 1-3 of 152 bookings</p>
        <div class="pagination flex-row gap-2">
            <button class="page-btn active">1</button>
            <button class="page-btn">2</button>
            <button class="page-btn">3</button>
            <span class="text-outline">...</span>
            <button class="page-btn">12</button>
        </div>
    </div>
</div>

<style>
    .text-xs { font-size: 11px; }
    .text-primary { color: var(--primary); font-weight: 600; }
    .text-outline { color: var(--outline); }
    
    .badge.primary-light { background: #e8eaf6; color: #3f51b5; }
    
    .btn-icon {
        background: none;
        border: none;
        color: var(--outline);
        cursor: pointer;
        padding: 4px;
        border-radius: 8px;
        transition: background 0.2s;
    }
    
    .btn-icon:hover { background: #eee; color: var(--primary); }
    
    .page-btn {
        width: 32px;
        height: 32px;
        border-radius: 8px;
        border: 1px solid #ddd;
        background: white;
        cursor: pointer;
        font-size: 13px;
        font-weight: 500;
        transition: all 0.2s;
    }
    
    .page-btn.active {
        background: var(--primary);
        color: white;
        border-color: var(--primary);
    }
</style>
