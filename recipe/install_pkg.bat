@echo on
setlocal enabledelayedexpansion

echo === [DEBUG] install_pkg.bat starting for %PKG_NAME% ===
echo === [DEBUG] PKG_VERSION=%PKG_VERSION% ===
echo === [DEBUG] LIBRARY_INC=%LIBRARY_INC% ===
echo === [DEBUG] LIBRARY_LIB=%LIBRARY_LIB% ===
echo === [DEBUG] LIBRARY_BIN=%LIBRARY_BIN% ===

cd openmp/build

cmake --install .
if %ERRORLEVEL% neq 0 exit 1

echo === [DEBUG] cmake --install completed successfully ===
echo === [DEBUG] Checking installed files ===
if exist "%LIBRARY_INC%\omp.h" (echo [DEBUG] FOUND: %LIBRARY_INC%\omp.h) else (echo [DEBUG] MISSING: %LIBRARY_INC%\omp.h)
if exist "%LIBRARY_BIN%\libomp.dll" (echo [DEBUG] FOUND: %LIBRARY_BIN%\libomp.dll) else (echo [DEBUG] MISSING: %LIBRARY_BIN%\libomp.dll)
if exist "%LIBRARY_LIB%\libomp.lib" (echo [DEBUG] FOUND: %LIBRARY_LIB%\libomp.lib) else (echo [DEBUG] MISSING: %LIBRARY_LIB%\libomp.lib)

:: we want clang to use the omp.h from this package, but stand-alone openmp doesn't
:: put this on clang's default search path. On unix we can use a symlink, but those
:: are not generally usable on windows. As a work-around, copy omp.h to the respective
:: paths for several likely clang versions. Since we have basically no constraints on
:: the version of `llvm-openmp`, environments will tend to have the newest one. In turn,
:: this means that the compiler version is (almost) always ≤ the openmp version, hence
:: it suffices to loop until the major version here. We start from clang 18, because
:: https://github.com/conda-forge/clangdev-feedstock/pull/345 is not backported further.
echo === [DEBUG] PKG_VERSION:~0,2 = %PKG_VERSION:~0,2% ===
echo === [DEBUG] Copying omp.h to clang version dirs (18 to %PKG_VERSION:~0,2%) ===
for /L %%I in (18,1,%PKG_VERSION:~0,2%) do (
    if not exist "%LIBRARY_LIB%\clang\%%I\include\" mkdir "%LIBRARY_LIB%\clang\%%I\include"
    echo [DEBUG] Copying omp.h to %LIBRARY_LIB%\clang\%%I\include\
    copy /Y "%LIBRARY_INC%\omp.h" "%LIBRARY_LIB%\clang\%%I\include\"
    if %ERRORLEVEL% neq 0 exit 1
    if exist "%LIBRARY_LIB%\clang\%%I\include\omp.h" (echo [DEBUG] VERIFIED: clang\%%I\include\omp.h) else (echo [DEBUG] FAILED: clang\%%I\include\omp.h copy)
)

:: remove fortran bits from regular llvm-openmp package
if "%PKG_NAME%" NEQ "llvm-openmp-fortran" (
    echo === [DEBUG] Removing fortran modules from llvm-openmp package ===
    del /s /q %LIBRARY_INC%\omp_lib.mod
    del /s /q %LIBRARY_INC%\omp_lib_kinds.mod
)

echo === [DEBUG] install_pkg.bat completed for %PKG_NAME% ===
