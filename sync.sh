#!/usr/bin/env bash

# 1. Chuyển vào thư mục gốc của kho Git và kiểm tra tính hợp lệ
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "[LỖI] Thư mục hiện tại không phải là một kho Git."
    exit 1
fi
cd "$REPO_ROOT"

# Kiểm tra remote 'origin'
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "[LỖI] Chưa cấu hình remote 'origin' cho kho Git này."
    exit 1
fi

# 2. Kiểm tra nếu đang có tiến trình rebase hoặc merge dở dang
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ -d "$GIT_DIR/rebase-merge" ] || [ -d "$GIT_DIR/rebase-apply" ]; then
    echo "[LỖI] Đang có một tiến trình rebase dở dang. Vui lòng xử lý xong (git rebase --continue) hoặc hủy bỏ (git rebase --abort) trước."
    exit 1
fi
if [ -f "$GIT_DIR/MERGE_HEAD" ]; then
    echo "[LỖI] Đang có một tiến trình merge dở dang. Vui lòng hoàn tất hoặc hủy bỏ (git merge --abort) trước."
    exit 1
fi

# 3. Cấu hình danh tính Git cục bộ nếu chưa có
if [ -z "$(git config user.name)" ]; then
    echo "==> Chưa có user.name, thiết lập mặc định: ẨnDanh"
    git config user.name "ẨnDanh"
fi

if [ -z "$(git config user.email)" ]; then
    echo "==> Chưa có user.email, thiết lập mặc định: an-danh@example.com"
    git config user.email "an-danh@example.com"
fi

# 4. Tạo commit trước nếu có thay đổi ở local
COMMIT_MSG="${1:-chore: sync by script}"
if [ -n "$(git status --porcelain)" ]; then
    echo "==> Phát hiện thay đổi cục bộ, đang tạo commit: '$COMMIT_MSG'..."
    git add -A
    git commit -m "$COMMIT_MSG"
fi

# 5. Xác định nhánh hiện tại đang đứng
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
    echo "[LỖI] Không thể xác định nhánh hiện tại (có thể đang ở trạng thái detached HEAD)."
    exit 1
fi

# 6. Kiểm tra kết nối mạng và cập nhật thông tin từ remote
echo "==> Đang kiểm tra kết nối tới remote 'origin'..."
if ! git fetch origin --prune; then
    echo "[LỖI] Không thể kết nối tới remote 'origin'. Vui lòng kiểm tra lại mạng hoặc quyền SSH/Token."
    exit 1
fi

# 7. Kéo dữ liệu từ remote về nếu nhánh đã tồn tại trên remote
if git show-ref --verify --quiet "refs/remotes/origin/$CURRENT_BRANCH"; then
    echo "==> Đang kéo dữ liệu từ remote (nhánh $CURRENT_BRANCH)..."
    if ! git pull --rebase origin "$CURRENT_BRANCH"; then
        echo ""
        echo "============================================================"
        echo " [LỖI] PHÁT HIỆN XUNG ĐỘT (CONFLICT) KHI ĐỒNG BỘ!"
        echo " Vui lòng kiểm tra và xử lý xung đột thủ công:"
        echo "============================================================"
        git status --short
        echo ""
        echo " Hướng dẫn xử lý:"
        echo " 1. Mở các tệp xung đột (được đánh dấu UU) để sửa."
        echo " 2. Chạy 'git add <tệp>' sau khi sửa xong."
        echo " 3. Chạy 'git rebase --continue' và 'git push -u origin $CURRENT_BRANCH'."
        echo "    (Hoặc 'git rebase --abort' nếu muốn hủy bỏ lần kéo này)"
        echo "============================================================"
        exit 1
    fi
else
    echo "==> Nhánh '$CURRENT_BRANCH' chưa có trên remote. Bỏ qua bước kéo dữ liệu."
fi

# 8. Đẩy thay đổi lên remote và thiết lập theo dõi (upstream tracking)
echo "==> Đang đẩy dữ liệu lên remote (nhánh $CURRENT_BRANCH)..."
if ! git push -u origin "$CURRENT_BRANCH"; then
    echo "[LỖI] Đẩy dữ liệu thất bại. Vui lòng kiểm tra lại kết nối mạng hoặc quyền truy cập."
    exit 1
fi

echo "==> Đồng bộ hoàn tất thành công!"
echo ""
echo "==> Lịch sử 5 commit gần nhất:"
git --no-pager log -n 5 --oneline
