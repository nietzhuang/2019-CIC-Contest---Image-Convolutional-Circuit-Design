module mac(
  input         clk,
  input         reset,
  input  [3:0]  cnt_pixel,
  input  [15:0] pi0,
  input  [15:0] pi1,
  input  [15:0] pi2,
  input  [5:0]  cnt_length,
  input  [5:0]  cnt_width,
  input         flag_corner,
  input         flag_upbot,
  input         flag_lfri,

  output [39:0] conv1,
  output [39:0] conv2
);

  parameter [15:0] k0w0 = 16'hA89E, k0w1 = 16'h92D5, k0w2 = 16'h6D43, k0w3 = 16'h01004, k0w4 = 16'h708F, k0w5 = 16'h91AC, k0w6 = 16'h5929, k0w7 = 16'h37CC, k0w8 = 16'h53E7;
  parameter [15:0] k1w0 = 16'h24AB, k1w1 = 16'h2992, k1w2 = 16'h366C, k1w3 = 16'h50FD, k1w4 = 16'h2F20, k1w5 = 16'h202D, k1w6 = 16'h3BD7, k1w7 = 16'h2C97, k1w8 = 16'h5E68;
  parameter [39:0] bias0 = 40'h00_1310_0000, bias1 = 40'hFF_7295_0000;

  reg [39:0] PE0[2:0];
  reg [39:0] PE1[2:0];

   /* parameter [19:0] k0w0 = 20'h0A89E, k0w1 = 20'h092D5, k0w2 = 20'h06D43, k0w3 = 20'h01004, k0w4 = 20'hF8F71, k0w5 = 20'hF6E54, k0w6 = 20'hFA6D7, k0w7 = 20'hFC834, k0w8 = 20'hFAC19;
    parameter [19:0] k1w0 = 20'hFDB55, k1w1 = 20'h02992, k1w2 = 20'hFC994, k1w3 = 20'h050FD, k1w4 = 20'h02F20, k1w5 = 20'h0202D, k1w6 = 20'h03BD7, k1w7 = 20'hFD369, k1w8 = 20'h05E68;*/
  assign conv1 = (PE0[0] + PE0[1]) + (PE0[2] + bias0);
  assign conv2 = (PE1[0] + PE1[1]) + (PE1[2] + bias1);

  always@(posedge clk)begin
    if(reset)begin
      PE0[0] <= 40'b0;
      PE0[1] <= 40'b0;
      PE0[2] <= 40'b0;
      PE1[0] <= 40'b0;
      PE1[1] <= 40'b0;
      PE1[2] <= 40'b0;
    end
    else begin
      case({flag_corner, flag_upbot, flag_lfri})
        3'b000:begin
            if(cnt_pixel == 4'd3)begin
              PE0[0] <= k0w0*pi0 + (k0w3*pi1 + (~(k0w6*pi2)+1));
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= ((~(k1w0*pi0)+1) + k1w3*pi1) + k1w6*pi2;
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if(cnt_pixel == 4'd6)begin
              PE0[1] <= k0w1*pi0 + ((~(k0w4*pi1)+1) + (~(k0w7*pi2)+1));
              PE0[2] <= 40'b0;
              PE1[1] <= k1w1*pi0 + (k1w4*pi1 + (~(k1w7*pi2)+1));
              PE1[2] <= 40'b0;
            end
            else if(cnt_pixel == 4'd9)begin
              PE0[2] <= k0w2*pi0 + ((~(k0w5*pi1)+1) + (~(k0w8*pi2)+1));
              PE1[2] <= ((~(k1w2*pi0)+1) + k1w5*pi1) + k1w8*pi2;
            end
        end
        3'b010:begin  // Line.
          if(cnt_length == 6'd0)begin  // upper line
            if((cnt_pixel == 4'd3))begin
              PE0[0] <= k0w3*pi0 + ((~(k0w6*pi1)+1) + (~(k0w4*pi2)+1));
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= k1w3*pi0 + (k1w6*pi1 + k1w4*pi2);
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if((cnt_pixel == 4'd6))begin
              PE0[1] <= (~(k0w7*pi0)+1) + ((~(k0w5*pi1)+1) + (~(k0w8*pi2)+1));
              PE0[2] <= 40'b0;
              PE1[1] <= ((~(k1w7*pi0)+1) + k1w5*pi1) + k1w8*pi2;
              PE1[2] <= 40'b0;
            end
          end
          else if(cnt_length == 6'd63)begin  // bottom line
            if(cnt_pixel == 4'd3)begin
              PE0[0] <= k0w0*pi0 + (k0w3*pi1 + k0w1*pi2);
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= ((~(k1w0*pi0)+1) + k1w3*pi1) + k1w1*pi2;
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if(cnt_pixel == 6'd6)begin
              PE0[1] <= k0w2*pi1 + ((~(k0w4*pi0)+1)+ (~(k0w5*pi2)+1));
              PE0[2] <= 40'b0;
              PE1[1] <= (k1w4*pi0 + (~(k1w2*pi1)+1)) + k1w5*pi2;
              PE1[2] <= 40'b0;
            end
          end
        end
        3'b001:begin
          if(cnt_width == 6'd0)begin  // left line
            if(cnt_pixel == 4'd3)begin
              PE0[0] <= k0w1*pi0 + ((~(k0w4*pi1)+1) + (~(k0w7*pi2)+1));
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= k1w4*pi1 + ((~(k1w1*pi0)+1) + (~(k1w7*pi2)+1));
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if((cnt_pixel == 4'd6))begin
              PE0[1] <= k0w2*pi0 + ((~(k0w5*pi1)+1)+ (~(k0w8*pi2)+1));
              PE0[2] <= 40'b0;
              PE1[1] <= ((~(k1w2*pi0)+1) + k1w5*pi1) + k1w8*pi2;
              PE1[2] <= 40'b0;
            end
          end
          else if(cnt_width == 6'd63)begin  // right line
            if(cnt_pixel == 4'd3)begin
              PE0[0] <= k0w0*pi0 + (k0w3*pi1 + (~(k0w6*pi2)+1));
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= ((~(k1w0*pi0)+1) + k1w3*pi1) + k1w6*pi2;
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if((cnt_pixel == 4'd6))begin
              PE0[1] <= k0w1*pi0 + ((~(k0w4*pi1)+1)+ (~(k0w7*pi2)+1));
              PE0[2] <= 40'b0;
              PE1[1] <= k1w1*pi0 + (k1w4*pi1 + (~(k1w7*pi2)+1));
              PE1[2] <= 40'b0;
            end
          end
        end
        3'b100:begin  // Corner.
          if((cnt_length == 6'd0) && (cnt_width == 6'd0))begin  // upper left
            if((cnt_pixel == 4'd3))begin
              PE0[0] <= ((~(k0w4*pi0)+1) + (~(k0w7*pi1)+1)) + (~(k0w5*pi2)+1);
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= (k1w4*pi0 + (~(k1w7*pi1)+1)) + k1w5*pi2;
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if(cnt_pixel == 4'd4)begin
              PE0[1] <= (~(k0w8*pi0)+1);
              PE0[2] <= 40'b0;
              PE1[1] <= k1w8*pi0;
              PE1[2] <= 40'b0;
            end
          end
          else if((cnt_length == 6'd0) && (cnt_width == 6'd63))begin  // upper right
            if(cnt_pixel == 4'd3)begin
              PE0[0] <= k0w3*pi0 + ((~(k0w6*pi1)+1) + (~(k0w4*pi2)+1));
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= k1w3*pi0 + (k1w6*pi1 + k1w4*pi2);
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if(cnt_pixel == 4'd4)begin
              PE0[1] <= (~(k0w7*pi0)+1);
              PE0[2] <= 40'b0;
              PE1[1] <= (~(k1w7*pi0)+1);
              PE1[2] <= 40'b0;
            end
          end
          else if((cnt_length == 6'd63) && (cnt_width == 6'd0))begin  // bottom left
            if(cnt_pixel == 4'd3)begin
              PE0[0] <= k0w1*pi0 + ((~(k0w4*pi1)+1) + k0w2*pi2);
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= k1w1*pi0 + (k1w4*pi1 + (~(k1w2*pi2)+1));
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if(cnt_pixel == 4'd4)begin
              PE0[1] <= (~(k0w5*pi0)+1);
              PE0[2] <= 40'b0;
              PE1[1] <= k1w5*pi0;
              PE1[2] <= 40'b0;
            end
          end
          else if((cnt_length == 6'd63) && (cnt_width == 6'd63))begin  // bottom right
            if(cnt_pixel == 4'd3)begin
              PE0[0] <= k0w0*pi0 + (k0w3*pi1 + k0w1*pi2);
              PE0[1] <= 40'b0;
              PE0[2] <= 40'b0;
              PE1[0] <= k1w3*pi1 + ((~(k1w0*pi0)+1)+ (~(k1w1*pi2)+1));
              PE1[1] <= 40'b0;
              PE1[2] <= 40'b0;
            end
            else if(cnt_pixel == 4'd4)begin
              PE0[1] <= (~(k0w4*pi0)+1);
              PE0[2] <= 40'b0;
              PE1[1] <= k1w4*pi0;
              PE1[2] <= 40'b0;
            end
          end
          //default:
        end
      endcase
    end
  end
endmodule
