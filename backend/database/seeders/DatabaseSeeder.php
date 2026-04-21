<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            CategorySeeder::class,
        ]);

        // Create default admin
        \App\Models\User::factory()->create([
            'name' => 'System Admin',
            'email' => 'admin@skilllink.com',
            'password' => bcrypt('password123'),
            'role' => 'admin',
            'is_verified' => true,
        ]);
    }
}
