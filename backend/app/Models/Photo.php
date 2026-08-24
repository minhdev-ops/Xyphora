<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Photo extends Model
{
    protected $table = 'Photo';
    protected $primaryKey = 'photo_id';
    public $timestamps = false; // Bật true nếu bảng của bạn có created_at, updated_at

    protected $fillable = [
        'link',
        'type',
    ];
}
