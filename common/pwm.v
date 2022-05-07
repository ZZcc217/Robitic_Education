module pwm (
    input wire clk,
    input enable,
    input [15:0] timeon,
    output reg PWM
    );
    
// Register Declaration
    reg [15:0] timerPWM;
    
// Datapath clocked
    always @(posedge clk)
    begin
        if (enable)
        begin
            timerPWM <= timerPWM + 1'b1;
            if (timerPWM == 16'd16000)
            begin
                timerPWM <= 0;
                PWM <= 1'b1;
            end
            
            else if (timerPWM > timeon)
                PWM <= 1'b0;
        end
        
        else
        begin
            timerPWM <=0;
            PWM <= 0;
        end
    end
endmodule
