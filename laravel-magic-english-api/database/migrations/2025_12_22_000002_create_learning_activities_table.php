<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void
  {
    Schema::create('learning_activities', function (Blueprint $table) {
      $table->id();
      $table->foreignId('user_id')->constrained()->cascadeOnDelete();
      $table->string('type', 50); // e.g. vocabulary_added, grammar_scored
      $table->json('data')->nullable();
      $table->timestamps();

      $table->index(['user_id', 'created_at']);
      $table->index(['type']);
    });
  }

  public function down(): void
  {
    Schema::dropIfExists('learning_activities');
  }
};
