<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('learning_activities', function (Blueprint $table) {
            $table->foreign('user_id')
                ->references('id')->on('users')
                ->onDelete('cascade');

            $table->foreign('notebook_id')
                ->references('id')->on('notebooks')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('learning_activities', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropForeign(['notebook_id']);
        });
    }
};

