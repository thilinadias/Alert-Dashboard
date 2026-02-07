<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            RoleSeeder::class,
        ]);

        $user = \App\Models\User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Admin User',
                'password' => bcrypt('password'),
            ]
        );
        $user->assignRole('admin');

        $nocUser = \App\Models\User::firstOrCreate(
            ['email' => 'analyst@example.com'],
            [
                'name' => 'NOC Analyst',
                'password' => bcrypt('password'),
            ]
        );
        $nocUser->assignRole('noc_analyst');
    }
}
