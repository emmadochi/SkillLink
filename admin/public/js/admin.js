/**
 * SkillLink Admin - Premium Interactivity System
 * Handles custom modals, tab switching, and generic form submissions.
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
 * Dispute Resolution Helpers
 */
function openResolveModal(id) {
    const body = `
        <div class="flex-column gap-3">
            <p class="text-sm text-muted">Provide the final resolution for this dispute. This will notify both parties.</p>
            <label class="input-label">Resolution Details</label>
            <textarea id="resolutionText" class="admin-input" rows="4" placeholder="e.g. Full refund processed due to service non-delivery."></textarea>
        </div>
    `;
    
    const footer = `
        <button class="btn-premium btn-outline" onclick="SkillLinkModal.hide()">Cancel</button>
        <button class="btn-premium btn-primary" onclick="confirmResolve(${id})">Submit Resolution</button>
    `;
    
    SkillLinkModal.show('Resolve Dispute', body, footer);
}

function confirmResolve(id) {
    const res = document.getElementById('resolutionText').value;
    if (!res) return alert('Please enter resolution details');
    submitHiddenForm('/SkillLink/admin/dispute/resolve', { id, resolution: res });
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

// Global initialization
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
});
