



// block for H_scan: 1-1040 
always@(posedge reset or posedge clk)
  if(reset)                 H_scan= 11'h000;
  else if(H_scan== 11'd1040)  H_scan= 11'h001;
  else                    H_scan= H_scan+11'h001; 
// block for V_scan: 1-666 
always@(posedge reset or posedge clk)
  if(reset)                 V_scan= 11'h000;
  else if(V_scan== 11'd666 &&
H_can== 11'd1040 )  V_scan= 11'h001;
  else if(H_scan== 11'd1040)  V_scan= V_scan+11'h001; 
  else                     V_scan= V_scan;

// block for H_on and V_on
assign  H_on= (H_scan>= 11'd0105 && H_scan<= 11'd0904);
assign  V_on= (V_scan>= 11'd0024 && V_scan<= 11'd0623);

// block for h_sync and v_sync
assign  h_sync= 
~(H_scan>= 11'd0921 && H_scan<= 11'd1040);
assign  v_sync= 
~(V_scan>= 11'd0661 && V_scan<= 11'd0666);

// block for X_pix and Y_pix
assign  X_pix= (H_scan>11'd0104 && H_scan<11'd0905)? H_scan - 11'd0104 : 11'd0000;
assign  Y_pix= (V_scan>11'd0023 && V_scan<11'd0624)? V_scan - 11'd0023 : 11'd0000;
