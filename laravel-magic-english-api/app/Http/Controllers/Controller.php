<?php

namespace App\Http\Controllers;

use Throwable;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;

class Controller extends \Illuminate\Routing\Controller
{
    use AuthorizesRequests, ValidatesRequests;

    public function apiResponse($status = true, $message = 'Success', $result = []): JsonResponse
    {
        return response()->json(array(
            'status' => $status,
            'message' => $message,
            'result' => $result,
        ));
    }

    public function action($params, string $table): JsonResponse
    {
        DB::beginTransaction();
        try {
            $modal = new $table;
            $idsArray = explode(',', $params['ids']);
            $tablteAction = $modal->whereIn('id', $idsArray)->get();

            if ($params['action'] == 'delete') {
                $tablteAction->each->delete();
            }
            if ($params['action'] == 'status') {
                $tablteAction->each->update([
                    'status' => $params['status']
                ]);
            }

            DB::commit();

            return $this->apiResponse(true, 'Success');
        } catch (Throwable $exception) {
            DB::rollBack();

            return $this->apiResponse(false, $exception->getMessage());
        }
    }

    public function flattenNestedArray(array $nestedArray, int $parentId = 0): array
    {
        $result = collect();

        foreach ($nestedArray as $index => $item) {
            $sortOrder = $index + 1;

            $result->push([
                'id' => $item['id'],
                'parent_id' => $parentId,
                'sort_order' => $sortOrder,
            ]);

            if (!empty($item['children'])) {
                $result = $result->merge($this->flattenNestedArray($item['children'], $item['id']));
            }
        }

        return $result->values()->toArray();
    }
}
