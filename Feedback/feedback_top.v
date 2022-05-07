module fpga_top (
    input wire WF_CLK, WF_BUTTON,
    input wire motorL_encdr, motorR_encdr,
    input wire bump0, bump1, bump2, bump3, bump4, bump5,
    output wire motorL_pwm, motorR_pwm,
    output wire motorL_en, motorL_dir, motorR_en, motorR_dir,
    output wire WF_LED
    );

wire enable;
wire l_stop, r_stop;

// 50 rotations, 3 rotations per second
stepctl #(.SPEED(16'd1080)) motorR(
    WF_CLK, r_stop, enable, motorR_encdr, 16'd18000, motorR_pwm, motorR_en
);
stepctl #(.SPEED(16'd1080)) motorL(
    WF_CLK, l_stop, enable, motorL_encdr, 16'd18000, motorL_pwm, motorL_en
);

// button edge detector
reg btn1, btn2, btn3;
wire pulse;
always @(posedge WF_CLK) begin
    btn1 <= WF_BUTTON;
    btn2 <= btn1;
    btn3 <= btn2;
end
assign pulse = ~btn3 & btn2;

assign enable = pulse;
assign WF_LED = ~(motorR_en | motorL_en);
assign motorL_dir = 0;
assign motorR_dir = 0;
assign r_stop = ~bump0 | ~bump1 | ~bump2;
assign l_stop = ~bump3 | ~bump4 | ~bump5;
endmodule