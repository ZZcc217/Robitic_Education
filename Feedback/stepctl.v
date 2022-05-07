// Cheng Zhao
// FPGA for Robotics Education
//------------------------------------------------------------------------------
// This is a more advanced motor driver that rotates the motor by a given number
// of degrees upon activation. Uses the speedctl module to generate PWM.
//
// inputs:
//      clk     -- a 16MHz clock
//      rst     -- active high reset
//      enable  -- start the action
//      encoder -- the encoder signal
//      ndegs   -- number of degrees to rotate
// output:
//      PWM     -- the pulse width modulation used to drive the motor
// parameters:
//      SPEED   -- degrees per second 
//

module stepctl (
    input clk,
    input rst,
    input enable,
    input encoder, // encoder pulse
    input [15:0] ndegs, // desired number of ticks (degrees)
    output wire PWM,
    output reg motor_en
);

// default speed
parameter SPEED = 16'd720;

// states
localparam IDLE = 4'd0;
localparam COUNTDOWN = 4'd1;

// registers
reg [3:0] state, next;
reg [15:0] counter, counter_next;
reg pwm_gen;

// encoder edge detector
reg enc1, enc2, enc3;
wire pulse;
always @(posedge clk) begin
    enc1 <= encoder;
    enc2 <= enc1;
    enc3 <= enc2;
end
assign pulse = ~enc3 & enc2;

// pwm generator
speedctl motorR(clk, pwm_gen, encoder, SPEED, PWM);

always @(posedge clk) begin
    state <= rst ? IDLE : next;
    counter <= counter_next;
end

always @(*) begin
    // defaults
    next = IDLE;
    pwm_gen = 0;
    counter_next = 16'd0;
    motor_en = 0;

    case (state)
        IDLE: begin
            next = enable ? COUNTDOWN : IDLE;

            pwm_gen = 0;
            counter_next = enable ? ndegs : 16'd0;
            motor_en = 0;
        end

        COUNTDOWN: begin
            next = (counter != 16'd0) ? COUNTDOWN : IDLE;

            pwm_gen = 1;
            counter_next = counter - {15'd0, pulse};
            motor_en = 1;
        end
    endcase
end

    
endmodule