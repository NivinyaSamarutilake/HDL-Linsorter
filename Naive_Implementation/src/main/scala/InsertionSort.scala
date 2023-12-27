import chisel3._
import chisel3.util._

class InsertionSort(val width: Int, val numElements: Int) extends Module {
  val io = IO(new Bundle {
    val in = Input(Vec(numElements, UInt(width.W)))
    val out = Output(Vec(numElements, UInt(width.W)))
  })

  val array = RegInit(VecInit(Seq.fill(numElements)(0.U(width.W))))
  val i = RegInit(5.U(log2Ceil(numElements+2).W)) // Start from the second element
  val j = RegInit(0.U(log2Ceil(numElements+1).W))
  val load = RegInit(true.B)
  val sorted = RegInit(false.B)

  // Load input into register array
  when(load && !sorted) {
    array := io.in
    load := false.B
    i := 1.U
    j := 1.U
  }

  // Insertion sort logic
  when(!load) {
    when(i <= numElements.U) {
      when(array(j) < array(j-1.U) && j >= 1.U) {
        val temp = array(j-1.U)
        array(j-1.U) := array(j)
        array(j) := temp
        j := j - 1.U
      } .otherwise {
        i := i + 1.U
        j := i
      }
    } .otherwise {
      load := true.B
      sorted := true.B
    }
  }

  // Assign sorted array to output
  io.out := array
}


object InsertionSortGenerator extends App {
  val width = 16 // Bit width of elements
  val numElements = 5 // Number of elements to sort
  println(s"Generating the InsertionSort hardware for $numElements elements")
  (new chisel3.stage.ChiselStage).emitVerilog(new InsertionSort(width, numElements))
}

