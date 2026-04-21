<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use Illuminate\Support\Str;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            ['name' => 'Plumbing', 'icon' => 'water_drop'],
            ['name' => 'Electrical', 'icon' => 'bolt'],
            ['name' => 'Cleaning', 'icon' => 'cleaning_services'],
            ['name' => 'Carpentry', 'icon' => 'home_repair_service'],
            ['name' => 'Catering', 'icon' => 'restaurant'],
            ['name' => 'Painting', 'icon' => 'format_paint'],
            ['name' => 'Laundry', 'icon' => 'local_laundry_service'],
        ];

        foreach ($categories as $cat) {
            Category::create([
                'name' => $cat['name'],
                'slug' => Str::slug($cat['name']),
                'icon' => $cat['icon'],
            ]);
        }
    }
}
