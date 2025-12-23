<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void
  {
    if (!Schema::hasTable('vocabulary_reviews')) {
      Schema::create('vocabulary_reviews', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->cascadeOnDelete();
        $table->foreignId('vocabulary_id')->constrained()->cascadeOnDelete();
        $table->unsignedInteger('repetition')->default(0);
        $table->unsignedInteger('interval_days')->default(0);
        $table->decimal('ease_factor', 4, 2)->default(2.50);
        $table->tinyInteger('last_grade')->nullable(); // 0..5
        $table->timestamp('due_at')->nullable();
        $table->timestamp('last_reviewed_at')->nullable();
        $table->unsignedInteger('total_reviews')->default(0);
        $table->timestamps();

        $table->unique(['user_id', 'vocabulary_id']);
        $table->index(['user_id', 'due_at']);
      });
    }
  }

  public function down(): void
  {
    Schema::dropIfExists('vocabulary_reviews');
  }
};
