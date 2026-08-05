@echo off
setlocal
title YTDLP WRAPPER - Made by Lxng

set "DOWNLOAD_DIR=%~dp0downloads"
if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"
set "COOKIES_FILE=%~dp0cookies.txt"

set "YT_DLP=yt-dlp"
where yt-dlp >nul 2>nul
if %errorlevel% neq 0 (
    if exist "%~dp0yt-dlp.exe" (
        set "YT_DLP=%~dp0yt-dlp.exe"
    ) else (
        echo [LOI] Khong tim thay yt-dlp.exe. Vui long tai va de chung thu muc!
        pause
        exit /b
    )
)

set "HAS_FFMPEG=1"
set "FFMPEG_STATUS=Da cai dat (Toi uu)"
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    set "HAS_FFMPEG=0"
    set "FFMPEG_STATUS=Thieu FFmpeg (Khong the chuyen doi am thanh/cat video)"
)

set "COOKIE_STATUS=Khong tim thay (Tai thuong)"
set BASE_CMD="%YT_DLP%" -P "%DOWNLOAD_DIR%" --js-runtimes node --concurrent-fragments 5
if exist "%COOKIES_FILE%" (
    set "COOKIE_STATUS=Da tich hop (Vuot gioi han)"
    set BASE_CMD=%BASE_CMD% --cookies "%COOKIES_FILE%"
)

:MainMenu
cls
echo.
echo   __     __  _______          _____    _      _____  
echo   \ \   / / \__   __/        ^|  __ \  ^| ^|    ^|  __ \ 
echo    \ \_/ /     ^| ^|     ___   ^| ^|  ^| ^| ^| ^|    ^| ^|__) ^|
echo     \   /      ^| ^|    ^|___^|  ^| ^|  ^| ^| ^| ^|    ^|  ___/ 
echo      ^| ^|       ^| ^|           ^| ^|__^| ^| ^| ^|____^| ^|     
echo      ^|_^|       ^|_^|           ^|_____/  ^|______^|_^|     
echo             +------------------------------+
echo             ^|         MADE BY LXNG         ^|
echo             +------------------------------+
echo.
echo [Trang thai he thong]
echo - Thu muc luu : %DOWNLOAD_DIR%
echo - Cookies     : %COOKIE_STATUS%
echo - FFmpeg      : %FFMPEG_STATUS%
echo ---------------------------------------------------
echo [Chuc nang chinh]
echo 1. Tai Video (Chon do phan giai)
echo 2. Tai Audio (MP3/FLAC - Chi tai am thanh, sieu nhanh)
echo 3. Tai Playlist/Kenh (Video MP4)
echo.
echo [Chuc nang chuyen sau]
echo 4. Tai CHI AM THANH cua Playlist (MP3 320kbps)
echo 5. Tai Video kem Phu de (Viet/Anh)
echo 6. Tai Video va xoa quang cao (SponsorBlock)
echo 7. Tai Video theo khoang thoi gian (Can FFmpeg)
echo.
echo [He thong]
echo 8. Mo thu muc luu file
echo 9. Cap nhat yt-dlp len ban moi nhat
echo c. Mo file cookies.txt de sua nhanh
echo 0. Thoat
echo ===================================================
set /p "CHOICE=Nhap lua chon cua ban (0-9/c): "

if "%CHOICE%"=="1" goto DownloadVideo
if "%CHOICE%"=="2" goto DownloadAudio
if "%CHOICE%"=="3" goto DownloadPlaylist
if "%CHOICE%"=="4" goto DownloadPlaylistAudio
if "%CHOICE%"=="5" goto DownloadSubtitle
if "%CHOICE%"=="6" goto DownloadSponsorBlock
if "%CHOICE%"=="7" goto DownloadTimeRange
if "%CHOICE%"=="8" goto OpenFolder
if "%CHOICE%"=="9" goto UpdateTool
if /i "%CHOICE%"=="c" goto OpenCookies
if "%CHOICE%"=="0" exit /b
goto MainMenu

:DownloadVideo
echo.
set /p "URL=Dan link video vao day: "
if "%URL%"=="" goto MainMenu
echo.
echo 1. Tu dong (Tot nhat) ^| 2. 1080p ^| 3. 720p ^| 4. 480p
set /p "RES=Chon chat luong (1-4) [Mac dinh: 1]: "
set FORMAT=-f "bv*+ba/b"
if "%RES%"=="2" set FORMAT=-f "bv*[height<=1080]+ba/b[height<=1080]/b"
if "%RES%"=="3" set FORMAT=-f "bv*[height<=720]+ba/b[height<=720]/b"
if "%RES%"=="4" set FORMAT=-f "bv*[height<=480]+ba/b[height<=480]/b"
echo.
echo Dang tai xuong...
%BASE_CMD% %FORMAT% --merge-output-format mp4 -o "%%(title)s_%%(resolution)s.%%(ext)s" "%URL%"
echo.
pause
goto MainMenu

:DownloadAudio
echo.
if "%HAS_FFMPEG%"=="0" (
    echo [!] Chuc nang nay bat buoc phai co FFmpeg de chuyen doi am thanh.
    pause
    goto MainMenu
)
set /p "URL=Dan link video/audio vao day: "
if "%URL%"=="" goto MainMenu
echo.
echo 1. MP3 (320kbps) ^| 2. FLAC (Lossless)
set /p "AUD=Chon dinh dang (1-2) [Mac dinh: 1]: "
set "A_FMT=mp3"
set "A_Q=320K"
if "%AUD%"=="2" (
    set "A_FMT=flac"
    set "A_Q=0"
)
echo.
echo Dang moc noi va tai luong am thanh...
%BASE_CMD% -f "ba/b[height<=360]/w" -x --audio-format %A_FMT% --audio-quality %A_Q% --embed-thumbnail --add-metadata -o "%%(title)s.%%(ext)s" "%URL%"
echo.
pause
goto MainMenu

