module barrel_shift_tb;
parameter N = 8;
//
logic [N-1:0]         data_in;
logic [N-1:0]         data_out;
logic [$clog2(N)-1:0] shift_num;
logic [2:0]           op;
logic [N-1:0]         data_out_ref;
//
logic                 error;
logic [N-1:0]         mask0;
logic [N-1:0]         mask1;
//mask0,1
assign mask0 = (1<<shift_num) - 1;
assign mask1 = (1<<(8-shift_num))-1;
//drv
initial begin
    forever begin
        data_in = {$random()} % 256;
        shift_num = {$random()} % 8;
        op = {$random()} % 5;         //0,1,2,3,4
        #10;
    end
end
//error flag
assign error = (data_out != data_out_ref) ? 1'b1 : 1'b0;
//
always_comb begin
    case(op)
        3'd0: data_out_ref = data_in >> shift_num; 
        3'd1: data_out_ref = $signed(data_in) >>> shift_num;
        3'd2: data_out_ref = data_in << shift_num;
        3'd3: data_out_ref = ((data_in & mask0) << (8-shift_num)) + (data_in >> shift_num);                          //rotate shift right
        3'd4: data_out_ref = (data_in << shift_num) + ((data_in & ~mask1) >> (8-shift_num));                         //rotate shift left
        default: data_out_ref = data_in;
    endcase
end
//
initial begin
    $fsdbDumpfile("barrel_shift.fsdb");
    $fsdbDumpvars(0);
    $fsdbDumpMDA();
end

initial begin
    #10000
    $finish;
end

barrel_shift #
( .N(8) ) 
U (
  .data_in  (data_in  ),
  .shift_num(shift_num),
  .op       (op       ),
  .data_out (data_out )
);

endmodule 
