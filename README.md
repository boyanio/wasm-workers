# wasm-workers

Demo project showing how to use WebAssembly and Web Workers.

## Build

You need emscripten to compile the WebAssembly sources using `compile-cpp.bat` (or just see the exact command for non-Windows).

Next, you will need following fixes to build using shared memory and mutex:

1. Copy the contents of `mutex.wast` into the generated `worker.wast` file just above the line `(export "_colorCells" (func $_colorCells))`
2. Delete the two mutex imports `__ZNSt3__25mutex4lockEv` and `__ZNSt3__25mutex4lockEv` as we have provided implementation for them.
3. Change memory import to `(import "env" "memory" (memory $memory 256 256 shared))` (add `shared` at the end)

You need to compile the updated `worker.wast` file back to `.wasm`. You can do this using the `wat2wasm` tool from [WebAssembly Binary Toolkit](https://github.com/WebAssembly/wabt) (with `--enable-threads` option) or using this [web demo](https://webassembly.github.io/wabt/demo/wat2wasm/) (with the threads checkbox checked). For the former, check `compile-wast.bat`.

You can play around with `USE_MUTEX` in `worker.cpp` to see how locking affects multiple workers.

## Run

Run in a Web server and use QueryString to change settings:

`/?matrixWidth=5&matrixHeight=5&workersCount=3`

![](/images/wasm-workers.jpg)

### Compatibility

For now, only Chrome supports `SharedArrayBuffer` (and hence shared WebAssembly memory).
