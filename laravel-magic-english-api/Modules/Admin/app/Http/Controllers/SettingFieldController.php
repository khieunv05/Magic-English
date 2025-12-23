<?php

namespace Modules\Admin\Http\Controllers;

use Illuminate\Http\JsonResponse;

use Illuminate\Support\Str;
use Modules\Admin\Models\Setting;
use Modules\Admin\Models\SettingField;
use Modules\Admin\Http\Requests\Setting\CreateSettingFieldRequest;
use Modules\Admin\Http\Requests\Setting\UpdateSettingFieldRequest;

use Modules\Admin\Resources\Setting\SettingResource;

class SettingFieldController extends \App\Http\Controllers\Controller
{
    /**
     * Store a newly created resource in storage.
     */
    public function store(CreateSettingFieldRequest $request): JsonResponse
    {
        $data = $request->validated();

        $field = SettingField::create([
            'group_id' => $data['group_id'],
            'name' => $data['name'],
            'slug' => Str::slug($data['name']),
            'type' => $data['type'],
            'options' => isset($data['options']) ? json_encode($data['options']) : null,
            'value' => $data['value'] ?? null,
            'is_required' => $data['is_required'] ?? false,
            'placeholder' => $data['placeholder'] ?? null,
            'description' => $data['description'] ?? null,
            'validation' => isset($data['validation']) ? json_encode($data['validation']) : null,
            'attributes' => isset($data['attributes']) ? json_encode($data['attributes']) : null,
            'order' => $data['order'] ?? 0,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Field created successfully',
            'data' => $field,
        ]);
    }

    /**
     * Show the specified resource.
     */
    public function show($id)
    {
        $setting = Setting::findOrFail($id);

        return new SettingResource($setting);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateSettingFieldRequest $request, $id): JsonResponse
    {
        $field = SettingField::findOrFail($id);
        $data = $request->validated();

        $field->update([
            'name' => $data['name'],
            'slug' => Str::slug($data['slug']),
            'type' => $data['type'],
            'options' => isset($data['options']) ? json_encode($data['options']) : null,
            'value' => $data['value'] ?? null,
            'is_required' => $data['is_required'] ?? false,
            'placeholder' => $data['placeholder'] ?? null,
            'description' => $data['description'] ?? null,
            'validation' => isset($data['validation']) ? json_encode($data['validation']) : null,
            'attributes' => isset($data['attributes']) ? json_encode($data['attributes']) : null,
            'order' => $data['order'] ?? 0,
        ]);

        return response()->json(['status' => true, 'message' => 'Field updated successfully']);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id): JsonResponse
    {
        $field = SettingField::findOrFail($id);
        $field->delete();

        return response()->json(['status' => true, 'message' => 'Field deleted successfully']);
    }
}
