@echo off

emcc -std=c++11 -g -O3 -s ONLY_MY_CODE=1 -s EXPORTED_FUNCTIONS="['_colorCells']" -s ERROR_ON_UNDEFINED_SYMBOLS=0 worker.cpp -o build/wasm/worker.wasm