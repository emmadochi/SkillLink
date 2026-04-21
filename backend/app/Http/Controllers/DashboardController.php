<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    /**
     * Display the admin dashboard.
     */
    public function index()
    {
        // Simple role check (In production, replace with Middleware)
        if (Auth::user()->role !== 'admin') {
            Auth::logout();
            return redirect()->route('login')->withErrors(['email' => 'Unauthorized access.']);
        }

        return view('admin.dashboard');
    }
}
