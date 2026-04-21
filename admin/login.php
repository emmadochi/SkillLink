<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | SkillLink Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #000c47;
            --secondary: #ffddb8;
            --surface: #f8f9fc;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--primary);
            height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        /* Abstract Background Elements */
        .blob {
            position: absolute;
            width: 500px;
            height: 500px;
            background: linear-gradient(135deg, rgba(255, 221, 184, 0.1) 0%, rgba(0, 12, 71, 0) 100%);
            border-radius: 50%;
            z-index: 0;
        }
        .blob-1 { top: -200px; right: -200px; }
        .blob-2 { bottom: -200px; left: -200px; }

        .login-card {
            background: white;
            padding: 48px;
            border-radius: 32px;
            width: 100%;
            max-width: 400px;
            position: relative;
            z-index: 1;
            box-shadow: 0 24px 48px rgba(0,0,0,0.2);
        }

        .logo-text {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-weight: 800;
            font-size: 28px;
            color: var(--primary);
            text-align: center;
            margin-bottom: 8px;
        }

        .subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 32px;
            font-size: 14px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: var(--primary);
            text-transform: uppercase;
            margin-bottom: 8px;
            letter-spacing: 0.5px;
        }

        input {
            width: 100%;
            padding: 14px 18px;
            border-radius: 12px;
            border: 1px solid #ddd;
            font-family: inherit;
            box-sizing: border-box;
            outline: none;
            transition: border-color 0.2s;
        }

        input:focus {
            border-color: var(--primary);
        }

        .btn-login {
            width: 100%;
            padding: 16px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
            transition: transform 0.2s;
        }

        .btn-login:hover {
            transform: translateY(-2px);
        }

        .footer-links {
            text-align: center;
            margin-top: 24px;
            font-size: 13px;
        }

        .footer-links a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>

    <div class="login-card">
        <div class="logo-text">SkillLink</div>
        <div class="subtitle">Administrative Portal Access</div>

        <form action="/SkillLink/admin/" method="GET">
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" placeholder="admin@skilllink.com" required>
            </div>
            
            <div class="form-group">
                <label>Password</label>
                <input type="password" placeholder="••••••••" required>
            </div>

            <button type="submit" class="btn-login">Sign In to Dashboard</button>
        </form>

        <div class="footer-links">
            <a href="#">Forgot password?</a>
        </div>
    </div>
</body>
</html>
