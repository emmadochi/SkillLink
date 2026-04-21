<?php

namespace App\Http\Controllers;

use App\Models\Artisan;
use Illuminate\Http\Request;

class ArtisanManagementController extends Controller
{
    public function index()
    {
        $artisans = Artisan::with('user')->orderBy('created_at', 'desc')->get();
        return view('admin.artisans', compact('artisans'));
    }

    public function verify(Request $request, $id)
    {
        $artisan = Artisan::where('user_id', $id)->firstOrFail();
        $artisan->update(['verification_status' => $request->status]);
        
        return back()->with('success', 'verification status updated.');
    }
}
