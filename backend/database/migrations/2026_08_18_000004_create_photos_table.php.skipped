<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('photos', function (Blueprint $table) {
            $table->id('photo_id');
            $table->string('link', 500);
            $table->string('mime_type', 50)->nullable();
            $table->unsignedBigInteger('size')->nullable();
            $table->foreignId('uploaded_by');
            $table->timestamp('created_at')->nullable(false)->useCurrent();

            $table->index('uploaded_by', 'idx_photos_uploaded_by');

            $table->foreign('uploaded_by', 'fk_photos_uploaded_by')
                ->references('id')->on('users')
                ->restrictOnDelete()->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('photos');
    }
};