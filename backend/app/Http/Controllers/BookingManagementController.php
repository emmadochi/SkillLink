<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Http\Request;

class BookingManagementController extends Controller
{
    public function index()
    {
        $bookings = Booking::with(['customer', 'artisan', 'category'])->orderBy('created_at', 'desc')->get();
        return view('admin.bookings', compact('bookings'));
    }
}
