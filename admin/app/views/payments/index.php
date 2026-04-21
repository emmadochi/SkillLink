<!-- Financial Management Overview -->
<div class="stats-container animate-fade-in">
    <div class="stat-card" style="border-left: 4px solid var(--primary);">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Escrow Balance</span>
                <div class="value"><?php echo $balance; ?></div>
            </div>
            <div class="stat-icon" style="background: var(--info-bg); color: var(--info);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="text-muted">Awaiting freelancer settlement</span>
        </div>
    </div>
    
    <div class="stat-card" style="border-left: 4px solid var(--success);">
        <div class="stat-header">
            <div class="stat-info">
                <span class="label">Net Commission (MTD)</span>
                <div class="value" style="color: var(--success);"><?php echo $monthly_revenue; ?></div>
            </div>
            <div class="stat-icon" style="background: var(--success-bg); color: var(--success);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
            </div>
        </div>
        <div class="stat-footer">
            <span class="font-bold" style="color: var(--success);">+8.4%</span>
            <span class="text-muted">growth vs last month</span>
        </div>
    </div>
</div>

<div class="premium-table-card animate-fade-in">
    <div class="card-header">
        <h3 class="text-sm">Transaction Ledger</h3>
        <button class="btn-premium btn-primary btn-sm">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            Export Statement
        </button>
    </div>
    
    <div class="table-responsive">
        <table class="premium-table">
            <thead>
                <tr>
                    <th>Ref #</th>
                    <th>User / Recipient</th>
                    <th>Type</th>
                    <th>Gross Amount</th>
                    <th>Plat. Fee (10%)</th>
                    <th>Settled At</th>
                    <th>Fulfillment</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($transactions)): ?>
                    <tr><td colspan="7" class="text-center" style="padding: 5rem; color: var(--text-muted);">No financial records in the ledger.</td></tr>
                <?php else: ?>
                    <?php foreach($transactions as $t): ?>
                    <tr>
                        <td><code class="text-xs text-muted"><?php echo htmlspecialchars($t['payment_reference'] ?: 'MANUAL_REF'); ?></code></td>
                        <td>
                            <div class="text-sm font-bold"><?php echo htmlspecialchars($t['user_name']); ?></div>
                            <div class="text-xs text-muted"><?php echo $t['booking_number'] ? 'Booking #'.$t['booking_number'] : 'Direct Payment'; ?></div>
                        </td>
                        <td>
                            <span class="text-xs font-bold" style="text-transform: uppercase; color: var(--primary);">
                                <?php echo htmlspecialchars($t['type']); ?>
                            </span>
                        </td>
                        <td><strong class="text-sm">₦<?php echo number_format($t['amount'], 2); ?></strong></td>
                        <td><span class="text-sm font-bold" style="color: var(--success);">₦<?php echo number_format($t['fee'], 2); ?></span></td>
                        <td>
                            <div class="text-sm"><?php echo date('M d, Y', strtotime($t['created_at'])); ?></div>
                        </td>
                        <td>
                            <span class="status-badge <?php echo $t['status'] === 'successful' ? 'badge-success' : ($t['status'] === 'failed' ? 'badge-danger' : 'badge-warning'); ?>">
                                <?php echo ucfirst($t['status']); ?>
                            </span>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

    <?php if ($total_transactions > $limit): ?>
    <div class="card-header py-3" style="justify-content: flex-end; background: var(--surface);">
        <div class="flex-row gap-2">
            <?php for($i = 1; $i <= ceil($total_transactions / $limit); $i++): ?>
                <a href="/SkillLink/admin/payment?page=<?php echo $i; ?>" 
                   class="btn-premium <?php echo $i === $current_page ? 'btn-primary' : 'btn-outline'; ?> btn-sm"
                   style="min-width: 38px; justify-content: center;">
                    <?php echo $i; ?>
                </a>
            <?php endfor; ?>
        </div>
    </div>
    <?php endif; ?>
</div>
