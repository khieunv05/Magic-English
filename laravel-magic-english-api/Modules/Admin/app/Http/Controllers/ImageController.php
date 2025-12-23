<?php

namespace Modules\Admin\Http\Controllers;

use Throwable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;
use Treconyl\ImagesUpload\ImageUpload;

class ImageController extends \App\Http\Controllers\Controller
{
    private function normalizeStoragePaths(mixed $data): mixed
    {
        if (is_string($data)) {
            $path = parse_url($data, PHP_URL_PATH) ?: $data;
            $path = str_replace('/public/storage/', '/storage/', $path);
            $path = preg_replace('#^public/storage/#', 'storage/', ltrim($path, '/'));
            if (!Str::startsWith($path, '/')) {
                $path = '/' . $path;
            }
            return $path;
        }

        if (is_array($data)) {
            return array_map(fn($v) => $this->normalizeStoragePaths($v), $data);
        }

        if (is_object($data)) {
            foreach ($data as $k => $v) {
                $data->{$k} = $this->normalizeStoragePaths($v);
            }
            return $data;
        }

        return $data;
    }

    public function upload(Request $request): JsonResponse
    {
        $image  = $request->image;
        $folder = $request->folder;

        try {
            if ($request->hasFile('image')) {
                $image = ImageUpload::file($request, 'image')
                    ->folder($folder)
                    ->convert('webp')
                    ->store();
            }

            $image = $this->normalizeStoragePaths($image);
            Log::info('image_output', ['image' => $image]);

            return $this->apiResponse(true, 'Upload Image Successfully', $image);
        } catch (Throwable $exception) {
            Log::error('image_upload_error', ['error' => $exception->getMessage()]);
            return $this->apiResponse(false, $exception->getMessage());
        }
    }

    public function uploads(Request $request): JsonResponse
    {
        $image  = $request->image;
        $folder = $request->folder;

        try {
            if ($request->hasFile('files')) {
                $image = ImageUpload::file($request, 'files')
                    ->folder($folder)
                    ->convert('webp')
                    ->store();
            }

            $image = $this->normalizeStoragePaths($image);
            Log::info('images_output', ['images' => $image]);

            return $this->apiResponse(true, 'Upload Image Successfully', $image);
        } catch (Throwable $exception) {
            Log::error('images_upload_error', ['error' => $exception->getMessage()]);
            return $this->apiResponse(false, $exception->getMessage());
        }
    }
}
