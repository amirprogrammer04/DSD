module Parking (input car_entered, is_uni_car_entered, car_exited, is_uni_car_exited, clk,
    output reg uni_is_vacated_space, is_vacated_space,
    output reg [9:0] uni_parked_car, parked_car, uni_vacated_space, vacated_space);

    reg [9:0] university_capacity;
    wire hour;
    reg [9:0] public_capacity;
    reg [9:0] changed_capacity;
    integer timer;

    initial begin
        parked_car = 0;
        uni_vacated_space = 500;
        timer= 8;
        uni_parked_car = 0;
        university_capacity = 500;
        vacated_space = 200;
        public_capacity = 200;
    end

    Counter #(60) counter(clk, hour);
    always @(posedge hour or posedge clk) begin
        if (hour) begin
			   timer = timer + 1;
				if (timer % 24 == 14 || timer % 24 == 15) begin
					changed_capacity = (uni_vacated_space < 50) ? uni_vacated_space : 50;
					university_capacity = university_capacity - changed_capacity;
					uni_vacated_space = uni_vacated_space - changed_capacity;
					public_capacity = public_capacity + changed_capacity;
					vacated_space = vacated_space + changed_capacity;
				end else if (timer % 24 == 16) begin
					university_capacity = (uni_parked_car > 200) ? uni_parked_car : 200;
					public_capacity = 700 - university_capacity;
					vacated_space = public_capacity - parked_car;
					uni_vacated_space = university_capacity - uni_parked_car;
				end
		  end else if (clk) begin
				uni_is_vacated_space = (uni_vacated_space != 0) ? 1 : 0;
				is_vacated_space = (vacated_space != 0) ? 1 : 0;
				if (car_entered && is_uni_car_entered && uni_is_vacated_space) begin
					uni_parked_car = uni_parked_car + 1;
					uni_vacated_space = uni_vacated_space - 1;
				end else if (car_entered && !is_uni_car_entered && is_vacated_space) begin
					parked_car = parked_car + 1;
					vacated_space = vacated_space - 1;
				end else if (car_exited && is_uni_car_exited && uni_vacated_space > 0) begin
					uni_parked_car = uni_parked_car - 1;
					uni_vacated_space = uni_vacated_space + 1;
				end else if (car_exited && !is_uni_car_exited && vacated_space > 0) begin
					parked_car = parked_car - 1;
					vacated_space = vacated_space + 1;
				end
		  end
    end
endmodule
module Counter #(parameter n = 60) (input clk, output reg hour);
    integer count;
    
    initial begin
        hour = 0;
        count = 0;
    end

    always @(posedge clk) begin
        count = count + 1;
        if (count % n == 0)
            hour = 1;
        else
            hour = 0;
    end
endmodule
module Parking_TB();
    reg car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,clk;
    wire uni_is_vacated_space, is_vacated_space;
    wire [9:0] uni_parked_car, parked_car, uni_vacated_space, vacated_space;

    always
        #5 clk = ~clk;

    Parking parking(car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,clk,
    uni_is_vacated_space, is_vacated_space,uni_parked_car, parked_car, uni_vacated_space, vacated_space);

    initial begin
        car_entered=0;
        is_uni_car_entered=0;
        car_exited=0;
        is_uni_car_exited=0;
        clk=0;
        #300 car_entered = 1;
        #60 is_uni_car_entered = 1;
        #70 car_entered = 0; is_uni_car_entered = 0; car_exited = 1; is_uni_car_exited = 0;
        #70 car_entered = 1; is_uni_car_entered = 1; car_exited = 0; is_uni_car_exited = 1;
        #200 $finish();
    end

    initial begin
        $monitor("time= %t\n: car_entered = %b || is_uni_car_entered = %b || car_exited = %b || is_uni_car_exited = %b >>>>> uni_is_vacated_space = %d ||",
        $time, car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,uni_is_vacated_space,
         "is_vacated_space = %d \n|| uni_parked_car = %d || parked_car = %d || uni_vacated_space = %d || vacated_space = %d",
         is_vacated_space,uni_parked_car, parked_car, uni_vacated_space, vacated_space);
    end
        initial begin
        $dumpfile("Parking.vcd");
        $dumpvars(0,Parking_TB);
    end
endmodule