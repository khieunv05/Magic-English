<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void
  {
    Schema::create('learning_activities', function (Blueprint $table) {
      $table->engine = 'InnoDB';

      $table->id();

      $table->unsignedBigInteger('user_id');
      $table->unsignedBigInteger('notebook_id')->nullable();

      $table->enum('type', ['add_vocab', 'review_vocab', 'grammar_check']);
      $table->unsignedBigInteger('related_id')->nullable();
      $table->date('activity_date');

      $table->timestamps();
      $table->index(['user_id', 'activity_date']);
    });
  }

  public function down(): void
  {
    Schema::dropIfExists('learning_activities');
  }
};

