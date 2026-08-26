<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Event extends Model
{
    protected $primaryKey = 'event_id';

    protected $fillable = [
        'owner_id',
        'title',
        'description',
        'icon',
        'cover_photo',
        'currency',
        'start_date',
        'end_date',
        'status',
    ];

    protected $casts = [
        'start_date' => 'date:Y-m-d',
        'end_date' => 'date:Y-m-d',
    ];

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id', 'id');
    }

    public function participants(): HasMany
    {
        return $this->hasMany(Participant::class, 'event_id', 'event_id');
    }

    public function expenses(): HasMany
    {
        return $this->hasMany(Expense::class, 'event_id', 'event_id');
    }
}
