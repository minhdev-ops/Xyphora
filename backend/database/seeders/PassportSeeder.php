<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Artisan;

class PassportSeeder extends Seeder
{
    public function run(): void
    {
        Artisan::call('passport:client', [
            '--personal' => true,
            '--name' => 'Xyphora Frontend',
            '--no-interaction' => true,
        ]);
    }
}
