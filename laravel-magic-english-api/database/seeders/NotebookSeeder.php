<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Notebook;

class NotebookSeeder extends Seeder
{
  public function run(): void
  {
    User::all()->each(function ($user) {
      Notebook::factory()->count(2)->for($user)->create();
    });
  }
}
