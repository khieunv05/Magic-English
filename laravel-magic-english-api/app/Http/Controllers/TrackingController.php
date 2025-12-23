<?php

namespace App\Http\Controllers;

use App\Models\LearningActivity;
use App\Services\Tracking\TrackingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TrackingController extends Controller
{
  public function __construct(private readonly TrackingService $tracking)
  {
  }

  // FR3.1: List activities (auto-logged elsewhere)
  public function activities(Request $request)
  {
    $userId = Auth::id();
    $query = LearningActivity::query()->where('user_id', $userId)->orderByDesc('created_at');

    if ($request->filled('type')) {
      $query->where('type', $request->string('type'));
    }
    if ($request->filled('from')) {
      $query->where('created_at', '>=', $request->date('from'));
    }
    if ($request->filled('to')) {
      $query->where('created_at', '<=', $request->date('to'));
    }

    $items = $query->paginate($request->integer('per_page', 15));
    return $this->apiResponse(true, 'Danh sách hoạt động', [
      'items' => $items->items(),
      'pagination' => [
        'total' => $items->total(),
        'per_page' => $items->perPage(),
        'current_page' => $items->currentPage(),
        'last_page' => $items->lastPage(),
      ],
    ]);
  }

  // FR3.2: Streak calculation
  public function streak()
  {
    $userId = Auth::id();
    return $this->apiResponse(true, 'Streak hiện tại', $this->tracking->getStreak($userId));
  }

  // FR3.3: Overview stats
  public function overview()
  {
    $userId = Auth::id();
    return $this->apiResponse(true, 'Tổng quan học tập', $this->tracking->getOverview($userId));
  }

  // FR3.4: Visualization data
  public function visualization()
  {
    $userId = Auth::id();
    return $this->apiResponse(true, 'Dữ liệu trực quan', $this->tracking->getVisualization($userId));
  }
}
