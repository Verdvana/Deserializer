//=============================================================================
// Module Name:				Deserializer
// Function Description:	Multi-bit Deserializer
// Department:				Qualcomm (Shanghai) Co., Ltd.
// Author:					Verdvana
// Email:					verdvana@outlook.com
//-----------------------------------------------------------------------------
// Version	Design		Coding		Simulate    Review      Rel date
// V1.0		Verdvana	Verdvana	Verdvana				2020-02-26
// V1.1		Verdvana	Verdvana	Verdvana				2021-08-15
// V1.2		Verdvana	Verdvana	Verdvana				2021-11-25
//-----------------------------------------------------------------------------
// Version	Modified History
// V1.0		Single bit deserialize;
//          The parallel width is configurable;
//          MSB/LSB.
// V1.1     Add stream mode.
// V1.2     Multi-bit deserialize.
//=============================================================================


// Include

// Define
//`define			FPGA_EMU


`timescale 1ns/1ps

//Module
module Deserializer #(
    parameter   DATA_WIDTH  = 8,
                PARL_WIDTH  = 8
)(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        en,
    input   wire                        dir,
    output  logic                       valid,
    output  logic                       valid_str,

    input   wire    [DATA_WIDTH-1:0]    ser,
    output  logic   [DATA_WIDTH-1:0]    par     [PARL_WIDTH]
);

	//=========================================================
	// The time unit and precision of the external declaration
	timeunit        	1ns;
	timeprecision   	1ps;

    //=========================================================
    // Local parameter
    localparam      TCO = 1;

	//=========================================================
	// Signal
    logic [$clog2(PARL_WIDTH-1)-1:0]    cnt;
    logic [PARL_WIDTH-1:0]              en_ff;


	//=========================================================
	// Status counter
    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            cnt     <= #TCO 0;
        else if(en)
            if(cnt >= (PARL_WIDTH-1))
                cnt     <= #TCO 0;
            else
                cnt     <= #TCO cnt + 1'b1;
        else
            cnt     <= #TCO 0;
    end

	//=========================================================
	// Parallel output
    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            for(int i=0;i<PARL_WIDTH;i++)begin
                par[i]  <= #TCO '0;
            end
        else if(en)
            if(dir)begin
                for(int i=0;i<(PARL_WIDTH-1);i++)begin
                    par[i+1]  <= #TCO par[i];
                end
                par [0]  <= #TCO ser;
            end
            else begin
                for(int i=0;i<(PARL_WIDTH-1);i++)begin
                    par[i]    <= #TCO par[i+1];
                end
                par [PARL_WIDTH-1]     <= #TCO ser;
            end
        else
            if(dir)begin
                for(int i=0;i<(PARL_WIDTH-1);i++)begin
                    par[i+1]  <= #TCO par[i];
                end
                par [0]  <= #TCO '0;
            end
            else begin
                for(int i=0;i<(PARL_WIDTH-1);i++)begin
                    par[i]    <= #TCO par[i+1];
                end
                par [PARL_WIDTH-1]  <= #TCO '0;
            end
    end


	//=========================================================
	// Status output
    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            valid   <= #TCO '0;
        else
            if(cnt == (PARL_WIDTH-1))
                valid   <= #TCO en;
            else
                valid   <= #TCO '0;
    end

    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            en_ff   <= #TCO '0;
        else
            en_ff   <= #TCO {en_ff[PARL_WIDTH-2:0],en};
    end

    assign valid_str    = en_ff[PARL_WIDTH-1];

endmodule
