
module barrel_shift
#(
    parameter N  = 8
)(
input  logic [N-1:0]          data_in,
input  logic [$clog2(N)-1:0]  shift_num,
input  logic [2:0]            op,         //0: shift right logic, 1:shift righti arithmetic, 2:shift left 3: rotate shift right 4: rotate shift left
output logic [N-1:0]          data_out
);

logic [N-1:0] data_in_reverse;
logic [N-1:0] data_out_reverse;

assign data_in_reverse = {<<{data_in}};
//
logic [N-1:0] data_stage [$clog2(N):0];
generate
    for(genvar i = 0; i < $clog2(N); i++) begin:gen_shift               //i=0,1,...,$clog2(N)-1
        localparam M = (1<<i);
        always_comb begin
            if(shift_num[i]) begin          //shift 2^i bit
                case(op)
                    3'd0,3'd2: data_stage[i+1] = {{M{1'b0}}, data_stage[i][N-1:M]};
                    3'd1:      data_stage[i+1] = {{M{data_stage[i][N-1]}}, data_stage[i][N-1:M]};
                    3'd3,3'd4: data_stage[i+1] = {data_stage[i][M-1:0], data_stage[i][N-1:M]};
                    default:   data_stage[i+1] = data_stage[i];
                endcase
            end
            else begin
                data_stage[i+1] = data_stage[i];
            end
        end
    end
endgenerate
//
assign data_out = (op == 3'd2 || op == 3'd4) ? {<<{data_stage[$clog2(N)]}} : data_stage[$clog2(N)];
assign data_stage[0] = (op == 3'd2 || op == 3'd4) ? data_in_reverse : data_in;

endmodule
