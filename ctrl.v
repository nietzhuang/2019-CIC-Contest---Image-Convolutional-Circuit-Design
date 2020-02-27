module  ctrl(
    input           clk,
    input           reset,
    output  reg     busy,
    input           ready,

    input           flag_corner,
    input           flag_upbot,
    input           flag_lfri,
    input   [3:0]   cnt_pixel,
    input           done,  // send high whenever nnlayer is done
    input           load_done,
    input           load_done_2,

    output  reg     crd,
    output  reg     cwr,
    output  reg[2:0]csel,
    output  reg     fm,  // determine feature map.
    output  reg[1:0]layer
    );

    parameter INIT = 3'b000, L0 = 3'b001, L1K0 = 3'b010, L1K1 = 3'b011, L2K0 = 3'b100, L2K1 = 3'b101;
    reg [2:0] cstate, nstate;
       
    always@(posedge clk, posedge reset)begin
        if(reset)begin
            cstate <= INIT;
            busy <= 1'b0;
        end
//        else if(done && (cstate == L2K1))
        else if(done && (cstate == L2K0))
            busy <= 1'b0;
        else if(ready)
            busy <= 1'b1;
        else
            cstate <= nstate;
    end
    
  always@*begin
        case(cstate)
            INIT:begin
                if(done) nstate = L0;
                else nstate = INIT;
            end
            L0:begin
                if(done)
                    nstate = L1K0;
                else
                    nstate = L0;
            end
            L1K0:begin
                if(cnt_pixel == 4'd4)
                    nstate = L1K1;
                else
                    nstate = L1K0;
            end
            L1K1:begin
                if(done)
                    nstate = L2K0;
                else if(cnt_pixel == 4'd4)
                    nstate = L1K0;
                else
                    nstate = L1K1;
            end
            L2K0:begin
                if(load_done)
                    nstate = L2K1;
                else
                    nstate = L2K0;
            end
            L2K1:begin
                if(load_done)
                    nstate = L2K0;
                else
                    nstate = L2K1;
            end
            default: nstate = INIT;
        endcase
    end
    
    always@*begin
        case(cstate)
            INIT:begin
                crd = 1'b0;
                cwr = 1'b0;
                fm = 1'b0;
                layer = 2'd0;
            end
            L0:begin
                crd = 1'b0;
                fm = 1'b0;
                layer = 2'd0;
                case({flag_corner, flag_upbot, flag_lfri})
                    3'b000:begin
                        if(load_done||load_done_2)
                            cwr = 1'b1;
                        else
                            cwr = 1'b0;
                    end
                    3'b010:begin
                        if(load_done||load_done_2)
                            cwr = 1'b1;
                        else
                            cwr = 1'b0;
                    end
                    3'b001:begin
                        if(load_done||load_done_2)
                            cwr = 1'b1;
                        else
                            cwr = 1'b0;
                    end
                    3'b100:begin
                        if(load_done||load_done_2)
                            cwr = 1'b1;
                        else
                            cwr = 1'b0;
                    end
                    default: cwr = 1'b0;
                endcase
            end
            L1K0:begin
                crd = (cnt_pixel != 4'd4);
                cwr = (cnt_pixel == 4'd4);
                fm = 1'b0;
                layer = 2'd1;
            end
            L1K1:begin
                crd = (cnt_pixel != 4'd4);
                cwr = (cnt_pixel == 4'd4);
                fm = 1'b1;
                layer = 2'd1;

            end
            L2K0:begin
                crd = (cnt_pixel == 4'd0);
                cwr = (cnt_pixel == 4'd1);
                fm = 1'b0;
                layer = 2'b10;
            end
            L2K1:begin
                crd = (cnt_pixel == 4'd0);
                cwr = (cnt_pixel == 4'd1);
                fm = 1'b1;
                layer = 2'b10;
            end
            default:begin
                crd = 1'b0;
                cwr = 1'b0;
                fm = 2'b0;
                layer = 2'd0;
            end
        endcase
  end
  
  always@*begin
        case(cstate)
            INIT: csel = 3'b000;
            L0:begin
                case({flag_corner, flag_upbot, flag_lfri})
                    3'b000:begin                        
                        if(load_done_2)
                            csel = 3'b010;
                        else
                            csel = 3'b001;
                    end
                    3'b010, 3'b001:begin                       
                        if(load_done_2)
                            csel = 3'b010;
                        else
                            csel = 3'b001;
                    end
                    3'b100:begin                    
                        if(load_done_2)
                            csel = 3'b010;
                        else
                            csel = 3'b001;
                    end
                    3'b010, 3'b001:begin                        
                        if(load_done_2)
                            csel = 3'b010;
                        else
                            csel = 3'b001;
                    end
                    3'b100:begin                        
                        if(load_done_2)
                            csel = 3'b010;
                        else
                            csel = 3'b001;
                    end
                    default: csel = 3'b000;
                endcase
            end
            L1K0:begin
                if(cnt_pixel <= 6'd3)
                    csel = 3'b001;
                else
                    csel = 3'b011;
            end
            L1K1:begin
                if(cnt_pixel <= 6'd3 )
                    csel = 3'b010;
                else
                    csel = 3'b100;
            end
            L2K0: csel = (cnt_pixel == 4'd0)? 3'b011:3'b101;
            L2K1: csel = (cnt_pixel == 4'd0)? 3'b100:3'b101;
            default: csel = 3'b000;
        endcase
    end
endmodule
