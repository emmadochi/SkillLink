<!-- Payment Management View -->
<div class="stats-grid mb-5">
    <div class="stat-card glass">
        <div class="stat-label">Total Platform Balance</div>
        <div class="stat-value text-primary"><?php echo $balance; ?></div>
        <p class="text-xs mt-2 text-outline">Escrow & Settled funds</p>
    </div>
    <div class="stat-card glass">
        <div class="stat-label">Net Platform Revenue (MTD)</div>
        <div class="stat-value" style="color: #2e7d32;"><?php echo $monthly_revenue; ?></div>
        <p class="text-xs mt-2 text-outline">10% commission on bookings</p>
    </div>
</div>

<div class="glass p-5 rounded-3xl">
    <div class="flex-row justify-between mb-5">
        <h3>Transaction Logs</h3>
        <button class="btn btn-outlined btn-sm">Export CSV</button>
    </div>
    
    <table class="admin-table">
        <thead>
            <tr>
                <th>Transaction ID</th>
                <th>User</th>
                <th>Amount</th>
                <th>Platform Fee</th>
                <th>Date</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach($transactions as $t): ?>
            <tr>
                <td><code class="text-xs"><?php echo $t['id']; ?></code></td>
                <td><strong><?php echo $t['customer']; ?></strong></td>
                <td><?php echo $t['amount']; ?></td>
                <td><span class="text-outline"><?php echo $t['fee']; ?></span></td>
                <td><?php echo $t['date']; ?></td>
                <td><span class="badge success"><?php echo $t['status']; ?></span></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>

<style>
    .text-primary { color: var(--primary); }
</style>
