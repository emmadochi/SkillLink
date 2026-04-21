<!-- Artisan Verification Details -->
<div class="mb-4">
    <a href="/SkillLink/admin/user" class="btn-back">← Back to List</a>
</div>

<div class="flex-row gap-6 items-start">
    <!-- Profile Card -->
    <div class="glass p-5 rounded-3xl" style="flex: 1;">
        <div class="flex-row gap-4 mb-5">
            <div class="avatar-lg"></div>
            <div>
                <h2 class="mb-1"><?php echo $artisan['name']; ?></h2>
                <span class="badge warning"><?php echo $artisan['status']; ?></span>
            </div>
        </div>
        
        <div class="info-grid">
            <div class="info-item">
                <label>Email Address</label>
                <p><?php echo $artisan['email']; ?></p>
            </div>
            <div class="info-item">
                <label>Phone Number</label>
                <p><?php echo $artisan['phone']; ?></p>
            </div>
            <div class="info-item">
                <label>Primary Skill</label>
                <p><?php echo $artisan['skill']; ?></p>
            </div>
            <div class="info-item">
                <label>Years of Experience</label>
                <p><?php echo $artisan['experience']; ?></p>
            </div>
        </div>
        
        <div class="mt-5">
            <label>Biography</label>
            <p class="body-text mt-2"><?php echo $artisan['bio']; ?></p>
        </div>
        
        <div class="flex-row gap-3 mt-6">
            <button class="btn btn-success">Approve Artisan</button>
            <button class="btn btn-danger">Reject Application</button>
        </div>
    </div>
    
    <!-- Portfolio Card -->
    <div class="glass p-5 rounded-3xl" style="width: 400px;">
        <h3 class="mb-4">Verification Portfolio</h3>
        <div class="portfolio-grid">
            <?php foreach($artisan['portfolio'] as $work): ?>
            <div class="portfolio-item">
                <img src="<?php echo $work['img']; ?>" alt="<?php echo $work['title']; ?>">
                <p class="mt-2 text-sm"><strong><?php echo $work['title']; ?></strong></p>
            </div>
            <?php endforeach; ?>
        </div>
        
        <div class="mt-5 p-3 rounded-xl bg-primary-light">
            <p class="text-sm"><strong>ID Verification:</strong> Government Issued ID Verified ✓</p>
        </div>
    </div>
</div>

<style>
    .items-start { align-items: flex-start; }
    .gap-3 { gap: 12px; }
    .gap-4 { gap: 16px; }
    .gap-6 { gap: 32px; }
    .mt-2 { margin-top: 8px; }
    .mt-5 { margin-top: 32px; }
    .mt-6 { margin-top: 40px; }
    .mb-1 { margin-bottom: 4px; }
    .mb-5 { margin-bottom: 32px; }
    
    .btn-back {
        text-decoration: none;
        color: var(--primary);
        font-weight: 600;
        font-size: 14px;
    }
    
    .avatar-lg {
        width: 80px;
        height: 80px;
        background-color: var(--secondary);
        border-radius: 50%;
    }
    
    .info-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 24px;
    }
    
    .info-item label, .mt-5 label {
        font-size: 12px;
        color: var(--outline);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .info-item p {
        margin: 4px 0 0;
        font-weight: 500;
    }
    
    .portfolio-grid {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }
    
    .portfolio-item img {
        width: 100%;
        border-radius: 16px;
        object-fit: cover;
        height: 180px;
    }
    
    .text-sm { font-size: 13px; }
    
    .btn-success { background: #2e7d32; }
    .btn-danger { background: #c62828; }
    .bg-primary-light { background: rgba(0, 12, 71, 0.05); }
    
    .body-text {
        line-height: 1.6;
        color: #444;
    }
</style>
