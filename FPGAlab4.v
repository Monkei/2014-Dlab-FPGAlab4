

//-------------------------------------------
//1.coding for VGA H_sync/V_sync and display coordinates
//----------------------------------------------
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


//------------------------------------------
//coding for RGB control block
//------------------------------------------
assign  R= RR;
assign  G= GG;            			  
assign  B= BB;


//---------------------------------------
//3.coding for BTN0/1/2 debouncing block
//---------------------------------------
always@(posedge reset or posedge clk)
 if(reset)      debcnt0= 20'h00000; 
 else if(btn0 && debcnt0<20'hFFFFE)   
debcnt0= debcnt0+20'h00001;
 else if(~btn0 && debcnt0==20'hffffe) 
debcnt0= 20'h00000;
 else if(~btn0 && debcnt0!=20'h00000) 
debcnt0= debcnt0;
 else          debcnt0= debcnt0;

always@(posedge reset or posedge clk)
 if(reset)      debcnt1= 20'h00000; 
 else if(btn1 && debcnt1<20'hFFFFE)   
debcnt1= debcnt1+20'h00001;
 else if(~btn1 && debcnt1==20'hffffe) 
debcnt1= 20'h00000;
 else if(~btn1 && debcnt1!=20'h00000) 
debcnt1= debcnt1;
 else        debcnt1= debcnt1;

always@(posedge reset or posedge clk)
 if(reset)     debcnt2= 20'h00000; 
 else if(btn2 && debcnt2<20'hFFFFE)  
 debcnt2= debcnt2+20'h00001;
 else if(~btn2 && debcnt2==20'hffffe) 
debcnt2= 20'h00000;
 else if(~btn2 && debcnt2!=20'h00000) 
debcnt2= debcnt2;
 else        debcnt2= debcnt2;


//---------------------------------------
//4.coding for block for MONSTER movement triggering block
//---------------------------------------
always@(posedge reset or posedge clk)
 if(reset)      slow_clk= 20'h00000; 
 else         slow_clk= slow_clk+20'h00001;
assign  mvclk= (slow_clk==20'hFFFFE)? 1:0;

// block for act_cnt control: 0-1-2
always@(posedge reset or negedge clk)  
  if(reset)              act_cnt= 3'b000;
  else if(~mvclk)         act_cnt= act_cnt; 
  else if(act_cnt==3'b100)  act_cnt=3'b000;
  else 				   act_cnt= act_cnt+3'b001;

// block for MONSTER moving “direction” control
// mvdir_indx:         10: leftward   11: rightward
//                   00: upward    01: downward
always@(posedge reset or negedge clk)        
if(reset)                   mvdir_indx= 2'b11; 
else if(debcnt0==20'h2FFFE)  mvdir_indx=
 {mvdir_indx[1], ~mvdir_indx[0]};
else if(debcnt1==20'h2FFFE)  mvdir_indx= ~mvdir_indx;
else if(debcnt2==20'h2FFFE)  mvdir_indx= {~mvdir_indx[1], mvdir_indx[0]};
else                      mvdir_indx= mvdir_indx;
// block for MONSTER moving “location” control
parameter   delta_x=11'h001, delta_y=11'h001;
always@(posedge reset or posedge clk)
  if(reset)       {body_x, body_y}= {11'd0400, 11'd0300};
  else if(~gostop) {body_x, body_y}= {body_x, body_y};
  else if(mvclk)
      // begin 
       if(mvdir_indx==2'b11)           // moving right 
		  body_x= (body_x+11'd0032+delta_x<11'd0800)? 
               body_x+delta_x :  body_x;
       else if(mvdir_indx==2'b10)       // moving left
		  body_x= (body_x>delta_x)?                     
               body_x-delta_x :  body_x;
       else if(mvdir_indx==2'b00)       // moving up
		  body_y= (body_y>delta_y)?                     
               body_y-delta_y :  body_y;
       else                         // moving down
 body_y= (body_y+11'd32+delta_y<11'd0600)?     
               body_y+delta_y :  body_y;
  else {body_x, body_y}={body_x, body_y};			


//---------------------------------------------
//5.coding for 'start-stop' block
//-----------------------------------------
always@(posedge reset or posedge clk)
 if(reset)            debcnt= 20'h00000; 
 else if(rot_dwn && debcnt<20'hFFFFE)    
debcnt= debcnt+20'h00001;
 else if(~rot_dwn && debcnt==20'hffffe)  
debcnt= 20'h00000;
 else if(~rot_dwn && debcnt!=20'h00000)  
debcnt= debcnt;
 else              debcnt= debcnt;
assign gostop1= 
(debcnt== 20'hFFFFE || debcnt== 20'hFFFFD)? 1 : 0;
always@(posedge reset or posedge clk)
 if(reset)    gostop2= 1'b0;
 else       gostop2= gostop1; 
assign      gostop3= gostop1 && ~gostop2;
always@(posedge reset or negedge clk)
if(reset)         gostop= 1'b0;
else if(gostop3)  gostop= ~gostop;
else           gostop= gostop; 


//----------------------------------------------
//6.
//----------------------------------------------
// 32x32 MNSTR
//  moving rightward:  
//     Rmvbody : Rmvjaw0  …act0 in a sequence of 5 flicks
//             : Rmvjaw1  …act1 in a sequence of 5 flicks
//             : Rmvjaw2  …act2 in a sequence of 5 flicks
//  moving leftward:  
//     Lmvbody : Lmvjaw0  …act0 in a sequence of 5 flicks
//             : Lmvjaw1  …act1 in a sequence of 5 flicks
//             : Lmvjaw2  …act2 in a sequence of 5 flicks
always@*
  case(MNSTR_y[4:0])
  5'h00:   Rmvbody= 16'h000F;
  5'h01:   Rmvbody= 16'h007F;
  5'h02:   Rmvbody= 16'h00FF;
  5'h03:   Rmvbody= 16'h03FF;
  5'h04:   Rmvbody= 16'h07FF;
  5'h05:   Rmvbody= 16'h0FFF;
  5'h06:   Rmvbody= 16'h1FFF;
  5'h07:   Rmvbody= 16'h3FFF;
  5'h08:   Rmvbody= 16'h3FFF;
  5'h09:   Rmvbody= 16'h3FFF;
  5'h0A:   Rmvbody= 16'h7FFF;
  5'h0B:   Rmvbody= 16'h7FFF;
  5'h0C:   Rmvbody= 16'h7FFF;
  5'h0D:   Rmvbody= 16'hFFFF;
  5'h0E:   Rmvbody= 16'hFFFF;
  5'h0F:   Rmvbody= 16'hFFFF;
  5'h1F:   Rmvbody= 16'h000F;
  5'h1E:   Rmvbody= 16'h007F;
  5'h1D:   Rmvbody= 16'h00FF;
  5'h1C:   Rmvbody= 16'h03FF;
  5'h1B:   Rmvbody= 16'h07FF;
  5'h1A:   Rmvbody= 16'h0FFF;
  5'h19:   Rmvbody= 16'h1FFF;
  5'h18:   Rmvbody= 16'h3FFF;
  5'h17:   Rmvbody= 16'h3FFF;
  5'h16:   Rmvbody= 16'h3FFF;
  5'h15:   Rmvbody= 16'h7FFF;
  5'h14:   Rmvbody= 16'h7FFF;
  5'h13:   Rmvbody= 16'h7FFF;
  5'h12:   Rmvbody= 16'hFFFF;
  5'h11:   Rmvbody= 16'hFFFF;
  5'h10:   Rmvbody= 16'hFFFF;
  default:  Rmvbody= 16'h0000;
  endcase

always@*
  case(MNSTR_y[4:0])
  5'h00:   Lmvbody= 16'hF000;
  5'h01:   Lmvbody= 16'hFE00;
  5'h02:   Lmvbody= 16'hFF00;
  5'h03:   Lmvbody= 16'hFFC0;
  5'h04:   Lmvbody= 16'hFFE0;
  5'h05:   Lmvbody= 16'hFFF0;
  5'h06:   Lmvbody= 16'hFFF8;
  5'h07:   Lmvbody= 16'hFFFC;
  5'h08:   Lmvbody= 16'hFFFC;
  5'h09:   Lmvbody= 16'hFFFC;
  5'h0A:   Lmvbody= 16'hFFFE;
  5'h0B:   Lmvbody= 16'hFFFE;
  5'h0C:   Lmvbody= 16'hFFFE;
  5'h0D:   Lmvbody= 16'hFFFF;
  5'h0E:   Lmvbody= 16'hFFFF;
  5'h0F:   Lmvbody= 16'hFFFF;
  5'h1F:   Lmvbody= 16'hF000;
  5'h1E:   Lmvbody= 16'hFE00;
  5'h1D:   Lmvbody= 16'hFF00;
  5'h1C:   Lmvbody= 16'hFFC0;
  5'h1B:   Lmvbody= 16'hFFE0;
  5'h1A:   Lmvbody= 16'hFFF0;
  5'h19:   Lmvbody= 16'hFFF8;
  5'h18:   Lmvbody= 16'hFFFC;
  5'h17:   Lmvbody= 16'hFFFC;
  5'h16:   Lmvbody= 16'hFFFC;
  5'h15:   Lmvbody= 16'hFFFE;
  5'h14:   Lmvbody= 16'hFFFE;
  5'h13:   Lmvbody= 16'hFFFE;
  5'h12:   Lmvbody= 16'hFFFF;
  5'h11:   Lmvbody= 16'hFFFF;
  5'h10:   Lmvbody= 16'hFFFF;
  default: Lmvbody= 16'h0000;
  endcase

always@(*)
  case(MNSTR_y[4:0])
  5'h00:   Rmvjaw0= 16'hE000;
  5'h01:   Rmvjaw0= 16'hF800;
  5'h02:   Rmvjaw0= 16'hFE00;
  5'h03:   Rmvjaw0= 16'hFC00;
  5'h04:   Rmvjaw0= 16'hFFC0;
  5'h05:   Rmvjaw0= 16'hFFE0;
  5'h06:   Rmvjaw0= 16'hFFC0;
  5'h07:   Rmvjaw0= 16'hFF80;
  5'h08:   Rmvjaw0= 16'hFF00;
  5'h09:   Rmvjaw0= 16'hFE00;
  5'h0A:   Rmvjaw0= 16'hFC00;
  5'h0B:   Rmvjaw0= 16'hF800;
  5'h0C:   Rmvjaw0= 16'hF000;
  5'h0D:   Rmvjaw0= 16'hE000;
  5'h0E:   Rmvjaw0= 16'hC000;
  5'h0F:   Rmvjaw0= 16'h8000;
  5'h1F:   Rmvjaw0= 16'hE000;
  5'h1E:   Rmvjaw0= 16'hF800;
  5'h1D:   Rmvjaw0= 16'hFE00;
  5'h1C:   Rmvjaw0= 16'hFC00;
  5'h1B:   Rmvjaw0= 16'hFFC0;
  5'h1A:   Rmvjaw0= 16'hFFE0;
  5'h19:   Rmvjaw0= 16'hFFC0;
  5'h18:   Rmvjaw0= 16'hFF80;
  5'h17:   Rmvjaw0= 16'hFF00;
  5'h16:   Rmvjaw0= 16'hFE00;
  5'h15:   Rmvjaw0= 16'hFC00;
  5'h14:   Rmvjaw0= 16'hF800;
  5'h13:   Rmvjaw0= 16'hF000;
  5'h12:   Rmvjaw0= 16'hE000;
  5'h11:   Rmvjaw0= 16'hC000;
  5'h10:   Rmvjaw0= 16'h8000;
  default: Rmvjaw0= 16'h0000;
  endcase
  
always@*
  case(MNSTR_y[4:0])
  5'h00:   Rmvjaw1= 16'hE000;
  5'h01:   Rmvjaw1= 16'hF800;
  5'h02:   Rmvjaw1= 16'hFE00;
  5'h03:   Rmvjaw1= 16'hFF00;
  5'h04:   Rmvjaw1= 16'hFF80;
  5'h05:   Rmvjaw1= 16'hFFC0;
  5'h06:   Rmvjaw1= 16'hFFE0;
  5'h07:   Rmvjaw1= 16'hFFF0;
  5'h08:   Rmvjaw1= 16'hFFF0;
  5'h09:   Rmvjaw1= 16'hFFF8;
  5'h0A:   Rmvjaw1= 16'hFFE0;
  5'h0B:   Rmvjaw1= 16'hFFC0;
  5'h0C:   Rmvjaw1= 16'hFF00;
  5'h0D:   Rmvjaw1= 16'hF800;
  5'h0E:   Rmvjaw1= 16'hE000;
  5'h0F:   Rmvjaw1= 16'hC000;
  5'h1F:   Rmvjaw1= 16'hE000;
  5'h1E:   Rmvjaw1= 16'hF800;
  5'h1D:   Rmvjaw1= 16'hFE00;
  5'h1C:   Rmvjaw1= 16'hFF00;
  5'h1B:   Rmvjaw1= 16'hFF80;
  5'h1A:   Rmvjaw1= 16'hFFC0;
  5'h19:   Rmvjaw1= 16'hFFE0;
  5'h18:   Rmvjaw1= 16'hFFF0;
  5'h17:   Rmvjaw1= 16'hFFF0;
  5'h16:   Rmvjaw1= 16'hFFF8;
  5'h15:   Rmvjaw1= 16'hFFE0;
  5'h14:   Rmvjaw1= 16'hFFC0;
  5'h13:   Rmvjaw1= 16'hFF00;
  5'h12:   Rmvjaw1= 16'hF800;
  5'h11:   Rmvjaw1= 16'hE000;
  5'h10:   Rmvjaw1= 16'hC000;
  default: Rmvjaw1= 16'h0000;
  endcase
 
always@*
  case(MNSTR_y[4:0])
  5'h00:   Rmvjaw2= 16'hE000;
  5'h01:   Rmvjaw2= 16'hF800;
  5'h02:   Rmvjaw2= 16'hFE00;
  5'h03:   Rmvjaw2= 16'hFF00;
  5'h04:   Rmvjaw2= 16'hFF80;
  5'h05:   Rmvjaw2= 16'hFFC0;
  5'h06:   Rmvjaw2= 16'hFFE0;
  5'h07:   Rmvjaw2= 16'hFFF0;
  5'h08:   Rmvjaw2= 16'hFFF8;
  5'h09:   Rmvjaw2= 16'hFFFC;
  5'h0A:   Rmvjaw2= 16'hFFFE;
  5'h0B:   Rmvjaw2= 16'hFFFF;
  5'h0C:   Rmvjaw2= 16'hFFFF;
  5'h0D:   Rmvjaw2= 16'hFFFF;
  5'h0E:   Rmvjaw2= 16'hFFC0;
  5'h0F:   Rmvjaw2= 16'hD000;
  5'h1F:   Rmvjaw2= 16'hE000;
  5'h1E:   Rmvjaw2= 16'hF800;
  5'h1D:   Rmvjaw2= 16'hFE00;
  5'h1C:   Rmvjaw2= 16'hFF00;
  5'h1B:   Rmvjaw2= 16'hFF80;
  5'h1A:   Rmvjaw2= 16'hFFC0;
  5'h19:   Rmvjaw2= 16'hFFE0;
  5'h18:   Rmvjaw2= 16'hFFF0;
  5'h17:   Rmvjaw2= 16'hFFF8;
  5'h16:   Rmvjaw2= 16'hFFFC;
  5'h15:   Rmvjaw2= 16'hFFFE;
  5'h14:   Rmvjaw2= 16'hFFFF;
  5'h13:   Rmvjaw2= 16'hFFFF;
  5'h12:   Rmvjaw2= 16'hFFFF;
  5'h11:   Rmvjaw2= 16'hFFC0;
  5'h10:   Rmvjaw2= 16'hD000;
  default: Rmvjaw2= 16'h0000;
  endcase

always@(*)
  case(MNSTR_y[4:0])
  5'h00:   Lmvjaw0= 16'h0007;
  5'h01:   Lmvjaw0= 16'h001F;
  5'h02:   Lmvjaw0= 16'h007F;
  5'h03:   Lmvjaw0= 16'h00FF;
  5'h04:   Lmvjaw0= 16'h03FF;
  5'h05:   Lmvjaw0= 16'h07FF;
  5'h06:   Lmvjaw0= 16'h03FF;
  5'h07:   Lmvjaw0= 16'h01FF;
  5'h08:   Lmvjaw0= 16'h00FF;
  5'h09:   Lmvjaw0= 16'h007F;
  5'h0A:   Lmvjaw0= 16'h003F;
  5'h0B:   Lmvjaw0= 16'h001F;
  5'h0C:   Lmvjaw0= 16'h000F;
  5'h0D:   Lmvjaw0= 16'h0007;
  5'h0E:   Lmvjaw0= 16'h0003;
  5'h0F:   Lmvjaw0= 16'h0001;
  5'h1F:   Lmvjaw0= 16'h0007;
  5'h1E:   Lmvjaw0= 16'h001F;
  5'h1D:   Lmvjaw0= 16'h007F;
  5'h1C:   Lmvjaw0= 16'h00FF;
  5'h1B:   Lmvjaw0= 16'h03FF;
  5'h1A:   Lmvjaw0= 16'h07FF;
  5'h19:   Lmvjaw0= 16'h03FF;
  5'h18:   Lmvjaw0= 16'h01FF;
  5'h17:   Lmvjaw0= 16'h00FF;
  5'h16:   Lmvjaw0= 16'h007F;
  5'h15:   Lmvjaw0= 16'h003F;
  5'h14:   Lmvjaw0= 16'h001F;
  5'h13:   Lmvjaw0= 16'h000F;
  5'h12:   Lmvjaw0= 16'h0007;
  5'h11:   Lmvjaw0= 16'h0003;
  5'h10:   Lmvjaw0= 16'h0001;
  default: Lmvjaw0= 16'h0000;
  endcase

always@(*)
  case(MNSTR_y[4:0])
  5'h00:   Lmvjaw1= 16'h0007;
  5'h01:   Lmvjaw1= 16'h001F;
  5'h02:   Lmvjaw1= 16'h007F;
  5'h03:   Lmvjaw1= 16'h00FF;
  5'h04:   Lmvjaw1= 16'h01FF;
  5'h05:   Lmvjaw1= 16'h03FF;
  5'h06:   Lmvjaw1= 16'h07FF;
  5'h07:   Lmvjaw1= 16'h0FFF;
  5'h08:   Lmvjaw1= 16'h0FFF;
  5'h09:   Lmvjaw1= 16'h1FFF;
  5'h0A:   Lmvjaw1= 16'h07FF;
  5'h0B:   Lmvjaw1= 16'h03FF;
  5'h0C:   Lmvjaw1= 16'h00FF;
  5'h0D:   Lmvjaw1= 16'h001F;
  5'h0E:   Lmvjaw1= 16'h0007;
  5'h0F:   Lmvjaw1= 16'h0003;
  5'h1F:   Lmvjaw1= 16'h0007;
  5'h1E:   Lmvjaw1= 16'h001F;
  5'h1D:   Lmvjaw1= 16'h007F;
  5'h1C:   Lmvjaw1= 16'h00FF;
  5'h1B:   Lmvjaw1= 16'h01FF;
  5'h1A:   Lmvjaw1= 16'h03FF;
  5'h19:   Lmvjaw1= 16'h07FF;
  5'h18:   Lmvjaw1= 16'h0FFF;
  5'h17:   Lmvjaw1= 16'h0FFF;
  5'h16:   Lmvjaw1= 16'h1FFF;
  5'h15:   Lmvjaw1= 16'h07FF;
  5'h14:   Lmvjaw1= 16'h03FF;
  5'h13:   Lmvjaw1= 16'h00FF;
  5'h12:   Lmvjaw1= 16'h001F;
  5'h11:   Lmvjaw1= 16'h0007;
  5'h10:   Lmvjaw1= 16'h0003;  
  default: Lmvjaw1= 16'h0000;
  endcase
  
  always@(*)
  case(MNSTR_y[4:0])
  5'h00:   Lmvjaw2= 16'h0007;
  5'h01:   Lmvjaw2= 16'h001F;
  5'h02:   Lmvjaw2= 16'h007F;
  5'h03:   Lmvjaw2= 16'h00FF;
  5'h04:   Lmvjaw2= 16'h01FF;
  5'h05:   Lmvjaw2= 16'h03FF;
  5'h06:   Lmvjaw2= 16'h07FF;
  5'h07:   Lmvjaw2= 16'h0FFF;
  5'h08:   Lmvjaw2= 16'h1FFF;
  5'h09:   Lmvjaw2= 16'h3FFF;
  5'h0A:   Lmvjaw2= 16'h7FFF;
  5'h0B:   Lmvjaw2= 16'hFFFF;
  5'h0C:   Lmvjaw2= 16'hFFFF;
  5'h0D:   Lmvjaw2= 16'hFFFF;
  5'h0E:   Lmvjaw2= 16'h03FF;
  5'h0F:   Lmvjaw2= 16'h0007;
  5'h1F:   Lmvjaw2= 16'h0007;
  5'h1E:   Lmvjaw2= 16'h001F;
  5'h1D:   Lmvjaw2= 16'h007F;
  5'h1C:   Lmvjaw2= 16'h00FF;
  5'h1B:   Lmvjaw2= 16'h01FF;
  5'h1A:   Lmvjaw2= 16'h03FF;
  5'h19:   Lmvjaw2= 16'h07FF;
  5'h18:   Lmvjaw2= 16'h0FFF;
  5'h17:   Lmvjaw2= 16'h1FFF;
  5'h16:   Lmvjaw2= 16'h3FFF;
  5'h15:   Lmvjaw2= 16'h7FFF;
  5'h14:   Lmvjaw2= 16'hFFFF;
  5'h13:   Lmvjaw2= 16'hFFFF;
  5'h12:   Lmvjaw2= 16'hFFFF;
  5'h11:   Lmvjaw2= 16'h03FF;
  5'h10:   Lmvjaw2= 16'h0007; 
  default: Lmvjaw2= 16'h0000;
  endcase
