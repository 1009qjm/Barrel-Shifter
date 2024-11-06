
module barrel_shift
#(
    parameter N  = 8
)(
input  logic [N-1:0]          data_in,
input  logic [$clog2(N)-1:0]  shift_num,
input  logic [2:0]            op,                 //0: shift right logic, 1:shift right, 2:shift left 3: rotate shift right 4: rotate shift left
output logic [N-1:0]          data_out
);

logic [N-1:0] data_in_reverse;
logic [N-1:0] data_stg0;
logic [N-1:0] data_stg1;     //shift 4bits
logic [N-1:0] data_stg2;     //shift 2bits
logic [N-1:0] data_stg3;     //shift 1bit
logic [N-1:0] data_out_reverse;

assign data_in_reverse = {<<{data_in}};
assign data_stg0 = (op == 3'd2 || op == 3'd4) ? data_in_reverse : data_in;
//N=8
//stg1, shift4
always_comb begin 
    if(shift_num[2]) begin
        case(op)
            3'd0,3'd2:data_stg1 = {4'd0, data_stg0[7:4]};
            3'd1:     data_stg1 = {{4{data_stg0[7]}}, data_stg0[7:4]};
            3'd3,3'd4:data_stg1 = {data_stg0[3:0], data_stg0[7:4]};
            default:data_stg1 = data_stg0;
        endcase
    end
    else begin
        data_stg1 = data_stg0;
    end
end
//stg2, shift 2
always_comb begin
    if(shift_num[1]) begin
        case(op)
            3'd0,3'd2:data_stg2 = {2'd0, data_stg1[7:2]};
            3'd1:     data_stg2 = {{2{data_stg1[7]}}, data_stg1[7:2]};
            3'd3,3'd4:data_stg2 = {data_stg1[1:0], data_stg1[7:2]};
            default:  data_stg2 = data_stg1;
        endcase
    end
    else begin
        data_stg2 = data_stg1;
    end
end
//stg3, shift 1
always_comb begin
    if(shift_num[0]) begin
        case(op)
            3'd0,3'd2: data_stg3 = {1'b0, data_stg2[7:1]};
            3'd1:      data_stg3 = {data_stg2[7], data_stg2[7:1]};
            3'd3,3'd4: data_stg3 = {data_stg2[0], data_stg2[7:1]};
            default:   data_stg3 = data_stg2;
        endcase
    end
    else begin
        data_stg3 = data_stg2;
    end
end

assign data_out = (op == 3'd2 || op == 3'd4) ? {<<{data_stg3}} : data_stg3;

endmodule
