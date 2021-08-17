//=============================================================================
//
// Module Name:					Deserializer
// Department:					Qualcomm (Shanghai) Co., Ltd.
// Function Description:	    Deserializer
//
//------------------------------------------------------------------------------
//
// Version 	Design		Coding		Simulata	  Review		Rel data
// V1.0		Verdvana	Verdvana	Verdvana		  			2021-08-15
//
//------------------------------------------------------------------------------
//
// Version	Modified History
// V1.0		
//
//=============================================================================

//The time unit and precision of the external declaration
timeunit        1ns;
timeprecision   1ps;

// Define
//`define			FPGA_EMU

//Module
module  Deserializer #(
    parameter       DATA_WIDTH  = 5                     //Data width
)(
	// Clock and reset
	input  logic							clk,		//Clock
	input  logic							rst_n,		//Async reset
    // Status
    input  logic                            dir,        //MSB or LSB
    input  logic                            valid,      //Input valid
    output logic                            ready,      //Output ready
    output logic                            ready_str,  //Stream output ready
	// Inout
	input  logic							ser,        //Serial input
    output logic [DATA_WIDTH-1:0]           par,        //Parallel output
    output logic [DATA_WIDTH-1:0]           par_str     //Parallel stream output
);

    //=========================================================
    // Bit width calculation function
    function integer clogb2 (input integer depth);
    begin
        for (clogb2=0; depth>0; clogb2=clogb2+1) 
            depth = depth >>1;                          
    end
    endfunction


    //=========================================================
    // Parameter
    localparam                  TCO  = 0.7;                  //Register delay


    //=========================================================
    // Signal
	logic   [clogb2(DATA_WIDTH-1)-1:0]  cnt;


    //=========================================================
    // Status counter
    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            cnt     <= #TCO '0;
        else if(valid)
                if(cnt>= DATA_WIDTH-1)
                    cnt     <= #TCO '0;
                else
                    cnt     <= #TCO cnt + 1'b1;
        else
            cnt     <= #TCO cnt;
    end


    //=========================================================
    // Parallel output
    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            par_str <= #TCO '0;
        else if(valid)
            if(dir)
                par_str <= #TCO {par_str[DATA_WIDTH-2:0],ser};
            else
                par_str <= #TCO {ser,par_str[DATA_WIDTH-1:1]};
        else
            par_str <= #TCO par_str;
    end

    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            par     <= #TCO '0;
        else if(valid)
            if(cnt == DATA_WIDTH-1)
                if(dir)
                    par     <= #TCO {par_str[DATA_WIDTH-2:0],ser};
                else
                    par     <= #TCO {ser,par_str[DATA_WIDTH-1:1]};
            else
                par     <= #TCO par;
        else
            par     <= #TCO par;
    end


    //=========================================================
    // Status output
    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            ready_str   <= #TCO '0;
        else if(valid)
            if(cnt == DATA_WIDTH-1)
                ready_str   <= #TCO '1;
            else
                ready_str   <= #TCO ready_str;
        else
            ready_str   <= #TCO '0;
    end

    always_ff@(posedge clk, negedge rst_n)begin
        if(!rst_n)
            ready   <= #TCO '0;
        else if(valid)
            if(cnt == DATA_WIDTH-1)
                ready   <= #TCO '1;
            else
                ready   <= #TCO '0;
        else
            ready   <= #TCO '0;
    end

endmodule
