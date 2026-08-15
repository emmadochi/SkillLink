<!-- Dispute Arbitration & Mediation Suite -->
<div class="stats-container animate-fade-in">
    <div class="stat-card" style="border-left: 4px solid var(--danger);">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Critical / Open Disputes</span>
                <div class="value" style="color: var(--danger);"><?php echo $open_count; ?></div>
            </div>
            <div class="stat-icon" style="background: var(--danger-bg); color: var(--danger);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="text-muted">Requires arbitration & fund disposition</span>
        </div>
    </div>
    
    <div class="stat-card" style="border-left: 4px solid var(--success);">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Resolution Success</span>
                <div class="value"><?php echo $total > 0 ? round((($total - $open_count) / $total) * 100) : 100; ?>%</div>
            </div>
            <div class="stat-icon" style="background: var(--success-bg); color: var(--success);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="font-bold" style="color: var(--success);">+<?php echo max(0, $total - $open_count); ?> Settled</span>
            <span class="text-muted">cases life-to-date</span>
        </div>
    </div>

    <div class="stat-card" style="border-left: 4px solid var(--info);">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Total Cases Logged</span>
                <div class="value"><?php echo $total; ?></div>
            </div>
            <div class="stat-icon" style="background: var(--info-bg); color: var(--info);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="text-muted">Mediation ledger history</span>
        </div>
    </div>
</div>

<div class="premium-table-card animate-fade-in">
    <div class="card-header">
        <div>
            <h3>Mediation & Arbitration Tribunal</h3>
            <p class="text-xs text-muted mt-1">Platform-assisted conflict resolution, escrow payouts, and customer refunds.</p>
        </div>
        <div class="flex-row gap-3">
            <select class="admin-input" style="width: 180px;" onchange="window.location.href='<?php echo admin_url('dispute'); ?>?status=' + this.value">
                <option value="">All Dispute Statuses</option>
                <option value="open" <?php echo ($status_filter ?? '') === 'open' ? 'selected' : ''; ?>>Open / Critical</option>
                <option value="under_review" <?php echo ($status_filter ?? '') === 'under_review' ? 'selected' : ''; ?>>Under Review</option>
                <option value="resolved" <?php echo ($status_filter ?? '') === 'resolved' ? 'selected' : ''; ?>>Resolved / Settled</option>
                <option value="closed" <?php echo ($status_filter ?? '') === 'closed' ? 'selected' : ''; ?>>Closed / Dismissed</option>
            </select>
            <div style="position: relative;">
                <input type="text" id="disputeTableSearch" placeholder="Filter by Booking # or Name..." class="admin-input" style="width: 230px; padding-left: 2.5rem;" onkeyup="filterDisputeTable(this.value)">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); opacity: 0.4;"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>
        </div>
    </div>
    
    <div class="table-responsive">
        <table class="premium-table" id="disputesTable">
            <thead>
                <tr>
                    <th>Booking Ref</th>
                    <th>Vertical</th>
                    <th>Customer vs. Artisan</th>
                    <th>Escrow Amount</th>
                    <th>Contention Claim</th>
                    <th>Lodged Date</th>
                    <th>Status</th>
                    <th style="text-align: right;">Mediation Action</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($disputes)): ?>
                    <tr><td colspan="8" class="text-center" style="padding: 5rem; color: var(--text-muted);">The dispute arbitration queue is currently clear.</td></tr>
                <?php else: ?>
                    <?php foreach($disputes as $d): ?>
                    <tr>
                        <td>
                            <code class="text-sm font-bold" style="color: var(--primary);">#<?php echo htmlspecialchars($d['booking_number']); ?></code>
                        </td>
                        <td>
                             <span class="text-xs text-muted"><?php echo htmlspecialchars($d['category']); ?></span>
                        </td>
                        <td>
                            <div class="text-sm font-bold"><?php echo htmlspecialchars($d['customer_name']); ?></div>
                            <div class="text-xs text-muted">Artisan: <?php echo htmlspecialchars($d['artisan_name']); ?></div>
                            <div class="text-xs" style="color: var(--primary);">Raised by: <?php echo htmlspecialchars($d['raised_by_name']); ?></div>
                        </td>
                        <td>
                            <strong class="text-sm" style="color: var(--primary);">₦<?php echo number_format($d['price'] ?? 0, 2); ?></strong>
                        </td>
                        <td style="max-width: 220px;">
                            <div class="text-sm" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<?php echo htmlspecialchars($d['reason']); ?>">
                                <?php echo htmlspecialchars($d['reason']); ?>
                            </div>
                        </td>
                        <td>
                            <div class="text-xs font-bold"><?php echo date('M d, Y', strtotime($d['created_at'])); ?></div>
                            <div class="text-xs text-muted"><?php echo date('h:i A', strtotime($d['created_at'])); ?></div>
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
                            <button class="btn-premium btn-primary btn-sm" onclick="SkillLinkArbitration.openCase(<?php echo $d['id']; ?>)">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><polygon points="10 8 16 12 10 16 10 8"/></svg>
                                Arbitrate Case
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
        <p class="text-xs text-muted">Displaying <?php echo count($disputes); ?> of <?php echo $total; ?> active records</p>
        <div class="flex-row gap-2">
            <?php for($i = 1; $i <= ceil($total / $limit); $i++): ?>
                <a href="<?php echo admin_url('dispute'); ?>?page=<?php echo $i; ?>&status=<?php echo $status_filter; ?>" 
                   class="btn-premium <?php echo $i === $current_page ? 'btn-primary' : 'btn-outline'; ?> btn-sm"
                   style="min-width: 38px; justify-content: center;">
                    <?php echo $i; ?>
                </a>
            <?php endfor; ?>
        </div>
    </div>
    <?php endif; ?>
</div>

<script>
function filterDisputeTable(query) {
    const q = query.toLowerCase();
    const rows = document.querySelectorAll('#disputesTable tbody tr');
    rows.forEach(row => {
        const text = row.innerText.toLowerCase();
        row.style.display = text.includes(q) ? '' : 'none';
    });
}
</script>
