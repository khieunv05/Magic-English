# Magic English – Database Schema (Summary)

Tài liệu này tóm tắt **toàn bộ các bảng mới thêm** cho dự án **Magic English**, phục vụ đủ **FR1 – FR2 – FR3**.

---

## 1. `notebooks` – Sổ tay của người dùng

**Mục đích:** Lưu các sổ tay học tập của mỗi user.

**Thuộc tính**

- `id`
- `user_id`
- `name`
- `description`
- `is_favorite`
- `created_at`
- `updated_at`

**Quan hệ**

- `users (1) → (n) notebooks`

---

## 2. `vocabularies` – Từ vựng trong sổ tay

**Mục đích:** Lưu từ vựng mà người dùng học trong từng sổ tay.

**Thuộc tính**

- `id`
- `notebook_id`
- `user_id`
- `word`
- `ipa`
- `meaning`
- `part_of_speech`
- `example`
- `cefr_level`
- `review_count`
- `last_reviewed_at`
- `created_at`
- `updated_at`

**Quan hệ**

- `notebooks (1) → (n) vocabularies`
- `users (1) → (n) vocabularies`

---

## 3. `vocabulary_reviews` – Lịch sử ôn tập từ vựng

**Mục đích:** Ghi nhận mỗi lần ôn tập để theo dõi tiến độ và tính streak.

**Thuộc tính**

- `id`
- `vocabulary_id`
- `user_id`
- `result` (remembered / forgot)
- `reviewed_at`
- `created_at`
- `updated_at`

**Quan hệ**

- `vocabularies (1) → (n) vocabulary_reviews`
- `users (1) → (n) vocabulary_reviews`

---

## 4. `grammar_checks` – Chấm ngữ pháp & văn phong

**Mục đích:** Lưu lịch sử các lần chấm câu/đoạn văn tiếng Anh.

**Thuộc tính**

- `id`
- `user_id`
- `original_text`
- `score`
- `errors` (JSON)
- `suggestions` (JSON)
- `created_at`
- `updated_at`

**Quan hệ**

- `users (1) → (n) grammar_checks`

---

## 5. `learning_activities` – Nhật ký hoạt động học tập

**Mục đích:** Theo dõi mọi hoạt động học để thống kê và tính streak.

**Thuộc tính**

- `id`
- `user_id`
- `notebook_id` (nullable)
- `type` (add_vocab / review_vocab / grammar_check)
- `related_id`
- `activity_date`
- `created_at`
- `updated_at`

**Quan hệ**

- `users (1) → (n) learning_activities`
- `notebooks (1) → (n) learning_activities` (có thể null)

---

## 6. `user_streaks` – Chuỗi ngày học

**Mục đích:** Lưu trạng thái chuỗi ngày học liên tục của người dùng.

**Thuộc tính**

- `id`
- `user_id`
- `current_streak`
- `longest_streak`
- `last_activity_date`
- `created_at`
- `updated_at`

**Quan hệ**

- `users (1) ↔ (1) user_streaks`

---

## Sơ đồ quan hệ tổng quát

```
users
 ├── notebooks
 │    └── vocabularies
 │         └── vocabulary_reviews
 ├── grammar_checks
 ├── learning_activities
 └── user_streaks
```

---
