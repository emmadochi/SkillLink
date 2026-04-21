@extends('layouts.admin')

@section('title', 'Artisan Management')

@section('header')
    <h1>Artisan Management</h1>
@endsection

@section('content')
    <style>
        .filter-row {
            display: flex;
            gap: 16px;
            margin-bottom: 24px;
        }

        .filter-pill {
            padding: 8px 16px;
            background: white;
            border-radius: 50px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid #eee;
            transition: all 0.2s;
        }

        .filter-pill.active {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        .artisan-table-card {
            background: white;
            border-radius: 24px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }

        .status-pill {
            padding: 4px 12px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .status-pending { background: #ffe0b2; color: #e65100; }
        .status-approved { background: #c8e6c9; color: #2e7d32; }
        .status-rejected { background: #ffcdd2; color: #c62828; }

        .action-btn {
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid #eee;
            background: white;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            color: var(--primary);
            transition: all 0.1s;
        }

        .action-btn:hover {
            background: #f8f9fc;
            border-color: var(--primary);
        }
    </style>

    <div class="filter-row">
        <div class="filter-pill active">All Artisans</div>
        <div class="filter-pill">Pending Verification</div>
        <div class="filter-pill">Approved</div>
        <div class="filter-pill">Top Rated</div>
    </div>

    <div class="artisan-table-card">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="border-bottom: 1px solid #f0f0f0;">
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Artisan</th>
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Category</th>
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Verification</th>
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Rating</th>
                    <th style="padding: 16px; text-align: right; font-size: 12px; text-transform: uppercase; color: #999;">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($artisans ?? [] as $artisan)
                    <tr style="border-bottom: 1px solid #f8f9fc;">
                        <td style="padding: 16px;">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 32px; height: 32px; background: #eee; border-radius: 50%;"></div>
                                <div>
                                    <div style="font-weight: 600;">{{ $artisan->user->name }}</div>
                                    <div style="font-size: 12px; color: #666;">{{ $artisan->user->email }}</div>
                                </div>
                            </div>
                        </td>
                        <td style="padding: 16px; font-size: 13px;">Plumbing (Mock)</td>
                        <td style="padding: 16px;">
                            <span class="status-pill status-{{ $artisan->verification_status }}">
                                {{ $artisan->verification_status }}
                            </span>
                        </td>
                        <td style="padding: 16px;">
                            <span style="font-weight: 700; color: #ffa000;">{{ $artisan->average_rating }} ★</span>
                        </td>
                        <td style="padding: 16px; text-align: right; gap: 8px; display: flex; justify-content: flex-end;">
                            <button class="action-btn">View Docs</button>
                            @if($artisan->verification_status === 'pending')
                                <button class="action-btn" style="background: var(--primary); color: white; border-color: var(--primary);">Approve</button>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" style="padding: 48px; text-align: center; color: #999;">No artisans registered yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