:DownloadPlaylist
echo.
set /p "URL=Dan link playlist/kenh vao day: "
if "%URL%"=="" goto MainMenu
echo.
echo 1. Tu dong (Tot nhat) ^| 2. 1080p ^| 3. 720p ^| 4. 480p
set /p "RES=Chon chat luong (1-4) [Mac dinh: 1]: "
set FORMAT=-f "bv*+ba/b"
if "%RES%"=="2" set FORMAT=-f "bv*[height<=1080]+ba/b[height<=1080]/b"
if "%RES%"=="3" set FORMAT=-f "bv*[height<=720]+ba/b[height<=720]/b"
if "%RES%"=="4" set FORMAT=-f "bv*[height<=480]+ba/b[height<=480]/b"
echo.
echo Dang quet va tai playlist video...
%BASE_CMD% -i %FORMAT% --merge-output-format mp4 --yes-playlist -o "%%(playlist_title)s/%%(playlist_index)02d - %%(title)s.%%(ext)s" "%URL%"
echo.
pause
goto MainMenu

:DownloadPlaylistAudio
echo.
if "%HAS_FFMPEG%"=="0" (
    echo [!] Chuc nang nay bat buoc phai co FFmpeg de chuyen doi am thanh.
    pause
    goto MainMenu
)
set /p "URL=Dan link playlist vao day: "
if "%URL%"=="" goto MainMenu
echo.
echo Dang tai chi luong am thanh tu playlist (MP3 320kbps)...
%BASE_CMD% -f "ba/b[height<=360]/w" -i -x --audio-format mp3 --audio-quality 320K --yes-playlist --embed-thumbnail --add-metadata -o "%%(playlist_title)s/%%(playlist_index)02d - %%(title)s.%%(ext)s" "%URL%"
echo.
echo [Thanh cong] Toan bo nhac da luu vao thu muc ten Playlist.
pause
goto MainMenu

:DownloadTimeRange
echo.
if "%HAS_FFMPEG%"=="0" (
    echo [!] Thieu FFmpeg, khong the cat video tren server.
    pause
    goto MainMenu
)
set /p "URL=Dan link video vao day: "
if "%URL%"=="" goto MainMenu
set /p "START_TIME=Thoi gian bat dau (VD: 00:01:30 hoac 90): "
set /p "END_TIME=Thoi gian ket thuc (VD: 00:02:45 hoac 165): "
echo.
echo Dang tien hanh cat video...
%BASE_CMD% --download-sections "*%START_TIME%-%END_TIME%" --force-keyframes-at-cuts -f "bv*+ba/b" --merge-output-format mp4 -o "%%(title)s_CUT.%%(ext)s" "%URL%"
echo.
pause
goto MainMenu

:DownloadSubtitle
echo.
set /p "URL=Dan link video vao day: "
if "%URL%"=="" goto MainMenu
echo.
echo 1. Tu dong (Tot nhat) ^| 2. 1080p ^| 3. 720p ^| 4. 480p
set /p "RES=Chon chat luong (1-4) [Mac dinh: 1]: "
set FORMAT=-f "bv*+ba/b"
if "%RES%"=="2" set FORMAT=-f "bv*[height<=1080]+ba/b[height<=1080]/b"
if "%RES%"=="3" set FORMAT=-f "bv*[height<=720]+ba/b[height<=720]/b"
if "%RES%"=="4" set FORMAT=-f "bv*[height<=480]+ba/b[height<=480]/b"
echo.
echo Dang tai va ghep phu de...
%BASE_CMD% %FORMAT% --merge-output-format mkv --write-subs --write-auto-subs --sub-langs "vi,en" --embed-subs -o "%%(title)s_SUB.%%(ext)s" "%URL%"
echo.
pause
goto MainMenu

:DownloadSponsorBlock
echo.
if "%HAS_FFMPEG%"=="0" (
    echo [!] Chuc nang nay bat buoc phai co FFmpeg de xoa quang cao.
    pause
    goto MainMenu
)
set /p "URL=Dan link video vao day: "
if "%URL%"=="" goto MainMenu
echo.
echo 1. Tu dong (Tot nhat) ^| 2. 1080p ^| 3. 720p ^| 4. 480p
set /p "RES=Chon chat luong (1-4) [Mac dinh: 1]: "
set FORMAT=-f "bv*+ba/b"
if "%RES%"=="2" set FORMAT=-f "bv*[height<=1080]+ba/b[height<=1080]/b"
if "%RES%"=="3" set FORMAT=-f "bv*[height<=720]+ba/b[height<=720]/b"
if "%RES%"=="4" set FORMAT=-f "bv*[height<=480]+ba/b[height<=480]/b"
echo.
echo Dang tai va cat bo quang cao/tai tro...
%BASE_CMD% %FORMAT% --merge-output-format mp4 --sponsorblock-remove all -o "%%(title)s_NoAds.%%(ext)s" "%URL%"
echo.
pause
goto MainMenu

:OpenFolder
echo.
echo Dang mo thu muc luu tru...
explorer "%DOWNLOAD_DIR%"
goto MainMenu

:UpdateTool
echo.
echo Dang kiem tra ban cap nhat tu Github...
"%YT_DLP%" -U
echo.
pause
goto MainMenu

:OpenCookies
echo.
if not exist "%COOKIES_FILE%" (
    echo # Netscape HTTP Cookie File> "%COOKIES_FILE%"
    echo # This file was created automatically by yt-dlp wrapper.>> "%COOKIES_FILE%"
)
echo Dang mo file cookies.txt...
start "" "%COOKIES_FILE%"
goto MainMenu