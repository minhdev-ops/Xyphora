<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Expense extends Model
{
    public const SPLIT_EQUAL = 'equal';

    public const SPLIT_EXACT = 'exact';

    public const SPLIT_PERCENTAGE = 'percentage';

    public const SPLIT_SHARE = 'share';

    protected $table = 'expenses';

    protected $primaryKey = 'expense_id';

    protected $fillable = [
        'event_id',
        'created_by',
        'payer_id',
        'category_id',
        'title',
        'description',
        'amount',
        'currency',
        'expense_date',
        'expense_type',
        'split_method',
        'note',
        'is_deleted',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'expense_date' => 'date',
            'is_deleted' => 'boolean',
        ];
    }

    /**
     * Mac dinh chi truy van cac chi phi chua bi xoa mem.
     */
    protected static function booted(): void
    {
        static::addGlobalScope('not-deleted', function (Builder $builder) {
            $builder->where('is_deleted', false);
        });
    }

    public function event(): BelongsTo
    {
        return $this->belongsTo(Event::class, 'event_id', 'event_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by', 'id');
    }

    public function payer(): BelongsTo
    {
        return $this->belongsTo(Participant::class, 'payer_id', 'participant_id');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'category_id', 'category_id');
    }

    public function splits(): HasMany
    {
        return $this->hasMany(ExpenseSplit::class, 'expense_id', 'expense_id');
    }

    public function history(): HasMany
    {
        return $this->hasMany(ExpenseHistory::class, 'expense_id', 'expense_id');
    }

    public function photos(): BelongsToMany
    {
        return $this->belongsToMany(
            Photo::class,
            'expense_photos',
            'expense_id',
            'photo_id',
            'expense_id',
            'photo_id'
        );
    }
}
