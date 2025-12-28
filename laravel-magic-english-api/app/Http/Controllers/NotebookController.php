<?php

namespace App\Http\Controllers;

use App\Models\Notebook;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

use App\Http\Resources\Notebook\NotebookCollection;
use App\Http\Resources\Notebook\NotebookResource;
use App\Http\Requests\Notebook\StoreNotebookRequest;
use App\Http\Requests\Notebook\UpdateNotebookRequest;

class NotebookController extends Controller
{
  // List notebooks
  public function index(Request $request): JsonResponse
  {
    // Auth is enforced by middleware; safely read current user id if needed
    $userId = Auth::id();

    // Always scope to the authenticated user's notebooks
    $query = Notebook::query()
      ->with(['user'])
      ->withCount('vocabularies')
      ->where('user_id', $userId);

    // Filter by name (exact param) or generic query 'q'
    if ($request->filled('name')) {
      $name = $request->string('name');
      $query->where('name', 'like', "%{$name}%");
    }
    if ($request->filled('q')) {
      $q = $request->string('q');
      $query->where('name', 'like', "%{$q}%");
    }

    // Filter by favorite flag
    if ($request->has('is_favorite')) {
      $query->where('is_favorite', $request->boolean('is_favorite'));
    }

    $notebooks = $query->orderByDesc('id')->paginate($request->integer('per_page', 10));

    return $this->apiResponse(true, 'Lấy danh sách sổ tay thành công', [
      'items' => NotebookCollection::collection($notebooks->items()),
      'pagination' => [
        'total' => $notebooks->total(),
        'per_page' => $notebooks->perPage(),
        'current_page' => $notebooks->currentPage(),
        'last_page' => $notebooks->lastPage(),
      ],
    ]);
  }

  // Create notebook
  public function store(StoreNotebookRequest $request)
  {
    $data = $request->validated();

    // Always use authenticated user to avoid cross-user creation
    $data['user_id'] = Auth::id();

    try {
      $notebook = Notebook::create($data);
      $notebook->load(['user']);
      $notebook->loadCount('vocabularies');

      return $this->apiResponse(true, 'Tạo sổ tay thành công', new NotebookResource($notebook));
    } catch (\Illuminate\Database\QueryException $e) {
      // Handle duplicate key or other DB errors with a friendly response
      if ((int) $e->getCode() === 23000) {
        return $this->apiResponse(false, 'Notebook name already exists for this user.', []);
      }
      return $this->apiResponse(false, 'Database error: ' . $e->getMessage(), []);
    }
  }

  // Show notebook
  public function show(Notebook $notebook)
  {
    if ($notebook->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }
    $notebook->load(['user']);
    $notebook->loadCount('vocabularies');
    return $this->apiResponse(true, 'Lấy thông tin sổ tay thành công', new NotebookResource($notebook));
  }

  // Update notebook
  public function update(UpdateNotebookRequest $request, Notebook $notebook)
  {
    if ($notebook->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }
    $data = $request->validated();
    $notebook->update($data);
    $notebook->load(['user']);
    $notebook->loadCount('vocabularies');

    return $this->apiResponse(true, 'Chỉnh sửa sổ tay thành công', new NotebookResource($notebook));
  }

  // Delete notebook
  public function destroy(Notebook $notebook)
  {
    if ($notebook->user_id !== Auth::id()) {
      return $this->apiResponse(false, 'Forbidden', []);
    }
    $notebook->delete();
    return $this->apiResponse(true, 'Xóa sổ tay thành công');
  }
}
