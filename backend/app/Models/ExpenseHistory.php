<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ExpenseHistory extends Model
{
    protected $table = 'expense_history';

    protected $primaryKey = 'history_id';

    public $timestamps = false;

    protected $fillable = [
        'expense_id',
        'updated_by',
        'field_name',
        'old_value',
        'new_value',
    ];

    public function expense(): BelongsTo
    {
        return $this->belongsTo(Expense::class, 'expense_id', 'expense_id');
    }

    public function updater(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by', 'id');
    }
}
