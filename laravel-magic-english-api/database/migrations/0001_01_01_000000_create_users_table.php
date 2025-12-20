<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('username')->nullable()->unique();
            $table->string('email')->unique();
            $table->string('description')->nullable()->comment('Mô tả người dùng');
            $table->string('phone')->nullable()->unique()->comment('Số điện thoại');
            $table->string('code')->nullable()->unique()->comment('Mã khách hàng');
            $table->string('image')->nullable()->comment('Ảnh đại diện');
            $table->string('password');
            $table->enum('status', ['active', 'inactive', 'banned', 'pending'])->default('active')->comment('Trạng thái');
            $table->enum('gender', ['male', 'female', 'other'])->nullable()->comment('Giới tính');
            $table->enum('is_staff', ['staff', 'user'])->default('user')->comment('Nhân viên quản lý ?');
            $table->foreignId('wallet_id')->nullable()->index()->comment('ID ví');
            $table->string('heard_from')->nullable()->comment('Nguồn biết đến');
            $table->timestamp('email_verified_at')->nullable();
            $table->string('email_verification_code', 10)->nullable()->comment('OTP 6 số xác minh email');
            $table->timestamp('email_verification_expires_at')->nullable()->comment('Hết hạn OTP');
            $table->unsignedSmallInteger('email_verification_attempts')->default(0)->comment('Số lần nhập OTP sai');
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('social_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            $table->string('provider');
            $table->string('provider_id');
            $table->string('provider_email')->nullable();
            $table->string('provider_name')->nullable();
            $table->string('avatar')->nullable();

            $table->timestamps();

            $table->unique(['provider', 'provider_id']);
            $table->index(['provider', 'provider_email']);
        });

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('sessions');
    }
};
