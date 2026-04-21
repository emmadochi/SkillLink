<!-- Platform Configuration & CMS -->
<div class="stats-container animate-fade-in align-start gap-6">
    <!-- Service Vertical Management -->
    <div class="premium-table-card" style="flex: 2;">
        <div class="card-header">
            <div>
                <h3 class="text-sm">Service Taxonomy</h3>
                <p class="text-xs text-muted mt-1">Define and manage active service verticals on the platform.</p>
            </div>
            <button class="btn-premium btn-primary btn-sm" onclick="showAddCategory()">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                Add Vertical
            </button>
        </div>
        
        <div style="padding: 1.5rem; display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.25rem;">
            <?php if (empty($categories)): ?>
                <div class="text-center" style="grid-column: span 2; padding: 3rem; color: var(--text-muted);">No service categories defined.</div>
            <?php else: ?>
                <?php foreach($categories as $cat): ?>
                <div class="stat-card" style="padding: 1.25rem; min-height: auto; flex-direction: row; align-items: center; justify-content: space-between;">
                    <div class="flex-row gap-3">
                        <div class="stat-icon" style="width: 40px; height: 40px; font-size: 1.125rem;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                        </div>
                        <div>
                            <strong class="text-sm" style="display: block; color: var(--primary);"><?php echo htmlspecialchars($cat['name']); ?></strong>
                            <span class="text-xs text-muted font-bold"><?php echo (int)$cat['artisan_count']; ?> Professionals</span>
                        </div>
                    </div>
                    <div class="flex-row gap-2">
                        <button class="btn-premium btn-outline btn-icon-only" onclick="editCategory(<?php echo $cat['id']; ?>, '<?php echo addslashes($cat['name']); ?>')">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                        <button class="btn-premium btn-outline btn-icon-only" style="color: var(--danger); border-color: rgba(239, 68, 68, 0.2);" onclick="deleteCategory(<?php echo $cat['id']; ?>)">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                        </button>
                    </div>
                </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
    
    <!-- Platform System Config -->
    <div class="flex-column gap-6" style="flex: 1;">
        <div class="stat-card" style="padding: 1.5rem; min-height: auto;">
            <h3 class="flex-row gap-2 mb-5" style="font-size: 1rem;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                System Config
            </h3>
            
            <div class="flex-column gap-5">
                <div>
                    <label class="input-label mb-2">Service Commission (%)</label>
                    <div class="flex-row gap-2">
                        <input type="text" class="admin-input font-bold" value="<?php echo htmlspecialchars($settings['platform_fee']); ?>" style="flex: 1;">
                        <button class="btn-premium btn-primary btn-sm">Update</button>
                    </div>
                </div>
                
                <div>
                    <label class="input-label mb-2">Minimum Settlement</label>
                    <div class="flex-row gap-2">
                         <input type="text" class="admin-input font-bold" value="<?php echo htmlspecialchars($settings['min_payout']); ?>" style="flex: 1;">
                         <button class="btn-premium btn-primary btn-sm">Update</button>
                    </div>
                </div>

                <div>
                    <label class="input-label mb-2">Operations Support Email</label>
                    <input type="text" class="admin-input font-bold" value="<?php echo htmlspecialchars($settings['support_email']); ?>">
                </div>
            </div>

            <div style="margin-top: 2.5rem; padding-top: 1.5rem; border-top: 1px solid var(--border);">
                <button class="btn-premium btn-outline" style="width: 100%; justify-content: center; color: var(--danger); border-color: var(--danger);">
                     Initialize Maintenance Mode
                </button>
            </div>
        </div>
    </div>
</div>
