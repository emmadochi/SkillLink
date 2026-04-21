<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Models\Artisan;
use App\Models\User;
use Illuminate\Http\Request;

class ArtisanController extends Controller
{
    /**
     * Search artisans by category and filters.
     */
    public function index(Request $request)
    {
        $query = Artisan::with('user')->where('verification_status', 'approved');

        if ($request->has('category')) {
            $query->whereHas('categories', function($q) use ($request) {
                $q->where('category_id', $request->category);
            });
        }

        if ($request->has('rating')) {
            $query->where('average_rating', '>=', $request->rating);
        }

        $artisans = $query->orderBy('average_rating', 'desc')->get();

        return response()->json([
            'status' => 'success',
            'data' => $artisans
        ]);
    }

    /**
     * Get single artisan profile.
     */
    public function profile($id)
    {
        $artisan = Artisan::with(['user', 'categories'])->where('user_id', $id)->first();

        if (!$artisan) {
            return response()->json([
                'status' => 'error',
                'message' => 'Artisan not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $artisan
        ]);
    }
}
