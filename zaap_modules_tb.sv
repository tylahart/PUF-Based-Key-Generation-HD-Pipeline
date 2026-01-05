`timescale 1ns / 1ps

module zaap_modules_zap;

    logic clk = 0;
    logic rst;

    logic enable_puf;
    logic enable_hd;
    logic enable_map;

    logic [6:0] randoms[0:5];
    logic [127:0] Ssk;
    logic [6:0] Hsl, Hsh;
    logic [6:0] t;

    logic [127:0] Pr, Pgr;
    logic [127:0] Ssk_out;
    logic [6:0] H[0:127];
    logic [6:0] HD[0:127];
    logic done_puf, done_hd;

    logic [127:0] F_tb[0:127];

    zaap_modules dut (
        .clk(clk),
        .rst(rst),
        .enable_puf(enable_puf),
        .enable_hd(enable_hd),
        .enable_map(enable_map),
        .randoms(randoms),
        .Ssk(Ssk),
        .Ssk_out(Ssk_out),
        .Hsl(Hsl),
        .Hsh(Hsh),
        .t(t),
        .Pr(Pr),
        .Pgr(Pgr),
        .H(H),
        .HD(HD),
        .F(F_tb),           
        .done_puf(done_puf),
        .done_hd(done_hd)
    );

    always #5 clk = ~clk;  // 10 ns clock period

    initial begin
        rst = 1;
        enable_puf = 0;
        enable_hd = 0;
        enable_map = 0;
        Hsl = 7'd12;
        Hsh = 7'd51;
        t   = 7'd7;

        Ssk = 128'hF0F0_FDFD_AAAA_5555_1234_ABCD_DCBA_BFFF;
        Pgr = 128'h0F0F_0A0A_1111_2222_3333_4444_5555_6666;

        randoms[0] = 7'd5;
        randoms[1] = 7'd20;
        randoms[2] = 7'd63;
        randoms[3] = 7'd90;
        randoms[4] = 7'd127;
        randoms[5] = 7'd1;

        F_tb[0] = 128'hDEAD_BEEF_0123_4567_89AB_CDEF_1357_9BDF;
        F_tb[1] = 128'hCAF3_BABE_F00D_1234_5678_9ABC_DEF0_1234;
        F_tb[2] = 128'h0F0F_AAAA_5555_3333_7777_9999_1111_ABCD;

        for (int i = 3; i < 128; i++) begin
            F_tb[i] = {$urandom, $urandom};
        end

        #20;
        rst = 0;

        // run PUF
        #10;
        enable_puf = 1;
        #10;
        enable_puf = 0;

        wait (done_puf == 1);

        // run HD_transform
        #20;
        enable_hd = 1;
        #10;
        enable_hd = 0;

        wait (done_hd == 1);
        
        // run map
        #10;
        enable_map = 1;
        #10;
        enable_map = 0;


        #50;
        $finish;
    end

endmodule
