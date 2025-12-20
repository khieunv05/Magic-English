<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void
  {
    Schema::create('vocabularies', function (Blueprint $table) {
      $table->id();
      $table->foreignId('notebook_id')->constrained()->cascadeOnDelete();
      $table->foreignId('user_id')->constrained()->cascadeOnDelete();
      $table->string('word');
      $table->string('ipa')->nullable();
      $table->string('meaning');
      $table->string('part_of_speech');
      $table->text('example')->nullable();
      $table->string('cefr_level', 2);
      $table->unsignedInteger('review_count')->default(0);
      $table->timestamp('last_reviewed_at')->nullable();
      $table->timestamps();

      $table->unique(['notebook_id', 'word']);
    });
  }

  public function down(): void
  {
    Schema::dropIfExists('vocabularies');
  }
};
