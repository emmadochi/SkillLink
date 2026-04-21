<!-- Platform Settings View -->
<div class="flex-row gap-6 items-start">
    <!-- Categories Manager -->
    <div class="glass p-5 rounded-3xl" style="flex: 2;">
        <div class="flex-row justify-between mb-5">
            <h3>Service Categories</h3>
            <button class="btn btn-sm">+ Add Category</button>
        </div>
        
        <div class="category-grid">
            <?php foreach($categories as $cat): ?>
            <div class="card p-3 flex-row justify-between mb-2 rounded-xl" style="background: rgba(255,255,255,0.5); border: 1px solid #eee;">
                <div>
                    <strong><?php echo $cat['name']; ?></strong>
                    <div class="text-xs text-outline"><?php echo $cat['count']; ?> Artisans linked</div>
                </div>
                <div class="flex-row gap-2">
                    <button class="btn-icon">✎</button>
                    <button class="btn-icon" style="color: #c62828;">🗑</button>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    
    <!-- System Configuration -->
    <div class="glass p-5 rounded-3xl" style="flex: 1;">
        <h3 class="mb-4">System Config</h3>
        
        <div class="mt-4">
            <label class="text-xs text-outline uppercase font-bold">Platform Commission</label>
            <div class="flex-row gap-2 mt-1">
                <input type="text" class="admin-input" value="<?php echo $settings['platform_fee']; ?>" style="flex: 1;">
                <button class="btn btn-sm">Save</button>
            </div>
        </div>
        
        <div class="mt-5">
            <label class="text-xs text-outline uppercase font-bold">Minimum Payout</label>
            <div class="flex-row gap-2 mt-1">
                <input type="text" class="admin-input" value="<?php echo $settings['min_payout']; ?>" style="flex: 1;">
                <button class="btn btn-sm">Save</button>
            </div>
        </div>
        
        <div class="mt-5">
            <label class="text-xs text-outline uppercase font-bold">Support Email</label>
            <div class="mt-1">
                <input type="text" class="admin-input" value="<?php echo $settings['support_email']; ?>" style="width: 100%;">
            </div>
        </div>
        
        <div class="mt-8 border-t pt-5">
            <button class="btn btn-outlined w-full" style="width: 100%;">System Maintenance Mode</button>
        </div>
    </div>
</div>

<style>
    .w-full { width: 100%; }
    .mt-4 { margin-top: 16px; }
    .mt-8 { margin-top: 48px; }
    .border-t { border-top: 1px solid #eee; }
    .pt-5 { padding-top: 24px; }
</style>
