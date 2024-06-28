module Parking #(parameter uni_vacated_space_initial=500, parameter time_initial=8,parameter university_capacity_initial=500,
parameter vacated_space_initial=200,parameter public_capacity_initial=200)
(input car_entered, is_uni_car_entered, car_exited, is_uni_car_exited, clk,
    output reg uni_is_vacated_space, is_vacated_space,
    output reg [9:0] uni_parked_car, parked_car, uni_vacated_space, vacated_space,output wire [6:0]time_counter,output reg[4:0] timer_hour);

    reg [9:0] university_capacity;
    wire hour;
    reg [9:0] public_capacity;
    reg [9:0] changed_capacity;

    initial begin
        parked_car = 0;
        uni_vacated_space = uni_vacated_space_initial;
        timer_hour= time_initial;
        uni_parked_car = 0;
        university_capacity = university_capacity_initial;
        vacated_space = vacated_space_initial;
        public_capacity = public_capacity_initial;
    end

    Counter #(60) counter(clk, hour,time_counter);
    always @(posedge hour or posedge clk) begin
        if (hour) begin
			   timer_hour = timer_hour + 1;
				if (timer_hour % 24 == 14 || timer_hour % 24 == 15) begin
					changed_capacity = (uni_vacated_space < 50) ? uni_vacated_space : 50;
					university_capacity = university_capacity - changed_capacity;
					uni_vacated_space = uni_vacated_space - changed_capacity;
					public_capacity = public_capacity + changed_capacity;
					vacated_space = vacated_space + changed_capacity;
				end else if (timer_hour % 24 == 16) begin
					university_capacity = (uni_parked_car > 200) ? uni_parked_car : 200;
					public_capacity = 700 - university_capacity;
					vacated_space = public_capacity - parked_car;
					uni_vacated_space = university_capacity - uni_parked_car;
				end
		  end else if (clk) begin
				uni_is_vacated_space = (uni_vacated_space != 0) ? 1 : 0;
				is_vacated_space = (vacated_space != 0) ? 1 : 0;
				if (car_entered && is_uni_car_entered && uni_is_vacated_space  ) begin
					uni_parked_car = uni_parked_car + 1;
					uni_vacated_space = uni_vacated_space - 1;
				end else if (car_entered && !is_uni_car_entered && is_vacated_space) begin
					parked_car = parked_car + 1;
					vacated_space = vacated_space - 1;
				end else if (car_exited && is_uni_car_exited && uni_parked_car > 0 ) begin
					uni_parked_car = uni_parked_car - 1;
					uni_vacated_space = uni_vacated_space + 1;
				end else if (car_exited && !is_uni_car_exited && parked_car > 0) begin
					parked_car = parked_car - 1;
					vacated_space = vacated_space + 1;
				end
		  end   if(timer_hour%24==0)
                    timer_hour=0;
    end
endmodule
module Counter #(parameter n = 60) (input clk, output reg hour,output reg[6:0] count);
    
    initial begin
        hour = 0;
        count = 0;
    end

    always @(posedge clk) begin
        count <= count + 1;
        if (count % (n-1) == 0 && count!=0)begin
            hour <= 1;
            count <= 0;
        end
        else
            hour <= 0;
    end
endmodule
module Parking_TB();
    reg car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,clk;
    wire uni_is_vacated_space, is_vacated_space;
    wire [9:0] uni_parked_car, parked_car, uni_vacated_space, vacated_space;
    wire [6:0]time_counter;
    wire [4:0]time_hour;

    always
        #5 clk = ~clk;

    Parking #(500,8,500,200,200)parking(car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,clk,
    uni_is_vacated_space, is_vacated_space,uni_parked_car, parked_car, uni_vacated_space, vacated_space,time_counter,time_hour);
          
    initial begin
        car_entered=0;
        is_uni_car_entered=0;
        car_exited=0;
        is_uni_car_exited=0;
        clk=0;
        #20 car_entered = 1;
        #30 is_uni_car_entered = 1;
        #50 car_entered = 0;    is_uni_car_entered = 0; car_exited = 1; is_uni_car_exited = 0;
        #50 car_exited = 1; is_uni_car_exited = 1;
        #10000 $finish();
    end

    initial begin
        $monitor("time= %d:%d\n: car_entered = %b || is_uni_car_entered = %b || car_exited = %b || is_uni_car_exited = %b >>>>> uni_is_vacated_space = %d ||",
        time_hour,time_counter, car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,uni_is_vacated_space,
         "is_vacated_space = %d \n|| uni_parked_car = %d || parked_car = %d || uni_vacated_space = %d || vacated_space = %d",
         is_vacated_space,uni_parked_car, parked_car, uni_vacated_space, vacated_space);
    end
        initial begin
        $dumpfile("Parking.vcd");
        $dumpvars(0,Parking_TB);
    end
endmodule




