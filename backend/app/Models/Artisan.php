<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Artisan extends Model
{
    use HasFactory;

    protected $primaryKey = 'user_id';
    public $incrementing = false;

    protected $fillable = [
        'user_id',
        'bio',
        'experience_years',
        'location_name',
        'latitude',
        'longitude',
        'verification_status',
        'average_rating',
        'total_reviews',
        'is_available',
    ];

    /**
     * Get the user that owns the artisan profile.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * The categories that belong to the artisan.
     */
    public function categories()
    {
        return $this->belongsToMany(Category::class, 'artisan_categories', 'artisan_id', 'category_id');
    }
}
