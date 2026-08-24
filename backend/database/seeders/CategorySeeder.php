<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Ăn uống', 'icon' => 'restaurant', 'color' => '#ef4444'],
            ['name' => 'Di chuyển', 'icon' => 'car', 'color' => '#3b82f6'],
            ['name' => 'Khách sạn', 'icon' => 'bed', 'color' => '#8b5cf6'],
            ['name' => 'Xăng xe', 'icon' => 'fuel', 'color' => '#f59e0b'],
            ['name' => 'Giải trí', 'icon' => 'ticket', 'color' => '#10b981'],
        ];

        foreach ($categories as $category) {
            DB::table('categories')->updateOrInsert(
                ['name' => $category['name'], 'is_default' => 1],
                [
                    'icon' => $category['icon'],
                    'color' => $category['color'],
                    'type' => 'expense',
                    'created_by' => null,
                ]
            );
        }
    }
}
