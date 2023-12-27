import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class InsertionSortTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "InsertionSort"

  it should "correctly sort the input array" in {
    val width = 32
    val numElements = 100

    test(new InsertionSort(width, numElements)) { dut =>
      dut.clock.setTimeout(0)
      // Example input array
      val inputs = Seq(95.U, 93.U, 43.U, 88.U, 56.U, 12.U, 18.U, 66.U, 98.U, 84.U, 19.U, 89.U, 71.U, 100.U, 42.U, 37.U, 69.U, 79.U, 5.U, 72.U, 97.U, 4.U, 54.U, 53.U, 47.U, 48.U, 67.U, 31.U, 33.U, 78.U, 14.U, 91.U, 85.U, 11.U, 45.U, 76.U, 26.U, 49.U, 3.U, 64.U, 28.U, 9.U, 39.U, 16.U, 81.U, 1.U, 44.U, 7.U, 46.U, 90.U, 96.U, 40.U, 20.U, 70.U, 65.U, 8.U, 21.U, 82.U, 10.U, 75.U, 25.U, 83.U, 87.U, 94.U, 15.U, 24.U, 55.U, 29.U, 99.U, 86.U, 63.U, 50.U, 58.U, 35.U, 27.U, 13.U, 60.U, 51.U, 6.U, 17.U, 34.U, 77.U, 73.U, 32.U, 68.U, 80.U, 22.U, 92.U, 36.U, 30.U, 62.U, 74.U, 2.U, 61.U, 23.U, 41.U, 57.U, 59.U, 38.U, 52.U)

      // Expected output (sorted array)
      val expectedOutputs = Seq(1.U, 2.U, 3.U, 4.U, 5.U, 6.U, 7.U, 8.U, 9.U, 10.U, 11.U, 12.U, 13.U, 14.U, 15.U) // Assuming ascending order

      // Poking each element of the input array
      for ((input, idx) <- inputs.zipWithIndex) {
        dut.io.in(idx).poke(input)
      }

      // Simulate enough clock cycles for sorting to complete
      val totalCycles = numElements*numElements
      dut.clock.step(totalCycles + 1) // Added 1 cycle for initialization

      // Print and check the output
      println("Actual Output:")
      for (idx <- 0 until numElements) {
        val outputValue = dut.io.out(idx).peek().litValue
        println(s"Output[$idx]: $outputValue")
      }

      // Check if the output matches the expected sorted array
      for ((expected, idx) <- expectedOutputs.zipWithIndex) {
        dut.io.out(idx).expect(expected)
      }
    }
  }
}

