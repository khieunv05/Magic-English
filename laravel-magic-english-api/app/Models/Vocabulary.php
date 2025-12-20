<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vocabulary extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'notebook_id',
        'word',
        'ipa',
        'meaning',
        'part_of_speech',
        'example',
        'cefr_level',
        'review_count',
        'last_reviewed_at',
    ];

    protected $casts = [
        'last_reviewed_at' => 'datetime',
    ];

    /* ================= Relations ================= */

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function notebook()
    {
        return $this->belongsTo(Notebook::class);
    }

    public function reviews()
    {
        return $this->hasMany(VocabularyReview::class);
    }
}
