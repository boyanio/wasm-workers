async function loadWasm(wasmMemory) {
  const wasm = await fetch("wasm/worker.wasm");
  const buffer = await wasm.arrayBuffer();
  const imports = {
    env: {
      memory: wasmMemory,
      _randomBetween: (minInclusive, maxExclusive) =>
        Math.floor(
          Math.random() * (maxExclusive - minInclusive) + minInclusive
        ),
      _debug: (...args) => console.log(args),
      _noop: () => {}
    }
  };
  const { instance } = await WebAssembly.instantiate(buffer, imports);
  return instance;
}

this.onmessage = async ({ data: { workerId, matrixSize, wasmMemory } }) => {
  const wasmInstance = await loadWasm(wasmMemory);
  const coloredCellsCount = wasmInstance.exports._colorCells(
    workerId,
    matrixSize
  );
  this.postMessage({ workerId, coloredCellsCount });
};
