<?php

namespace Modules\Admin\Resources\Setting;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

class SettingCollection extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'parent_id' => $this->parent_id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'order' => $this->order,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'fields' => $this->fields->map(fn($field) => $this->transformField($field)),
            'children' => $this->whenLoaded('children', function () {
                return SettingCollection::collection($this->children);
            }),
        ];
    }

    protected function transformField($field): array
    {
        return [
            'id' => $field->id,
            'group_id' => $field->group_id,
            'name' => $field->name,
            'slug' => $field->slug,
            'type' => $field->type,
            'value' => $field->type === 'json'
                ? json_decode($field->value, true)
                : $field->value,
            'placeholder' => $field->placeholder,
            'description' => $field->description,
            'is_required' => (bool) $field->is_required,
            'options' => $field->options ? json_decode($field->options, true) : null,
            'validation' => $field->validation ? json_decode($field->validation, true) : null,
            'attributes' => $field->attributes ? json_decode($field->attributes, true) : null,
            'order' => $field->order,
            'created_at' => Carbon::parse($this->created_at)->format('d-m-Y H:i:s'),
            'updated_at' => Carbon::parse($this->updated_at)->format('d-m-Y H:i:s'),
        ];
    }
}
