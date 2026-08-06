<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    public const TYPE_EXPENSE = 'expense';

    public const TYPE_INCOME = 'income';

    protected $table = 'categories';

    protected $primaryKey = 'category_id';

    public $timestamps = false;

    protected $fillable = [
        'name',
        'icon',
        'color',
        'type',
        'is_default',
        'created_by',
    ];

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by', 'id');
    }

    public function expenses(): HasMany
    {
        return $this->hasMany(Expense::class, 'category_id', 'category_id');
    }
}
