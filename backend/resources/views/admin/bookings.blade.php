@extends('layouts.admin')

@section('title', 'Booking Management')

@section('header')
    <h1>All Bookings</h1>
@endsection

@section('content')
    <style>
        .booking-card {
            background: white;
            border-radius: 24px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }

        .booking-status {
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
        }

        .status-pending { background: #f5f5f5; color: #666; }
        .status-confirmed { background: #e3f2fd; color: #1976d2; }
        .status-in_progress { background: #fff3e0; color: #f57c00; }
        .status-completed { background: #e8f5e9; color: #2e7d32; }
        .status-cancelled { background: #ffebee; color: #c62828; }
    </style>

    <div class="booking-card">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="border-bottom: 1px solid #f0f0f0;">
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">ID</th>
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Customer</th>
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Artisan</th>
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Service</th>
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Scheduled</th>
                    <th style="padding: 16px; text-align: left; font-size: 12px; text-transform: uppercase; color: #999;">Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse($bookings ?? [] as $booking)
                    <tr style="border-bottom: 1px solid #f8f9fc;">
                        <td style="padding: 16px; font-weight: 600;">#{{ $booking->booking_number }}</td>
                        <td style="padding: 16px; font-size: 14px;">{{ $booking->customer->name }}</td>
                        <td style="padding: 16px; font-size: 14px;">{{ $booking->artisan->name }}</td>
                        <td style="padding: 16px; font-size: 14px;">{{ $booking->category->name }}</td>
                        <td style="padding: 16px; font-size: 14px;">{{ $booking->scheduled_at }}</td>
                        <td style="padding: 16px;">
                            <span class="booking-status status-{{ $booking->status }}">
                                {{ str_replace('_', ' ', $booking->status) }}
                            </span>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" style="padding: 48px; text-align: center; color: #999;">No bookings recorded yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
