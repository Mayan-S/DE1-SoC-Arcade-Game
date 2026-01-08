`default_nettype none

module vga_demo (CLOCK_50, PS2_CLK, KEY, PS2_DAT, HEX5, HEX4,
                 HEX3, HEX2, HEX1, HEX0, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
                  
    parameter nX = 10;
    parameter nY = 9;

    input wire CLOCK_50;
    input wire [3:0] KEY;
    inout wire PS2_CLK, PS2_DAT;
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output wire [7:0] VGA_R, VGA_G, VGA_B;
    output wire VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
    
    // Ship signals
    wire [nX-1:0] ship_x;
    wire [nY-1:0] ship_y;
    wire [8:0] ship_colour;
    wire ship_write;
    wire ship_done;
    wire [nX-1:0] ship_pos_x;  // Ship center position for collision
    wire [nY-1:0] ship_pos_y;
    
    // Asteroid signals - from top (moving down)
    wire [nX-1:0] ast_down1_x, ast_down2_x, ast_down3_x, ast_down4_x;
    wire [nY-1:0] ast_down1_y, ast_down2_y, ast_down3_y, ast_down4_y;
    wire [8:0] ast_down1_colour, ast_down2_colour, ast_down3_colour, ast_down4_colour;
    wire ast_down1_write, ast_down2_write, ast_down3_write, ast_down4_write;
    wire ast_down1_done, ast_down2_done, ast_down3_done, ast_down4_done;
    wire [nX-1:0] ast_down1_pos_x, ast_down2_pos_x, ast_down3_pos_x, ast_down4_pos_x;
    wire [nY-1:0] ast_down1_pos_y, ast_down2_pos_y, ast_down3_pos_y, ast_down4_pos_y;
    
    // Asteroid signals - from bottom (moving up)
    wire [nX-1:0] ast_up1_x, ast_up2_x, ast_up3_x, ast_up4_x;
    wire [nY-1:0] ast_up1_y, ast_up2_y, ast_up3_y, ast_up4_y;
    wire [8:0] ast_up1_colour, ast_up2_colour, ast_up3_colour, ast_up4_colour;
    wire ast_up1_write, ast_up2_write, ast_up3_write, ast_up4_write;
    wire ast_up1_done, ast_up2_done, ast_up3_done, ast_up4_done;
    wire [nX-1:0] ast_up1_pos_x, ast_up2_pos_x, ast_up3_pos_x, ast_up4_pos_x;
    wire [nY-1:0] ast_up1_pos_y, ast_up2_pos_y, ast_up3_pos_y, ast_up4_pos_y;
    
    // Asteroid signals - from left (moving right)
    wire [nX-1:0] ast_right1_x, ast_right2_x, ast_right3_x, ast_right4_x;
    wire [nY-1:0] ast_right1_y, ast_right2_y, ast_right3_y, ast_right4_y;
    wire [8:0] ast_right1_colour, ast_right2_colour, ast_right3_colour, ast_right4_colour;
    wire ast_right1_write, ast_right2_write, ast_right3_write, ast_right4_write;
    wire ast_right1_done, ast_right2_done, ast_right3_done, ast_right4_done;
    wire [nX-1:0] ast_right1_pos_x, ast_right2_pos_x, ast_right3_pos_x, ast_right4_pos_x;
    wire [nY-1:0] ast_right1_pos_y, ast_right2_pos_y, ast_right3_pos_y, ast_right4_pos_y;
    
    // Asteroid signals - from right (moving left)
    wire [nX-1:0] ast_left1_x, ast_left2_x, ast_left3_x, ast_left4_x;
    wire [nY-1:0] ast_left1_y, ast_left2_y, ast_left3_y, ast_left4_y;
    wire [8:0] ast_left1_colour, ast_left2_colour, ast_left3_colour, ast_left4_colour;
    wire ast_left1_write, ast_left2_write, ast_left3_write, ast_left4_write;
    wire ast_left1_done, ast_left2_done, ast_left3_done, ast_left4_done;
    wire [nX-1:0] ast_left1_pos_x, ast_left2_pos_x, ast_left3_pos_x, ast_left4_pos_x;
    wire [nY-1:0] ast_left1_pos_y, ast_left2_pos_y, ast_left3_pos_y, ast_left4_pos_y;
    
    // VGA mux signals
    reg [nX-1:0] give_x;
    reg [nY-1:0] give_y;
    reg [8:0] give_colour;
    reg give_write;
    
    // Grant signals for round-robin
    reg gntShip, gntD1, gntD2, gntD3, gntD4, gntU1, gntU2, gntU3, gntU4, gntR1, gntR2, gntR3, gntR4, gntL1, gntL2, gntL3, gntL4;
    reg [4:0] select;
    
    // PS2 keyboard signals
    reg prev_ps2_clk;
    wire negedge_ps2_clk;
    wire ps2_rec;
    reg [32:0] Serial;
    reg [3:0] Packet;
    wire [7:0] scancode;
    wire PS2_CLK_S, PS2_DAT_S;
    reg Esc;
    reg shipReq;
    
    // Key press signals
    wire key_W, key_A, key_S, key_D;
    
    wire Resetn = 1'b1;  // Always high
    wire KEY0_sync;
    
    // ============ GAME RESET ============
    // KEY[0] triggers a full game restart
    wire game_reset;
    assign game_reset = KEY0_sync;
    
    // ============ SCREEN CLEAR ============
    // Clears entire screen to black when game resets
    wire [nX-1:0] clear_x;
    wire [nY-1:0] clear_y;
    wire clear_write;
    wire clear_active;
    wire clear_done;
    
    screen_clear CLEAR (
        .Clock(CLOCK_50),
        .start(game_reset),
        .x(clear_x),
        .y(clear_y),
        .write(clear_write),
        .active(clear_active),
        .done(clear_done)
    );
    
    // ============ COLLISION DETECTION ============
    reg game_frozen;
    wire collision;
    
    // Collision detection - check if ship overlaps any asteroid (16x16 bounding boxes)
    // Objects collide if distance between centers < 16 on both axes
    wire coll_d1, coll_d2, coll_d3, coll_d4;
    wire coll_u1, coll_u2, coll_u3, coll_u4;
    wire coll_r1, coll_r2, coll_r3, coll_r4;
    wire coll_l1, coll_l2, coll_l3, coll_l4;
    
    // Helper function for absolute difference check
    // Two 16x16 objects collide if |x1-x2| < 16 AND |y1-y2| < 16
    function collision_check;
        input [9:0] ship_x, ast_x;
        input [8:0] ship_y, ast_y;
        reg [9:0] dx;
        reg [8:0] dy;
        begin
            dx = (ship_x > ast_x) ? (ship_x - ast_x) : (ast_x - ship_x);
            dy = (ship_y > ast_y) ? (ship_y - ast_y) : (ast_y - ship_y);
            collision_check = (dx < 10'd16) && (dy < 9'd16);
        end
    endfunction
    
    assign coll_d1 = collision_check(ship_pos_x, ast_down1_pos_x, ship_pos_y, ast_down1_pos_y);
    assign coll_d2 = collision_check(ship_pos_x, ast_down2_pos_x, ship_pos_y, ast_down2_pos_y);
    assign coll_d3 = collision_check(ship_pos_x, ast_down3_pos_x, ship_pos_y, ast_down3_pos_y);
    assign coll_d4 = collision_check(ship_pos_x, ast_down4_pos_x, ship_pos_y, ast_down4_pos_y);
    assign coll_u1 = collision_check(ship_pos_x, ast_up1_pos_x, ship_pos_y, ast_up1_pos_y);
    assign coll_u2 = collision_check(ship_pos_x, ast_up2_pos_x, ship_pos_y, ast_up2_pos_y);
    assign coll_u3 = collision_check(ship_pos_x, ast_up3_pos_x, ship_pos_y, ast_up3_pos_y);
    assign coll_u4 = collision_check(ship_pos_x, ast_up4_pos_x, ship_pos_y, ast_up4_pos_y);
    assign coll_r1 = collision_check(ship_pos_x, ast_right1_pos_x, ship_pos_y, ast_right1_pos_y);
    assign coll_r2 = collision_check(ship_pos_x, ast_right2_pos_x, ship_pos_y, ast_right2_pos_y);
    assign coll_r3 = collision_check(ship_pos_x, ast_right3_pos_x, ship_pos_y, ast_right3_pos_y);
    assign coll_r4 = collision_check(ship_pos_x, ast_right4_pos_x, ship_pos_y, ast_right4_pos_y);
    assign coll_l1 = collision_check(ship_pos_x, ast_left1_pos_x, ship_pos_y, ast_left1_pos_y);
    assign coll_l2 = collision_check(ship_pos_x, ast_left2_pos_x, ship_pos_y, ast_left2_pos_y);
    assign coll_l3 = collision_check(ship_pos_x, ast_left3_pos_x, ship_pos_y, ast_left3_pos_y);
    assign coll_l4 = collision_check(ship_pos_x, ast_left4_pos_x, ship_pos_y, ast_left4_pos_y);
    
    assign collision = coll_d1 | coll_d2 | coll_d3 | coll_d4 |
                       coll_u1 | coll_u2 | coll_u3 | coll_u4 |
                       coll_r1 | coll_r2 | coll_r3 | coll_r4 |
                       coll_l1 | coll_l2 | coll_l3 | coll_l4;
    
    // Game freeze logic - once frozen, stays frozen until reset
    initial begin
        game_frozen = 1'b0;
    end
    
    always @(posedge CLOCK_50)
    begin
        if (game_reset)
            game_frozen <= 1'b0;
        else if (collision)
            game_frozen <= 1'b1;
    end

    // Synchronizers for inputs
    sync s0 (~KEY[0], 1'b1, CLOCK_50, KEY0_sync);
    sync s3 (PS2_CLK, 1'b1, CLOCK_50, PS2_CLK_S);
    sync s4 (PS2_DAT, 1'b1, CLOCK_50, PS2_DAT_S);

    // ============ STOPWATCH TIMER ON HEX DISPLAYS ============
    // Counts from 000000 to 999999, incrementing every second
    // Stops when game is frozen
    reg [25:0] second_counter;  // Counts to 50,000,000 for 1 second at 50MHz
    reg [3:0] digit0, digit1, digit2, digit3, digit4, digit5;  // BCD digits
    
    // Initialize stopwatch
    initial begin
        second_counter = 26'd0;
        digit0 = 4'd0;
        digit1 = 4'd0;
        digit2 = 4'd0;
        digit3 = 4'd0;
        digit4 = 4'd0;
        digit5 = 4'd0;
    end
    
    // 1-second counter and BCD digit incrementing (stops when frozen or clearing, resets on game_reset)
    always @(posedge CLOCK_50)
    begin
        if (game_reset)
        begin
            second_counter <= 26'd0;
            digit0 <= 4'd0;
            digit1 <= 4'd0;
            digit2 <= 4'd0;
            digit3 <= 4'd0;
            digit4 <= 4'd0;
            digit5 <= 4'd0;
        end
        else if (!game_frozen && !clear_active)
        begin
            if (second_counter >= 26'd49_999_999)
            begin
                second_counter <= 26'd0;
                // Increment BCD counter
                if (digit0 == 4'd9)
                begin
                    digit0 <= 4'd0;
                    if (digit1 == 4'd9)
                    begin
                        digit1 <= 4'd0;
                        if (digit2 == 4'd9)
                        begin
                            digit2 <= 4'd0;
                            if (digit3 == 4'd9)
                            begin
                                digit3 <= 4'd0;
                                if (digit4 == 4'd9)
                                begin
                                    digit4 <= 4'd0;
                                    if (digit5 == 4'd9)
                                        digit5 <= 4'd0;  // Wrap around at 999999
                                    else
                                        digit5 <= digit5 + 4'd1;
                                end
                                else
                                    digit4 <= digit4 + 4'd1;
                            end
                            else
                                digit3 <= digit3 + 4'd1;
                        end
                        else
                            digit2 <= digit2 + 4'd1;
                    end
                    else
                        digit1 <= digit1 + 4'd1;
                end
                else
                    digit0 <= digit0 + 4'd1;
            end
            else
                second_counter <= second_counter + 26'd1;
        end
    end
    
    // 7-segment decoder (active low)
    // Segments: 0=top, 1=top-right, 2=bottom-right, 3=bottom, 4=bottom-left, 5=top-left, 6=middle
    function [6:0] seg7;
        input [3:0] digit;
        case (digit)
            4'd0: seg7 = 7'b1000000;
            4'd1: seg7 = 7'b1111001;
            4'd2: seg7 = 7'b0100100;
            4'd3: seg7 = 7'b0110000;
            4'd4: seg7 = 7'b0011001;
            4'd5: seg7 = 7'b0010010;
            4'd6: seg7 = 7'b0000010;
            4'd7: seg7 = 7'b1111000;
            4'd8: seg7 = 7'b0000000;
            4'd9: seg7 = 7'b0010000;
            default: seg7 = 7'b1111111;
        endcase
    endfunction
    
    // Connect digits to HEX displays
    assign HEX0 = seg7(digit0);
    assign HEX1 = seg7(digit1);
    assign HEX2 = seg7(digit2);
    assign HEX3 = seg7(digit3);
    assign HEX4 = seg7(digit4);
    assign HEX5 = seg7(digit5);

    // PS2 clock edge detection
    always @(posedge CLOCK_50)
        prev_ps2_clk <= PS2_CLK_S;
     
    assign negedge_ps2_clk = (prev_ps2_clk & !PS2_CLK_S);

    // PS2 serial data shift register
    always @(posedge CLOCK_50)
    begin
        if (Resetn == 0)
            Serial <= 33'b0;
        else if (negedge_ps2_clk)
        begin
            Serial[31:0] <= Serial[32:1];
            Serial[32] <= PS2_DAT_S;
        end
    end
     
    // PS2 packet counter
    always @(posedge CLOCK_50)
    begin
        if (!Resetn || Packet == 'd11)
            Packet <= 'b0;
        else if (negedge_ps2_clk)
        begin
            Packet <= Packet + 'b1;
        end
    end
     
    assign ps2_rec = (Packet == 'd11) && (Serial[30:23] == Serial[8:1]);

    // Store scancode
    regn u1 (Serial[8:1], Resetn, Esc, CLOCK_50, scancode);

    // Decode which key was pressed
    assign key_W = (scancode == 8'h1D);  // W = forward
    assign key_A = (scancode == 8'h1C);  // A = rotate left
    assign key_S = (scancode == 8'h1B);  // S = backward
    assign key_D = (scancode == 8'h23);  // D = rotate right

    // Valid key detection
    wire valid_key;
    assign valid_key = (Serial[8:1] == 8'h1C) || (Serial[8:1] == 8'h23) ||
                       (Serial[8:1] == 8'h1D) || (Serial[8:1] == 8'h1B);

    // Ship request logic - request update when valid key pressed (only if not frozen)
    always @(posedge CLOCK_50)
    begin
        if (~Resetn)
            shipReq <= 1'b0;
        else
        begin
            if (ps2_rec && valid_key && !game_frozen)
                shipReq <= 1'b1;
            else if (ship_done)
                shipReq <= 1'b0;
        end
    end

    // Enable scancode capture
    always @(*)
    begin
        Esc = 1'b1;
    end
    
    // Round-robin select state machine
    always @(posedge CLOCK_50)
    begin
        if (!Resetn)
            select <= 5'd0;
        else if (shipReq)
            select <= 5'd0;  // Ship has priority
        else if (select == 5'd0 && (ship_done || !shipReq))
            select <= 5'd1;
        else if (select == 5'd1 && ast_down1_done)
            select <= 5'd2;
        else if (select == 5'd2 && ast_down2_done)
            select <= 5'd3;
        else if (select == 5'd3 && ast_down3_done)
            select <= 5'd4;
        else if (select == 5'd4 && ast_down4_done)
            select <= 5'd5;
        else if (select == 5'd5 && ast_up1_done)
            select <= 5'd6;
        else if (select == 5'd6 && ast_up2_done)
            select <= 5'd7;
        else if (select == 5'd7 && ast_up3_done)
            select <= 5'd8;
        else if (select == 5'd8 && ast_up4_done)
            select <= 5'd9;
        else if (select == 5'd9 && ast_right1_done)
            select <= 5'd10;
        else if (select == 5'd10 && ast_right2_done)
            select <= 5'd11;
        else if (select == 5'd11 && ast_right3_done)
            select <= 5'd12;
        else if (select == 5'd12 && ast_right4_done)
            select <= 5'd13;
        else if (select == 5'd13 && ast_left1_done)
            select <= 5'd14;
        else if (select == 5'd14 && ast_left2_done)
            select <= 5'd15;
        else if (select == 5'd15 && ast_left3_done)
            select <= 5'd16;
        else if (select == 5'd16 && ast_left4_done)
            select <= 5'd1;  // Loop back to first asteroid
    end
    
    // Grant signals based on select
    always @(*)
    begin
        gntShip = (select == 5'd0);
        gntD1 = (select == 5'd1);
        gntD2 = (select == 5'd2);
        gntD3 = (select == 5'd3);
        gntD4 = (select == 5'd4);
        gntU1 = (select == 5'd5);
        gntU2 = (select == 5'd6);
        gntU3 = (select == 5'd7);
        gntU4 = (select == 5'd8);
        gntR1 = (select == 5'd9);
        gntR2 = (select == 5'd10);
        gntR3 = (select == 5'd11);
        gntR4 = (select == 5'd12);
        gntL1 = (select == 5'd13);
        gntL2 = (select == 5'd14);
        gntL3 = (select == 5'd15);
        gntL4 = (select == 5'd16);
    end
    
    // VGA output mux - screen clear has highest priority
    always @(*)
    begin
        if (clear_active)
        begin
            give_x = clear_x;
            give_y = clear_y;
            give_colour = 9'b000000000;  // Black
            give_write = clear_write;
        end
        else
        begin
            case (select)
                5'd0: begin give_x = ship_x; give_y = ship_y; give_colour = ship_colour; give_write = ship_write; end
                5'd1: begin give_x = ast_down1_x; give_y = ast_down1_y; give_colour = ast_down1_colour; give_write = ast_down1_write; end
                5'd2: begin give_x = ast_down2_x; give_y = ast_down2_y; give_colour = ast_down2_colour; give_write = ast_down2_write; end
                5'd3: begin give_x = ast_down3_x; give_y = ast_down3_y; give_colour = ast_down3_colour; give_write = ast_down3_write; end
                5'd4: begin give_x = ast_down4_x; give_y = ast_down4_y; give_colour = ast_down4_colour; give_write = ast_down4_write; end
                5'd5: begin give_x = ast_up1_x; give_y = ast_up1_y; give_colour = ast_up1_colour; give_write = ast_up1_write; end
                5'd6: begin give_x = ast_up2_x; give_y = ast_up2_y; give_colour = ast_up2_colour; give_write = ast_up2_write; end
                5'd7: begin give_x = ast_up3_x; give_y = ast_up3_y; give_colour = ast_up3_colour; give_write = ast_up3_write; end
                5'd8: begin give_x = ast_up4_x; give_y = ast_up4_y; give_colour = ast_up4_colour; give_write = ast_up4_write; end
                5'd9: begin give_x = ast_right1_x; give_y = ast_right1_y; give_colour = ast_right1_colour; give_write = ast_right1_write; end
                5'd10: begin give_x = ast_right2_x; give_y = ast_right2_y; give_colour = ast_right2_colour; give_write = ast_right2_write; end
                5'd11: begin give_x = ast_right3_x; give_y = ast_right3_y; give_colour = ast_right3_colour; give_write = ast_right3_write; end
                5'd12: begin give_x = ast_right4_x; give_y = ast_right4_y; give_colour = ast_right4_colour; give_write = ast_right4_write; end
                5'd13: begin give_x = ast_left1_x; give_y = ast_left1_y; give_colour = ast_left1_colour; give_write = ast_left1_write; end
                5'd14: begin give_x = ast_left2_x; give_y = ast_left2_y; give_colour = ast_left2_colour; give_write = ast_left2_write; end
                5'd15: begin give_x = ast_left3_x; give_y = ast_left3_y; give_colour = ast_left3_colour; give_write = ast_left3_write; end
                5'd16: begin give_x = ast_left4_x; give_y = ast_left4_y; give_colour = ast_left4_colour; give_write = ast_left4_write; end
                default: begin give_x = 10'd0; give_y = 9'd0; give_colour = 9'd0; give_write = 1'b0; end
            endcase
        end
    end

    // Ship module instance with rotation support
    ship O1 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .ps2_rec(shipReq),
        .key_W(key_W),
        .key_A(key_A),
        .key_S(key_S),
        .key_D(key_D),
        .VGA_x(ship_x),
        .VGA_y(ship_y),
        .VGA_color(ship_colour),
        .VGA_write(ship_write),
        .done(ship_done),
        .reset(game_reset),
        .frozen(game_frozen),
        .pos_x(ship_pos_x),
        .pos_y(ship_pos_y)
    );
    
    // ============ ASTEROIDS FROM TOP (moving down) - 4 asteroids ============
    // DELAY values: 1.25x slower than previous (28125*1.25, etc.)
    asteroid_down AD1 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntD1),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_down1_x),
        .VGA_y(ast_down1_y),
        .VGA_color(ast_down1_colour),
        .VGA_write(ast_down1_write),
        .done(ast_down1_done),
        .pos_x(ast_down1_pos_x),
        .pos_y(ast_down1_pos_y)
    );
    defparam AD1.XOFFSET = 60;
    defparam AD1.YOFFSET = 20;
    defparam AD1.DELAY = 24'd54931;
    defparam AD1.LFSR_SEED = 16'hACE1;
    
    asteroid_down AD2 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntD2),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_down2_x),
        .VGA_y(ast_down2_y),
        .VGA_color(ast_down2_colour),
        .VGA_write(ast_down2_write),
        .done(ast_down2_done),
        .pos_x(ast_down2_pos_x),
        .pos_y(ast_down2_pos_y)
    );
    defparam AD2.XOFFSET = 200;
    defparam AD2.YOFFSET = 120;
    defparam AD2.DELAY = 24'd65918;
    defparam AD2.LFSR_SEED = 16'h1234;
    
    asteroid_down AD3 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntD3),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_down3_x),
        .VGA_y(ast_down3_y),
        .VGA_color(ast_down3_colour),
        .VGA_write(ast_down3_write),
        .done(ast_down3_done),
        .pos_x(ast_down3_pos_x),
        .pos_y(ast_down3_pos_y)
    );
    defparam AD3.XOFFSET = 400;
    defparam AD3.YOFFSET = 60;
    defparam AD3.DELAY = 24'd47606;
    defparam AD3.LFSR_SEED = 16'h5678;
    
    asteroid_down AD4 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntD4),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_down4_x),
        .VGA_y(ast_down4_y),
        .VGA_color(ast_down4_colour),
        .VGA_write(ast_down4_write),
        .done(ast_down4_done),
        .pos_x(ast_down4_pos_x),
        .pos_y(ast_down4_pos_y)
    );
    defparam AD4.XOFFSET = 550;
    defparam AD4.YOFFSET = 180;
    defparam AD4.DELAY = 24'd58594;
    defparam AD4.LFSR_SEED = 16'h9ABC;
    
    // ============ ASTEROIDS FROM BOTTOM (moving up) - 4 asteroids ============
    asteroid_up AU1 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntU1),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_up1_x),
        .VGA_y(ast_up1_y),
        .VGA_color(ast_up1_colour),
        .VGA_write(ast_up1_write),
        .done(ast_up1_done),
        .pos_x(ast_up1_pos_x),
        .pos_y(ast_up1_pos_y)
    );
    defparam AU1.XOFFSET = 100;
    defparam AU1.YOFFSET = 460;
    defparam AU1.DELAY = 24'd51269;
    defparam AU1.LFSR_SEED = 16'hBEEF;
    
    asteroid_up AU2 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntU2),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_up2_x),
        .VGA_y(ast_up2_y),
        .VGA_color(ast_up2_colour),
        .VGA_write(ast_up2_write),
        .done(ast_up2_done),
        .pos_x(ast_up2_pos_x),
        .pos_y(ast_up2_pos_y)
    );
    defparam AU2.XOFFSET = 280;
    defparam AU2.YOFFSET = 380;
    defparam AU2.DELAY = 24'd62255;
    defparam AU2.LFSR_SEED = 16'hFACE;
    
    asteroid_up AU3 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntU3),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_up3_x),
        .VGA_y(ast_up3_y),
        .VGA_color(ast_up3_colour),
        .VGA_write(ast_up3_write),
        .done(ast_up3_done),
        .pos_x(ast_up3_pos_x),
        .pos_y(ast_up3_pos_y)
    );
    defparam AU3.XOFFSET = 460;
    defparam AU3.YOFFSET = 420;
    defparam AU3.DELAY = 24'd56761;
    defparam AU3.LFSR_SEED = 16'hD00D;
    
    asteroid_up AU4 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntU4),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_up4_x),
        .VGA_y(ast_up4_y),
        .VGA_color(ast_up4_colour),
        .VGA_write(ast_up4_write),
        .done(ast_up4_done),
        .pos_x(ast_up4_pos_x),
        .pos_y(ast_up4_pos_y)
    );
    defparam AU4.XOFFSET = 580;
    defparam AU4.YOFFSET = 340;
    defparam AU4.DELAY = 24'd43945;
    defparam AU4.LFSR_SEED = 16'hBABE;
    
    // ============ ASTEROIDS FROM LEFT (moving right) - 4 asteroids ============
    asteroid_right AR1 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntR1),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_right1_x),
        .VGA_y(ast_right1_y),
        .VGA_color(ast_right1_colour),
        .VGA_write(ast_right1_write),
        .done(ast_right1_done),
        .pos_x(ast_right1_pos_x),
        .pos_y(ast_right1_pos_y)
    );
    defparam AR1.XOFFSET = 20;
    defparam AR1.YOFFSET = 80;
    defparam AR1.DELAY = 24'd53100;
    defparam AR1.LFSR_SEED = 16'hCAFE;
    
    asteroid_right AR2 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntR2),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_right2_x),
        .VGA_y(ast_right2_y),
        .VGA_color(ast_right2_colour),
        .VGA_write(ast_right2_write),
        .done(ast_right2_done),
        .pos_x(ast_right2_pos_x),
        .pos_y(ast_right2_pos_y)
    );
    defparam AR2.XOFFSET = 100;
    defparam AR2.YOFFSET = 200;
    defparam AR2.DELAY = 24'd65918;
    defparam AR2.LFSR_SEED = 16'hFEED;
    
    asteroid_right AR3 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntR3),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_right3_x),
        .VGA_y(ast_right3_y),
        .VGA_color(ast_right3_colour),
        .VGA_write(ast_right3_write),
        .done(ast_right3_done),
        .pos_x(ast_right3_pos_x),
        .pos_y(ast_right3_pos_y)
    );
    defparam AR3.XOFFSET = 60;
    defparam AR3.YOFFSET = 320;
    defparam AR3.DELAY = 24'd49438;
    defparam AR3.LFSR_SEED = 16'hC0DE;
    
    asteroid_right AR4 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntR4),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_right4_x),
        .VGA_y(ast_right4_y),
        .VGA_color(ast_right4_colour),
        .VGA_write(ast_right4_write),
        .done(ast_right4_done),
        .pos_x(ast_right4_pos_x),
        .pos_y(ast_right4_pos_y)
    );
    defparam AR4.XOFFSET = 140;
    defparam AR4.YOFFSET = 420;
    defparam AR4.DELAY = 24'd58594;
    defparam AR4.LFSR_SEED = 16'hF00D;
    
    // ============ ASTEROIDS FROM RIGHT (moving left) - 4 asteroids ============
    asteroid_left AL1 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntL1),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_left1_x),
        .VGA_y(ast_left1_y),
        .VGA_color(ast_left1_colour),
        .VGA_write(ast_left1_write),
        .done(ast_left1_done),
        .pos_x(ast_left1_pos_x),
        .pos_y(ast_left1_pos_y)
    );
    defparam AL1.XOFFSET = 620;
    defparam AL1.YOFFSET = 60;
    defparam AL1.DELAY = 24'd51269;
    defparam AL1.LFSR_SEED = 16'hDEAD;
    
    asteroid_left AL2 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntL2),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_left2_x),
        .VGA_y(ast_left2_y),
        .VGA_color(ast_left2_colour),
        .VGA_write(ast_left2_write),
        .done(ast_left2_done),
        .pos_x(ast_left2_pos_x),
        .pos_y(ast_left2_pos_y)
    );
    defparam AL2.XOFFSET = 540;
    defparam AL2.YOFFSET = 160;
    defparam AL2.DELAY = 24'd64086;
    defparam AL2.LFSR_SEED = 16'hB00B;
    
    asteroid_left AL3 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntL3),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_left3_x),
        .VGA_y(ast_left3_y),
        .VGA_color(ast_left3_colour),
        .VGA_write(ast_left3_write),
        .done(ast_left3_done),
        .pos_x(ast_left3_pos_x),
        .pos_y(ast_left3_pos_y)
    );
    defparam AL3.XOFFSET = 580;
    defparam AL3.YOFFSET = 280;
    defparam AL3.DELAY = 24'd45775;
    defparam AL3.LFSR_SEED = 16'hDADA;
    
    asteroid_left AL4 (
        .Resetn(Resetn),
        .Clock(CLOCK_50),
        .gnt(gntL4),
        .frozen(game_frozen),
        .game_reset(game_reset),
        .VGA_x(ast_left4_x),
        .VGA_y(ast_left4_y),
        .VGA_color(ast_left4_colour),
        .VGA_write(ast_left4_write),
        .done(ast_left4_done),
        .pos_x(ast_left4_pos_x),
        .pos_y(ast_left4_pos_y)
    );
    defparam AL4.XOFFSET = 500;
    defparam AL4.YOFFSET = 400;
    defparam AL4.DELAY = 24'd54931;
    defparam AL4.LFSR_SEED = 16'hABCD;
   
    // VGA Adapter
    vga_adapter VGA (
        .resetn(Resetn),
        .clock(CLOCK_50),
        .color(give_colour),
        .x(give_x),
        .y(give_y),
        .write(give_write),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK));

endmodule

// ============================================================
// ASTEROID MODULES - Each moves in one direction and respawns
// Using initial blocks for FPGA initialization (since Resetn is always 1)
// Using bit selection for random positions covering FULL screen range
// Added frozen input and pos_x/pos_y outputs for collision detection
// ============================================================

// Asteroid moving DOWN (starts at top, respawns at random X when reaching bottom)
module asteroid_down (Resetn, Clock, gnt, frozen, game_reset, VGA_x, VGA_y, VGA_color, VGA_write, done, pos_x, pos_y);
    parameter nX = 10;
    parameter nY = 9;
    parameter XOFFSET = 100;
    parameter YOFFSET = 20;
    parameter asteroid_x = 4;
    parameter asteroid_y = 4;
    parameter BOX_SIZE_X = 1 << asteroid_x;
    parameter BOX_SIZE_Y = 1 << asteroid_y;
    parameter INIT_FILE = "./MIF/circle_16_16_9.mif";
    parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100,
              F = 3'b101, G = 3'b110, H = 3'b111;
    parameter DELAY = 24'd500000;
    parameter Y_MIN = 9'd8;
    parameter Y_MAX = 9'd472;
    parameter LFSR_SEED = 16'hACE1;
    
    input wire Resetn, Clock, gnt, frozen, game_reset;
    output wire [nX-1:0] VGA_x;
    output wire [nY-1:0] VGA_y;
    output wire [8:0] VGA_color;
    output wire VGA_write;
    output reg done;
    output wire [nX-1:0] pos_x;
    output wire [nY-1:0] pos_y;
    
    reg [nX-1:0] X;
    wire [nY-1:0] Y;
    wire [nX-1:0] size_x = BOX_SIZE_X;
    wire [nY-1:0] size_y = BOX_SIZE_Y;
    wire [asteroid_x-1:0] XC;
    wire [asteroid_y-1:0] YC;
    reg write, Lxc, Lyc, Exc, Eyc;
    reg erase;
    reg Lx, Ly, Ex, Ey;
    reg [2:0] y_Q, Y_D;
    wire [8:0] obj_color;
    reg tick;
    reg [23:0] slow_count;
    reg needs_respawn;
    
    // Output position for collision detection
    assign pos_x = X;
    assign pos_y = Y;
    
    // Startup delay - 5 seconds at 50MHz = 250,000,000 cycles
    reg [27:0] startup_count;
    wire startup_done;
    assign startup_done = (startup_count >= 28'd250_000_000);
    
    // LFSR for pseudo-random X position
    reg [15:0] lfsr;
    
    // Random X: Full range 0-639
    wire [9:0] random_x;
    assign random_x = lfsr[9] ? ({2'b00, lfsr[7:0]} + 10'd384) : {1'b0, lfsr[8:0]};
    
    // Y load value: YOFFSET for initial spawn, 0 (top edge) for respawn
    wire [nY-1:0] y_load_value;
    assign y_load_value = needs_respawn ? 9'd0 : YOFFSET;
    
    // FPGA initialization
    initial begin
        lfsr = LFSR_SEED;
        X = XOFFSET;
        slow_count = 24'd0;
        tick = 1'b0;
        needs_respawn = 1'b0;
        y_Q = 3'b0;
        startup_count = 28'd0;
    end
    
    // Startup delay counter (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            startup_count <= 28'd0;
        else if (!startup_done)
            startup_count <= startup_count + 28'd1;
    end
    
    // LFSR - generates pseudo-random numbers (runs continuously)
    always @(posedge Clock)
    begin
        if (game_reset)
            lfsr <= LFSR_SEED;
        else
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3]};
    end
    
    // X position register with random respawn (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            X <= XOFFSET;
        else if (Lx && !frozen)
        begin
            if (needs_respawn)
                X <= random_x;
            else
                X <= XOFFSET;
        end
    end
    
    // Y counter - loads y_load_value (0 for respawn, YOFFSET for initial)
    upDn_count_frozen_reset UY (y_load_value, Clock, Resetn, Ly, Ey, 1'b1, frozen, game_reset, YOFFSET, Y);
        defparam UY.n = nY;
    upDn_count U3 ({asteroid_x{1'd0}}, Clock, Resetn, Lxc, Exc, 1'b1, XC);
        defparam U3.n = asteroid_x;
    upDn_count U4 ({asteroid_y{1'd0}}, Clock, Resetn, Lyc, Eyc, 1'b1, YC);
        defparam U4.n = asteroid_y;
    
    // Timing logic - only active after startup delay, stops when frozen, resets on game_reset
    always @(posedge Clock)
    begin
        if (game_reset)
        begin
            slow_count <= 24'd0;
            tick <= 1'b0;
        end
        else if (!startup_done || frozen)
        begin
            if (!startup_done)
                slow_count <= 24'd0;
            tick <= 1'b0;
        end
        else if (slow_count >= DELAY)
        begin
            slow_count <= 24'd0;
            tick <= 1'b1;
        end
        else
        begin
            slow_count <= slow_count + 24'd1;
            tick <= 1'b0;
        end
    end
    
    // Latched respawn flag (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            needs_respawn <= 1'b0;
        else if (!frozen)
        begin
            if (y_Q == E && gnt && needs_respawn)
                needs_respawn <= 1'b0;
            else if (Y >= Y_MAX)
                needs_respawn <= 1'b1;
        end
    end
    
    // State machine
    always @(*)
        case (y_Q)
            A:  if (startup_done) Y_D = B;
                else Y_D = A;
            B:  if (gnt && tick) Y_D = C;
                else Y_D = B;
            C:  if (gnt && XC != size_x-1) Y_D = C;
                else if (gnt) Y_D = D;
                else Y_D = C;
            D:  if (gnt && YC != size_y-1) Y_D = C;
                else if (gnt) Y_D = E;
                else Y_D = D;
            E:  if (gnt) Y_D = F;
                else Y_D = E;
            F:  if (gnt && XC != size_x-1) Y_D = F;
                else if (gnt) Y_D = G;
                else Y_D = F;
            G:  if (gnt && YC != size_y-1) Y_D = F;
                else if (gnt) Y_D = H;
                else Y_D = G;
            H:  if (gnt) Y_D = B;
                else Y_D = H;
            default: Y_D = A;
        endcase
    
    // Control signals
    always @(*)
    begin
        Lx = 1'b0; Ly = 1'b0; Ex = 1'b0; Ey = 1'b0; write = 1'b0;
        Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0; erase = 1'b0; done = 1'b0;
        
        case (y_Q)
            A:  begin Lx = 1'b1; Ly = 1'b1; end
            B:  begin Lxc = 1'b1; Lyc = 1'b1; end
            C:  if (gnt) begin Exc = 1'b1; write = 1'b1; erase = 1'b1; end
            D:  if (gnt) begin Lxc = 1'b1; Eyc = 1'b1; erase = 1'b1; end
            E:  if (gnt) begin 
                    if (needs_respawn) begin Ly = 1'b1; Lx = 1'b1; end
                    else Ey = 1'b1;
                end
            F:  if (gnt) begin Exc = 1'b1; write = 1'b1; end
            G:  if (gnt) begin Lxc = 1'b1; Eyc = 1'b1; end
            H:  if (gnt) done = 1'b1;
        endcase
    end
    
    always @(posedge Clock)
        if (game_reset)
            y_Q <= A;
        else
            y_Q <= Y_D;
    
    object_mem U6 ({YC,XC}, Clock, obj_color);
        defparam U6.n = 9;
        defparam U6.Mn = asteroid_x + asteroid_y;
        defparam U6.INIT_FILE = INIT_FILE;
    
    regn U7 (X - (size_x >> 1) + XC, Resetn, 1'b1, Clock, VGA_x);
        defparam U7.n = nX;
    regn U8 (Y - (size_y >> 1) + YC, Resetn, 1'b1, Clock, VGA_y);
        defparam U8.n = nY;
    regn U9 (write, Resetn, 1'b1, Clock, VGA_write);
        defparam U9.n = 1;
    
    assign VGA_color = erase ? 9'b000000000 : obj_color;
endmodule

// Asteroid moving UP (starts at bottom, respawns at random X when reaching top)
module asteroid_up (Resetn, Clock, gnt, frozen, game_reset, VGA_x, VGA_y, VGA_color, VGA_write, done, pos_x, pos_y);
    parameter nX = 10;
    parameter nY = 9;
    parameter XOFFSET = 100;
    parameter YOFFSET = 460;
    parameter asteroid_x = 4;
    parameter asteroid_y = 4;
    parameter BOX_SIZE_X = 1 << asteroid_x;
    parameter BOX_SIZE_Y = 1 << asteroid_y;
    parameter INIT_FILE = "./MIF/circle_16_16_9.mif";
    parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100,
              F = 3'b101, G = 3'b110, H = 3'b111;
    parameter DELAY = 24'd500000;
    parameter Y_MIN = 9'd8;
    parameter Y_MAX = 9'd472;
    parameter LFSR_SEED = 16'hBEEF;
    
    input wire Resetn, Clock, gnt, frozen, game_reset;
    output wire [nX-1:0] VGA_x;
    output wire [nY-1:0] VGA_y;
    output wire [8:0] VGA_color;
    output wire VGA_write;
    output reg done;
    output wire [nX-1:0] pos_x;
    output wire [nY-1:0] pos_y;
    
    reg [nX-1:0] X;
    wire [nY-1:0] Y;
    wire [nX-1:0] size_x = BOX_SIZE_X;
    wire [nY-1:0] size_y = BOX_SIZE_Y;
    wire [asteroid_x-1:0] XC;
    wire [asteroid_y-1:0] YC;
    reg write, Lxc, Lyc, Exc, Eyc;
    reg erase;
    reg Lx, Ly, Ex, Ey;
    reg [2:0] y_Q, Y_D;
    wire [8:0] obj_color;
    reg tick;
    reg [23:0] slow_count;
    reg needs_respawn;
    
    // Output position for collision detection
    assign pos_x = X;
    assign pos_y = Y;
    
    // Startup delay - 5 seconds at 50MHz = 250,000,000 cycles
    reg [27:0] startup_count;
    wire startup_done;
    assign startup_done = (startup_count >= 28'd250_000_000);
    
    // LFSR for pseudo-random X position
    reg [15:0] lfsr;
    
    // Random X: Full range 0-639
    wire [9:0] random_x;
    assign random_x = lfsr[9] ? ({2'b00, lfsr[7:0]} + 10'd384) : {1'b0, lfsr[8:0]};
    
    // Y load value: YOFFSET for initial spawn, 479 (bottom edge) for respawn
    wire [nY-1:0] y_load_value;
    assign y_load_value = needs_respawn ? 9'd479 : YOFFSET;
    
    // FPGA initialization
    initial begin
        lfsr = LFSR_SEED;
        X = XOFFSET;
        slow_count = 24'd0;
        tick = 1'b0;
        needs_respawn = 1'b0;
        y_Q = 3'b0;
        startup_count = 28'd0;
    end
    
    // Startup delay counter (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            startup_count <= 28'd0;
        else if (!startup_done)
            startup_count <= startup_count + 28'd1;
    end
    
    // LFSR
    always @(posedge Clock)
    begin
        if (game_reset)
            lfsr <= LFSR_SEED;
        else
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3]};
    end
    
    // X position register (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            X <= XOFFSET;
        else if (Lx && !frozen)
        begin
            if (needs_respawn)
                X <= random_x;
            else
                X <= XOFFSET;
        end
    end
    
    // Y counter - moving UP (decrementing), loads y_load_value (479 for respawn)
    upDn_count_frozen_reset UY (y_load_value, Clock, Resetn, Ly, Ey, 1'b0, frozen, game_reset, YOFFSET, Y);
        defparam UY.n = nY;
    upDn_count U3 ({asteroid_x{1'd0}}, Clock, Resetn, Lxc, Exc, 1'b1, XC);
        defparam U3.n = asteroid_x;
    upDn_count U4 ({asteroid_y{1'd0}}, Clock, Resetn, Lyc, Eyc, 1'b1, YC);
        defparam U4.n = asteroid_y;
    
    // Timing logic - only active after startup delay, stops when frozen, resets on game_reset
    always @(posedge Clock)
    begin
        if (game_reset)
        begin
            slow_count <= 24'd0;
            tick <= 1'b0;
        end
        else if (!startup_done || frozen)
        begin
            if (!startup_done)
                slow_count <= 24'd0;
            tick <= 1'b0;
        end
        else if (slow_count >= DELAY)
        begin
            slow_count <= 24'd0;
            tick <= 1'b1;
        end
        else
        begin
            slow_count <= slow_count + 24'd1;
            tick <= 1'b0;
        end
    end
    
    // Latched respawn flag (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            needs_respawn <= 1'b0;
        else if (!frozen)
        begin
            if (y_Q == E && gnt && needs_respawn)
                needs_respawn <= 1'b0;
            else if (Y <= Y_MIN)
                needs_respawn <= 1'b1;
        end
    end
    
    // State machine
    always @(*)
        case (y_Q)
            A:  if (startup_done) Y_D = B;
                else Y_D = A;
            B:  if (gnt && tick) Y_D = C;
                else Y_D = B;
            C:  if (gnt && XC != size_x-1) Y_D = C;
                else if (gnt) Y_D = D;
                else Y_D = C;
            D:  if (gnt && YC != size_y-1) Y_D = C;
                else if (gnt) Y_D = E;
                else Y_D = D;
            E:  if (gnt) Y_D = F;
                else Y_D = E;
            F:  if (gnt && XC != size_x-1) Y_D = F;
                else if (gnt) Y_D = G;
                else Y_D = F;
            G:  if (gnt && YC != size_y-1) Y_D = F;
                else if (gnt) Y_D = H;
                else Y_D = G;
            H:  if (gnt) Y_D = B;
                else Y_D = H;
            default: Y_D = A;
        endcase
    
    // Control signals
    always @(*)
    begin
        Lx = 1'b0; Ly = 1'b0; Ex = 1'b0; Ey = 1'b0; write = 1'b0;
        Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0; erase = 1'b0; done = 1'b0;
        
        case (y_Q)
            A:  begin Lx = 1'b1; Ly = 1'b1; end
            B:  begin Lxc = 1'b1; Lyc = 1'b1; end
            C:  if (gnt) begin Exc = 1'b1; write = 1'b1; erase = 1'b1; end
            D:  if (gnt) begin Lxc = 1'b1; Eyc = 1'b1; erase = 1'b1; end
            E:  if (gnt) begin 
                    if (needs_respawn) begin Ly = 1'b1; Lx = 1'b1; end
                    else Ey = 1'b1;
                end
            F:  if (gnt) begin Exc = 1'b1; write = 1'b1; end
            G:  if (gnt) begin Lxc = 1'b1; Eyc = 1'b1; end
            H:  if (gnt) done = 1'b1;
        endcase
    end
    
    always @(posedge Clock)
        if (game_reset)
            y_Q <= A;
        else
            y_Q <= Y_D;
    
    object_mem U6 ({YC,XC}, Clock, obj_color);
        defparam U6.n = 9;
        defparam U6.Mn = asteroid_x + asteroid_y;
        defparam U6.INIT_FILE = INIT_FILE;
    
    regn U7 (X - (size_x >> 1) + XC, Resetn, 1'b1, Clock, VGA_x);
        defparam U7.n = nX;
    regn U8 (Y - (size_y >> 1) + YC, Resetn, 1'b1, Clock, VGA_y);
        defparam U8.n = nY;
    regn U9 (write, Resetn, 1'b1, Clock, VGA_write);
        defparam U9.n = 1;
    
    assign VGA_color = erase ? 9'b000000000 : obj_color;
endmodule

// Asteroid moving RIGHT (starts at left, respawns at random Y when reaching right)
module asteroid_right (Resetn, Clock, gnt, frozen, game_reset, VGA_x, VGA_y, VGA_color, VGA_write, done, pos_x, pos_y);
    parameter nX = 10;
    parameter nY = 9;
    parameter XOFFSET = 20;
    parameter YOFFSET = 100;
    parameter asteroid_x = 4;
    parameter asteroid_y = 4;
    parameter BOX_SIZE_X = 1 << asteroid_x;
    parameter BOX_SIZE_Y = 1 << asteroid_y;
    parameter INIT_FILE = "./MIF/circle_16_16_9.mif";
    parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100,
              F = 3'b101, G = 3'b110, H = 3'b111;
    parameter DELAY = 24'd500000;
    parameter X_MIN = 10'd8;
    parameter X_MAX = 10'd632;
    parameter LFSR_SEED = 16'hCAFE;
    
    input wire Resetn, Clock, gnt, frozen, game_reset;
    output wire [nX-1:0] VGA_x;
    output wire [nY-1:0] VGA_y;
    output wire [8:0] VGA_color;
    output wire VGA_write;
    output reg done;
    output wire [nX-1:0] pos_x;
    output wire [nY-1:0] pos_y;
    
    wire [nX-1:0] X;
    reg [nY-1:0] Y;
    wire [nX-1:0] size_x = BOX_SIZE_X;
    wire [nY-1:0] size_y = BOX_SIZE_Y;
    wire [asteroid_x-1:0] XC;
    wire [asteroid_y-1:0] YC;
    reg write, Lxc, Lyc, Exc, Eyc;
    reg erase;
    reg Lx, Ly, Ex, Ey;
    reg [2:0] y_Q, Y_D;
    wire [8:0] obj_color;
    reg tick;
    reg [23:0] slow_count;
    reg needs_respawn;
    
    // Output position for collision detection
    assign pos_x = X;
    assign pos_y = Y;
    
    // Startup delay - 5 seconds at 50MHz = 250,000,000 cycles
    reg [27:0] startup_count;
    wire startup_done;
    assign startup_done = (startup_count >= 28'd250_000_000);
    
    // LFSR for pseudo-random Y position
    reg [15:0] lfsr;
    
    // Random Y: Full range 0-479
    wire [8:0] random_y;
    assign random_y = lfsr[8] ? ({1'b0, lfsr[7:0]} + 9'd224) : {1'b0, lfsr[7:0]};
    
    // X load value: XOFFSET for initial spawn, 0 (left edge) for respawn
    wire [nX-1:0] x_load_value;
    assign x_load_value = needs_respawn ? 10'd0 : XOFFSET;
    
    // FPGA initialization
    initial begin
        lfsr = LFSR_SEED;
        Y = YOFFSET;
        slow_count = 24'd0;
        tick = 1'b0;
        needs_respawn = 1'b0;
        y_Q = 3'b0;
        startup_count = 28'd0;
    end
    
    // Startup delay counter (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            startup_count <= 28'd0;
        else if (!startup_done)
            startup_count <= startup_count + 28'd1;
    end
    
    // LFSR
    always @(posedge Clock)
    begin
        if (game_reset)
            lfsr <= LFSR_SEED;
        else
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3]};
    end
    
    // Y position register (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            Y <= YOFFSET;
        else if (Ly && !frozen)
        begin
            if (needs_respawn)
                Y <= random_y;
            else
                Y <= YOFFSET;
        end
    end
    
    // X counter - moving RIGHT (incrementing), loads x_load_value (0 for respawn)
    upDn_count_frozen_reset UX (x_load_value, Clock, Resetn, Lx, Ex, 1'b1, frozen, game_reset, XOFFSET, X);
        defparam UX.n = nX;
    upDn_count U3 ({asteroid_x{1'd0}}, Clock, Resetn, Lxc, Exc, 1'b1, XC);
        defparam U3.n = asteroid_x;
    upDn_count U4 ({asteroid_y{1'd0}}, Clock, Resetn, Lyc, Eyc, 1'b1, YC);
        defparam U4.n = asteroid_y;
    
    // Timing logic - only active after startup delay, stops when frozen, resets on game_reset
    always @(posedge Clock)
    begin
        if (game_reset)
        begin
            slow_count <= 24'd0;
            tick <= 1'b0;
        end
        else if (!startup_done || frozen)
        begin
            if (!startup_done)
                slow_count <= 24'd0;
            tick <= 1'b0;
        end
        else if (slow_count >= DELAY)
        begin
            slow_count <= 24'd0;
            tick <= 1'b1;
        end
        else
        begin
            slow_count <= slow_count + 24'd1;
            tick <= 1'b0;
        end
    end
    
    // Latched respawn flag (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            needs_respawn <= 1'b0;
        else if (!frozen)
        begin
            if (y_Q == E && gnt && needs_respawn)
                needs_respawn <= 1'b0;
            else if (X >= X_MAX)
                needs_respawn <= 1'b1;
        end
    end
    
    // State machine
    always @(*)
        case (y_Q)
            A:  if (startup_done) Y_D = B;
                else Y_D = A;
            B:  if (gnt && tick) Y_D = C;
                else Y_D = B;
            C:  if (gnt && XC != size_x-1) Y_D = C;
                else if (gnt) Y_D = D;
                else Y_D = C;
            D:  if (gnt && YC != size_y-1) Y_D = C;
                else if (gnt) Y_D = E;
                else Y_D = D;
            E:  if (gnt) Y_D = F;
                else Y_D = E;
            F:  if (gnt && XC != size_x-1) Y_D = F;
                else if (gnt) Y_D = G;
                else Y_D = F;
            G:  if (gnt && YC != size_y-1) Y_D = F;
                else if (gnt) Y_D = H;
                else Y_D = G;
            H:  if (gnt) Y_D = B;
                else Y_D = H;
            default: Y_D = A;
        endcase
    
    // Control signals
    always @(*)
    begin
        Lx = 1'b0; Ly = 1'b0; Ex = 1'b0; Ey = 1'b0; write = 1'b0;
        Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0; erase = 1'b0; done = 1'b0;
        
        case (y_Q)
            A:  begin Lx = 1'b1; Ly = 1'b1; end
            B:  begin Lxc = 1'b1; Lyc = 1'b1; end
            C:  if (gnt) begin Exc = 1'b1; write = 1'b1; erase = 1'b1; end
            D:  if (gnt) begin Lxc = 1'b1; Eyc = 1'b1; erase = 1'b1; end
            E:  if (gnt) begin 
                    if (needs_respawn) begin Lx = 1'b1; Ly = 1'b1; end
                    else Ex = 1'b1;
                end
            F:  if (gnt) begin Exc = 1'b1; write = 1'b1; end
            G:  if (gnt) begin Lxc = 1'b1; Eyc = 1'b1; end
            H:  if (gnt) done = 1'b1;
        endcase
    end
    
    always @(posedge Clock)
        if (game_reset)
            y_Q <= A;
        else
            y_Q <= Y_D;
    
    object_mem U6 ({YC,XC}, Clock, obj_color);
        defparam U6.n = 9;
        defparam U6.Mn = asteroid_x + asteroid_y;
        defparam U6.INIT_FILE = INIT_FILE;
    
    regn U7 (X - (size_x >> 1) + XC, Resetn, 1'b1, Clock, VGA_x);
        defparam U7.n = nX;
    regn U8 (Y - (size_y >> 1) + YC, Resetn, 1'b1, Clock, VGA_y);
        defparam U8.n = nY;
    regn U9 (write, Resetn, 1'b1, Clock, VGA_write);
        defparam U9.n = 1;
    
    assign VGA_color = erase ? 9'b000000000 : obj_color;
endmodule

// Asteroid moving LEFT (starts at right, respawns at random Y when reaching left)
module asteroid_left (Resetn, Clock, gnt, frozen, game_reset, VGA_x, VGA_y, VGA_color, VGA_write, done, pos_x, pos_y);
    parameter nX = 10;
    parameter nY = 9;
    parameter XOFFSET = 620;
    parameter YOFFSET = 100;
    parameter asteroid_x = 4;
    parameter asteroid_y = 4;
    parameter BOX_SIZE_X = 1 << asteroid_x;
    parameter BOX_SIZE_Y = 1 << asteroid_y;
    parameter INIT_FILE = "./MIF/circle_16_16_9.mif";
    parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100,
              F = 3'b101, G = 3'b110, H = 3'b111;
    parameter DELAY = 24'd500000;
    parameter X_MIN = 10'd8;
    parameter X_MAX = 10'd632;
    parameter LFSR_SEED = 16'hDEAD;
    
    input wire Resetn, Clock, gnt, frozen, game_reset;
    output wire [nX-1:0] VGA_x;
    output wire [nY-1:0] VGA_y;
    output wire [8:0] VGA_color;
    output wire VGA_write;
    output reg done;
    output wire [nX-1:0] pos_x;
    output wire [nY-1:0] pos_y;
    
    wire [nX-1:0] X;
    reg [nY-1:0] Y;
    wire [nX-1:0] size_x = BOX_SIZE_X;
    wire [nY-1:0] size_y = BOX_SIZE_Y;
    wire [asteroid_x-1:0] XC;
    wire [asteroid_y-1:0] YC;
    reg write, Lxc, Lyc, Exc, Eyc;
    reg erase;
    reg Lx, Ly, Ex, Ey;
    reg [2:0] y_Q, Y_D;
    wire [8:0] obj_color;
    reg tick;
    reg [23:0] slow_count;
    reg needs_respawn;
    
    // Output position for collision detection
    assign pos_x = X;
    assign pos_y = Y;
    
    // Startup delay - 5 seconds at 50MHz = 250,000,000 cycles
    reg [27:0] startup_count;
    wire startup_done;
    assign startup_done = (startup_count >= 28'd250_000_000);
    
    // LFSR for pseudo-random Y position
    reg [15:0] lfsr;
    
    // Random Y: Full range 0-479
    wire [8:0] random_y;
    assign random_y = lfsr[8] ? ({1'b0, lfsr[7:0]} + 9'd224) : {1'b0, lfsr[7:0]};
    
    // X load value: XOFFSET for initial spawn, 639 (right edge) for respawn
    wire [nX-1:0] x_load_value;
    assign x_load_value = needs_respawn ? 10'd639 : XOFFSET;
    
    // FPGA initialization
    initial begin
        lfsr = LFSR_SEED;
        Y = YOFFSET;
        slow_count = 24'd0;
        tick = 1'b0;
        needs_respawn = 1'b0;
        y_Q = 3'b0;
        startup_count = 28'd0;
    end
    
    // Startup delay counter (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            startup_count <= 28'd0;
        else if (!startup_done)
            startup_count <= startup_count + 28'd1;
    end
    
    // LFSR
    always @(posedge Clock)
    begin
        if (game_reset)
            lfsr <= LFSR_SEED;
        else
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3]};
    end
    
    // Y position register (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            Y <= YOFFSET;
        else if (Ly && !frozen)
        begin
            if (needs_respawn)
                Y <= random_y;
            else
                Y <= YOFFSET;
        end
    end
    
    // X counter - moving LEFT (decrementing), loads x_load_value (639 for respawn)
    upDn_count_frozen_reset UX (x_load_value, Clock, Resetn, Lx, Ex, 1'b0, frozen, game_reset, XOFFSET, X);
        defparam UX.n = nX;
    upDn_count U3 ({asteroid_x{1'd0}}, Clock, Resetn, Lxc, Exc, 1'b1, XC);
        defparam U3.n = asteroid_x;
    upDn_count U4 ({asteroid_y{1'd0}}, Clock, Resetn, Lyc, Eyc, 1'b1, YC);
        defparam U4.n = asteroid_y;
    
    // Timing logic - only active after startup delay, stops when frozen, resets on game_reset
    always @(posedge Clock)
    begin
        if (game_reset)
        begin
            slow_count <= 24'd0;
            tick <= 1'b0;
        end
        else if (!startup_done || frozen)
        begin
            if (!startup_done)
                slow_count <= 24'd0;
            tick <= 1'b0;
        end
        else if (slow_count >= DELAY)
        begin
            slow_count <= 24'd0;
            tick <= 1'b1;
        end
        else
        begin
            slow_count <= slow_count + 24'd1;
            tick <= 1'b0;
        end
    end
    
    // Latched respawn flag (resets on game_reset)
    always @(posedge Clock)
    begin
        if (game_reset)
            needs_respawn <= 1'b0;
        else if (!frozen)
        begin
            if (y_Q == E && gnt && needs_respawn)
                needs_respawn <= 1'b0;
            else if (X <= X_MIN)
                needs_respawn <= 1'b1;
        end
    end
    
    // State machine
    always @(*)
        case (y_Q)
            A:  if (startup_done) Y_D = B;
                else Y_D = A;
            B:  if (gnt && tick) Y_D = C;
                else Y_D = B;
            C:  if (gnt && XC != size_x-1) Y_D = C;
                else if (gnt) Y_D = D;
                else Y_D = C;
            D:  if (gnt && YC != size_y-1) Y_D = C;
                else if (gnt) Y_D = E;
                else Y_D = D;
            E:  if (gnt) Y_D = F;
                else Y_D = E;
            F:  if (gnt && XC != size_x-1) Y_D = F;
                else if (gnt) Y_D = G;
                else Y_D = F;
            G:  if (gnt && YC != size_y-1) Y_D = F;
                else if (gnt) Y_D = H;
                else Y_D = G;
            H:  if (gnt) Y_D = B;
                else Y_D = H;
            default: Y_D = A;
        endcase
    
    // Control signals
    always @(*)
    begin
        Lx = 1'b0; Ly = 1'b0; Ex = 1'b0; Ey = 1'b0; write = 1'b0;
        Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0; erase = 1'b0; done = 1'b0;
        
        case (y_Q)
            A:  begin Lx = 1'b1; Ly = 1'b1; end
            B:  begin Lxc = 1'b1; Lyc = 1'b1; end
            C:  if (gnt) begin Exc = 1'b1; write = 1'b1; erase = 1'b1; end
            D:  if (gnt) begin Lxc = 1'b1; Eyc = 1'b1; erase = 1'b1; end
            E:  if (gnt) begin 
                    if (needs_respawn) begin Lx = 1'b1; Ly = 1'b1; end
                    else Ex = 1'b1;
                end
            F:  if (gnt) begin Exc = 1'b1; write = 1'b1; end
            G:  if (gnt) begin Lxc = 1'b1; Eyc = 1'b1; end
            H:  if (gnt) done = 1'b1;
        endcase
    end
    
    always @(posedge Clock)
        if (game_reset)
            y_Q <= A;
        else
            y_Q <= Y_D;
    
    object_mem U6 ({YC,XC}, Clock, obj_color);
        defparam U6.n = 9;
        defparam U6.Mn = asteroid_x + asteroid_y;
        defparam U6.INIT_FILE = INIT_FILE;
    
    regn U7 (X - (size_x >> 1) + XC, Resetn, 1'b1, Clock, VGA_x);
        defparam U7.n = nX;
    regn U8 (Y - (size_y >> 1) + YC, Resetn, 1'b1, Clock, VGA_y);
        defparam U8.n = nY;
    regn U9 (write, Resetn, 1'b1, Clock, VGA_write);
        defparam U9.n = 1;
    
    assign VGA_color = erase ? 9'b000000000 : obj_color;
endmodule

// ============================================================
// HELPER MODULES
// ============================================================

// Synchronizer module
module sync (D, Resetn, Clock, Q);
    input wire D, Resetn, Clock;
    output reg Q;
    reg Qi;
    
    always @(posedge Clock)
        if (Resetn == 0)
        begin
            Qi <= 1'b0;
            Q <= 1'b0;
        end
        else
        begin
            Qi <= D;
            Q <= Qi;
        end
endmodule

// Register module
module regn (R, Reset, enable, clk, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire clk, enable, Reset;
    output reg [n-1:0] Q;
    
    always @(posedge clk)
        if (!Reset)
            Q <= 0;
        else if (enable)
            Q <= R;
endmodule

// Up/down counter with step size
module upDn_count_step (R, Clock, Resetn, L, E, Dir, Step, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Clock, Resetn, E, L, Dir;
    input wire [n-1:0] Step;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (Resetn == 0)
            Q <= {n{1'b0}};
        else if (L == 1)
            Q <= R;
        else if (E)
            if (Dir)
                Q <= Q + Step;
            else
                Q <= Q - Step;
endmodule

// Up/down counter with step size and frozen input
module upDn_count_step_frozen (R, Clock, Resetn, L, E, Dir, Step, frozen, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Clock, Resetn, E, L, Dir, frozen;
    input wire [n-1:0] Step;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (Resetn == 0)
            Q <= {n{1'b0}};
        else if (L == 1 && !frozen)
            Q <= R;
        else if (E && !frozen)
            if (Dir)
                Q <= Q + Step;
            else
                Q <= Q - Step;
endmodule

// Up/down counter (increment by 1)
module upDn_count (R, Clock, Resetn, L, E, Dir, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Clock, Resetn, E, L, Dir;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (Resetn == 0)
            Q <= {n{1'b0}};
        else if (L == 1)
            Q <= R;
        else if (E)
            if (Dir)
                Q <= Q + {{n-1{1'b0}},1'b1};
            else
                Q <= Q - {{n-1{1'b0}},1'b1};
endmodule

// Up/down counter with frozen input (for asteroids)
module upDn_count_frozen (R, Clock, Resetn, L, E, Dir, frozen, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Clock, Resetn, E, L, Dir, frozen;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (Resetn == 0)
            Q <= {n{1'b0}};
        else if (L == 1 && !frozen)
            Q <= R;
        else if (E && !frozen)
            if (Dir)
                Q <= Q + {{n-1{1'b0}},1'b1};
            else
                Q <= Q - {{n-1{1'b0}},1'b1};
endmodule

// Up/down counter with frozen and game_reset inputs (for asteroids)
module upDn_count_frozen_reset (R, Clock, Resetn, L, E, Dir, frozen, game_reset, reset_val, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire [n-1:0] reset_val;
    input wire Clock, Resetn, E, L, Dir, frozen, game_reset;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (Resetn == 0)
            Q <= {n{1'b0}};
        else if (game_reset)
            Q <= reset_val;
        else if (L == 1 && !frozen)
            Q <= R;
        else if (E && !frozen)
            if (Dir)
                Q <= Q + {{n-1{1'b0}},1'b1};
            else
                Q <= Q - {{n-1{1'b0}},1'b1};
endmodule

// Ship module with rotation - controlled by WASD
module ship (Resetn, Clock, ps2_rec, key_W, key_A, key_S, key_D, 
             VGA_x, VGA_y, VGA_color, VGA_write, done, reset, frozen, pos_x, pos_y);
    parameter nX = 10;
    parameter nY = 9;
    parameter XOFFSET = 320;
    parameter YOFFSET = 240;
    parameter ship_x = 4, ship_y = 4;
    parameter BOX_SIZE_X = 1 << ship_x;
    parameter BOX_SIZE_Y = 1 << ship_y;
    parameter Mn = ship_x + ship_y;
    parameter STEP = 16;
    parameter X_MIN = 10'd16; 
    parameter X_MAX = 10'd624;
    parameter Y_MIN = 9'd16;  
    parameter Y_MAX = 9'd464; 
    
    parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100,
              F = 3'b101, G = 3'b110, H = 3'b111;
    
    parameter DIR_UP = 2'b00, DIR_RIGHT = 2'b01, DIR_DOWN = 2'b10, DIR_LEFT = 2'b11;
           
    input wire Resetn, reset, Clock, ps2_rec, frozen;
    input wire key_W, key_A, key_S, key_D;
    output wire [nX-1:0] VGA_x;              
    output wire [nY-1:0] VGA_y;              
    output wire [8:0] VGA_color;              
    output wire VGA_write;                  
    output reg done;
    output wire [nX-1:0] pos_x;
    output wire [nY-1:0] pos_y;

    wire [nX-1:0] X, X0;
    wire [nY-1:0] Y, Y0;
    wire [nX-1:0] size_x = BOX_SIZE_X;
    wire [nY-1:0] size_y = BOX_SIZE_Y;
    wire [ship_x-1:0] XC;
    wire [ship_y-1:0] YC;
    reg write, Lxc, Lyc, Exc, Eyc;
    reg erase;
    reg Lx, Ly, Ex, Ey;
    reg move_x_en, move_y_en;
    reg [2:0] y_Q, Y_D;
    
    reg [1:0] direction;
    reg move_up, move_down, move_left, move_right;
    
    wire [8:0] color_up, color_right, color_down, color_left;
    reg [8:0] obj_color;

    wire [nX-1:0] x_step = STEP;
    wire [nY-1:0] y_step = STEP;
    assign X0 = XOFFSET;
    assign Y0 = YOFFSET;
    
    // Output position for collision detection
    assign pos_x = X;
    assign pos_y = Y;
    
    always @(posedge Clock)
    begin
        if (!Resetn || reset)
            direction <= DIR_UP;
        else if (ps2_rec && y_Q == B && !frozen)
        begin
            if (key_D)
                direction <= direction + 2'b01;
            else if (key_A)
                direction <= direction - 2'b01;
        end
    end
    
    always @(*)
    begin
        move_up = 1'b0;
        move_down = 1'b0;
        move_left = 1'b0;
        move_right = 1'b0;
        
        if (key_W && !frozen)
        begin
            case (direction)
                DIR_UP:    move_up = 1'b1;
                DIR_RIGHT: move_right = 1'b1;
                DIR_DOWN:  move_down = 1'b1;
                DIR_LEFT:  move_left = 1'b1;
            endcase
        end
        else if (key_S && !frozen)
        begin
            case (direction)
                DIR_UP:    move_down = 1'b1;
                DIR_RIGHT: move_left = 1'b1;
                DIR_DOWN:  move_up = 1'b1;
                DIR_LEFT:  move_right = 1'b1;
            endcase
        end
    end
    
    always @(*)
    begin
        if (move_right && (X + x_step > X_MAX))
            move_x_en = 1'b0;
        else if (move_left && (X < X_MIN + x_step))
            move_x_en = 1'b0;
        else
            move_x_en = 1'b1;
        
        if (move_down && (Y + y_step > Y_MAX))
            move_y_en = 1'b0;
        else if (move_up && (Y < Y_MIN + y_step))
            move_y_en = 1'b0;
        else
            move_y_en = 1'b1;
    end
    
    upDn_count_step_frozen UX (X0, Clock, (Resetn & ~reset), Lx, Ex & move_x_en, move_right, x_step, frozen, X);
        defparam UX.n = nX;
    upDn_count_step_frozen UY (Y0, Clock, (Resetn & ~reset), Ly, Ey & move_y_en, move_down, y_step, frozen, Y);
        defparam UY.n = nY;

    upDn_count U3 ({ship_x{1'd0}}, Clock, Resetn, Lxc, Exc, 1'b1, XC);
        defparam U3.n = ship_x;
    upDn_count U4 ({ship_y{1'd0}}, Clock, Resetn, Lyc, Eyc, 1'b1, YC);
        defparam U4.n = ship_y;

    always @(*)
        case (y_Q)
            A:   Y_D = B;
            B:  if (ps2_rec) Y_D = C;
                else Y_D = B;
            C:  if (XC != size_x-1) Y_D = C;
                else Y_D = D;
            D:  if (YC != size_y-1) Y_D = C;
                else Y_D = E;
            E:  Y_D = F;
            F:  if (XC != size_x-1) Y_D = F;
                else Y_D = G;
            G:  if (YC != size_y-1) Y_D = F;
                else Y_D = H;
            H:  Y_D = B;
            default: Y_D = A;
        endcase
       
    always @(*)
    begin
        Lx = 1'b0; Ly = 1'b0; Ex = 1'b0; Ey = 1'b0; write = 1'b0;
        Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0; erase = 1'b0; done = 1'b0;
        if (reset)
        begin
            Lx = 1'b1;
            Ly = 1'b1;
            erase = 1'b1;
        end
        else
        begin
            case (y_Q)
                A:  begin Lx = 1'b1; Ly = 1'b1; end
                B:  begin Lxc = 1'b1; Lyc = 1'b1; end
                C:  begin Exc = 1'b1; write = 1'b1; erase = 1'b1; end
                D:  begin Lxc = 1'b1; Eyc = 1'b1; erase = 1'b1; end
                E:  begin Ex = move_left | move_right; Ey = move_up | move_down; end
                F:  begin Exc = 1'b1; write = 1'b1; end
                G:  begin Lxc = 1'b1; Eyc = 1'b1; end
                H:  done = 1'b1;
            endcase
        end
    end

    always @(posedge Clock)
    begin
        if (!Resetn || reset)
            y_Q <= 3'b0;
        else
            y_Q <= Y_D;
    end

    object_mem mem_up ({YC,XC}, Clock, color_up);
        defparam mem_up.n = 9;
        defparam mem_up.Mn = ship_x + ship_y;
        defparam mem_up.INIT_FILE = "./MIF/object_mem_16_16_9.mif";
    
    object_mem mem_right ({YC,XC}, Clock, color_right);
        defparam mem_right.n = 9;
        defparam mem_right.Mn = ship_x + ship_y;
        defparam mem_right.INIT_FILE = "./MIF/rotated_90_right.mif";
    
    object_mem mem_down ({YC,XC}, Clock, color_down);
        defparam mem_down.n = 9;
        defparam mem_down.Mn = ship_x + ship_y;
        defparam mem_down.INIT_FILE = "./MIF/rotated_180_degrees.mif";
    
    object_mem mem_left ({YC,XC}, Clock, color_left);
        defparam mem_left.n = 9;
        defparam mem_left.Mn = ship_x + ship_y;
        defparam mem_left.INIT_FILE = "./MIF/rotated_270_degrees.mif";
    
    always @(*)
    begin
        case (direction)
            DIR_UP:    obj_color = color_up;
            DIR_RIGHT: obj_color = color_right;
            DIR_DOWN:  obj_color = color_down;
            DIR_LEFT:  obj_color = color_left;
            default:   obj_color = color_up;
        endcase
    end

    regn U7 (X - (size_x >> 1) + XC, Resetn, 1'b1, Clock, VGA_x);
        defparam U7.n = nX;
    regn U8 (Y - (size_y >> 1) + YC, Resetn, 1'b1, Clock, VGA_y);
        defparam U8.n = nY;

    regn U9 (write, Resetn, 1'b1, Clock, VGA_write);
        defparam U9.n = 1;

    assign VGA_color = erase ? {9{1'b0}} : obj_color;
endmodule

// ============================================================
// SCREEN CLEAR MODULE
// Clears the entire 640x480 screen to black
// ============================================================
module screen_clear (Clock, start, x, y, write, active, done);
    parameter nX = 10;
    parameter nY = 9;
    parameter X_MAX = 640;
    parameter Y_MAX = 480;
    
    input wire Clock;
    input wire start;
    output reg [nX-1:0] x;
    output reg [nY-1:0] y;
    output reg write;
    output reg active;
    output reg done;
    
    reg [1:0] state;
    parameter IDLE = 2'd0, CLEARING = 2'd1, FINISHED = 2'd2;
    
    initial begin
        x = 0;
        y = 0;
        write = 0;
        active = 0;
        done = 0;
        state = IDLE;
    end
    
    always @(posedge Clock)
    begin
        case (state)
            IDLE: begin
                done <= 1'b0;
                if (start) begin
                    x <= 0;
                    y <= 0;
                    write <= 1'b1;
                    active <= 1'b1;
                    state <= CLEARING;
                end
                else begin
                    write <= 1'b0;
                    active <= 1'b0;
                end
            end
            
            CLEARING: begin
                write <= 1'b1;
                if (x < X_MAX - 1) begin
                    x <= x + 1'b1;
                end
                else begin
                    x <= 0;
                    if (y < Y_MAX - 1) begin
                        y <= y + 1'b1;
                    end
                    else begin
                        // Finished clearing
                        write <= 1'b0;
                        active <= 1'b0;
                        done <= 1'b1;
                        state <= FINISHED;
                    end
                end
            end
            
            FINISHED: begin
                done <= 1'b0;
                write <= 1'b0;
                active <= 1'b0;
                state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
endmodule