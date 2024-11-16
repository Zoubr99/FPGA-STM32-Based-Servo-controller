#include <cstdint>
#include <mbed.h>
#include <stdio.h>

// Define SPI1 (MOTOR)
SPI spi1(PA_7, PA_6, PA_5);      // Ordered as: mosi, miso, sclk

// Define SPI2 (LCD)
SPI spi2(PB_15, NC, PB_13);      // Ordered as: mosi, miso (NOT CONNECTED), sclk

// chip select for SPI1
DigitalOut cs1(PC_6);

// chip select for SPI2
DigitalOut cs2(PB_9);    

// MAKE PB_12 (D19) an INPUT do NOT make an OUTPUT under any circumstances!
// This Pin is connected to the 5VDC from the FPGA card and an INPUT that is 5V Tolerant
DigitalIn DO_NOT_USE(PB_12);    

// Busy flag for motor
DigitalIn busy_flag(PA_15);

// Hall effect pin
InterruptIn halleffect(PB_8);

// interrupt used for rst switch
// the FPGA DIP switches have really bad contact
// this can lead to multiple entries/exits of the ISRs
InterruptIn rst(PC_7);

// Nucleo LEDs
DigitalOut led_r(PB_14);
DigitalOut led_g(PB_0);
DigitalOut led_b(PB_7);


// functions
void spi_setup(void);
uint16_t spi1_readwrite(uint16_t data);
uint16_t spi2_readwrite(uint16_t data);
void lcd_data(char c);
void lcd_command(char c);
void lcd_int(int c);
void write(char *str);
void LCD_telemetry (int i, int x);
void operate_motor(bool a, bool b, uint16_t c);
void motor_user_input (void);
void buffer_end_of_transmission(void);
void clear_terminal(void);
void calibration(void);
void terminal_red(void);
void terminal_green(void);
void terminal_orange(void);
void terminal_default(void);


// ISRs
void rstISR_posedge(void);
void rstISR_negedge(void);
void hallISR(void);

// globals

// This will hold the 16-bit data returned from the SPI interface (sent by the FPGA)
// Currently the inputs to the SPI recieve are left floating (see quartus files)
uint16_t rx1; // SPI1
uint16_t rx2; // SPI2

int16_t delta_angle = 0;
int16_t desired_angle = 0; 
int16_t prev_angle = 0; 
uint16_t motor_data = 0; // what is sent to MCU
bool change = 0; // either a 1 or 0
bool direction = 0; // either a 1 or 0
uint16_t pulses = 0; // number of pulses
int pulses_offset; // offset for number of pulses to be sent to MCU
const float offset = 0.27; // offset for number of pulses
bool rst_state = 0; // stores state of reset pin
bool busy_state; // stores state of PA15 (busy flag pin)
int16_t RealTimePulseCounter_ACW = 0; // counts hall effect pulses for ACW dir
int16_t RealTimePulseCounter_CW = 0; // counts hall effect pulses for CW dir
int16_t delta_pulses; // difference between ACW and CW pulses
int16_t RealTimeAngle = 0;
bool reset_counter = 0;


// ANSI ESC CODES

// ESC Code Sequence	Description
// ESC[38;5;{ID}m	Set foreground color.
// ESC[48;5;{ID}m	Set background color.

char foreground_red[] = "\033[38;5;196m"; // red
char foreground_green[] = "\033[38;5;47m"; // green
char foreground_orange[] = "\033[38;5;214m"; // orange
char foreground_white[] = "\033[38;5;255m"; // white (default)


// main entry point
int main() {

    // clears serial monitor
    clear_terminal();

    // ISR Setup
    rst.rise(&rstISR_posedge); // interrupts on rising edge of rst pin
    rst.fall(&rstISR_negedge); // interrupts on falling edge of rst pin
    halleffect.rise(&hallISR); // interrupts on rising edge of hall effect signal

    // sets up spi1 and spi2 parameters
    spi_setup();

    // calibration variable
    bool calibration_counter = 0;


    while (true) {
        
        // calibrates current position of motor to degrees
        if (calibration_counter == 0) {

            calibration();
            calibration_counter = 1;

        }

        // accepts user input for desired angle
        motor_user_input();
        
        delta_angle = desired_angle - prev_angle;

        printf("Motor rotated %d degrees \n\n", delta_angle);

        // offset for number of pulses to be sent to motor
        // as error scales with an increase in delta_angle, this compensates for it!
        pulses_offset = delta_angle * offset;
        

        // number of pulses calculation
        // this will produce a slight error due to rounding
        // as it should be 2.8 not 3 - see derivation in OneNote
        // hence an offset was used to compensate
        pulses = abs( (delta_angle * 3) - pulses_offset );
        
        

        // direction bit determination
        if (delta_angle > 0) {
            direction = 1;
            printf("The motor rotated anticlockwise\n");
        }

        else {
            direction = 0;
            printf("The motor rotated clockwise\n");
        }

        // display motor info on LCD
        LCD_telemetry(desired_angle, pulses); 

        // needed for operation of pulse generator
        // see motor logic chip schematic for further details
        // pulse generator does not produce a pulse desired angle = current angle
        // i.e. pulses = 0
        if (pulses != 0) {
            change = !change;
        }



        printf("The number of pulses sent is: %d\n\n", pulses);
        // run motor!
        operate_motor(change, direction, pulses);

        
        
        
    }
  

}

