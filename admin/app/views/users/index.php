<!-- User & Artisan Management Portal -->
<div class="card-header pb-4" style="background: none; border: none;">
    <div class="tab-controls flex-row gap-2" style="background: #e2e8f0; padding: 6px; border-radius: var(--radius-md); width: fit-content;">
        <button id="btn-customers" class="btn-premium <?php echo (!isset($_GET['tab']) || $_GET['tab'] === 'customers') ? 'btn-primary' : 'btn-outline'; ?>" onclick="window.location.href='?tab=customers'">Customers</button>
        <button id="btn-artisans" class="btn-premium <?php echo ($_GET['tab'] ?? '') === 'artisans' ? 'btn-primary' : 'btn-outline'; ?>" onclick="window.location.href='?tab=artisans'">Artisans</button>
    </div>
</div>

<?php if (!isset($_GET['tab']) || $_GET['tab'] === 'customers'): ?>
<div id="customers-tab" class="premium-table-card animate-fade-in">
    <div class="card-header">
        <h3 class="text-sm">Registered Customers</h3>
        <div class="flex-row gap-3">
            <input type="text" placeholder="Search customers..." class="admin-input" style="width: 280px;">
        </div>
    </div>
    
    <div class="table-responsive">
        <table class="premium-table">
            <thead>
                <tr>
                    <th>Customer Name</th>
                    <th>Email Address</th>
                    <th>Phone</th>
                    <th>KYC Status</th>
                    <th style="text-align: right;">Action</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($users)): ?>
                    <tr><td colspan="5" class="text-center" style="padding: 3rem; color: var(--text-muted);">No customers registered yet.</td></tr>
                <?php else: ?>
                    <?php foreach($users as $user): ?>
                    <tr>
                        <td>
                             <div class="flex-row gap-3">
                                <div class="avatar-circle" style="width: 32px; height: 32px; font-size: 11px; background: var(--info);">
                                    <?php echo strtoupper(substr($user['name'], 0, 1)); ?>
                                </div>
                                <strong class="text-sm"><?php echo htmlspecialchars($user['name']); ?></strong>
                            </div>
                        </td>
                        <td><span class="text-sm"><?php echo htmlspecialchars($user['email']); ?></span></td>
                        <td><span class="text-sm"><?php echo htmlspecialchars($user['phone'] ?: '—'); ?></span></td>
                        <td>
                            <span class="status-badge <?php echo $user['is_verified'] ? 'badge-success' : 'badge-warning'; ?>">
                                <?php echo $user['is_verified'] ? 'Verified' : 'Pending'; ?>
                            </span>
                        </td>
                        <td style="text-align: right;">
                            <button class="btn-premium btn-outline btn-icon-only">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            </button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>
<?php else: ?>
<div id="artisans-tab" class="premium-table-card animate-fade-in">
    <div class="card-header">
        <h3 class="text-sm">Service Providers (Artisans)</h3>
        <div class="flex-row gap-3">
             <input type="text" placeholder="Search artisans..." class="admin-input" style="width: 280px;">
        </div>
    </div>
    
    <div class="table-responsive">
        <table class="premium-table">
            <thead>
                <tr>
                    <th>Artisan</th>
                    <th>Top Skill</th>
                    <th>City / Region</th>
                    <th>Rating</th>
                    <th>Vetting Status</th>
                    <th style="text-align: right;">Action</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($artisans)): ?>
                    <tr><td colspan="6" class="text-center" style="padding: 3rem; color: var(--text-muted);">No artisans found.</td></tr>
                <?php else: ?>
                    <?php foreach($artisans as $a): ?>
                    <tr>
                        <td>
                            <div class="flex-row gap-3">
                                <div class="avatar-circle" style="width: 32px; height: 32px; font-size: 11px;">
                                    <?php echo strtoupper(substr($a['name'], 0, 1)); ?>
                                </div>
                                <strong class="text-sm"><?php echo htmlspecialchars($a['name']); ?></strong>
                            </div>
                        </td>
                        <td>
                            <span class="text-sm" style="background: var(--surface); padding: 4px 8px; border-radius: 6px; font-weight: 500;">
                                <?php echo htmlspecialchars($a['skills'] ?: $a['skill'] ?: 'Misc'); ?>
                            </span>
                        </td>
                        <td><span class="text-sm"><?php echo htmlspecialchars($a['location_name'] ?: 'N/A'); ?></span></td>
                        <td>
                            <div class="flex-row gap-1 font-bold text-sm">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="#f59e0b" stroke="#f59e0b"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                                <?php echo number_format($a['rating'], 1); ?>
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
                             <a href="<?php echo admin_url('user/details?id=' . $a['id']); ?>" class="btn-premium btn-primary btn-sm">
                                <?php echo $a['status'] === 'pending' ? 'Verify Application' : 'Manage'; ?>
                             </a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>
