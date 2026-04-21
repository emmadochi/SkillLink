<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_number',
        'customer_id',
        'artisan_id',
        'category_id',
        'service_description',
        'scheduled_at',
        'status',
        'price',
        'platform_fee',
        'artisan_payout',
    ];

    /**
     * Get the customer that made the booking.
     */
    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    /**
     * Get the artisan providing the service.
     */
    public function artisan()
    {
        return $this->belongsTo(User::class, 'artisan_id');
    }

    /**
     * Get the category of the service.
     */
    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }
}
