<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void
  {
    Schema::create('vocabulary_reviews', function (Blueprint $table) {
      $table->id();
      $table->foreignId('vocabulary_id')->constrained()->cascadeOnDelete();
      $table->foreignId('user_id')->constrained()->cascadeOnDelete();
      $table->enum('result', ['remembered', 'forgot']);
      $table->timestamp('reviewed_at');
      $table->timestamps();

      $table->index(['user_id', 'reviewed_at']);
    });
  }

  public function down(): void
  {
    Schema::dropIfExists('vocabulary_reviews');
  }
};
