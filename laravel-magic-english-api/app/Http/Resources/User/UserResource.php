<?php

namespace App\Http\Resources\User;

use Illuminate\Support\Carbon;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    private function resolveGenderVi(mixed $gender): ?string
    {
        if (!is_string($gender)) {
            return null;
        }

        $value = trim(mb_strtolower($gender));

        return match ($value) {
            'male' => 'nam',
            'female' => 'nữ',
            'other' => 'khác',
            default => $gender,
        };
    }

    private function resolveAvatarUrl(?string $image): ?string
    {
        $image = $image ? trim($image) : '';
        if ($image === '') {
            return null;
        }

        // If already a full URL (e.g. social login avatar), return as-is
        if (preg_match('/^https?:\/\//i', $image)) {
            return $image;
        }

        // Otherwise treat as a public path (e.g. storage/avatars/..)
        return asset(ltrim($image, '/'));
    }

    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'date_of_birth' => $this->date_of_birth,
            'email' => $this->email,
            'role' => $this->role,
            'phone' => $this->phone,
            'status' => $this->status,
            'gender' => $this->resolveGenderVi($this->gender),
            'image' => $this->image,
            'avatar' => $this->resolveAvatarUrl($this->image),

            'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
            'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
        ];
    }
}
