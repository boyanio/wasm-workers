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
      _noop: () => {}
    }
  };
  const { instance } = await WebAssembly.instantiate(buffer, imports);
  return instance;
}

this.onmessage = async ({ data }) => {
  const { workerId, matrixSize, wasmMemory } = data;
  const wasmInstance = await loadWasm(wasmMemory);
  const coloredCellsCount = wasmInstance.exports._colorCells(
    workerId,
    matrixSize
  );
  this.postMessage({ workerId, coloredCellsCount });
};
