/**
 * SkillLink Admin - Premium Interactivity System
 * Handles custom modals, tab switching, interactive live operations map, and dispute arbitration suite.
 */

const SkillLinkModal = {
    overlay: null,
    content: null,
    
    init() {
        this.overlay = document.getElementById('modalOverlay');
        this.content = document.getElementById('modalContent');
        
        // Close on overlay click
        if (this.overlay) {
            this.overlay.addEventListener('click', (e) => {
                if (e.target === this.overlay) this.hide();
            });
        }
    },
    
    show(title, bodyHtml, footerHtml) {
        if (!this.overlay) this.init();
        
        const titleEl = this.overlay.querySelector('.modal-header h3');
        const bodyEl = this.overlay.querySelector('.modal-body');
        const footerEl = this.overlay.querySelector('.modal-footer');
        
        if (titleEl) titleEl.textContent = title;
        if (bodyEl) bodyEl.innerHTML = bodyHtml;
        if (footerEl) footerEl.innerHTML = footerHtml || '';
        
        this.overlay.classList.add('active');
        document.body.style.overflow = 'hidden';
    },
    
    hide() {
        if (this.overlay) {
            this.overlay.classList.remove('active');
            document.body.style.overflow = '';
        }
    }
};

/**
 * Switch between tabs in the Users view
 */
function switchTab(tab) {
    const tabs = ['customers', 'artisans'];
    tabs.forEach(t => {
        const tabEl = document.getElementById(t + '-tab');
        const btnEl = document.getElementById('btn-' + t);
        if (tabEl) tabEl.classList.add('hidden');
        if (btnEl) {
            btnEl.classList.remove('btn-primary');
            btnEl.classList.add('btn-outline');
        }
    });
    
    const activeTab = document.getElementById(tab + '-tab');
    const activeBtn = document.getElementById('btn-' + tab);
    if (activeTab) activeTab.classList.remove('hidden');
    if (activeBtn) {
        activeBtn.classList.add('btn-primary');
        activeBtn.classList.remove('btn-outline');
    }
}

/**
 * Generic helper to submit data via a POST request using a hidden form
 */
function submitHiddenForm(action, data) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = action;
    
    for (const key in data) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = key;
        input.value = data[key];
        form.appendChild(input);
    }
    
    document.body.appendChild(form);
    form.submit();
}

/**
 * Category Management Helpers
 */
function showAddCategory() {
    const body = `
        <div class="flex-column gap-3">
            <label class="input-label">Vertical Name</label>
            <input type="text" id="categoryName" class="admin-input" placeholder="e.g. Electrician, Plumbing">
        </div>
    `;
    
    const footer = `
        <button class="btn-premium btn-outline" onclick="SkillLinkModal.hide()">Cancel</button>
        <button class="btn-premium btn-primary" onclick="confirmAddCategory()">Create Vertical</button>
    `;
    
    SkillLinkModal.show('Add Service Vertical', body, footer);
}

function confirmAddCategory() {
    const name = document.getElementById('categoryName').value;
    if (!name) return;
    submitHiddenForm('/SkillLink/admin/settings/addCategory', { name });
}

function editCategory(id, currentName) {
    const body = `
        <div class="flex-column gap-3">
            <label class="input-label">Vertical Name</label>
            <input type="text" id="editCategoryName" class="admin-input" value="${currentName}">
        </div>
    `;
    
    const footer = `
        <button class="btn-premium btn-outline" onclick="SkillLinkModal.hide()">Cancel</button>
        <button class="btn-premium btn-primary" onclick="confirmEditCategory(${id})">Save Changes</button>
    `;
    
    SkillLinkModal.show('Edit Vertical', body, footer);
}

function confirmEditCategory(id) {
    const name = document.getElementById('editCategoryName').value;
    if (!name) return;
    submitHiddenForm('/SkillLink/admin/settings/updateCategory', { id, name });
}

