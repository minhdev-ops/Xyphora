<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Participant extends Model
{
    public const ROLE_OWNER = 'owner';

    public const ROLE_ADMIN = 'admin';

    public const ROLE_MEMBER = 'member';

    public const STATUS_ACTIVE = 'active';

    public const STATUS_REMOVED = 'removed';

    public const STATUS_LEFT = 'left';

    protected $table = 'participants';

    protected $primaryKey = 'participant_id';

    public $timestamps = false;

    protected $fillable = [
        'event_id',
        'user_id',
        'display_name',
        'email',
        'avatar',
        'role',
        'joined_at',
        'status',
    ];

    public function event(): BelongsTo
    {
        return $this->belongsTo(Event::class, 'event_id', 'event_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function paidExpenses(): HasMany
    {
        return $this->hasMany(Expense::class, 'payer_id', 'participant_id');
    }

    public function splits(): HasMany
    {
        return $this->hasMany(ExpenseSplit::class, 'participant_id', 'participant_id');
    }
}
