<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expense_photos', function (Blueprint $table) {
            $table->unsignedBigInteger('expense_id');
            $table->unsignedBigInteger('photo_id');

            $table->primary(['expense_id', 'photo_id']);
            $table->index('photo_id', 'idx_expense_photos_photo');

            $table->foreign('expense_id', 'fk_expense_photos_expense')
                ->references('expense_id')->on('expenses')
                ->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreign('photo_id', 'fk_expense_photos_photo')
                ->references('photo_id')->on('photos')
                ->cascadeOnUpdate()->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expense_photos');
    }
};
