<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Phan chia chi phi cho tung thanh vien.
 *
 * LUU Y: bang nay dung KHOI CHINH TONG HOP (expense_id, participant_id).
 * Eloquent khong ho tro composite primary key, vi vay cac thao tac find/get
 * mac dinh cua Eloquent khong dung duoc. Truy van theo dung 2 khoa:
 *
 *   ExpenseSplit::where('expense_id', $x)->where('participant_id', $p)->first()
 *
 * Khong goi ExpenseSplit::find($id) hoac moi quan he belongsTo/HasMany goc
 * tu model nay (chi doc du lieu qua query builder thong thuong).
 */
class ExpenseSplit extends Model
{
    public const STATUS_PENDING = 'pending';

    public const STATUS_SETTLED = 'settled';

    protected $table = 'expense_splits';

    protected $primaryKey = 'expense_id';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'expense_id',
        'participant_id',
        'amount',
        'percentage',
        'share',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'percentage' => 'decimal:2',
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
