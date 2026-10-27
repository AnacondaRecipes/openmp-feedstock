@echo on

REM LLVM 23 removed the standalone openmp build; build it through the
REM runtimes directory, which needs the full llvm-project tree
mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

REM the runtimes build only enables Fortran when a compiler is passed;
REM FC is flang.exe from the flang activation
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_TRY_COMPILE_CONFIGURATION=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_Fortran_COMPILER=%FC% ^
    -DLIBOMP_FORTRAN_MODULES=ON ^
    -DLLVM_ENABLE_RUNTIMES=openmp ^
    ../runtimes
if %ERRORLEVEL% neq 0 exit 1

cmake --build .
if %ERRORLEVEL% neq 0 exit 1
