<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Photo extends Model
{
    protected $table = 'photos';

    protected $primaryKey = 'photo_id';

    public $timestamps = false;

    protected $fillable = [
        'link',
        'mime_type',
        'size',
        'uploaded_by',
    ];

    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by', 'id');
    }

    public function expenses(): BelongsToMany
    {
        return $this->belongsToMany(
            Expense::class,
            'expense_photos',
            'photo_id',
            'expense_id',
            'photo_id',
            'expense_id'
        );
    }
}
