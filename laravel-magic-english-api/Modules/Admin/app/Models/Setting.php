<?php

namespace Modules\Admin\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Cache;

use Modules\Admin\Models\SettingField;

class Setting extends Model
{
    use HasFactory;

    protected $table = 'settings';
    protected $guarded = [];

    public static function getSettings()
    {
        return Cache::remember('settings', 3600, function () {
            return self::all()->pluck('value', 'key')->toArray();
        });
    }

    public static function get($key, $default = null)
    {
        $settings = self::getSettings();
        return $settings[$key] ?? $default;
    }

    /**
     * Get all of the fields for the Setting
     *
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function fields(): HasMany
    {
        return $this->hasMany(SettingField::class, 'group_id')->orderBy('order');
    }

    /**
     * Get all of the children for the Setting
     *
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function children(): HasMany
    {
        return $this->hasMany(Setting::class, 'parent_id')->orderBy('order');
    }
}
