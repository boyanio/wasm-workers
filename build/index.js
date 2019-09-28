(() => {
  function createMatrix(width, height) {
    const matrixEl = document.getElementById("matrix");
    const matrixSize = width * height;
    const cellSize = 50;
    const matrixElBorder = 1;

    for (let cellId = 0; cellId < matrixSize; cellId++) {
      const cellEl = document.createElement("div");
      cellEl.id = `cell_${cellId}`;
      cellEl.innerText = `${cellId + 1}`;
      cellEl.className = "cell";
      cellEl.style.width = `${cellSize}px`;
      cellEl.style.height = `${cellSize}px`;
      cellEl.style.lineHeight = `${cellSize}px`;
      matrixEl.appendChild(cellEl);
    }

    const matrixElWidth = width * cellSize + matrixElBorder;
    matrixEl.style.width = `${matrixElWidth}px`;

    const matrixContainerEl = document.getElementById("matrix-container");
    const matrixContainerElWidth = matrixContainerEl.clientWidth;
    const matrixElLeft = (matrixContainerElWidth - matrixElWidth) / 2;
    matrixEl.style.left = `${matrixElLeft}px`;

    const matrixElHeight = height * cellSize + matrixElBorder;
    matrixContainerEl.style.height = `${matrixElHeight + 30}px`;
  }

  function colorCell(cellId, color) {
    const { red, green, blue } = color;
    const cellEl = document.getElementById(`cell_${cellId}`);
    cellEl.style.backgroundColor = `rgb(${red}, ${green}, ${blue})`;
  }

  function setStatus(what) {
    document.getElementById("status").innerHTML = what;
  }

  function createWasmWorkers(workersCount, matrixSize) {
    const wasmMemory = new WebAssembly.Memory({
      initial: 256,
      maximum: 256,
      shared: true
    });

    const createWorker = (workerId, startCellId, every) =>
      new Promise(resolve => {
        const worker = new Worker("wasm-worker.js");
        worker.onmessage = messageEvent => {
          worker.terminate();
          resolve(messageEvent.data);
        };
        worker.postMessage({
          workerId,
          matrixSize,
          startCellId,
          every,
          wasmMemory
        });
      });

    const colorCells = () => {
      const heap = new Uint8Array(wasmMemory.buffer);
      const startOffset = 1024;

      const dumpMemory = () => {
        for (let i = 0; i < 10000; i++) {
          if (heap[i] > 0) {
            console.log(i, heap[i]);
          }
        }
      };

      const getInt = function(offset) {
        return (
          heap[offset] |
          (heap[offset + 1] << 8) |
          (heap[offset + 2] << 16) |
          (heap[offset + 3] << 24)
        );
      };

      const getRgb = rgbInt => ({
        red: (rgbInt >> 16) & 0xff,
        green: (rgbInt >> 8) & 0xff,
        blue: rgbInt & 0xff
      });

      for (let cellId = 0; cellId < matrixSize; cellId++) {
        const cellStartOffset = startOffset + cellId * 4;
        const color = getRgb(getInt(cellStartOffset));
        colorCell(cellId, color);
      }
    };

    const startTime = performance.now();

    const workers = Array.from(Array(workersCount)).map((_, workerId) =>
      createWorker(workerId, workerId, workersCount)
    );

    Promise.all(workers).then(results => {
      colorCells();

      const endTime = performance.now();
      const timeDiff = Math.floor(endTime - startTime);

      const totalColoredCellsCount = results.reduce(
        (sum, r) => sum + r.coloredCellsCount,
        0
      );

      const resultsStatus = results
        .map(r => `Worker ${r.workerId} colored ${r.coloredCellsCount} cells`)
        .join("<br/>");
      setStatus(
        `Completed in ${timeDiff}ms<br/><br/>` +
          `${resultsStatus}<br/><br/>` +
          `Total ${totalColoredCellsCount} cells colored`
      );
    });
  }

  const urlParams = new URLSearchParams(window.location.search);
  const parseUrlParam = (urlParam, defaultValue) => {
    const value = parseInt(urlParams.get(urlParam), 10);
    return isNaN(value) || value <= 0 ? defaultValue : value;
  };

  const matrixWidth = parseUrlParam("width", 7);
  const matrixHeight = parseUrlParam("height", 7);
  const workersCount = parseUrlParam("workers", 2);

  createMatrix(matrixWidth, matrixHeight);
  createWasmWorkers(workersCount, matrixWidth * matrixHeight);

  document.getElementById("matrixWidth").value = matrixWidth;
  document.getElementById("matrixHeight").value = matrixHeight;
  document.getElementById("workersCount").value = workersCount;
  setStatus("Running...");
})();
