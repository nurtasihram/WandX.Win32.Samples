@echo off
setlocal enabledelayedexpansion
set script_dir=%~dp0
if "%script_dir:~-1%"=="\" set script_dir=%script_dir:~0,-1%
for %%i in ("%script_dir%\..") do set global_dir=%%~fi
set workspace=%script_dir%
set build_pushed=
pushd "%workspace%"
if /i "%1" == "clean" (
	echo -- Clean started
	set clear_path=
	set clear_path=!clear_path! "!global_dir!\gcm.cache"
	set clear_path=!clear_path! "!workspace!\x64"
	set clear_path=!clear_path! "!workspace!\Debug"
	set clear_path=!clear_path! "!workspace!\Release"
	set clear_path=!clear_path! "!workspace!\wx_test"
	set clear_path=!clear_path! "!workspace!\build"
	for %%p in (!clear_path!) do (
		if exist %%p rmdir %%p /s /q && echo clean and remove folder %%p
	)
	set clear_filter=*.o *.obj *.pcm *.exe *.manifest *.aps *.ilk *.pdb *.exp *.lib
	for %%p in (!clear_filter!) do (
		del /q "!workspace!\%%p" 2>nul && echo remove file !workspace!\%%p
	)
	echo -- Clean finished
) else if /i "%1" == "build" (
	set build_dir=!workspace!\build\%2
	if not exist "!build_dir!" mkdir "!build_dir!"
	pushd "!build_dir!"
	set build_pushed=1
	set module_files=
	set module_files=!module_files! "!global_dir!\WandX.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.String.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.Type.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.Console.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.Realtime.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.File.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.GDI.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.Resource.cppm"
	set module_files=!module_files! "!global_dir!\WandX.Win32.Security.cppm"
	rem set module_files=!module_files! "!global_dir!\WandX.Win32.Window.cppm" 
	rem set module_files=!module_files! "!global_dir!\WandX.Win32.Control.cppm"
	set source_files=!module_files! "!workspace!\wx_test.cpp"
	set source_files=!source_files! "!global_dir!\WandX.Win32.Main.cpp"
	set include_paths=-I"!global_dir!"
	if /i "%2" == "clang" (
		set compiler=clang++
		set compile_mod=-std=c++2a -fmodules -fprebuilt-module-path="./" --precompile
		set compile_mod=!compile_mod! !include_paths!
		set compile_src=-std=c++2a -fmodules -fprebuilt-module-path="./"
		set compile_src=!compile_src! -c !include_paths!
		set link_args=
	) else if /i "%2" == "mingw" (
		set compiler=g++
		set compile_mod=-c -std=c++2a -fmodules
		set compile_mod=!compile_mod! !include_paths!
		set compile_src=-c -std=c++2a -fmodules
		set compile_src=!compile_src! -c !include_paths!
		set link_args=-lgdi32 -lcomdlg32
	) else (
		echo Unknown compiler %2
		goto help
	)
	echo ----- Compilation test ----- 
	!compiler! --version || echo Compiler command "!compiler!" is invalid && goto end
	echo ----------------------------
	echo -- Use compiler %2
	echo  -- Compile modules
	for %%p in (!module_files!) do (
		echo  - module %%p
		echo !compiler! %%p !compile_mod!
		!compiler! %%p !compile_mod! || echo Module %%p compile failed && goto end
	)
	echo  -- Compile source files
	for %%p in (!source_files!) do (
		echo  - source %%p
		echo !compiler! %%p !compile_src!
		!compiler! %%p !compile_src! || echo Source %%p compile failed && goto end
	)
	if /i "%2" == "clang" (
		echo  -- Compile PCM files
		for %%p in (*.pcm) do (
			echo  - PCM %%p
			echo !compiler! %%p !compile_src!
			!compiler! %%p !compile_src! || echo PCM %%p compile failed && goto end
		)
	)
	echo  -- Link object files
	set object_files=
	for %%i in (*.o) do (
		set object_files=!object_files! %%i
	)
	echo !compiler! !object_files! -o wx_test.exe !link_args!
	!compiler! !object_files! -o wx_test.exe !link_args! || echo Link failed && goto end
	echo -- Compilation built
) else (
	if not "%1" == "" (
		if /i not "%1" == "help" (
			echo Unknown commands %*
		)
	)
:help
	echo    clean           - prebuild files like *.o *.obj *.pcm gcm.cache *.pdb *.idb
	echo    build clang     - build test target with clang++
	echo    build mingw     - build test target with MinGW
	echo    help            - show this list
)
:end
if defined build_pushed popd
popd
