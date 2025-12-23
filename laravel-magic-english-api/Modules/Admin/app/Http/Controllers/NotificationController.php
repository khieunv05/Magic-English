<?php

namespace Modules\Admin\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class NotificationController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $user = Auth::guard("admin")->user();

        $query = $user->notifications()->latest();

        if ($request->has('filter') && $request->filter === 'unread') {
            $query->whereNull('read_at');
        }

        $notifications = $query->paginate(10);

        return response()->json([
            'status' => true,
            'result' => $notifications
        ]);
    }

    /**
     * Đánh dấu 1 thông báo là đã đọc.
     */
    public function markAsRead($id): JsonResponse
    {
        $user = Auth::guard("admin")->user();

        $notification = $user->notifications()->findOrFail($id);
        $notification->markAsRead();

        return $this->apiResponse(true, 'Đã đánh dấu đã đọc.');
    }

    /**
     * Đánh dấu tất cả thông báo là đã đọc.
     */
    public function markAllAsRead(): JsonResponse
    {
        $user = Auth::guard("admin")->user();

        $user->unreadNotifications->markAsRead();

        return $this->apiResponse(true, 'Tất cả thông báo đã được đánh dấu là đã đọc.');
    }

    /**
     * Xóa 1 thông báo.
     */
    public function destroy($id): JsonResponse
    {
        $user = Auth::guard("admin")->user();

        $notification = $user->notifications()->findOrFail($id);
        $notification->delete();

        return $this->apiResponse(true, 'Thông báo đã được xóa.');
    }
}
