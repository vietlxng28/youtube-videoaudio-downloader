#!/usr/bin/env bash

# Chuyển vào thư mục chứa script
cd "$(dirname "$0")"

# 0. Kiểm tra cấu hình danh tính Git, nếu chưa có thì thiết lập mặc định (chỉ áp dụng cục bộ cho kho này)
if [ -z "$(git config user.name)" ]; then
    echo "==> Chưa có user.name, thiết lập mặc định: ẨnDanh"
    git config user.name "ẨnDanh"
fi

if [ -z "$(git config user.email)" ]; then
    echo "==> Chưa có user.email, thiết lập mặc định: an-danh@example.com"
    git config user.email "an-danh@example.com"
fi

# 1. Nếu có thay đổi ở local, tạo commit trước
if [ -n "$(git status --porcelain)" ]; then
    echo "==> Phát hiện thay đổi cục bộ, đang tạo commit..."
    git add -A
    git commit -m "chore: sync by script"
fi

# 2. Kéo dữ liệu từ remote về và kiểm tra xung đột
echo "==> Đang kéo dữ liệu từ remote..."
if ! git pull --rebase origin main; then
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
    echo " 3. Chạy 'git rebase --continue' và 'git push origin main'."
    echo "    (Hoặc 'git rebase --abort' nếu muốn hủy bỏ lần kéo này)"
    echo "============================================================"
    exit 1
fi

# 3. Đẩy thay đổi lên remote
echo "==> Đang đẩy dữ liệu lên remote..."
if ! git push origin main; then
    echo "[LỖI] Đẩy dữ liệu thất bại. Vui lòng kiểm tra lại kết nối mạng hoặc quyền truy cập."
    exit 1
fi

echo "==> Đồng bộ hoàn tất thành công!"
echo ""
echo "==> Lịch sử 10 commit gần nhất:"
git --no-pager log -n 10 --oneline
