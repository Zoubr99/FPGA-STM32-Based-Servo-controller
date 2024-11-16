// SPI Slave (behavioural model)
// v1.0
// Nicholas Outram (University of Plymouth)

module my_spi_sv #(parameter N = 16) (
    input logic sclk,         // SPI Clock
    input logic cs,           // Chip select
    input logic mosi,         // Master Out Slave In (MOSI)
    output logic miso,        // Master In Slave Out (MISO)
    input logic reset,        // Asynchronous Reset
    input logic [N-1:0] data_tx,  // Parallel N-bit data to return back to the master
    output logic [N-1:0] data_rx, // Parallel N-bit data received from the master
    output logic busyrx,      // Do not read data_rx while high
    output logic busytx       // Do not write data_tx while high
);

    logic [N-1:0] sregin = '0;   // Shift register for incoming data
    logic [N-1:0] rx = '0;       // Receive Register
    logic [N-1:0] sregout = '0;  // Shift register for outgoing data
    logic busytx_sync;           // Synchronous busy signal
    logic sof;                   // Start of frame internal signal

    // Clock incoming data in on the rising edge of SCLK and store in data_rx once all N bits are received
    always_ff @(posedge sclk, negedge reset)
    begin
        if (~reset) begin
            sregin  <= '0;
            rx      <= '0;
            busyrx <= '0;
        end else if (~cs) begin
            sregin  <= {sregin[N-2:0], mosi};
            if (sof) begin
                rx <= {sregin[N-2:0], mosi};
                busyrx <= '1;
            end else begin
                busyrx <= '0;
            end
            if (|sregin[N-1:0]) begin
                sof <= '1;
            end else begin
                sof <= '0;
            end
        end else begin
            sregin  <= '0;
            busyrx <= '0;
            sof <= '0;
        end
    end

    assign data_rx = rx;

    // Transmit logic
    always_ff @(posedge sclk, negedge reset)
    begin
        if (~reset) begin
            sregout <= '0;          // Reset internal shift register to all zeros
            busytx_sync <= '0;      // Reset state
        end else if (~cs) begin
            if (|data_tx) begin
                sregout <= data_tx;  // Pre-load shift register
            end
            if (busytx_sync) begin
                busytx <= '1;
            end else begin
                busytx <= '0;
            end
            if (sregout[N-1]) begin
                miso <= 1'b1;
            end else begin
                miso <= 1'b0;
            end
            sregout <= {sregout[N-2:0], 1'b0};
        end else begin
            sregout <= '0;
            busytx <= '0;
        end
    end

endmodule
