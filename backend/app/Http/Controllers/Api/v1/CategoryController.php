<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * Get all categories.
     */
    public function index()
    {
        $categories = Category::orderBy('name', 'asc')->get();

        return response()->json([
            'status' => 'success',
            'data' => $categories
        ]);
    }
}
