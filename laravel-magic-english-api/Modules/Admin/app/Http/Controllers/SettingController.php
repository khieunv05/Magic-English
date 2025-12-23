<?php

namespace Modules\Admin\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Cache;

use Modules\Admin\Models\Setting;
use Modules\Admin\Models\SettingField;

use Modules\Admin\Http\Requests\Setting\SettingRequest;

use Modules\Admin\Resources\Setting\SettingCollection;
use Modules\Admin\Resources\Setting\SettingResource;

class SettingController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(): JsonResponse
    {
        $settings = Cache::remember('settings', Carbon::now()->addDays(30), function () {
            return Setting::with(['fields', 'children.fields'])->whereNull('parent_id')->orderBy('order')->get();
        });

        return $this->apiResponse(
            true,
            'Settings fetched successfully',
            SettingCollection::collection($settings),
        );
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(SettingRequest $request): JsonResponse
    {
        foreach ($request->validated('fields') as $fieldData) {
            SettingField::create([
                'group_id' => $fieldData['group_id'],
                'name' => $fieldData['name'],
                'slug' => $fieldData['slug'],
                'type' => $fieldData['type'] ?? 'text',
                'options' => isset($fieldData['options']) ? json_encode($fieldData['options']) : null,
                'value' => isset($fieldData['value'])
                    ? (is_array($fieldData['value']) ? json_encode($fieldData['value']) : $fieldData['value'])
                    : null,
                'is_required' => $fieldData['is_required'] ?? false,
                'placeholder' => $fieldData['placeholder'] ?? null,
                'description' => $fieldData['description'] ?? null,
                'validation' => isset($fieldData['validation']) ? json_encode($fieldData['validation']) : null,
                'attributes' => isset($fieldData['attributes']) ? json_encode($fieldData['attributes']) : null,
                'order' => $fieldData['order'] ?? 0,
            ]);
        }

        return response()->json(['status' => true, 'message' => 'Field created successfully']);
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
    public function updateAll(Request $request): JsonResponse
    {
        $data = $request->except('_token', '_method');
        $updatedCount = 0;

        try {
            foreach ($data as $slug => $value) {
                $field = SettingField::where('slug', $slug)->first();

                if (!$field) {
                    logger("Không tìm thấy field với slug: {$slug}");
                    continue;
                }

                $value = $this->transformValue($field, $value, $request);

                // Cập nhật giá trị nếu thay đổi
                if ($field->value !== $value) {
                    $field->value = $value;
                    $field->save();
                    $updatedCount++;
                }
            }

            return $this->apiResponse(
                true,
                $updatedCount > 0 ? 'Cập nhật cài đặt thành công.' : 'Không có thay đổi nào được lưu.'
            );
        } catch (\Throwable $th) {
            logger("Lỗi cập nhật settings: " . $th->getMessage());
            return $this->apiResponse(false, 'Đã xảy ra lỗi: ' . $th->getMessage());
        }
    }

    private function transformValue($field, $value, $request)
    {
        if ($field->type === 'checkbox') {
            return is_array($value) ? json_encode($value) : json_encode([]);
        }

        return $value;
    }

    public function updateOrder(Request $request): JsonResponse
    {
        $groups = $request->input('groups', []);

        foreach ($groups as $group) {
            Setting::where('id', $group['id'])->update(['order' => $group['order']]);
        }

        return response()->json(['success' => true]);
    }

    public function updateFieldOrder(Request $request): JsonResponse
    {
        $fields = $request->input('fields', []);

        foreach ($fields as $field) {
            SettingField::where('id', $field['id'])->update([
                'order' => $field['order'],
                'group_id' => $field['group_id'],
            ]);
        }

        return response()->json(['success' => true]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        //
    }
}
