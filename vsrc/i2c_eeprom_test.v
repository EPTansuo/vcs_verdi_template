
//==========================================================================
//   Description:   
//
//   
//==========================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------
//  2019/11/14    lhj         1.1         Original
//*************************************************************************/
module i2c_eeprom_test
(
input            sys_clk,       //system clock 50Mhz on board
input            rst_n,         //reset ,low active
input            key1,          //user key on board
inout            i2c_sda,       // i2c data
inout            i2c_scl,       // i2c clock
output [3:0]     led           //user leds on board
);
/*************************************************************************
Defines the states of operating the EEPROM state machine
****************************************************************************/
localparam S_IDLE       = 0;
localparam S_READ       = 1;
localparam S_WAIT       = 2;
localparam S_WRITE      = 3;
reg[3:0] state;

wire button_negedge;
reg[7:0] read_data;             //read eeprom data
reg[31:0] timer;

wire scl_pad_i;
wire scl_pad_o;
wire scl_padoen_o;

wire sda_pad_i;
wire sda_pad_o;
wire sda_padoen_o;

reg[ 7:0] i2c_slave_dev_addr;   // i2c device address
reg[15:0] i2c_slave_reg_addr;   // i2c device address
reg[ 7:0] i2c_write_data;       // i2c write data
reg i2c_read_req;               // i2c reading request
wire i2c_read_req_ack;          // i2c reading request response
reg i2c_write_req;              //i2c writing request
wire i2c_write_req_ack;         // i2c writing request response
wire[7:0] i2c_read_data;        // i2c read data

assign led = ~read_data[3:0];
/*************************************************************************
Only one pulse is generated when a key is pressed to meet requirements
****************************************************************************/
ax_debounce ax_debounce_m0
(
.clk             (sys_clk),
.rst             (~rst_n),
.button_in       (key1),
.button_posedge  (),
.button_negedge  (button_negedge),
.button_out      ()
);
/*************************************************************************
This module is a state machine that generates reading and writing EEPROM
****************************************************************************/ 
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        state <= S_IDLE;
        i2c_write_req <= 1'b0;
        read_data <= 8'h00;
        timer <= 32'd0;
        i2c_write_data <= 8'd0;
        i2c_slave_reg_addr <= 16'd0;
        i2c_slave_dev_addr <= 8'ha2;//1010 001 0
        i2c_read_req <= 1'b0;
    end
    else
        case(state)
            S_IDLE:
            begin
                if(timer >= 32'd12_499_999)//250ms
                    state <= S_READ;
                else
                    timer <= timer + 32'd1;
            end
            S_READ:
            begin
                if(i2c_read_req_ack)//i2c reading request response
                begin
                    i2c_read_req <= 1'b0;
                    read_data <= i2c_read_data;
                    state <= S_WAIT;
                end
                else
                begin
                    i2c_read_req <= 1'b1; //generate  reading request
                    i2c_slave_dev_addr <= 8'ha2;
                    i2c_slave_reg_addr <= 16'd0;
                end
            end
            S_WAIT:
            begin
                if(button_negedge)
                begin
                    state <= S_WRITE;
                    read_data <= read_data + 8'd1;
                end
            end
            S_WRITE:
            begin
                if(i2c_write_req_ack)//i2c writing request response
                begin
                    i2c_write_req <= 1'b0;
                    state <= S_READ;
                end
                else
                begin
                    i2c_write_req <= 1'b1;//generate  writing request
                    i2c_write_data <= read_data;
                end
            end
            
            default:
                state <= S_IDLE;
        endcase
end

assign sda_pad_i = i2c_sda;
assign i2c_sda = ~sda_padoen_o ? sda_pad_o : 1'bz;
assign scl_pad_i = i2c_scl;
assign i2c_scl = ~scl_padoen_o ? scl_pad_o : 1'bz;
/*************************************************************************
Operate I2C bus to write or read I2C device data
****************************************************************************/ 
i2c_master_top i2c_master_top_m0
(
.rst(~rst_n),
.clk(sys_clk),
.clk_div_cnt(16'd99),       //Standard mode:100Khz

// I2C signals 
// i2c clock line
.scl_pad_i(scl_pad_i),            // SCL-line input
.scl_pad_o(scl_pad_o),            // SCL-line output (always 1'b0)
.scl_padoen_o(scl_padoen_o),      // SCL-line output enable (active low)

// i2c data line
.sda_pad_i(sda_pad_i),           // SDA-line input
.sda_pad_o(sda_pad_o),           // SDA-line output (always 1'b0)
.sda_padoen_o(sda_padoen_o),     // SDA-line output enable (active low)

.i2c_addr_2byte(1'b0),
.i2c_read_req(i2c_read_req),
.i2c_read_req_ack(i2c_read_req_ack),
.i2c_write_req(i2c_write_req),
.i2c_write_req_ack(i2c_write_req_ack),
.i2c_slave_dev_addr(i2c_slave_dev_addr),
.i2c_slave_reg_addr(i2c_slave_reg_addr),
.i2c_write_data(i2c_write_data),
.i2c_read_data(i2c_read_data),
.error()
);

endmodule 
