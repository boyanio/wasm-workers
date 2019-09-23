@echo off

emcc worker.cpp -std=c++11 -g -O3 -o build/wasm/worker.wasm -s ONLY_MY_CODE=1 -s EXPORTED_FUNCTIONS="['_colorCells']" -s ERROR_ON_UNDEFINED_SYMBOLS=0