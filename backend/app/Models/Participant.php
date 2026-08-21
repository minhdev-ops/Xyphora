<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Participant extends Model
{
    protected $primaryKey = 'participant_id';

    public $timestamps = false;

    protected $fillable = [
        'event_id',
        'user_id',
        'display_name',
        'email',
        'avatar',
        'role',
        'status',
    ];

    protected $casts = [
        'joined_at' => 'datetime',
    ];

    public function event(): BelongsTo
    {
        return $this->belongsTo(Event::class, 'event_id', 'event_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }
}
