`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 11:06:17 PM
// Design Name: 
// Module Name: zaap_modules
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module puf(
    input logic clk, rst,
    input logic enable,
    input logic [6:0] randoms[0:5],
    output logic done,
    output logic [127:0] Pr
);
    logic [127:0] Pc;
    logic [127:0] Pr_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 128; i++) begin
                Pc[i] <= (i % 2 == 0);
            end
            Pr_reg <= '0;
            done <= 0;
        end else begin
            if (!enable) begin
                Pr_reg <= '0;
                done <= 0;
            end else begin
                for (int i = 0; i < 128; i++) begin
                    Pr_reg[i] <= Pc[i]; // copy all bits
                end
                for (int i = 0; i < 6; i++) begin
                    Pr_reg[randoms[i]] <= ~Pc[randoms[i]]; // flip specific bits
                end
                done <= 1;
            end
        end
    end

    assign Pr = Pr_reg;

endmodule


module HD_transform (
    input  logic        clk, rst,
    input  logic        enable,
    input  logic [127:0] Ssk,
    input  logic [6:0]  Hsl,
    input  logic [6:0]  Hsh,
    output logic        done,
    output logic [6:0]  H [0:127]
);


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            for (int i = 0; i < 128; i++) begin
                H[i] <= 7'd0;
            end
        end else begin

            if (enable) begin
                for (int i = 0; i < 128; i++) begin
                    if (Ssk[127 - i] == 1'b0) begin
                        H[i] <= Hsl;
                    end else begin
                        H[i] <= Hsh;
                    end 
                end
                done <= 1;
            end else begin
                done <= 0;
            end
        end
    end

endmodule

module MAP (
    input  logic        enable,
    input  logic [127:0] F[0:127],
    input  logic [127:0] Pgr,
    input  logic [6:0]   t,
    input  logic [6:0]   Hsl,
    input  logic [6:0]   Hsh,
    output logic [6:0]   HD[0:127],
    output logic [127:0] Ssk_out
);
    logic [6:0] HD_temp[0:127];

    genvar i;
    generate
        for (i = 0; i < 128; i++) begin : gen_hamming
            HammingBlock hb (
                .a(F[i]),
                .b(Pgr),
                .distance(HD_temp[i])
            );
        end
    endgenerate

    always_comb begin
        for (int i = 0; i < 128; i++) begin
            if (enable) begin
                HD[i] = HD_temp[i];
                if ((Hsl - t) < HD_temp[i] && HD_temp[i] < (Hsh + t))
                    Ssk_out[i] = 1'b1;
                else
                    Ssk_out[i] = 1'b0;
            end else begin
                HD[i] = 7'd0;
                Ssk_out[i] = 1'b0;
            end
        end
    end
endmodule


module HammingBlock(
    input  logic [127:0] a,
    input  logic [127:0] b,
    output logic [6:0] distance
);
    always_comb begin
        int count = 0;
        for (int i = 0; i < 128; i++) begin
            if (a[i] != b[i])
                count++;
        end
        distance = count[6:0];
    end
endmodule


module zaap_modules(
    input logic clk, rst, enable_puf, enable_hd, enable_map,
    input logic [127:0] F[0:127],
    input logic [6:0] randoms[0:5],
    input logic [127:0] Ssk, Pgr,
    input logic [6:0] Hsl, Hsh, t,
    output logic [127:0] Pr, Ssk_out,
    output logic [6:0] H[0:127], 
    output logic [6:0] HD[0:127],
    output logic done_puf, done_hd
);

    puf u_puf (
        .clk(clk),
        .rst(rst),
        .enable(enable_puf),
        .randoms(randoms),
        .done(done_puf),
        .Pr(Pr)
    );

    HD_transform u_hd_transform (
        .clk(clk),
        .rst(rst),
        .enable(enable_hd),
        .Ssk(Ssk),
        .Hsl(Hsl),
        .Hsh(Hsh),
        .done(done_hd),
        .H(H)
    );
    
    MAP u_map (
        .enable(enable_map),
        .F(F), 
        .Pgr(Pgr), 
        .t(t), 
        .Hsl(Hsl), 
        .Hsh(Hsh), 
        .HD(HD), 
        .Ssk_out(Ssk_out)
    );
endmodule

