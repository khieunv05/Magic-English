<?php

namespace App\Models\Address;

use Illuminate\Database\Eloquent\Model;

class AdministrativeUnit extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'id',
        'full_name',
        'full_name_en',
        'short_name',
        'short_name_en',
        'code_name',
        'code_name_en'
    ];
}
