<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GrammarCheck extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'original_text',
        'score',
        'errors',
        'suggestions',
    ];

    protected $casts = [
        'errors' => 'array',
        'suggestions' => 'array',
    ];

    /* ================= Relations ================= */

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
