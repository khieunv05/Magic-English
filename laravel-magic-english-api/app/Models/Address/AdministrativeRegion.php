<?php

namespace App\Models\Address;

use Illuminate\Database\Eloquent\Model;

class AdministrativeRegion extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'id',
        'name',
        'name_en',
        'code_name',
        'code_name_en'
    ];
}
