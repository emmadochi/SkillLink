<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->string('booking_number')->unique();
            $table->foreignId('customer_id')->constrained('users');
            $table->foreignId('artisan_id')->constrained('users');
            $table->foreignId('category_id')->constrained('categories');
            $table->text('service_description')->nullable();
            $table->dateTime('scheduled_at');
            $table->enum('status', ['pending', 'confirmed', 'arrived', 'in_progress', 'completed', 'cancelled'])->default('pending');
            $table->decimal('price', 12, 2);
            $table->decimal('platform_fee', 12, 2);
            $table->decimal('artisan_payout', 12, 2);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
