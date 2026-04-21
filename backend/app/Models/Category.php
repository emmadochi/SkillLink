<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'icon',
    ];

    /**
     * The artisans that belong to the category.
     */
    public function artisans()
    {
        return $this->belongsToMany(Artisan::class, 'artisan_categories', 'category_id', 'artisan_id');
    }
}
