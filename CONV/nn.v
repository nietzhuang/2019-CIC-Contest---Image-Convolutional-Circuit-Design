module  nn(
    input               clk,
    input               reset,
    input   [2:0]       csel,  // used to determine which nnlayer.
    input               busy,
    input               ready,
    output  reg [11:0]  iaddr,
    input   [19:0]      idata,

    output  reg [11:0]  caddr_wr,
    output  reg [19:0]  cdata_wr,
    output  reg [11:0]  caddr_rd,
    input   [19:0]      cdata_rd,

    input   [1:0]       layer,
    input               fm,
    output              flag_corner,
    output              flag_upbot,
    output              flag_lfri,
    output  reg [3:0]   cnt_pixel,
    output  reg         done,
    output  reg         load_done,
    output  reg         load_done_2
    );
    
    integer     i;
    reg [5:0]   cnt_width, cnt_length;
    reg [19:0]  relu2_pi_2;
    wire[19:0]  pool1, pool2, poolout;
    wire [39:0] conv1, conv2;
    wire[19:0]  relu1_pi, relu2_pi;
    reg [19:0]  mem[2:0];
    reg [19:0]  pi0, pi1, pi2;

    mac uMAC(
      .clk(clk),
      .reset(reset),
      .cnt_pixel(cnt_pixel),
      .pi0(mem[0][15:0]),
      .pi1(mem[1][15:0]),
      .pi2(mem[2][15:0]),
      .cnt_length(cnt_length),
      .cnt_width(cnt_width),
      .flag_corner(flag_corner),
      .flag_upbot(flag_upbot),
      .flag_lfri(flag_lfri),
      .conv1(conv1),
      .conv2(conv2)
    );
    
    assign flag_corner = ((cnt_length == 6'd0)||(cnt_length == 6'd63)) && ((cnt_width == 6'd0)||(cnt_width == 6'd63));
    assign flag_upbot = ((cnt_length ==6'd0)||(cnt_length == 6'd63)) && ((cnt_width != 6'd0)&&(cnt_width != 6'd63));
    assign flag_lfri = ((cnt_length != 6'd0)&&(cnt_length != 6'd63)) && ((cnt_width == 6'd0)||(cnt_width == 6'd63));
    
    
    always@(posedge clk, posedge reset)begin
        if(reset)begin
            for(i = 0; i < 3; i = i + 1)begin
                mem[i] <= 20'b0;
            end
        end
        else if(busy && (!ready))begin
            case(layer)
                2'b00:begin
                        case(cnt_pixel)
                                4'd0, 4'd3, 4'd6: mem[0] <= idata;
                                4'd1, 4'd4, 4'd7: mem[1] <= idata;
                                4'd2, 4'd5, 4'd8: mem[2] <= idata;
                        endcase
                end
                2'b01, 2'b10:begin
                        if(cnt_pixel[1:0] <= 2'd2)begin
                                mem[cnt_pixel[1:0]] <= cdata_rd;  // Read L0_MEM or L1_MEM image.
                        end
                end
            endcase
        end
    end
    
    // Counter width & length. 
    always@(posedge clk, posedge reset)begin
        if(reset)begin
            cnt_width <= 6'b0;
            cnt_length <= 6'b0;
        end
        else begin
            case(layer)
                2'b00:begin
                    if(load_done_2)begin
                        if(cnt_width == 6'd63)begin
                            cnt_width <= cnt_width + 1;
                            cnt_length <= cnt_length + 1;
                        end
                        else
                            cnt_width <= cnt_width + 1;
                    end
                end
                2'b01:begin  // stride = 2.
                    if(load_done && (csel == 3'b100))begin
                        if(cnt_width == 6'd62)begin
                            cnt_width <= cnt_width + 2;
                            cnt_length <= cnt_length + 2;
                        end
                        else
                            cnt_width <= cnt_width + 2;
                    end
                end
/*
                2'b10:begin  // Flattern.
                    if(cnt_width == 6'd31)begin
                        
                    end
                end 
*/
            endcase
        end
    end

    // Assert done to procce to next layer.
    always@*begin
        if((csel == 3'b000) && (cnt_pixel == 4'd2))  // set cnt_pixel=2 beforehand.
            done = 1;
        else begin
            case(layer)
                2'b00:begin
                    if(load_done_2 && (cnt_width == 6'd63) && (cnt_length == 6'd63))
                        done = 1'b1;
                    else
                        done = 1'b0;
                end
                2'b01:begin
                    if(load_done && (csel == 3'b100) && (cnt_width == 6'd62) && (cnt_length == 6'd62))
                        done = 1'b1;
                    else
                        done = 1'b0;
                end
                2'b10:begin
                    if((caddr_wr == 12'd2048))
                        done = 1'b1;
                    else
                        done = 1'b0;
                end
                default: done = 1'b0;
            endcase
        end
    end
    
    // Load done
    always@*begin
        case(layer)
            2'b00:begin
                case({flag_corner, flag_upbot, flag_lfri})
                    3'b000:begin
                        if(cnt_pixel == 4'd11)
                            load_done = 1'b1;
                        else
                            load_done = 1'b0;
                    end
                    3'b010, 3'b001:begin
                        if(cnt_pixel == 4'd8)
                            load_done = 1'b1;
                        else
                            load_done = 1'b0;
                    end
                    3'b100:begin
                        if(cnt_pixel == 4'd5)
                            load_done = 1'b1;
                        else
                            load_done = 1'b0;
                    end
                    default: load_done = 1'b0;
                endcase
            end
            2'b01:begin
            if(cnt_pixel == 4'd4)
                    load_done = 1'b1;
                else
                    load_done = 1'b0;
            end
            2'b10:begin
                if(cnt_pixel == 4'd1)
                    load_done = 1'b1;
                else
                    load_done = 1'b0;
            end
            default: load_done = 1'b0;
        endcase
    end
    
    // Creat load_done_2
    always@(posedge clk)begin
        load_done_2 <= load_done;
    end

    // Count pixel number.
    always@(posedge clk, posedge reset)begin
        if(reset)
            cnt_pixel <= 4'b0;
        else if(busy && (!ready))begin
            case(layer)
                2'b00:begin
                    case({flag_corner, flag_upbot, flag_lfri})
                        3'b000:begin
                            if(cnt_pixel == 4'd12)
                                cnt_pixel <= 4'd0;
                            else
                                cnt_pixel <= cnt_pixel + 1;
                        end
                        3'b010, 3'b001:begin
                            if(cnt_pixel == 4'd9)
                                cnt_pixel <= 4'd0;
                            else
                                cnt_pixel <= cnt_pixel + 1;
                        end
                        3'b100:begin
                            if(cnt_pixel == 4'd6)
                                cnt_pixel <= 4'd0;
                            else
                                cnt_pixel <= cnt_pixel + 1;
                        end
                        default:
                            cnt_pixel <= 4'd0;
                    endcase
                end
                2'b01:begin
                    if(cnt_pixel == 4'd4)
                        cnt_pixel <= 4'd0;
                    else
                        cnt_pixel <= cnt_pixel + 1;
                end

                2'b10:begin
                    if(cnt_pixel == 4'd1)
                        cnt_pixel <= 4'd0;
                    else
                        cnt_pixel <= cnt_pixel + 1;
                end
            endcase
        end
    end
    
    // Input image
    always@(posedge clk, posedge reset)begin
        if(reset)begin
            iaddr <= 12'b0;
            caddr_rd <= 12'd0;
        end
        else if(busy && (!ready))begin
            case(layer)
                2'b00:begin
                    case({flag_corner, flag_upbot, flag_lfri})
                        3'b000:begin
                            if((cnt_pixel == 4'd2)||(cnt_pixel == 4'd5))
                                iaddr <= iaddr - 12'd127;
                            else if(cnt_pixel == 4'd8)  // reload.
                                iaddr <= iaddr - 12'd129;
                            else if(cnt_pixel >= 4'd9)
                                iaddr <= iaddr;
                            else
                                iaddr <= iaddr + 12'd64;
                        end
                        3'b010:begin
                            if((cnt_pixel == 4'd1)||(cnt_pixel == 4'd3))
                                iaddr <= iaddr - 12'd63;
                            else if(cnt_pixel == 4'd5)  // reload.
                                iaddr <= iaddr - 12'd65;
                            else if(cnt_pixel >= 4'd6)
                                iaddr <= iaddr;
                            else
                                iaddr <= iaddr + 12'd64;
                        end
                        3'b001:begin
                        if((cnt_pixel == 4'd2))
                                iaddr <= iaddr - 12'd127;
                            else if((cnt_pixel == 4'd5)&&(cnt_width == 6'd0))  // left line.
                                iaddr <= iaddr - 12'd129;
                            else if((cnt_pixel == 4'd5)&&(cnt_width == 6'd63))  // right line.
                                iaddr <= iaddr - 12'd127;
                            else if(cnt_pixel >= 4'd6)
                                iaddr <= iaddr;
                            else
                                iaddr <= iaddr + 12'd64;
                        end
                        3'b100:begin
                            if(cnt_pixel == 4'd1)
                                iaddr <= iaddr - 12'd63;
                            else if((cnt_pixel == 4'd3)&&(cnt_width == 6'd0))  // left corner.
                                iaddr <= iaddr - 12'd65;
                            else if((cnt_pixel == 4'd3)&&(cnt_width == 6'd63)) // right corner
                                iaddr <= iaddr - 12'd127;
                            else if(cnt_pixel >= 4'd4)
                                iaddr <= iaddr;
                            else
                                iaddr <= iaddr + 12'd64;
                        end
                        default:
                            iaddr <= 12'd0;
                    endcase
                end
                2'b01:begin
                    if(csel == 3'b100)begin
                        if((cnt_pixel == 4'd1)||(cnt_pixel == 4'd3))
                            caddr_rd <= caddr_rd - 12'd63;
                        else if((cnt_pixel == 4'd4) && (cnt_width == 6'd62))  // margin
                            caddr_rd <= caddr_rd + 12'd64;
                        else if(cnt_pixel == 4'd4)
                            caddr_rd <= caddr_rd;
                        else
                            caddr_rd <= caddr_rd + 12'd64;
                    end
                    else begin
                        if((cnt_pixel == 4'd1)||(cnt_pixel == 4'd3))
                            caddr_rd <= caddr_rd -12'd63;
                        else if(cnt_pixel == 4'd4)
                            caddr_rd <= caddr_rd - 12'd2;
                        else
                            caddr_rd <= caddr_rd + 12'd64;
                    end
                end
                2'b10:begin
                    if(csel == 3'b100)
                        caddr_rd <= caddr_rd + 12'd1;
                end
                default: caddr_rd <= 12'd0;

            endcase
        end
        else begin
            iaddr <= 12'b0;                                                                                                                              297,5         80%
            caddr_rd <= 12'b0;
        end
    end
    
    assign relu1_pi = (conv1[39])? 20'b0: conv1[35:16] + conv1[15];
    assign relu2_pi = (conv2[39])? 20'b0: conv2[35:16] + conv2[15];

    //  Maximum pooling Operator.
    assign  pool1 = (mem[0]>=mem[1])? mem[0]:mem[1];
    assign  pool2 = (pool1>=mem[2])? pool1:mem[2];
    assign  poolout = (pool2>=cdata_rd)? pool2:cdata_rd;

    // Write Block
    always@(posedge clk)begin
        relu2_pi_2 <= relu2_pi;
    end

    always@(posedge clk, posedge reset)begin
        if(reset)
            caddr_wr <= 12'd0;
        else begin
            case(layer)
                2'b00:begin
                    if(load_done_2)
                        caddr_wr <= caddr_wr + 12'd1;
                end
                2'b01:begin
                    if(load_done && (csel == 3'b100)&&(cnt_width == 6'd62)&&(cnt_length == 6'd62))
                        caddr_wr <= 12'd0;
                    else if(load_done && fm)   /// Attention!!!!
                        caddr_wr <= caddr_wr + 12'd1;
                    else
                        caddr_wr <= caddr_wr;
                end
                2'b10:begin
                    if(load_done)
                        caddr_wr <= caddr_wr + 12'd1;
                end
                default:begin
                    caddr_wr <= 12'd0;
                end
            endcase
        end
    end    
    
    always@*begin
        case(layer)
            2'b00:begin  // Write ReLU data to L0_MEM.
                if(load_done)
                    cdata_wr = relu1_pi;
                else if(load_done_2)
                    cdata_wr = relu2_pi_2;
                else
                    cdata_wr = 20'd0;
            end
            2'b01:begin  // Write pooling data to L1_MEM
                if(load_done)
                    cdata_wr = poolout;
                else
                    cdata_wr = 20'd0;
            end
            2'b10:begin
                if(load_done)
                    cdata_wr = mem[0];
                else
                    cdata_wr = 20'd0;
            end
            default: cdata_wr = 20'd0;
        endcase
    end

endmodule


    
    
    
    
