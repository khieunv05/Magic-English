<?php

namespace Modules\Admin\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SettingField extends Model
{
    use HasFactory;

    protected $table = 'setting_fields';
    protected $guarded = [];
}
