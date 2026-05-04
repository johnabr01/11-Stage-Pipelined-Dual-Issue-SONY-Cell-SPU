// function int count_lines(string fname);
//     int fd;
//     string line;
//     int cnt;
//     int status;
//     begin
//       fd = $fopen(fname, "r");
//       if (fd == 0) begin
//         $display("Failed to open file %s", fname);
//         return -1;
//       end

//       cnt = 0;
//       while (!$feof(fd)) begin
//         status = $fgets(line, fd);
//         if (status != 0) begin
//           cnt++;
//         end
//       end

//       $fclose(fd);
//       return cnt;
//     end
//   endfunction

module top_level_tb();

   logic clk;
   logic reset_n;
   logic stop;

   // DUT
   top_level dut (.clk(clk), .rst_n(reset_n), .stop(stop));

   // Clock generation (10ns period)
   initial clk = 0;
   always #5 clk = ~clk;

   initial begin 
      int stop_count = 0;
      int cycles = 0;
      int max_cycles = 100000;  // safety timeout

      // Reset sequence
      reset_n = 0;
      @(posedge clk);
      #1 reset_n = 1;

      // Run until stop is high for 10 consecutive cycles
      while (1) begin
         @(posedge clk);
         #1;

         cycles++;

         if (stop) begin
            stop_count++;
         end else begin
            stop_count = 0;
         end

         if (stop_count == 25) begin
            $display("Stop signal held high for 25 cycles. Ending simulation.");
            break;
         end

         if (cycles > max_cycles) begin
            $fatal("Timeout: stop never stayed high for 25 cycles.");
         end
      end

      #1;
      $finish;
   end

endmodule    