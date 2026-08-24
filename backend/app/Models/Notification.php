<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Notification extends Model
{
    public const TYPE_INVITATION = 'invitation';

    public const TYPE_EXPENSE_ADDED = 'expense_added';

    public const TYPE_EXPENSE_UPDATED = 'expense_updated';

    public const TYPE_EXPENSE_DELETED = 'expense_deleted';

    public const TYPE_SETTLEMENT_REQUEST = 'settlement_request';

    public const TYPE_SETTLEMENT_COMPLETED = 'settlement_completed';

    public const TYPE_REMINDER = 'reminder';

    public const TYPE_SYSTEM = 'system';

    protected $table = 'notifications';

    protected $primaryKey = 'notification_id';

    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'type',
        'title',
        'content',
        'reference_id',
        'is_read',
    ];

    protected function casts(): array
    {
        return [
            'is_read' => 'boolean',
        ];
    }

    public function scopeUnread(Builder $query): Builder
    {
        return $query->where('is_read', false);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }
}
