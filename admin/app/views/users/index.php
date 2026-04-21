<!-- User & Artisan Management -->
<div class="card-tabs mb-4">
    <button class="tab-btn active" onclick="switchTab('customers')">Customers</button>
    <button class="tab-btn" onclick="switchTab('artisans')">Artisans</button>
</div>

<!-- Customers Section -->
<div id="customers-tab" class="tab-content transition-fade">
    <div class="glass p-5 rounded-3xl">
        <div class="flex-row justify-between mb-4">
            <h3>Registered Customers</h3>
            <div class="search-box">
                <input type="text" placeholder="Search customers..." class="admin-input">
            </div>
        </div>
        
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach($users as $user): ?>
                <tr>
                    <td>#<?php echo $user['id']; ?></td>
                    <td><strong><?php echo $user['name']; ?></strong></td>
                    <td><?php echo $user['email']; ?></td>
                    <td><span class="badge success"><?php echo $user['status']; ?></span></td>
                    <td><button class="btn btn-outlined btn-sm">Manage</button></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- Artisans Section -->
<div id="artisans-tab" class="tab-content hidden transition-fade">
    <div class="glass p-5 rounded-3xl">
        <div class="flex-row justify-between mb-4">
            <h3>Service Providers</h3>
            <div class="search-box">
                <input type="text" placeholder="Search artisans..." class="admin-input">
            </div>
        </div>
        
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Skill</th>
                    <th>Rating</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach($artisans as $a): ?>
                <tr>
                    <td>#<?php echo $a['id']; ?></td>
                    <td><strong><?php echo $a['name']; ?></strong></td>
                    <td><?php echo $a['skill']; ?></td>
                    <td>⭐ <?php echo $a['rating']; ?></td>
                    <td>
                        <span class="badge <?php echo $a['status'] === 'Pending' ? 'warning' : 'success'; ?>">
                            <?php echo $a['status']; ?>
                        </span>
                    </td>
                    <td>
                        <a href="/SkillLink/admin/user/details?id=<?php echo $a['id']; ?>" class="btn btn-sm">
                            <?php echo $a['status'] === 'Pending' ? 'Review' : 'View'; ?>
                        </a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
function switchTab(tab) {
    const tabs = ['customers', 'artisans'];
    tabs.forEach(t => {
        document.getElementById(t + '-tab').classList.add('hidden');
        document.querySelector(`.tab-btn:nth-child(${tabs.indexOf(t) + 1})`).classList.remove('active');
    });
    
    document.getElementById(tab + '-tab').classList.remove('hidden');
    event.currentTarget.classList.add('active');
}
</script>

<style>
    .flex-row { display: flex; align-items: center; }
    .justify-between { justify-content: space-between; }
    .mb-4 { margin-bottom: 24px; }
    .p-5 { padding: 32px; }
    .rounded-3xl { border-radius: 24px; }
    .hidden { display: none; }
    
    .card-tabs {
        display: flex;
        gap: 12px;
        background: #ebedef;
        padding: 6px;
        border-radius: 16px;
        width: fit-content;
    }
    
    .tab-btn {
        padding: 10px 24px;
        border: none;
        background: none;
        border-radius: 12px;
        cursor: pointer;
        font-weight: 500;
        color: var(--outline);
        transition: all 0.2s;
    }
    
    .tab-btn.active {
        background: white;
        color: var(--primary);
        box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }
    
    .admin-input {
        padding: 10px 16px;
        border-radius: 12px;
        border: 1px solid #ddd;
        font-family: inherit;
        outline: none;
        width: 240px;
    }
    
    .btn-outlined {
        background: none;
        border: 1px solid var(--primary);
        color: var(--primary);
    }
</style>
