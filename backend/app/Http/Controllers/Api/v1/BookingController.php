<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class BookingController extends Controller
{
    /**
     * Create a new booking.
     */
    public function create(Request $request)
    {
        $request->validate([
            'artisan_id' => 'required|exists:users,id',
            'category_id' => 'required|exists:categories,id',
            'scheduled_at' => 'required|date',
            'price' => 'required|numeric',
        ]);

        $price = floatval($request->price);
        $fee = $price * 0.10;
        $payout = $price - $fee;
        
        $bookingNumber = 'SL' . date('ymd') . rand(1000, 9999);

        $booking = Booking::create([
            'booking_number' => $bookingNumber,
            'customer_id' => Auth::id(),
            'artisan_id' => $request->artisan_id,
            'category_id' => $request->category_id,
            'service_description' => $request->service_description,
            'scheduled_at' => $request->scheduled_at,
            'price' => $price,
            'platform_fee' => $fee,
            'artisan_payout' => $payout,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Booking request sent successfully',
            'data' => $booking
        ], 201);
    }

    /**
     * Get booking history for current user.
     */
    public function history()
    {
        $user = Auth::user();
        $field = ($user->role === 'customer') ? 'customer_id' : 'artisan_id';
        
        $bookings = Booking::with(['customer', 'artisan', 'category'])
            ->where($field, $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $bookings
        ]);
    }
}
