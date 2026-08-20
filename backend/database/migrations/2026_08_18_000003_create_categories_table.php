<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id('category_id');
            $table->string('name', 100);
            $table->string('icon', 50)->nullable();
            $table->string('color', 7)->default('#64748b');
            $table->enum('type', ['expense', 'income'])->default('expense');
            $table->boolean('is_default')->default(false);
            $table->foreignId('created_by')->nullable();

            $table->index('created_by', 'idx_categories_created_by');
            $table->index('type', 'idx_categories_type');

            $table->foreign('created_by', 'fk_categories_created_by')
                ->references('id')->on('users')
                ->nullOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};