function deleteCategory(id) {
    const body = `
        <p class="text-sm">Are you sure you want to delete this category? This might affect artisan associations.</p>
    `;
    
    const footer = `
        <button class="btn-premium btn-outline" onclick="SkillLinkModal.hide()">Cancel</button>
        <button class="btn-premium btn-primary" style="background: var(--danger);" onclick="submitHiddenForm('/SkillLink/admin/settings/deleteCategory', { id })">Delete Anyway</button>
    `;
    
    SkillLinkModal.show('Delete Vertical', body, footer);
}

// Backward compatible aliases
function openResolveModal(id) {
    SkillLinkArbitration.openCase(id);
}

/**
 * =========================================================================
 * SkillLink Dispute Arbitration & Mediation Suite
 * =========================================================================
 */
const SkillLinkArbitration = {
    currentCase: null,
    selectedRuling: 'full_refund',

    openCase(disputeId) {
        SkillLinkModal.show(
            'Loading Dispute Case...',
            '<div class="text-center p-5"><div class="spinner mb-2"></div><span class="text-muted text-sm">Retrieving case files & chat transcripts...</span></div>',
            ''
        );

        fetch(`/SkillLink/admin/dispute/details?id=${disputeId}`, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(res => res.json())
        .then(json => {
            if (json.status === 'success') {
                this.currentCase = json.data;
                this.renderModal();
            } else {
                alert(json.message || 'Failed to load case');
                SkillLinkModal.hide();
            }
        })
        .catch(err => {
            console.error('Case fetch error:', err);
            alert('Error loading dispute details');
            SkillLinkModal.hide();
        });
    },

    renderModal() {
        const d = this.currentCase;
        const price = parseFloat(d.price || 0);

        const bodyHtml = `
            <div class="modal-tabs">
                <button class="modal-tab-btn active" id="tabBtnCase" onclick="SkillLinkArbitration.switchTab('case')">📋 Case File</button>
                <button class="modal-tab-btn" id="tabBtnChat" onclick="SkillLinkArbitration.switchTab('chat')">💬 Chat Evidence (${d.chat_evidence ? d.chat_evidence.length : 0})</button>
                <button class="modal-tab-btn" id="tabBtnRuling" onclick="SkillLinkArbitration.switchTab('ruling')">⚖️ Arbitration Ruling</button>
            </div>

            <!-- Tab 1: Case File Overview -->
            <div id="tabContentCase">
                <div class="flex-row justify-between p-3 mb-3" style="background: var(--surface); border-radius: var(--radius-sm); border: 1px solid var(--border);">
                    <div>
                        <div class="text-xs text-muted">Booking Reference</div>
                        <code class="text-sm font-bold" style="color: var(--primary);">#${d.booking_number}</code>
                        <div class="text-xs text-muted mt-1">${d.category_name || 'General Service'}</div>
                    </div>
                    <div style="text-align: right;">
                        <div class="text-xs text-muted">Escrow Amount at Stake</div>
                        <div class="font-bold text-sm" style="color: var(--primary); font-size: 1.1rem;">₦${price.toLocaleString('en-US', {minimumFractionDigits: 2})}</div>
                        <span class="status-badge ${d.status === 'open' ? 'badge-danger' : (d.status === 'under_review' ? 'badge-warning' : 'badge-success')}">
                            ${d.status.toUpperCase()}
                        </span>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="text-xs text-muted font-bold">Contention Claim / Reason</label>
                    <div class="p-3 mt-1" style="background: #fef2f2; border: 1px solid rgba(239,68,68,0.2); border-radius: var(--radius-sm); color: #991b1b; font-size: 0.85rem;">
                        "${d.reason || 'No description provided'}"
                        <div class="text-xs text-muted mt-1">Raised by: <strong>${d.raised_by_name}</strong> (${d.raised_by_role}) on ${new Date(d.created_at).toLocaleString()}</div>
                    </div>
                </div>

                <div class="inspector-parties-grid mb-3">
                    <div class="inspector-party-card">
                        <span class="party-label">Customer</span>
                        <strong class="text-sm">${d.customer_name}</strong>
                        <div class="text-xs text-muted">${d.customer_email || ''} | ${d.customer_phone || 'N/A'}</div>
                    </div>
                    <div class="inspector-party-card">
                        <span class="party-label">Artisan</span>
                        <strong class="text-sm">${d.artisan_name}</strong>
                        <div class="text-xs text-muted">${d.artisan_email || ''} | ${d.artisan_phone || 'N/A'}</div>
                    </div>
                </div>

                ${d.resolution ? `
                <div class="p-3 mb-3" style="background: #ecfdf5; border: 1px solid rgba(16,185,129,0.2); border-radius: var(--radius-sm);">
                    <label class="text-xs text-muted font-bold" style="color: var(--success);">Previous Ruling / Resolution Record</label>
                    <p class="text-sm mt-1 mb-0">${d.resolution}</p>
                </div>` : ''}
            </div>

            <!-- Tab 2: Chat Evidence -->
            <div id="tabContentChat" class="hidden">
                <div class="chat-evidence-container" id="chatEvidenceList">
                    ${(!d.chat_evidence || d.chat_evidence.length === 0) 
                        ? '<div class="text-center p-4 text-muted text-xs">No direct chat messages recorded between parties.</div>'
                        : d.chat_evidence.map(msg => `
                            <div class="chat-msg ${parseInt(msg.sender_id) === parseInt(d.customer_id) ? 'msg-customer' : 'msg-artisan'}">
                                <div class="font-bold text-xs mb-1">${msg.sender_name} (${msg.sender_role})</div>
                                <div>${msg.message}</div>
                                <div class="chat-meta">${new Date(msg.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</div>
                            </div>
                        `).join('')
                    }
                </div>
            </div>

            <!-- Tab 3: Arbitration & Disposition -->
            <div id="tabContentRuling" class="hidden">
                <label class="text-xs text-muted font-bold mb-2 block">1. Select Arbitration Ruling Preset</label>
                <div class="ruling-options-grid">
                    <div class="ruling-option-card ${this.selectedRuling === 'full_refund' ? 'selected' : ''}" onclick="SkillLinkArbitration.selectRuling('full_refund')">
                        <div class="ruling-icon">↩️</div>
                        <div class="ruling-name">100% Customer Refund</div>
                        <div class="ruling-desc">Full return of escrow</div>
                    </div>
                    <div class="ruling-option-card ${this.selectedRuling === 'full_payout' ? 'selected' : ''}" onclick="SkillLinkArbitration.selectRuling('full_payout')">
                        <div class="ruling-icon">💰</div>
                        <div class="ruling-name">100% Artisan Release</div>
                        <div class="ruling-desc">Full service payout</div>
                    </div>
                    <div class="ruling-option-card ${this.selectedRuling === 'split_settlement' ? 'selected' : ''}" onclick="SkillLinkArbitration.selectRuling('split_settlement')">
                        <div class="ruling-icon">⚖️</div>
                        <div class="ruling-name">Split Settlement</div>
                        <div class="ruling-desc">Partial refund & payout</div>
                    </div>
                    <div class="ruling-option-card ${this.selectedRuling === 'dismiss' ? 'selected' : ''}" onclick="SkillLinkArbitration.selectRuling('dismiss')">
                        <div class="ruling-icon">🚫</div>
                        <div class="ruling-name">Dismiss Claim</div>
                        <div class="ruling-desc">Uphold original contract</div>
                    </div>
                </div>

                <div class="split-calculator-box">
                    <div class="flex-row justify-between mb-2">
                        <span class="text-xs font-bold">Fund Disposition Breakdown</span>
                        <span class="text-xs text-muted">Total Escrow: <strong>₦${price.toLocaleString()}</strong></span>
                    </div>

                    <div class="flex-row gap-3">
                        <div class="flex-1">
                            <label class="text-xs text-muted">Customer Refund (₦)</label>
                            <input type="number" id="inputRefundAmount" class="admin-input mt-1" value="${price}" max="${price}" min="0" oninput="SkillLinkArbitration.onAmountChange('refund')">
                        </div>
                        <div class="flex-1">
                            <label class="text-xs text-muted">Artisan Payout (₦)</label>
                            <input type="number" id="inputPayoutAmount" class="admin-input mt-1" value="0" max="${price}" min="0" oninput="SkillLinkArbitration.onAmountChange('payout')">
                        </div>
                    </div>
                </div>

                <div class="flex-column gap-2 mb-3">
                    <label class="input-label">Formal Resolution Statement (Public to Parties)</label>
                    <textarea id="arbitrationResolution" class="admin-input" rows="2" placeholder="e.g. 100% refund approved due to unverified electrical safety report."></textarea>
                </div>

                <div class="flex-column gap-2 mb-3">
                    <label class="input-label">Internal Mediation Notes (Admin Only)</label>
                    <textarea id="arbitrationAdminNotes" class="admin-input" rows="2" placeholder="e.g. Verified photo evidence shows incomplete wiring."></textarea>
                </div>
            </div>
        `;

        const footerHtml = `
            <button class="btn-premium btn-outline" onclick="SkillLinkModal.hide()">Close</button>
            <button class="btn-premium btn-primary" id="btnExecuteRuling" onclick="SkillLinkArbitration.submitRuling()">Execute Ruling & Settle</button>
        `;

        SkillLinkModal.show(`Arbitration Tribunal: Case #${d.booking_number}`, bodyHtml, footerHtml);
        this.selectRuling('full_refund');
    },

    switchTab(tab) {
        ['case', 'chat', 'ruling'].forEach(t => {
            const btn = document.getElementById(`tabBtn${t.charAt(0).toUpperCase() + t.slice(1)}`);
            const content = document.getElementById(`tabContent${t.charAt(0).toUpperCase() + t.slice(1)}`);
            if (btn) btn.classList.remove('active');
            if (content) content.classList.add('hidden');
        });

        const activeBtn = document.getElementById(`tabBtn${tab.charAt(0).toUpperCase() + tab.slice(1)}`);
        const activeContent = document.getElementById(`tabContent${tab.charAt(0).toUpperCase() + tab.slice(1)}`);
        if (activeBtn) activeBtn.classList.add('active');
        if (activeContent) activeContent.classList.remove('hidden');
    },

    selectRuling(ruling) {
        this.selectedRuling = ruling;
        const d = this.currentCase;
        const price = parseFloat(d.price || 0);

        // Update card active states
        document.querySelectorAll('.ruling-option-card').forEach(card => card.classList.remove('selected'));
        const activeIdx = ['full_refund', 'full_payout', 'split_settlement', 'dismiss'].indexOf(ruling);
        const cards = document.querySelectorAll('.ruling-option-card');
        if (cards[activeIdx]) cards[activeIdx].classList.add('selected');

        const refundInput = document.getElementById('inputRefundAmount');
        const payoutInput = document.getElementById('inputPayoutAmount');
        const resText = document.getElementById('arbitrationResolution');

        if (ruling === 'full_refund') {
            if (refundInput) refundInput.value = price;
            if (payoutInput) payoutInput.value = 0;
            if (resText) resText.value = 'Full refund approved and issued back to the customer wallet.';
        } else if (ruling === 'full_payout') {
            if (refundInput) refundInput.value = 0;
            if (payoutInput) payoutInput.value = (price * 0.90).toFixed(2);
            if (resText) resText.value = 'Work deemed satisfactory; full escrow funds released to artisan.';
        } else if (ruling === 'split_settlement') {
            const half = (price / 2).toFixed(2);
            if (refundInput) refundInput.value = half;
            if (payoutInput) payoutInput.value = (price - half).toFixed(2);
            if (resText) resText.value = 'Mediation agreement reached: 50% refund to customer and 50% compensation to artisan.';
        } else if (ruling === 'dismiss') {
            if (refundInput) refundInput.value = 0;
            if (payoutInput) payoutInput.value = 0;
            if (resText) resText.value = 'Dispute dismissed after mediation review. Contract terms remain intact.';
        }
    },

    onAmountChange(source) {
        const d = this.currentCase;
        const price = parseFloat(d.price || 0);
        const refundInput = document.getElementById('inputRefundAmount');
        const payoutInput = document.getElementById('inputPayoutAmount');

        if (source === 'refund') {
            const refVal = parseFloat(refundInput.value || 0);
            payoutInput.value = Math.max(0, price - refVal).toFixed(2);
        } else {
            const payVal = parseFloat(payoutInput.value || 0);
            refundInput.value = Math.max(0, price - payVal).toFixed(2);
        }
    },

    submitRuling() {
        const d = this.currentCase;
        const resolution = document.getElementById('arbitrationResolution')?.value.trim();
        const adminNotes = document.getElementById('arbitrationAdminNotes')?.value.trim() || '';
        const refundAmount = parseFloat(document.getElementById('inputRefundAmount')?.value || 0);
        const payoutAmount = parseFloat(document.getElementById('inputPayoutAmount')?.value || 0);

        if (!resolution) {
            alert('Please enter a formal resolution statement before executing.');
            return;
        }

        if (!confirm(`Are you sure you want to execute this arbitration ruling for Case #${d.booking_number}? This will record transactions in the platform financial ledger.`)) {
            return;
        }

        const formData = new FormData();
        formData.append('id', d.id);
        formData.append('ruling', this.selectedRuling);
        formData.append('refund_amount', refundAmount);
        formData.append('payout_amount', payoutAmount);
        formData.append('resolution', resolution);
        formData.append('admin_notes', adminNotes);

        const btn = document.getElementById('btnExecuteRuling');
        if (btn) {
            btn.disabled = true;
            btn.innerText = 'Processing Settlement...';
        }

        fetch('/SkillLink/admin/dispute/arbitrate', {
            method: 'POST',
            body: formData,
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(res => res.json())
        .then(json => {
            if (json.status === 'success') {
                alert(json.message || 'Arbitration settlement successful!');
                window.location.reload();
            } else {
                alert(json.message || 'Failed to process ruling');
                if (btn) {
                    btn.disabled = false;
                    btn.innerText = 'Execute Ruling & Settle';
                }
            }
        })
        .catch(err => {
            console.error('Arbitration submission error:', err);
            alert('Error processing arbitration request.');
            if (btn) {
                btn.disabled = false;
                btn.innerText = 'Execute Ruling & Settle';
            }
        });
    }
};

/**
 * =========================================================================
 * SkillLink Live Operations & Citywide Dispatch System
 * =========================================================================
 */
const SkillLinkOps = {
    map: null,
    jobMarkers: {},
    artisanMarkers: {},
    routeVectors: {},
    currentJobFocus: null,
    syncIntervalId: null,
    syncSeconds: 30,
    layersVisible: {
        artisans: true,
        jobs: true,
        vectors: true
    },
    data: {
        jobs: [],
        artisans: [],
        kpis: {}
    },

    init() {
        const mapContainer = document.getElementById('operationsMap');
        if (!mapContainer || typeof L === 'undefined') return;

        // Default to Lagos City Center coordinates
        const defaultCenter = [6.5244, 3.3792];

        // Initialize Leaflet Map with dark sleek canvas
        this.map = L.map('operationsMap', {
            zoomControl: true,
            attributionControl: false
        }).setView(defaultCenter, 13);

        // CartoDB Dark Matter base tile layer
        L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
            maxZoom: 19,
            subdomains: 'abcd'
        }).addTo(this.map);

        // Load initial data from page
        if (window.initialOpsData) {
            this.data = window.initialOpsData;
            this.renderAll();
        }

        // Setup filter handlers
        const searchInput = document.getElementById('opsJobSearch');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => this.filterFeed(e.target.value));
        }

        document.querySelectorAll('.filter-chips .chip').forEach(chip => {
            chip.addEventListener('click', (e) => {
                document.querySelectorAll('.filter-chips .chip').forEach(c => c.classList.remove('active'));
                chip.classList.add('active');
                this.filterByStatus(chip.dataset.status);
            });
        });

        // Start auto-sync loop
        this.setSyncInterval(30);
    },

    renderAll() {
        if (!this.map) return;

        // Clear existing markers
        Object.values(this.jobMarkers).forEach(m => this.map.removeLayer(m));
        Object.values(this.artisanMarkers).forEach(m => this.map.removeLayer(m));
        Object.values(this.routeVectors).forEach(v => this.map.removeLayer(v));
        this.jobMarkers = {};
        this.artisanMarkers = {};
        this.routeVectors = {};

        const bounds = [];

        // 1. Render Active Jobs
        if (this.data.jobs && Array.isArray(this.data.jobs)) {
            this.data.jobs.forEach(job => {
                const lat = job.artisan.latitude;
                const lng = job.artisan.longitude;
                if (!lat || !lng) return;

                bounds.push([lat, lng]);

                // Create custom HTML marker icon
                const statusClass = `icon-job-${job.status}`;
                const iconHtml = `<div class="custom-map-icon ${statusClass}" style="width: 32px; height: 32px;">🔧</div>`;
                const customIcon = L.divIcon({
                    html: iconHtml,
                    className: 'ops-job-div-icon',
                    iconSize: [32, 32],
                    iconAnchor: [16, 16]
                });

                const marker = L.marker([lat, lng], { icon: customIcon }).addTo(this.map);
                marker.bindPopup(`
                    <div style="font-family: Inter, sans-serif; min-width: 180px;">
                        <strong style="color: #000c47; font-size: 0.85rem;">#${job.booking_number}</strong>
                        <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">${job.category.name}</div>
                        <div style="font-size: 0.8rem; font-weight: 600;">Artisan: ${job.artisan.name}</div>
                        <div style="font-size: 0.8rem; color: #10b981; font-weight: bold; margin-top: 4px;">₦${job.price.toLocaleString()}</div>
                    </div>
                `);

                marker.on('click', () => {
                    this.focusJob(job.id);
                });

                this.jobMarkers[job.id] = marker;

                // Draw route line to customer if in progress or en route
                if (job.customer && job.customer.latitude && job.customer.longitude && this.layersVisible.vectors) {
                    const custLat = job.customer.latitude;
                    const custLng = job.customer.longitude;
                    bounds.push([custLat, custLng]);

                    const polyline = L.polyline([[lat, lng], [custLat, custLng]], {
                        color: job.status === 'in_progress' ? '#f59e0b' : '#3b82f6',
                        weight: 3,
                        dashArray: '6, 6',
                        opacity: 0.85
                    }).addTo(this.map);

                    this.routeVectors[job.id] = polyline;
                }
            });
        }

        // 2. Render On-Duty Artisans
        if (this.data.artisans && Array.isArray(this.data.artisans) && this.layersVisible.artisans) {
            this.data.artisans.forEach(a => {
                if (!a.latitude || !a.longitude) return;

                const iconClass = a.is_live ? 'icon-artisan-live' : 'icon-artisan-idle';
                const iconHtml = `<div class="custom-map-icon ${iconClass}" style="width: 26px; height: 26px;">👷</div>`;
                const customIcon = L.divIcon({
                    html: iconHtml,
                    className: 'ops-artisan-div-icon',
                    iconSize: [26, 26],
                    iconAnchor: [13, 13]
                });

                const marker = L.marker([a.latitude, a.longitude], { icon: customIcon }).addTo(this.map);
                marker.bindPopup(`
                    <div style="font-family: Inter, sans-serif; min-width: 170px;">
                        <strong style="color: #000c47; font-size: 0.85rem;">${a.name}</strong>
                        <div style="font-size: 0.72rem; color: #64748b;">${a.categories || a.skill}</div>
                        <div style="font-size: 0.75rem; margin-top: 4px;">⭐ ${a.rating.toFixed(1)} | ${a.location_name}</div>
                        <span class="status-badge ${a.is_live ? 'badge-success' : 'badge-muted'}" style="margin-top: 4px; display: inline-block;">
                            ${a.is_live ? 'LIVE GPS' : 'AVAILABLE'}
                        </span>
                    </div>
                `);

                this.artisanMarkers[a.id] = marker;
            });
        }

        // Adjust bounds if points exist
        if (bounds.length > 0) {
            this.map.fitBounds(bounds, { padding: [40, 40], maxZoom: 15 });
        }
    },

    focusJob(jobId) {
        const job = (this.data.jobs || []).find(j => parseInt(j.id) === parseInt(jobId));
        if (!job) return;

        this.currentJobFocus = job;

        // Highlight card in left feed
        document.querySelectorAll('.ops-job-card').forEach(card => card.classList.remove('active-focus'));
        const targetCard = document.getElementById(`job-card-${jobId}`);
        if (targetCard) {
            targetCard.classList.add('active-focus');
            targetCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }

        // Pan map
        const lat = job.artisan.latitude;
        const lng = job.artisan.longitude;
        if (this.map && lat && lng) {
            this.map.flyTo([lat, lng], 15, { animate: true, duration: 1.2 });
            const marker = this.jobMarkers[jobId];
            if (marker) marker.openPopup();
        }

        // Open Inspector Drawer
        this.openInspector(job);
    },

    openInspector(job) {
        const drawer = document.getElementById('jobInspectorDrawer');
        if (!drawer) return;

        document.getElementById('inspBookingNumber').innerText = '#' + job.booking_number;
        document.getElementById('inspCategoryName').innerText = job.category.name;
        document.getElementById('inspDescription').innerText = job.service_description || 'Standard service request';
        document.getElementById('inspPrice').innerText = '₦' + parseFloat(job.price).toLocaleString('en-US', {minimumFractionDigits: 2});

        const statusBadge = document.getElementById('inspStatusBadge');
        statusBadge.className = `status-badge ${job.status === 'in_progress' ? 'badge-warning' : (job.status === 'completed' ? 'badge-success' : 'badge-info')}`;
        statusBadge.innerText = job.status.replace('_', ' ').toUpperCase();

        document.getElementById('inspArtisanName').innerText = job.artisan.name;
        document.getElementById('inspArtisanRating').innerText = `⭐ ${parseFloat(job.artisan.rating).toFixed(1)}`;
        document.getElementById('inspArtisanLoc').innerText = `Location: ${job.artisan.location_name || 'City Metro'}`;
        document.getElementById('inspArtisanCall').href = `tel:${job.artisan.phone}`;

        document.getElementById('inspCustomerName').innerText = job.customer.name;
        document.getElementById('inspCustomerPhone').innerText = `Phone: ${job.customer.phone}`;
        document.getElementById('inspCustomerCall').href = `tel:${job.customer.phone}`;

        drawer.classList.add('open');
    },

    closeInspector() {
        const drawer = document.getElementById('jobInspectorDrawer');
        if (drawer) drawer.classList.remove('open');
        this.currentJobFocus = null;
    },

    dispatchAction(newStatus) {
        if (!this.currentJobFocus) return;
        const jobId = this.currentJobFocus.id;

        if (!confirm(`Confirm dispatch intervention: Change status of #${this.currentJobFocus.booking_number} to ${newStatus}?`)) {
            return;
        }

        const formData = new FormData();
        formData.append('booking_id', jobId);
        formData.append('status', newStatus);
        formData.append('notes', `Status updated to ${newStatus} by Dispatch Control`);

        fetch('/SkillLink/admin/operations/updateStatus', {
            method: 'POST',
            body: formData,
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(res => res.json())
        .then(json => {
            if (json.status === 'success') {
                this.fetchFeed();
            } else {
                alert(json.message || 'Action failed');
            }
        })
        .catch(err => {
            console.error('Dispatch error:', err);
            alert('Error updating status');
        });
    },

    toggleLayer(layer) {
        this.layersVisible[layer] = !this.layersVisible[layer];
        this.renderAll();
    },

    setSyncInterval(seconds) {
        this.syncSeconds = parseInt(seconds);
        if (this.syncIntervalId) clearInterval(this.syncIntervalId);

        const radarLabel = document.getElementById('radarSyncLabel');
        if (this.syncSeconds <= 0) {
            if (radarLabel) radarLabel.innerText = 'SYNC PAUSED';
            return;
        }

        if (radarLabel) radarLabel.innerText = `LIVE SYNC (${this.syncSeconds}s)`;

        this.syncIntervalId = setInterval(() => {
            this.fetchFeed();
        }, this.syncSeconds * 1000);
    },

    fetchFeed() {
        const btn = document.getElementById('btnManualSync');
        if (btn) btn.classList.add('spinning');

        fetch('/SkillLink/admin/operations/feed', {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(res => res.json())
        .then(json => {
            if (btn) btn.classList.remove('spinning');
            if (json.status === 'success') {
                this.data = json;
                this.renderAll();
                this.updateKPIs(json.kpis);
                const timeEl = document.getElementById('lastUpdatedTime');
                if (timeEl) timeEl.innerText = 'Updated ' + new Date().toLocaleTimeString();
            }
        })
        .catch(err => {
            if (btn) btn.classList.remove('spinning');
            console.error('Feed sync error:', err);
        });
    },

    updateKPIs(kpis) {
        if (!kpis) return;
        const setVal = (id, val) => { const el = document.getElementById(id); if (el) el.innerText = val; };
        setVal('kpi-active-jobs', kpis.active_jobs ?? 0);
        setVal('kpi-in-progress', kpis.in_progress_jobs ?? 0);
        setVal('kpi-en-route', kpis.en_route_jobs ?? 0);
        setVal('kpi-artisans', kpis.on_duty_artisans ?? 0);
        setVal('kpi-disputes', kpis.open_disputes ?? 0);
    },

    filterFeed(query) {
        const q = query.toLowerCase();
        const cards = document.querySelectorAll('.ops-job-card');
        cards.forEach(c => {
            const text = c.innerText.toLowerCase();
            c.style.display = text.includes(q) ? '' : 'none';
        });
    },

    filterByStatus(status) {
        const cards = document.querySelectorAll('.ops-job-card');
        cards.forEach(c => {
            if (status === 'all') {
                c.style.display = '';
            } else if (status === 'en_route') {
                const text = c.innerText.toLowerCase();
                c.style.display = (text.includes('confirmed') || text.includes('arrived')) ? '' : 'none';
            } else {
                const text = c.innerText.toLowerCase();
                c.style.display = text.includes(status.replace('_', ' ')) ? '' : 'none';
            }
        });
    }
};

// Global Initialization
document.addEventListener('DOMContentLoaded', () => {
    SkillLinkModal.init();

    // Sidebar Toggle for Mobile
    const toggleBtn = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.sidebar');
    
    if (toggleBtn && sidebar) {
        toggleBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            sidebar.classList.toggle('mobile-active');
        });

        // Close sidebar on outside click
        document.addEventListener('click', (e) => {
            if (sidebar.classList.contains('mobile-active') && !sidebar.contains(e.target) && e.target !== toggleBtn) {
                sidebar.classList.remove('mobile-active');
            }
        });
    }

    // Initialize Operations Map if container exists
    if (document.getElementById('operationsMap')) {
        SkillLinkOps.init();
    }
});