// SPI1 - leave alone
uint16_t spi1_readwrite(uint16_t data) {	

	cs1 = 0;             									//Select the device by seting chip select LOW
	uint16_t rx1 = (uint16_t)spi1.write(data);				//Send the data - ignore the return data
	wait_us(1);												//wait for last clock cycle to clear
	cs1 = 1;             									//De-Select the device by seting chip select HIGH
	wait_us(1);
	return rx1;

}

// SPI2 - leave alone
uint16_t spi2_readwrite(uint16_t data) {	

	cs2 = 0;             									//Select the device by seting chip select LOW
	uint16_t rx2 = (uint16_t)spi2.write(data);				//Send the data - ignore the return data
	wait_us(1);												//wait for last clock cycle to clear
	cs2 = 1;             									//De-Select the device by seting chip select HIGH
	wait_us(1);
	return rx2;

}
// this function sets up both SPI interfaces
void spi_setup(void) {

    // SPI1 setup used for motor
    cs1 = 1;                     // Chip must be deselected, Chip Select is active LOW
    spi1.format(16,0);           // Setup the DATA frame SPI for 16 bit wide word, Clock Polarity 0 and Clock Phase 0 (0)
    spi1.frequency(1000000);     // 1MHz clock rate
    wait_us(10000);

    // SPI2 setup used for LCD
    cs2 = 1;                     // Chip must be deselected, Chip Select is active LOW
    spi2.format(16,0);           // Setup the DATA frame SPI for 16 bit wide word, Clock Polarity 0 and Clock Phase 0 (0)
    spi2.frequency(1000000);     // 1MHz clock rate
    wait_us(10000);

}

// this function sends data to the LCD
// 9th bit is a 1 to indicate data
// bottom 8 bits are the information bits
void lcd_data(char c) {

    // character to be stored in the bottom 8 bits of rx2
    uint16_t lcd_spi = (uint16_t) c; // convert the character to a 16-bit unsigned integer
    
    // set the 9th bit of rx2 to be 1
    lcd_spi |= (1 << 8);
    rx2 = spi2_readwrite(lcd_spi);

}

// this function sends commands to the LCD
// 9th bit is a 0 to indicate command
// bottom 8 bits are the information bits
void lcd_command(char c) {

    // character to be stored in the bottom 8 bits of rx2
    uint16_t lcd_spi = (uint16_t) c; // convert the character to a 16-bit unsigned integer
    rx2 = spi2_readwrite(lcd_spi);
    
}

// this function converts integer to string and writes to LCD
void lcd_int(int c) {

    char str[16]; // allocate buffer for string representation of integer
    sprintf(str, "%d", c); 
    for (int i = 0; str[i] != '\0'; i++) {

        lcd_data(str[i]); // send each character to LCD

        // allows consecutive repeating chars to be displayed on LCD
        // due to pulse generator operation
        // 'sandwiches' two repeating words with a different word
        // can be any command that was already sent during the boot sequence
        lcd_command(0x06); 

    }
    
}


// this function writes strings on lcd
void write (char *str) { // enter the string intended

	while(*str >0){ // keep writing chars of the string until the whole string has been written
		
		lcd_data(*str++); // sends the chars of the string to be displayed on the LCD
 
	}
}

// this function displays the desired angle and the number of pulses needed
void LCD_telemetry(int i, int x) {

    lcd_command(0x01); // clear screen
    write("Motor: ");
    lcd_int(i); // current angle of motor
    write(" deg");
    lcd_command(0xC0); // move to second line
    write("Pulses: ");
    lcd_int(x); // number of pulses sent
    buffer_end_of_transmission();
    
}

