<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Event extends Model
{
    use HasFactory;

    protected $table = 'events';

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

    protected function casts(): array
    {
        return [
            'start_date' => 'date',
            'end_date' => 'date',
        ];
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id', 'id');
    }

    public function participants(): HasMany
    {
        return $this->hasMany(Participant::class, 'event_id', 'event_id');
    }

    public function invitations(): HasMany
    {
        return $this->hasMany(Invitation::class, 'event_id', 'event_id');
    }

    public function expenses(): HasMany
    {
        return $this->hasMany(Expense::class, 'event_id', 'event_id');
    }

    public function settlements(): HasMany
    {
        return $this->hasMany(Settlement::class, 'event_id', 'event_id');
    }
}
