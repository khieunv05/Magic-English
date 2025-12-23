<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void
  {
    // Upgrade existing vocabulary_reviews to SM-2 fields if created by older migration
    if (Schema::hasTable('vocabulary_reviews')) {
      Schema::table('vocabulary_reviews', function (Blueprint $table) {
        if (!Schema::hasColumn('vocabulary_reviews', 'repetition')) {
          $table->unsignedInteger('repetition')->default(0)->after('user_id');
        }
        if (!Schema::hasColumn('vocabulary_reviews', 'interval_days')) {
          $table->unsignedInteger('interval_days')->default(0)->after('repetition');
        }
        if (!Schema::hasColumn('vocabulary_reviews', 'ease_factor')) {
          $table->decimal('ease_factor', 4, 2)->default(2.50)->after('interval_days');
        }
        if (!Schema::hasColumn('vocabulary_reviews', 'last_grade')) {
          $table->tinyInteger('last_grade')->nullable()->after('ease_factor');
        }
        if (!Schema::hasColumn('vocabulary_reviews', 'due_at')) {
          $table->timestamp('due_at')->nullable()->after('last_grade');
        }
        if (!Schema::hasColumn('vocabulary_reviews', 'last_reviewed_at')) {
          $table->timestamp('last_reviewed_at')->nullable()->after('due_at');
        }
        if (!Schema::hasColumn('vocabulary_reviews', 'total_reviews')) {
          $table->unsignedInteger('total_reviews')->default(0)->after('last_reviewed_at');
        }
      });

      // Ensure composite unique on (user_id, vocabulary_id)
      Schema::table('vocabulary_reviews', function (Blueprint $table) {
        // Add index for scheduling, if missing
        $table->index(['user_id', 'due_at']);
      });
    }
  }

  public function down(): void
  {
    // Optional rollback: drop added columns if present
    if (Schema::hasTable('vocabulary_reviews')) {
      Schema::table('vocabulary_reviews', function (Blueprint $table) {
        if (Schema::hasColumn('vocabulary_reviews', 'total_reviews')) {
          $table->dropColumn('total_reviews');
        }
        if (Schema::hasColumn('vocabulary_reviews', 'last_reviewed_at')) {
          $table->dropColumn('last_reviewed_at');
        }
        if (Schema::hasColumn('vocabulary_reviews', 'due_at')) {
          $table->dropColumn('due_at');
        }
        if (Schema::hasColumn('vocabulary_reviews', 'last_grade')) {
          $table->dropColumn('last_grade');
        }
        if (Schema::hasColumn('vocabulary_reviews', 'ease_factor')) {
          $table->dropColumn('ease_factor');
        }
        if (Schema::hasColumn('vocabulary_reviews', 'interval_days')) {
          $table->dropColumn('interval_days');
        }
        if (Schema::hasColumn('vocabulary_reviews', 'repetition')) {
          $table->dropColumn('repetition');
        }
      });
    }
  }
};