// this function operates the motor accordingly
// we always send 16 bits!
// we are only interested in bits [12..0]
// bit [12] is the sense (change) bit
// bit [11] is the direction bit
// bits [10..0] are the data bits
// so bits [15..13] should always be zero - unused!
// refer to top level schematic if confused
void operate_motor(bool a, bool b, uint16_t c) {

    change = a;
    direction = b;
    pulses = c;

    // Set the 12th bit of motor_data to the change bit (0 or 1)
    motor_data |= (change << 12);

    // Set the 11th bit of motor_data to the direction bit (0 or 1)
    motor_data |= (direction << 11);

    // Set bits [10..0] of motor_data to the pulses bits (a 11-bit value)
    motor_data |= (pulses & 0x7FF);

    rx1 = spi1_readwrite(motor_data); // sends motor data via SPI1


    // Busy flag monitoring section //

    // if busy_state = 1 then the motor is spinning
    // if busy_state = 0 then the motor is not spinning
    // this section prevents the user from sending any data to the motor whilst
    // the motor is still spinning to prevent overwrites.
    // Once the motor has stopped spinning, the user is allowed to enter data once again


    // tiny delay to wait for the pin to go high, before reading the state of the pin
    // this does NOT interfere with the motor in any way
    // the motor logic chip runs from a 22kHz clock, so T = 45us
    // so delay must be atleast 45us; 100us was chosen to be safe
    wait_us(100); 

    busy_state = busy_flag.read(); // reads the state of PA15 (busy flag pin)
    
    printf("Please wait, motor is spinning. Busy Flag is: %d\n\n", busy_state);

    while(busy_state) {
        
        busy_state = busy_flag.read();
        
    }

    // Real time angle calculation section //

    // this is not a very consistent way of accurate real time angle determination
    // accuracy varies from being off by 1 degree to being off by 10-15 degrees

    delta_pulses = (RealTimePulseCounter_ACW - RealTimePulseCounter_CW);

    if (reset_counter == 1) {
        RealTimeAngle = 0;
    }

    else {
        RealTimeAngle = (delta_pulses + pulses_offset)/3;
    }

    printf("Motor has stopped spinning. Busy Flag is: %d\n\n", busy_state);
    terminal_orange();
    printf("Real time pulses at: %d\n", delta_pulses);
    printf("Real time ACW pulses at: %d\n", RealTimePulseCounter_ACW);
    printf("Real time CW pulses at: %d\n", RealTimePulseCounter_CW);
    printf("Real time angle at: %d\n\n", RealTimeAngle);
    terminal_default();

                                
    motor_data = 0; // important - leave as is
    prev_angle = desired_angle; // latch
    reset_counter = 0;

    

}


void motor_user_input(void) {

    printf("Motor is currently at: %d degrees \n\n", desired_angle);
    printf("Enter desired angle (-360 to +360): \n\n");
    scanf("%hd", &desired_angle); // user enters desired angle
    clear_terminal(); // clears terminal

    // range check
    while (desired_angle > 360 || desired_angle < -360) {

        printf("Out of range! Input must be between -360 and 360\n\n");
        printf("You input: %d degrees \n\n", desired_angle);
        printf("Enter desired angle (-360 to +360): \n\n");
        scanf("%hd", &desired_angle); // user enters desired angle
        clear_terminal();

    }
    
    printf("Motor is currently at: %d degrees \n\n", desired_angle);


}

// This function sends two special words that indicate end of transmission
void buffer_end_of_transmission(void) {

    // this indicates end of transmission (needed for buffer)
    spi2_readwrite(0b100000000); 
    // this sets the last value on the spi not to be "256" (which triggers some conditions in the buffer)
    spi2_readwrite(0b000000000); 

}

// clears terminal
void clear_terminal(void) {

    printf("\033[2J"); // clears terminal
    printf("\033[H"); // returns cursor to home

}

void calibration(void) {

    operate_motor(0, 0, 0);
    LCD_telemetry(0, 0);
    terminal_green();
    printf("Motor angle calibration complete!\n\n");
    terminal_default();

}

/// terminal colour commands ///

void terminal_red(void) {

    printf(foreground_red);

}

void terminal_green(void) {

    printf(foreground_green);
    
}

void terminal_orange(void) {

    printf(foreground_orange);
    
}

void terminal_default(void) {

    printf(foreground_white);
    
}

///                          ///


// rising edge rst ISR
void rstISR_posedge(void) {
    
    clear_terminal();
    terminal_red();
    printf("Reset is high!\n\n");
    terminal_default();
    rst_state = rst.read();

    // indicator NUCLEO LEDs on
    led_r = 1;
    led_g = 1;
    led_b = 1;

    // waits until rst is low
    while(rst_state) {

        rst_state = rst.read();

    }

}


// falling edge rst ISR
void rstISR_negedge(void) {

    // waits for reset signal to settle in hardware
    // not strictly needed, but to be safe
    wait_us(100); 

    clear_terminal();
    calibration();
    prev_angle = 0;
    desired_angle = 0;
    pulses = 0;
    RealTimePulseCounter_ACW = 0;
    RealTimePulseCounter_CW = 0;
    RealTimeAngle = 0;

    // indicator NUCLEO LEDs off
    led_r = 0;
    led_g = 0;
    led_b = 0;

    reset_counter = 1;

    printf("Enter desired angle (-360 to +360): \n\n");


}

// this executes on the rising edge of the hall effect signal
// it counts the number of hall effect pulses and stores it in a variable
// depending on the direction. This is raw unprocessed data!
// used for real time angle calculations
void hallISR(void) {

    if(direction){
        RealTimePulseCounter_ACW++;
    }
    else{
        RealTimePulseCounter_CW++;
    }


}
