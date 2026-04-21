<!-- Dispute Resolution Center -->
<div class="stats-container animate-fade-in">
    <div class="stat-card" style="border-left: 4px solid var(--danger);">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Critical Disputes</span>
                <div class="value" style="color: var(--danger);"><?php echo $open_count; ?></div>
            </div>
            <div class="stat-icon" style="background: var(--danger-bg); color: var(--danger);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="text-muted">Requiring immediate mediation</span>
        </div>
    </div>
    
    <div class="stat-card" style="border-left: 4px solid var(--success);">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Resolution Success</span>
                <div class="value"><?php echo $total > 0 ? round((($total - $open_count) / $total) * 100) : 100; ?>%</div>
            </div>
            <div class="stat-icon" style="background: var(--success-bg); color: var(--success);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="font-bold" style="color: var(--success);">+<?php echo $total - $open_count; ?> Resolved</span>
            <span class="text-muted">life-to-date</span>
        </div>
    </div>
</div>

<div class="premium-table-card animate-fade-in">
    <div class="card-header">
        <div>
            <h3>Active Mediation Queue</h3>
            <p class="text-xs text-muted mt-1">Platform-assisted conflict resolution between customers and artisans.</p>
        </div>
        <div class="flex-row gap-3">
             <div style="position: relative;">
                <input type="text" placeholder="Filter by Booking ID..." class="admin-input" style="width: 220px; padding-left: 2.5rem;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); opacity: 0.4;"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>
        </div>
    </div>
    
    <div class="table-responsive">
        <table class="premium-table">
            <thead>
                <tr>
                    <th>Booking Reg.</th>
                    <th>Vertical</th>
                    <th>Reporter</th>
                    <th>Contention Reason</th>
                    <th>Lodged Date</th>
                    <th>Priority</th>
                    <th style="text-align: right;">Action</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($disputes)): ?>
                    <tr><td colspan="7" class="text-center" style="padding: 5rem; color: var(--text-muted);">The mediation queue is currently empty.</td></tr>
                <?php else: ?>
                    <?php foreach($disputes as $d): ?>
                    <tr>
                        <td><code class="text-sm font-bold" style="color: var(--primary);"><?php echo htmlspecialchars($d['booking_number']); ?></code></td>
                        <td>
                             <span class="text-xs text-muted"><?php echo htmlspecialchars($d['category']); ?></span>
                        </td>
                        <td>
                            <div class="text-sm font-bold"><?php echo htmlspecialchars($d['raised_by_name']); ?></div>
                        </td>
                        <td style="max-width: 240px;">
                            <div class="text-sm" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<?php echo htmlspecialchars($d['reason']); ?>">
                                <?php echo htmlspecialchars($d['reason']); ?>
                            </div>
                        </td>
                        <td>
                            <div class="text-xs"><?php echo date('M d, Y', strtotime($d['created_at'])); ?></div>
                        </td>
                        <td>
                            <span class="status-badge <?php 
                                echo match($d['status']) {
                                    'open' => 'badge-danger',
                                    'under_review' => 'badge-warning',
                                    'resolved' => 'badge-success',
                                    default => 'badge-muted'
                                };
                            ?>">
                                <?php echo ucfirst(str_replace('_', ' ', $d['status'])); ?>
                            </span>
                        </td>
                        <td style="text-align: right;">
                            <?php if ($d['status'] === 'open' || $d['status'] === 'under_review'): ?>
                                <button class="btn-premium btn-primary btn-sm" onclick="openResolveModal(<?php echo $d['id']; ?>)">Resolve</button>
                            <?php else: ?>
                                <button class="btn-premium btn-outline btn-sm" disabled style="opacity: 0.5;">Finalized</button>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>
