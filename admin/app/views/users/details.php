<!-- Artisan Verification Portal -->
<div class="mb-5 animate-fade-in">
    <a href="/SkillLink/admin/user?tab=artisans" class="btn-premium btn-outline btn-sm">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="m15 18-6-6 6-6"/></svg>
        Back to Artisan Directory
    </a>
</div>

<div class="stats-container align-start gap-6">
    <!-- Profile & Dossier -->
    <div class="stat-card" style="padding: 2.5rem; min-height: auto; flex: 2;">
        <div class="flex-row justify-between mb-5 align-start">
            <div class="flex-row gap-4">
                <div class="avatar-circle" style="width: 100px; height: 100px; font-size: 2.5rem; overflow: hidden;">
                    <?php if (!empty($artisan['passport_photo'])): ?>
                        <img src="<?php echo asset_url($artisan['passport_photo']); ?>" alt="Passport" style="width: 100%; height: 100%; object-fit: cover;">
                    <?php else: ?>
                        <?php echo strtoupper(substr($artisan['name'], 0, 1)); ?>
                    <?php endif; ?>
                </div>
                <div>
                    <h1 class="mb-2" style="font-size: 1.85rem;"><?php echo htmlspecialchars($artisan['name']); ?></h1>
                    <div class="flex-row gap-2">
                        <span class="status-badge <?php 
                            echo match($artisan['status']) {
                                'approved' => 'badge-success',
                                'pending' => 'badge-warning',
                                'rejected' => 'badge-danger',
                                default => 'badge-muted'
                            };
                        ?>">
                            <?php echo ucfirst($artisan['status']); ?> Status
                        </span>
                        <span class="status-badge" style="background: <?php echo $artisan['id_status'] === 'approved' ? 'var(--success-bg)' : 'var(--info-bg)'; ?>; color: <?php echo $artisan['id_status'] === 'approved' ? 'var(--success)' : 'var(--info)'; ?>;">
                             <?php echo $artisan['id_status'] === 'approved' ? 'Verified Identity' : 'Identity ' . ucfirst($artisan['id_status'] ?: 'Not Submitted'); ?>
                        </span>
                    </div>
                </div>
            </div>

            <div style="text-align: right;">
                 <span class="input-label mb-1">Platform Rating</span>
                 <div style="font-size: 2rem; font-weight: 800; color: var(--primary); font-family: 'Plus Jakarta Sans';">
                    ⭐ <?php echo number_format($artisan['rating'], 1); ?>
                 </div>
            </div>
        </div>
        
        <div class="dossier-grid" style="border-top: 1px solid var(--border); padding-top: 2rem; margin-top: 1.5rem;">
            <div>
                <label class="input-label mb-2">Primary Skills</label>
                <div class="flex-row gap-2" style="flex-wrap: wrap;">
                    <?php 
                    $skills = explode(',', $artisan['skills'] ?: 'Uncategorized');
                    foreach($skills as $skill): ?>
                        <span style="background: var(--surface); border: 1px solid var(--border); padding: 4px 12px; border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 600;">
                            <?php echo trim($skill); ?>
                        </span>
                    <?php endforeach; ?>
                </div>
            </div>
            <div>
                <label class="input-label mb-2">Contact Information</label>
                <p class="font-bold mb-1"><?php echo htmlspecialchars($artisan['email']); ?></p>
                <p class="text-sm text-muted"><?php echo htmlspecialchars($artisan['phone'] ?: 'No Phone recorded'); ?></p>
            </div>
            <div>
                <label class="input-label mb-2">Professional Experience</label>
                <p class="font-bold" style="color: var(--primary); font-size: 1.125rem;"><?php echo (int)$artisan['experience_years']; ?> Successful Years</p>
            </div>
            <div>
                <label class="input-label mb-2">Base Location</label>
                <div class="flex-row gap-2 font-bold text-sm">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                    <?php echo htmlspecialchars($artisan['location_name'] ?: 'Remote'); ?>
                </div>
            </div>
        </div>
        
        <div class="mb-5" style="margin-top: 2.5rem; padding: 1.5rem; background: var(--surface); border-radius: var(--radius-md); border: 1px solid var(--border);">
            <label class="input-label mb-2">Artisan Biography</label>
            <p class="text-sm" style="line-height: 1.7; color: var(--text-main);"><?php echo nl2br(htmlspecialchars($artisan['bio'] ?: 'The artisan has not provided a biography yet.')); ?></p>
        </div>
        
        <!-- Decision Actions -->
        <div class="flex-row gap-3" style="margin-top: 3rem; border-top: 1px solid var(--border); padding-top: 2rem;">
            <?php if ($artisan['status'] !== 'approved'): ?>
            <form action="/SkillLink/admin/user/approve" method="POST">
                <input type="hidden" name="id" value="<?php echo $artisan['id']; ?>">
                <button type="submit" class="btn-premium btn-primary" style="padding: 0.875rem 2rem; background: var(--success);">
                    Approve Application
                </button>
            </form>
            <?php endif; ?>

            <?php if ($artisan['status'] !== 'rejected'): ?>
            <form action="/SkillLink/admin/user/reject" method="POST">
                <input type="hidden" name="id" value="<?php echo $artisan['id']; ?>">
                <button type="submit" class="btn-premium btn-outline" style="padding: 0.875rem 2rem; color: var(--danger); border-color: var(--danger);">
                    Reject Application
                </button>
            </form>
            <?php endif; ?>
        </div>
    </div>
    
    <!-- Supporting Evidence Section -->
    <div class="flex-column gap-6" style="flex: 1;">
        <div class="stat-card" style="padding: 1.5rem; min-height: auto;">
            <h3 class="flex-row gap-2 mb-4" style="font-size: 1rem;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                Portfolio Gallery
            </h3>
            <div class="portfolio-grid">
                <?php if (empty($artisan['portfolio'])): ?>
                    <p class="text-sm text-muted">No portfolio items uploaded.</p>
                <?php else: ?>
                    <?php foreach($artisan['portfolio'] as $work): ?>
                    <div class="portfolio-item animate-fade-in" style="position: relative; border-radius: var(--radius-md); overflow: hidden; height: 160px;">
                        <img src="<?php echo asset_url($work['image_url']); ?>" alt="<?php echo htmlspecialchars($work['description']); ?>" style="width: 100%; height: 100%; object-fit: cover;">
                        <div style="position: absolute; bottom: 0; left: 0; right: 0; background: linear-gradient(transparent, rgba(0,0,0,0.8)); padding: 12px; color: white;">
                            <span style="font-size: 0.75rem; font-weight: 600;"><?php echo htmlspecialchars($work['description']); ?></span>
                        </div>
                    </div>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </div>

        <div class="stat-card" style="padding: 1.5rem; min-height: auto; background: var(--primary); color: white;">
            <h3 class="mb-4" style="color: var(--accent); font-size: 0.875rem; text-transform: uppercase;">Compliance Checklist</h3>
            <div class="compliance-list">
                <div class="compliance-item">
                    <span><?php echo strtoupper(str_replace('_', ' ', $artisan['id_type'] ?: 'Identity ID')); ?></span>
                    <span style="color: <?php echo $artisan['id_status'] === 'approved' ? 'var(--success)' : 'var(--accent)'; ?>; font-weight: 800;">
                        <?php echo $artisan['id_status'] === 'approved' ? '✓ Verified' : '— ' . ucfirst($artisan['id_status'] ?: 'Pending'); ?>
                    </span>
                </div>
                <?php if ($artisan['id_image_front']): ?>
                <div class="flex-column gap-2 mt-3">
                    <label class="text-xs opacity-70">ID Front</label>
                    <img src="<?php echo asset_url($artisan['id_image_front']); ?>" style="width: 100%; border-radius: 4px; cursor: pointer;" onclick="window.open(this.src)">
                </div>
                <?php endif; ?>
                <?php if ($artisan['id_image_back']): ?>
                <div class="flex-column gap-2 mt-2">
                    <label class="text-xs opacity-70">ID Back</label>
                    <img src="<?php echo asset_url($artisan['id_image_back']); ?>" style="width: 100%; border-radius: 4px; cursor: pointer;" onclick="window.open(this.src)">
                </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>
