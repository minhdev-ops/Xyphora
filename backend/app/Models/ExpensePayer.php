<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Nhung nguoi da tra cho mot khoan chi tieu (ho tro nhieu nguoi tra).
 *
 * Bang nay dung KHOI CHINH (expense_id, participant_id). Eloquent khong ho tro
 * composite primary key, vi vay truy van theo dung 2 khoa.
 */
class ExpensePayer extends Model
{
    protected $table = 'expense_payers';

    protected $primaryKey = 'expense_id';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'expense_id',
        'participant_id',
        'amount',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
        ];
    }

    public function expense(): BelongsTo
    {
        return $this->belongsTo(Expense::class, 'expense_id', 'expense_id');
    }

    public function participant(): BelongsTo
    {
        return $this->belongsTo(Participant::class, 'participant_id', 'participant_id');
    }
}