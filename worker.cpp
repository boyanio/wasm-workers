#include <mutex>

const int MAX_MATRIX_SIZE = 1000;
int matrixRgbInt[MAX_MATRIX_SIZE];
std::mutex matrixMutex;

extern "C" {

  int rgbToInt(int red, int green, int blue);

  void simulateSlowComputation();

  extern void noop(int x);

  extern int randomBetween(int minInclusive, int maxExclusive);

  int colorCells(int workerId, int matrixSize) {

    int coloredCellsCount = 0;

    // Generate random number [1, 256). We avoid 0,
    // because we will check the global matrix for 0
    // as if there is value or not
    int red, green, blue, rgbInt;
    red = randomBetween(1, 256);
    green = randomBetween(1, 256);
    blue = randomBetween(1, 256);
    rgbInt = rgbToInt(red, green, blue);

    // Create an array containing the indices of
    // possible cells that we have not manipulated.
    // We use a shared memory, so we have to use
    // workerId to generate a complex index
    int indexBase = workerId * matrixSize;

    int possibleCellIds[MAX_MATRIX_SIZE];
    for (int i = 0; i < matrixSize; i++) {
      possibleCellIds[indexBase + i] = i;
    }

    int possibleCellsCount = matrixSize;
    while (possibleCellsCount > 0) {

      if (randomBetween(0, 2) == 0) {
        simulateSlowComputation();
      }

      int cellIdIndex = randomBetween(0, possibleCellsCount);
      int cellId = possibleCellIds[indexBase + cellIdIndex];
      
      matrixMutex.lock();
      if (matrixRgbInt[cellId] == 0) {        
        matrixRgbInt[cellId] = rgbInt;
        matrixMutex.unlock();

        if (randomBetween(0, 2) == 0) {
          simulateSlowComputation();
        }

        coloredCellsCount++;
      }
      else {
        matrixMutex.unlock();
      }

      // Swap current index with the value of the last one
      // and set the last one to -1, so we don't use it
      // anymore
      if (cellIdIndex + 1 < possibleCellsCount) {
        possibleCellIds[indexBase + cellIdIndex] =
          possibleCellIds[indexBase + possibleCellsCount - 1];
      }
      possibleCellIds[indexBase + possibleCellsCount - 1] = -1;
      possibleCellsCount--;
    }

    return coloredCellsCount;
  }

  int rgbToInt(int red, int green, int blue) {
    int rgbInt = red;
    rgbInt = (rgbInt << 8) + green;
    rgbInt = (rgbInt << 8) + blue;
    return rgbInt;
  }

  int fibonacci(int num) {
    int a = 1;
    int b = 1;

    while (num-- > 1) {
      int t = a;
      a = b;
      b += t;
    }
    return b;
  }

  void simulateSlowComputation() {
    int num = randomBetween(20, 40);
    int f;

    for (int i = 0; i < 3000; i++) {
      for (int j = 0; j < 1000; j++) {
        f = fibonacci(num);
      }
    }

    return noop(f);
  }

}