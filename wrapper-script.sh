#!/bin/bash

# Lay duong dan thu muc chua script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOWNLOAD_DIR="$SCRIPT_DIR/downloads"
mkdir -p "$DOWNLOAD_DIR"

COOKIES_FILE="$SCRIPT_DIR/cookies.txt"

# Tim yt-dlp
if command -v yt-dlp &> /dev/null; then
    YT_DLP="yt-dlp"
elif [ -f "$SCRIPT_DIR/yt-dlp" ]; then
    YT_DLP="$SCRIPT_DIR/yt-dlp"
    chmod +x "$YT_DLP"
else
    echo "[LOI] Khong tim thay yt-dlp. Vui long tai va de chung thu muc!"
    read -p "Nhan Enter de thoat..."
    exit 1
fi

# Tim ffmpeg
HAS_FFMPEG=1
FFMPEG_STATUS="Da cai dat (Toi uu)"
if ! command -v ffmpeg &> /dev/null; then
    HAS_FFMPEG=0
    FFMPEG_STATUS="Thieu FFmpeg (Khong the chuyen doi am thanh/cat video)"
fi

# Tim cookies
COOKIE_STATUS="Khong tim thay (Tai thuong)"
BASE_CMD=("$YT_DLP" -P "$DOWNLOAD_DIR" --js-runtimes node --concurrent-fragments 5)
if [ -f "$COOKIES_FILE" ]; then
    COOKIE_STATUS="Da tich hop (Vuot gioi han)"
    BASE_CMD+=("--cookies" "$COOKIES_FILE")
fi

