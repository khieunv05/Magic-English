<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_id')->nullable()->constrained('settings')->onDelete('cascade')->comment('ID của tab cha, nếu NULL là tab lớn');
            $table->string('name')->comment('Tên của tab hoặc nhóm cài đặt');
            $table->string('slug')->unique()->comment('Định danh duy nhất');
            $table->text('description')->nullable()->comment('Mô tả ngắn về tab hoặc nhóm cài đặt');
            $table->integer('order')->default(0)->comment('Thứ tự hiển thị');
            $table->timestamps();
        });

        Schema::create('setting_fields', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained('settings')->onDelete('cascade')->comment('ID của nhóm chứa trường cài đặt');
            $table->string('name')->comment('Tên trường cài đặt');
            $table->string('slug')->unique()->comment('Định danh duy nhất của trường');
            $table->enum('type', ['text', 'textarea', 'select', 'multi-select', 'radio', 'checkbox', 'image', 'file', 'number', 'email', 'password', 'date-range', 'code', 'json'])->default('text')->comment('Loại dữ liệu của trường');
            $table->text('options')->nullable()->comment('Lựa chọn cho các kiểu select, radio, checkbox (Lưu JSON)');
            $table->text('value')->nullable()->comment('Giá trị hiện tại của trường');
            $table->boolean('is_required')->default(false)->comment('Trường có bắt buộc nhập không');
            $table->string('placeholder')->nullable()->comment('Văn bản gợi ý nhập cho trường');
            $table->text('description')->nullable()->comment('Mô tả ngắn về trường cài đặt');
            $table->text('validation')->nullable()->comment('Các quy tắc kiểm tra dữ liệu (Lưu JSON)');
            $table->text('attributes')->nullable()->comment('Các thuộc tính của trường (Lưu JSON)');
            $table->integer('order')->default(0)->comment('Thứ tự hiển thị của trường');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('setting_fields');
        Schema::dropIfExists('settings');
    }
};
