<!-- Live Operations Command Center -->
<div class="operations-hud animate-fade-in">
    <!-- KPI Overview Cards -->
    <div class="stats-container" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); margin-bottom: 1.25rem;">
        <div class="stat-card" style="border-left: 4px solid var(--primary); padding: 1.25rem;">
            <div class="stat-header">
                <div class="stat-info">
                    <span class="label flex-row gap-2">
                        <span class="live-dot pulse-primary"></span> Active Jobs
                    </span>
                    <div class="value" id="kpi-active-jobs" style="font-size: 1.75rem;"><?php echo $kpis['active_jobs'] ?? 0; ?></div>
                </div>
                <div class="stat-icon" style="background: var(--info-bg); color: var(--info); width: 42px; height: 42px;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                </div>
            </div>
            <div class="stat-footer text-xs text-muted">Across city grid</div>
        </div>

        <div class="stat-card" style="border-left: 4px solid var(--warning); padding: 1.25rem;">
            <div class="stat-header">
                <div class="stat-info">
                    <span class="label flex-row gap-2">
                        <span class="live-dot pulse-warning"></span> In Progress
                    </span>
                    <div class="value" id="kpi-in-progress" style="font-size: 1.75rem; color: var(--warning);"><?php echo $kpis['in_progress_jobs'] ?? 0; ?></div>
                </div>
                <div class="stat-icon" style="background: var(--warning-bg); color: var(--warning); width: 42px; height: 42px;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                </div>
            </div>
            <div class="stat-footer text-xs text-muted">Active job sites</div>
        </div>

        <div class="stat-card" style="border-left: 4px solid var(--info); padding: 1.25rem;">
            <div class="stat-header">
                <div class="stat-info">
                    <span class="label">En Route / Arrived</span>
                    <div class="value" id="kpi-en-route" style="font-size: 1.75rem;"><?php echo $kpis['en_route_jobs'] ?? 0; ?></div>
                </div>
                <div class="stat-icon" style="background: var(--info-bg); color: var(--info); width: 42px; height: 42px;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
                </div>
            </div>
            <div class="stat-footer text-xs text-muted">Artisans dispatched</div>
        </div>

        <div class="stat-card" style="border-left: 4px solid var(--success); padding: 1.25rem;">
            <div class="stat-header">
                <div class="stat-info">
                    <span class="label">Artisans On-Duty</span>
                    <div class="value" id="kpi-artisans" style="font-size: 1.75rem; color: var(--success);"><?php echo $kpis['on_duty_artisans'] ?? 0; ?></div>
                </div>
                <div class="stat-icon" style="background: var(--success-bg); color: var(--success); width: 42px; height: 42px;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><polyline points="16 11 18 13 22 9"/></svg>
                </div>
            </div>
            <div class="stat-footer text-xs text-muted">Online & Available</div>
        </div>

        <div class="stat-card" style="border-left: 4px solid <?php echo ($kpis['open_disputes'] ?? 0) > 0 ? 'var(--danger)' : 'var(--border)'; ?>; padding: 1.25rem;">
            <div class="stat-header">
                <div class="stat-info">
                    <span class="label">Mediation Queue</span>
                    <div class="value" id="kpi-disputes" style="font-size: 1.75rem; color: <?php echo ($kpis['open_disputes'] ?? 0) > 0 ? 'var(--danger)' : 'inherit'; ?>;">
                        <?php echo $kpis['open_disputes'] ?? 0; ?>
                    </div>
                </div>
                <div class="stat-icon" style="background: var(--danger-bg); color: var(--danger); width: 42px; height: 42px;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                </div>
            </div>
            <div class="stat-footer text-xs text-muted">₦<?php echo number_format($kpis['escrow_at_risk'] ?? 0, 2); ?> at stake</div>
        </div>
    </div>

    <!-- Main Operations Canvas (Split Feed + Map) -->
    <div class="operations-grid">
        
        <!-- Left Sidebar: Job & Dispatch Feed -->
        <div class="ops-feed-panel">
            <div class="ops-feed-header">
                <div class="flex-row justify-between align-start mb-3">
                    <div>
                        <h3 style="font-size: 1.1rem; font-weight: 700;">Active Jobs Feed</h3>
                        <p class="text-xs text-muted">Real-time citywide service dispatches</p>
                    </div>
                    <span class="badge-count" id="feedJobCount"><?php echo count($active_jobs); ?></span>
                </div>

                <!-- Search & Filters -->
                <div class="ops-filter-box">
                    <div style="position: relative; margin-bottom: 0.5rem;">
                        <input type="text" id="opsJobSearch" placeholder="Search ref, artisan, client..." class="admin-input" style="width: 100%; padding-left: 2.2rem; font-size: 0.82rem; height: 36px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="position: absolute; left: 0.8rem; top: 50%; transform: translateY(-50%); opacity: 0.4;"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
                    </div>

                    <div class="filter-chips">
                        <button class="chip active" data-status="all">All</button>
                        <button class="chip" data-status="in_progress">In Progress</button>
                        <button class="chip" data-status="en_route">En Route</button>
                        <button class="chip" data-status="pending">Pending</button>
                    </div>
                </div>
            </div>

            <!-- List of Jobs -->
            <div class="ops-job-list" id="opsJobList">
                <?php if (empty($active_jobs)): ?>
                    <div class="text-center p-5 text-muted text-sm">
                        <div class="mb-2" style="font-size: 1.8rem; opacity: 0.4;">🛰️</div>
                        No active jobs in the field right now.
                    </div>
                <?php else: ?>
                    <?php foreach ($active_jobs as $job): ?>
                        <div class="ops-job-card" id="job-card-<?php echo $job['id']; ?>" onclick="SkillLinkOps.focusJob(<?php echo $job['id']; ?>)">
                            <div class="flex-row justify-between mb-2">
                                <span class="job-ref">#<?php echo htmlspecialchars($job['booking_number']); ?></span>
                                <span class="status-badge <?php 
                                    echo match($job['status']) {
                                        'in_progress' => 'badge-warning',
                                        'arrived', 'confirmed' => 'badge-info',
                                        'completed' => 'badge-success',
                                        'cancelled' => 'badge-danger',
                                        default => 'badge-muted'
                                    };
                                ?>">
                                    <?php echo ucfirst(str_replace('_', ' ', $job['status'])); ?>
                                </span>
                            </div>

                            <div class="job-service-name">
                                <span class="job-category-tag"><?php echo htmlspecialchars($job['category']['name']); ?></span>
                                <span><?php echo htmlspecialchars($job['service_description']); ?></span>
                            </div>

                            <div class="job-parties">
                                <div class="party-item">
                                    <span class="party-label">Artisan</span>
                                    <span class="party-name"><?php echo htmlspecialchars($job['artisan']['name']); ?></span>
                                </div>
                                <div class="party-item">
                                    <span class="party-label">Customer</span>
                                    <span class="party-name"><?php echo htmlspecialchars($job['customer']['name']); ?></span>
                                </div>
                            </div>

                            <div class="job-card-footer flex-row justify-between">
                                <span class="job-price">₦<?php echo number_format($job['price'], 2); ?></span>
                                <span class="text-xs text-muted"><?php echo date('h:i A', strtotime($job['created_at'])); ?></span>
                            </div>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </div>

        <!-- Right / Main Canvas: Interactive Map & HUD Toolbar -->
        <div class="ops-map-container">
            <!-- Map Top Toolbar -->
            <div class="ops-map-toolbar">
                <div class="flex-row gap-2">
                    <span class="radar-status flex-row gap-2">
                        <span class="radar-ping"></span>
                        <span class="text-xs font-bold" id="radarSyncLabel">LIVE SYNC ACTIVE</span>
                    </span>
                    <span class="text-xs text-muted" id="lastUpdatedTime">Updated just now</span>
                </div>

                <div class="flex-row gap-3">
                    <!-- Layer Toggles -->
                    <div class="map-layer-toggles">
                        <label class="toggle-checkbox-label">
                            <input type="checkbox" id="layerArtisans" checked onchange="SkillLinkOps.toggleLayer('artisans')">
                            <span>Artisans (<span id="artisanMarkerCount"><?php echo count($on_duty_artisans); ?></span>)</span>
                        </label>
                        <label class="toggle-checkbox-label">
                            <input type="checkbox" id="layerJobs" checked onchange="SkillLinkOps.toggleLayer('jobs')">
                            <span>Job Sites (<span id="jobMarkerCount"><?php echo count($active_jobs); ?></span>)</span>
                        </label>
                        <label class="toggle-checkbox-label">
                            <input type="checkbox" id="layerVectors" checked onchange="SkillLinkOps.toggleLayer('vectors')">
                            <span>Route Lines</span>
                        </label>
                    </div>

                    <!-- Auto-Sync Interval -->
                    <select id="autoSyncInterval" class="admin-input" style="height: 32px; font-size: 0.8rem; padding: 2px 8px; width: 120px;" onchange="SkillLinkOps.setSyncInterval(this.value)">
                        <option value="10">Auto (10s)</option>
                        <option value="30" selected>Auto (30s)</option>
                        <option value="60">Auto (60s)</option>
                        <option value="0">Paused</option>
                    </select>

                    <button class="btn-premium btn-primary btn-sm" id="btnManualSync" onclick="SkillLinkOps.fetchFeed()" title="Refresh telemetry">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"/></svg>
                        Sync
                    </button>
                </div>
            </div>

            <!-- Leaflet Map Canvas -->
            <div id="operationsMap" class="ops-leaflet-map"></div>

            <!-- Floating Map Legend -->
            <div class="ops-map-legend">
                <div class="legend-title">Live Map Legend</div>
                <div class="legend-items">
                    <div class="legend-item"><span class="legend-marker marker-job-progress"></span> In Progress Site</div>
                    <div class="legend-item"><span class="legend-marker marker-job-route"></span> En Route / Arrived</div>
                    <div class="legend-item"><span class="legend-marker marker-job-pending"></span> Pending Request</div>
                    <div class="legend-item"><span class="legend-marker marker-artisan-live"></span> Live GPS Artisan</div>
                    <div class="legend-item"><span class="legend-marker marker-artisan-idle"></span> Available Artisan</div>
                </div>
            </div>

            <!-- Selected Job Inspector Drawer (Sliding Overlay) -->
            <div id="jobInspectorDrawer" class="job-inspector-drawer">
                <div class="inspector-header">
                    <div class="flex-row gap-3">
                        <div class="inspector-badge" id="inspCategoryIcon">🔧</div>
                        <div>
                            <h4 id="inspBookingNumber">#SL-BOOKING</h4>
                            <span class="text-xs text-muted" id="inspCategoryName">Plumbing Service</span>
                        </div>
                    </div>
                    <button class="modal-close" onclick="SkillLinkOps.closeInspector()">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 6 6 18M6 6l12 12"/></svg>
                    </button>
                </div>

                <div class="inspector-body">
                    <!-- Status & Escrow Bar -->
                    <div class="flex-row justify-between p-3 mb-3" style="background: var(--surface); border-radius: var(--radius-sm); border: 1px solid var(--border);">
                        <div>
                            <span class="text-xs text-muted">Status</span>
                            <div id="inspStatusBadge" class="status-badge badge-warning mt-1">In Progress</div>
                        </div>
                        <div style="text-align: right;">
                            <span class="text-xs text-muted">Escrow Amount</span>
                            <div class="font-bold text-sm" style="color: var(--primary);" id="inspPrice">₦0.00</div>
                        </div>
                    </div>

                    <!-- Service Description -->
                    <div class="mb-3">
                        <label class="text-xs text-muted font-bold">Service Requirement</label>
                        <p class="text-sm mt-1" id="inspDescription" style="color: var(--text-main);">-</p>
                    </div>

                    <!-- Parties Grid -->
                    <div class="inspector-parties-grid">
                        <div class="inspector-party-card">
                            <div class="flex-row gap-2 mb-2">
                                <div class="avatar-circle" style="width: 28px; height: 28px; font-size: 11px;" id="inspArtisanAvatar">A</div>
                                <div>
                                    <div class="text-xs font-bold" id="inspArtisanName">Artisan</div>
                                    <span class="text-xs text-muted" id="inspArtisanRating">⭐ 5.0</span>
                                </div>
                            </div>
                            <div class="text-xs text-muted" id="inspArtisanLoc">Location: Metro Area</div>
                            <div class="mt-2">
                                <a href="#" id="inspArtisanCall" class="btn-premium btn-outline btn-sm w-100" style="padding: 4px 8px; font-size: 0.75rem;">
                                    📞 Call Artisan
                                </a>
                            </div>
                        </div>

                        <div class="inspector-party-card">
                            <div class="flex-row gap-2 mb-2">
                                <div class="avatar-circle" style="width: 28px; height: 28px; font-size: 11px;" id="inspCustomerAvatar">C</div>
                                <div>
                                    <div class="text-xs font-bold" id="inspCustomerName">Customer</div>
                                    <span class="text-xs text-muted">Client</span>
                                </div>
                            </div>
                            <div class="text-xs text-muted" id="inspCustomerPhone">Phone: N/A</div>
                            <div class="mt-2">
                                <a href="#" id="inspCustomerCall" class="btn-premium btn-outline btn-sm w-100" style="padding: 4px 8px; font-size: 0.75rem;">
                                    📞 Call Client
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Dispatch Controls -->
                    <div class="inspector-actions mt-4">
                        <label class="text-xs text-muted font-bold mb-2 block">Dispatcher Intervention</label>
                        <div class="flex-row gap-2">
                            <button class="btn-premium btn-outline btn-sm flex-1" onclick="SkillLinkOps.dispatchAction('arrived')">Mark Arrived</button>
                            <button class="btn-premium btn-outline btn-sm flex-1" onclick="SkillLinkOps.dispatchAction('in_progress')">In Progress</button>
                            <button class="btn-premium btn-outline btn-sm flex-1" onclick="SkillLinkOps.dispatchAction('completed')">Complete</button>
                        </div>
                        <div class="flex-row gap-2 mt-2">
                            <button class="btn-premium btn-outline btn-sm flex-1" style="color: var(--danger); border-color: var(--danger);" onclick="SkillLinkOps.dispatchAction('cancelled')">Emergency Cancel</button>
                            <a href="<?php echo admin_url('dispute'); ?>" class="btn-premium btn-primary btn-sm flex-1" style="text-align: center;">Open Dispute Room</a>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- Operations Map Controller Initialization -->
<script>
window.initialOpsData = {
    jobs: <?php echo json_encode($active_jobs); ?>,
    artisans: <?php echo json_encode($on_duty_artisans); ?>,
    kpis: <?php echo json_encode($kpis); ?>,
    feedUrl: '<?php echo admin_url('operations/feed'); ?>',
    updateStatusUrl: '<?php echo admin_url('operations/updateStatus'); ?>'
};
</script>