while true; do
    clear
    echo ""
    echo "  __     __  _______          _____    _      _____  "
    echo "  \\ \\   / / \\__   __/        |  __ \\  | |    |  __ \\ "
    echo "   \\ \\_/ /     | |     ___   | |  | | | |    | |__) |"
    echo "    \\   /      | |    |___|  | |  | | | |    |  ___/ "
    echo "     | |       | |           | |__| | | |____| |     "
    echo "     |_|       |_|           |_____/  |______|_|     "
    echo "             +------------------------------+"
    echo "             |         MADE BY LXNG         |"
    echo "             +------------------------------+"
    echo ""
    echo "[Trang thai he thong]"
    echo "- Thu muc luu : $DOWNLOAD_DIR"
    echo "- Cookies     : $COOKIE_STATUS"
    echo "- FFmpeg      : $FFMPEG_STATUS"
    echo "---------------------------------------------------"
    echo "[Chuc nang chinh]"
    echo "1. Tai Video (Chon do phan giai)"
    echo "2. Tai Audio (MP3/FLAC - Chi tai am thanh, sieu nhanh)"
    echo "3. Tai Playlist/Kenh (Video MP4)"
    echo ""
    echo "[Chuc nang chuyen sau]"
    echo "4. Tai CHI AM THANH cua Playlist (MP3 320kbps)"
    echo "5. Tai Video kem Phu de (Viet/Anh)"
    echo "6. Tai Video va xoa quang cao (SponsorBlock)"
    echo "7. Tai Video theo khoang thoi gian (Can FFmpeg)"
    echo ""
    echo "[He thong]"
    echo "8. Mo thu muc luu file"
    echo "9. Di chuyen den thu muc luu file (downloads)"
    echo "10. Cap nhat yt-dlp len ban moi nhat"
    echo "c. Mo file cookies.txt de sua nhanh"
    echo "0. Thoat"
    echo "==================================================="
    read -p "Nhap lua chon cua ban (0-9/c): " CHOICE

    case "$CHOICE" in
        1)
            echo ""
            read -p "Dan link video vao day: " URL
            if [ -n "$URL" ]; then
                echo ""
                echo "1. Tu dong (Tot nhat) | 2. 1080p | 3. 720p | 4. 480p"
                read -p "Chon chat luong (1-4) [Mac dinh: 1]: " RES
                FORMAT="-f bv*+ba/b"
                if [ "$RES" = "2" ]; then
                    FORMAT="-f bv*[height<=1080]+ba/b[height<=1080]/b"
                elif [ "$RES" = "3" ]; then
                    FORMAT="-f bv*[height<=720]+ba/b[height<=720]/b"
                elif [ "$RES" = "4" ]; then
                    FORMAT="-f bv*[height<=480]+ba/b[height<=480]/b"
                fi
                echo ""
                echo "Dang tai xuong..."
                "${BASE_CMD[@]}" $FORMAT --merge-output-format mp4 -o "%(title)s_%(resolution)s.%(ext)s" "$URL"
                echo ""
                read -p "Nhan Enter de tiep tuc..."
            fi
            ;;
        2)
            echo ""
            if [ "$HAS_FFMPEG" = "0" ]; then
                echo "[!] Chuc nang nay bat buoc phai co FFmpeg de chuyen doi am thanh."
                read -p "Nhan Enter de tiep tuc..."
                continue
            fi
            read -p "Dan link video/audio vao day: " URL
            if [ -n "$URL" ]; then
                echo ""
                echo "1. MP3 (320kbps) | 2. FLAC (Lossless)"
                read -p "Chon dinh dang (1-2) [Mac dinh: 1]: " AUD
                A_FMT="mp3"
                A_Q="320K"
                if [ "$AUD" = "2" ]; then
                    A_FMT="flac"
                    A_Q="0"
                fi
                echo ""
                echo "Dang moc noi va tai luong am thanh..."
                "${BASE_CMD[@]}" -f "ba/b[height<=360]/w" -x --audio-format "$A_FMT" --audio-quality "$A_Q" --embed-thumbnail --add-metadata -o "%(title)s.%(ext)s" "$URL"
                echo ""
                read -p "Nhan Enter de tiep tuc..."
            fi
            ;;
        3)
            echo ""
            read -p "Dan link playlist/kenh vao day: " URL
            if [ -n "$URL" ]; then
                echo ""
                echo "1. Tu dong (Tot nhat) | 2. 1080p | 3. 720p | 4. 480p"
                read -p "Chon chat luong (1-4) [Mac dinh: 1]: " RES
                FORMAT="-f bv*+ba/b"
                if [ "$RES" = "2" ]; then
                    FORMAT="-f bv*[height<=1080]+ba/b[height<=1080]/b"
                elif [ "$RES" = "3" ]; then
                    FORMAT="-f bv*[height<=720]+ba/b[height<=720]/b"
                elif [ "$RES" = "4" ]; then
                    FORMAT="-f bv*[height<=480]+ba/b[height<=480]/b"
                fi
                echo ""
                echo "Dang quet va tai playlist video..."
                "${BASE_CMD[@]}" -i $FORMAT --merge-output-format mp4 --yes-playlist -o "%(playlist_title)s/%(playlist_index)02d - %(title)s.%(ext)s" "$URL"
                echo ""
                read -p "Nhan Enter de tiep tuc..."
            fi
            ;;
        4)
            echo ""
            if [ "$HAS_FFMPEG" = "0" ]; then
                echo "[!] Chuc nang nay bat buoc phai co FFmpeg de chuyen doi am thanh."
                read -p "Nhan Enter de tiep tuc..."
                continue
            fi
            read -p "Dan link playlist vao day: " URL
            if [ -n "$URL" ]; then
                echo ""
                echo "Dang tai chi luong am thanh tu playlist (MP3 320kbps)..."
                "${BASE_CMD[@]}" -f "ba/b[height<=360]/w" -i -x --audio-format mp3 --audio-quality 320K --yes-playlist --embed-thumbnail --add-metadata -o "%(playlist_title)s/%(playlist_index)02d - %(title)s.%(ext)s" "$URL"
                echo ""
                echo "[Thanh cong] Toan bo nhac da luu vao thu muc ten Playlist."
                read -p "Nhan Enter de tiep tuc..."
            fi
            ;;
        5)
            echo ""
            read -p "Dan link video vao day: " URL
            if [ -n "$URL" ]; then
                echo ""
                echo "1. Tu dong (Tot nhat) | 2. 1080p | 3. 720p | 4. 480p"
                read -p "Chon chat luong (1-4) [Mac dinh: 1]: " RES
                FORMAT="-f bv*+ba/b"
                if [ "$RES" = "2" ]; then
                    FORMAT="-f bv*[height<=1080]+ba/b[height<=1080]/b"
                elif [ "$RES" = "3" ]; then
                    FORMAT="-f bv*[height<=720]+ba/b[height<=720]/b"
                elif [ "$RES" = "4" ]; then
                    FORMAT="-f bv*[height<=480]+ba/b[height<=480]/b"
                fi
                echo ""
                echo "Dang tai va ghep phu de..."
                "${BASE_CMD[@]}" $FORMAT --merge-output-format mkv --write-subs --write-auto-subs --sub-langs "vi,en" --embed-subs -o "%(title)s_SUB.%(ext)s" "$URL"
                echo ""
                read -p "Nhan Enter de tiep tuc..."
            fi
            ;;
        6)
            echo ""
            if [ "$HAS_FFMPEG" = "0" ]; then
                echo "[!] Chuc nang nay bat buoc phai co FFmpeg de xoa quang cao."
                read -p "Nhan Enter de tiep tuc..."
                continue
            fi
            read -p "Dan link video vao day: " URL
            if [ -n "$URL" ]; then
                echo ""
                echo "1. Tu dong (Tot nhat) | 2. 1080p | 3. 720p | 4. 480p"
                read -p "Chon chat luong (1-4) [Mac dinh: 1]: " RES
                FORMAT="-f bv*+ba/b"
                if [ "$RES" = "2" ]; then
                    FORMAT="-f bv*[height<=1080]+ba/b[height<=1080]/b"
                elif [ "$RES" = "3" ]; then
                    FORMAT="-f bv*[height<=720]+ba/b[height<=720]/b"
                elif [ "$RES" = "4" ]; then
                    FORMAT="-f bv*[height<=480]+ba/b[height<=480]/b"
                fi
                echo ""
                echo "Dang tai va cat bo quang cao/tai tro..."
                "${BASE_CMD[@]}" $FORMAT --merge-output-format mp4 --sponsorblock-remove all -o "%(title)s_NoAds.%(ext)s" "$URL"
                echo ""
                read -p "Nhan Enter de tiep tuc..."
            fi
            ;;
        7)
            echo ""
            if [ "$HAS_FFMPEG" = "0" ]; then
                echo "[!] Thieu FFmpeg, khong the cat video tren server."
                read -p "Nhan Enter de tiep tuc..."
                continue
            fi
            read -p "Dan link video vao day: " URL
            if [ -n "$URL" ]; then
                read -p "Thoi gian bat dau (VD: 00:01:30 hoac 90): " START_TIME
                read -p "Thoi gian ket thuc (VD: 00:02:45 hoac 165): " END_TIME
                echo ""
                echo "Dang tien hanh cat video..."
                "${BASE_CMD[@]}" --download-sections "*$START_TIME-$END_TIME" --force-keyframes-at-cuts -f "bv*+ba/b" --merge-output-format mp4 -o "%(title)s_CUT.%(ext)s" "$URL"
                echo ""
                read -p "Nhan Enter de tiep tuc..."
            fi
            ;;
        8)
            echo ""
            echo "Dang mo thu muc luu tru..."
            if command -v xdg-open &> /dev/null; then
                xdg-open "$DOWNLOAD_DIR"
            elif command -v gio &> /dev/null; then
                gio open "$DOWNLOAD_DIR"
            else
                echo "Khong tim thay cong cu de mo thu muc tu dong. Vui long mo thu muc bang tay tai: $DOWNLOAD_DIR"
            fi
            read -p "Nhan Enter de tiep tuc..."
            ;;
        9)
            echo ""
            echo "Dang di chuyen thu muc lam viec..."
            cd "$DOWNLOAD_DIR"
            echo "[Thanh cong] Thu muc lam viec hien tai da thay doi."
            echo "---------------------------------------------------"
            echo "De thuan tien, he thong dang mo mot phien Terminal moi tai:"
            echo "$DOWNLOAD_DIR"
            echo "-> Go 'exit' khi ban muon quay lai Menu chinh."
            echo "---------------------------------------------------"
            bash
            ;;
        10)
            echo ""
            echo "Dang kiem tra ban cap nhat tu Github..."
            "$YT_DLP" -U
            echo ""
            read -p "Nhan Enter de tiep tuc..."
            ;;
        [cC])
            echo ""
            if [ ! -f "$COOKIES_FILE" ]; then
                echo "# Netscape HTTP Cookie File" > "$COOKIES_FILE"
                echo "# This file was created automatically by yt-dlp wrapper." >> "$COOKIES_FILE"
            fi
            echo "Dang mo file cookies.txt..."
            if command -v gnome-text-editor &> /dev/null; then
                gnome-text-editor "$COOKIES_FILE" &
            elif [ -n "$EDITOR" ]; then
                "$EDITOR" "$COOKIES_FILE"
            elif command -v nano &> /dev/null; then
                nano "$COOKIES_FILE"
            elif command -v vi &> /dev/null; then
                vi "$COOKIES_FILE"
            else
                echo "Khong tim thay trinh soan thao text (gnome-text-editor, nano, vi, \$EDITOR). Ban co the tu sua file tai: $COOKIES_FILE"
            fi
            read -p "Nhan Enter de tiep tuc..."
            ;;
        0)
            exit 0
            ;;
        *)
            ;;
    esac
done
