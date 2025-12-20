<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VocabularyReview extends Model
{
    use HasFactory;

    protected $fillable = [
        'vocabulary_id',
        'user_id',
        'result',
        'reviewed_at',
    ];

    protected $casts = [
        'reviewed_at' => 'datetime',
    ];

    /* ================= Relations ================= */

    public function vocabulary()
    {
        return $this->belongsTo(Vocabulary::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
