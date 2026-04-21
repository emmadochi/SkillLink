@extends('layouts.admin')

@section('title', 'Admin Dashboard')

@section('header')
    <div class="subtitle" style="font-size: 14px; color: #666; margin-bottom: 4px;">Welcome back, Administrator</div>
    <h1>Platform Overview</h1>
@endsection

@section('content')
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 24px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: white;
            padding: 24px;
            border-radius: 24px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .stat-icon {
            width: 56px;
            height: 56px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .stat-label {
            font-size: 13px;
            color: #666;
            margin-bottom: 4px;
            font-weight: 500;
        }

        .stat-value {
            font-size: 22px;
            font-weight: 700;
            color: var(--primary);
        }

        .table-card {
            background: white;
            border-radius: 24px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }

        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            font-size: 12px;
            text-transform: uppercase;
            color: #999;
            padding: 16px;
            border-bottom: 1px solid #f0f0f0;
            letter-spacing: 0.5px;
        }

        td {
            padding: 16px;
            border-bottom: 1px solid #f8f9fc;
            font-size: 14px;
        }

        .badge {
            padding: 6px 12px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-pending { background: #fff8e1; color: #ffa000; }
        .badge-approved { background: #e8f5e9; color: #2e7d32; }
    </style>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(0, 12, 71, 0.05); color: var(--primary);">
                <span class="material-icons-outlined">people</span>
            </div>
            <div>
                <div class="stat-label">Total Users</div>
                <div class="stat-value">--</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(255, 221, 184, 0.2); color: #d69e5e;">
                <span class="material-icons-outlined">handyman</span>
            </div>
            <div>
                <div class="stat-label">Verified Artisans</div>
                <div class="stat-value">--</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(46, 125, 50, 0.05); color: #2e7d32;">
                <span class="material-icons-outlined">payments</span>
            </div>
            <div>
                <div class="stat-label">Total Revenue</div>
                <div class="stat-value">₦ 0.00</div>
            </div>
        </div>
    </div>

    <div class="table-card">
        <div class="table-header">
            <h2 style="margin: 0; font-family: 'Plus Jakarta Sans', sans-serif; font-size: 18px;">Recent Artisan Applications</h2>
            <a href="#" style="color: var(--primary); font-size: 14px; font-weight: 600; text-decoration: none;">View All</a>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Artisan Name</th>
                    <th>Category</th>
                    <th>Experience</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="5" style="text-align: center; padding: 40px; color: #999;">
                        No pending applications found.
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
@endsection
