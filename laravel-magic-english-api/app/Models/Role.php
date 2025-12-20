<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Role extends Model
{
    protected $table = 'roles';
    protected $guarded = [];

    public function permissions(): BelongsToMany
    {
        return $this->belongsToMany(Permission::class, 'permission_role');
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'role_user');
    }

    /**
     * Scope: Tìm kiếm theo từ khóa (keywords)
     */
    public function scopeKeywords($query, $keywords)
    {
        if (!empty($keywords)) {
            return $query->where('name', 'LIKE', "%{$keywords}%")
                ->orWhere('description', 'LIKE', "%{$keywords}%");
        }
        return $query;
    }
}
