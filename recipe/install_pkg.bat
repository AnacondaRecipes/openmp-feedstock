@echo on
setlocal enabledelayedexpansion

cd build

cmake --install .
if %ERRORLEVEL% neq 0 exit 1

:: we want clang to use the omp.h from this package, but stand-alone openmp doesn't
:: put this on clang's default search path. On unix we can use a symlink, but those
:: are not generally usable on windows. As a work-around, copy omp.h to the respective
:: paths for several likely clang versions. Since we have basically no constraints on
:: the version of `llvm-openmp`, environments will tend to have the newest one. In turn,
:: this means that the compiler version is (almost) always ≤ the openmp version, hence
:: it suffices to loop until the major version here. We start from clang 18, because
:: https://github.com/conda-forge/clangdev-feedstock/pull/345 is not backported further.
for /L %%I in (18,1,%PKG_VERSION:~0,2%) do (
    if not exist "%LIBRARY_LIB%\clang\%%I\include\" mkdir "%LIBRARY_LIB%\clang\%%I\include"
    copy /Y "%LIBRARY_INC%\omp.h" "%LIBRARY_LIB%\clang\%%I\include\"
    if %ERRORLEVEL% neq 0 exit 1
)

REM LLVM 23 installs the Fortran modules and omp_lib.h into flang's own module
REM search path, lib\clang\MAJOR\finclude\flang\TRIPLE, instead of include.
set "OMP_TRIPLE=x86_64-pc-windows-msvc"
if "%target_platform%" == "win-arm64" set "OMP_TRIPLE=aarch64-pc-windows-msvc"
set "MOD_DIR=%LIBRARY_LIB%\clang\%PKG_VERSION:~0,2%\finclude\flang\%OMP_TRIPLE%"
if not exist "%MOD_DIR%\omp_lib.mod" exit 1

if "%PKG_NAME%" == "llvm-openmp-fortran" (
    REM also keep the 22.x location, which is on the -I path the flang activation sets
    copy /Y "%MOD_DIR%\omp_lib.mod" "%LIBRARY_INC%\"
    if errorlevel 1 exit 1
    copy /Y "%MOD_DIR%\omp_lib_kinds.mod" "%LIBRARY_INC%\"
    if errorlevel 1 exit 1
) else (
    REM regular llvm-openmp: no Fortran modules; keep omp_lib.h in include as in 22.x
    copy /Y "%MOD_DIR%\omp_lib.h" "%LIBRARY_INC%\"
    if errorlevel 1 exit 1
    rmdir /s /q "%LIBRARY_LIB%\clang\%PKG_VERSION:~0,2%\finclude"
)

:: PKG-18188 / anaconda-issues 13513: also ship libomp.dll under the alias name
:: pytorch's win-64 openblas torch_cpu.dll links (libomp140.x86_64.dll) - same
:: runtime, different filename. llvm-openmp only, not the fortran metapackage.
:: Presence is verified by the test in meta.yaml.
if "%PKG_NAME%" == "llvm-openmp" if "%target_platform%" == "win-64" copy /Y "%LIBRARY_BIN%\libomp.dll" "%LIBRARY_BIN%\libomp140.x86_64.dll"
if errorlevel 1 exit 1
