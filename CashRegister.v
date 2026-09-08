`timescale 1ms / 100ns

module CashRegister(
    input [11:0] Entry,
    input [5:0] Act,
    input Key,ShowD,ShowV,Clr,clk,
    output reg [11:0] Display,
    output reg BluLt, WhtLt, RedLt,
    output reg [1:0] Buzz
    );
    parameter idle = 0;
    parameter transaction = 1;
    parameter item_entry = 2;
    parameter pay_entry = 3;
    parameter void_confirm = 4;
    parameter finished_trans = 5;
    parameter undo = 6;
    parameter admin_mode = 7;
    parameter void_wait = 8;
    
    reg [3:0] state, next_state, prev_state;
    reg[11:0] tally;
    reg[11:0] balance;
    reg paid_flag;
    reg[11:0] daily_tally;
    reg[11:0] prev_tally;
    reg undo_used;
    reg[11:0] void_tally;
    reg prev_paid_flag;
    reg[11:0] cla_a, cla_b;
    reg cla_cin;
    wire[11:0] cla_output;
    wire cla_co;
    wire[11:0] daily_sum;
    wire daily_co;
    wire[11:0] void_sum;
    wire void_co;
    
    CLA_UNIT trans_adder(.A(cla_a),.B(cla_b),.sub(cla_cin),.sum(cla_output),.co(cla_co));
    CLA_UNIT daily_adder(.A(daily_tally),.B(tally),.sub(0),.sum(daily_sum),.co(daily_co));
    CLA_UNIT void_adder(.A(void_tally),.B(tally),.sub(0),.sum(void_sum),.co(void_co));
    
    
    always @(*) begin
    cla_a = tally;
    cla_b = Entry;
    cla_cin = 0;
    if (next_state == item_entry) begin
        cla_a = tally;
        cla_b = Entry;
        cla_cin = 0; 
    end
    else if (next_state == pay_entry) begin
        cla_a = tally;
        cla_b = Entry;
        cla_cin = 1; 
    end
end

    always @(posedge clk or posedge Clr) begin
    if (Clr) begin
        state <= idle;
        tally <= 0;
        balance <= 0;
        paid_flag <= 0;
        undo_used <= 0;
        daily_tally <= 0;
        void_tally <= 0;
        prev_tally <= 0;
        prev_state <= idle;
    end
    else begin
        state <= next_state;
        if (next_state == transaction && state == idle) begin
            tally <= 0;
            balance <= 0;
            paid_flag <= 0;
            undo_used <= 0;
            end
        if (next_state == item_entry && !paid_flag) begin
            prev_state <= transaction;
            prev_tally <= tally;
            prev_paid_flag <= paid_flag;
            tally <= cla_output;
            end
        if (next_state == pay_entry) begin
            prev_state <= transaction;
            prev_tally <= tally;
            prev_paid_flag <= paid_flag;
            balance <= cla_output;
            paid_flag <= 1; 
            end
        if (next_state == finished_trans && state == transaction) begin
            daily_tally <= daily_sum;
            end
         if (next_state == undo) begin
            tally <= prev_tally; 
            paid_flag <= prev_paid_flag;
            undo_used <= 1; 
            end
        if (state == void_confirm && Act[0]) begin
            void_tally <= void_sum; 
            tally <= 0;
            paid_flag <= 0;
            end
        if (next_state == admin_mode && Clr) begin
                daily_tally <= 0; 
                void_tally <= 0;
            end  
    end
 end

    always @(*)begin
        next_state = state;
        
        case(state)
        idle: begin
              if(Act[5]) next_state = transaction;
              else if(!Key) next_state = admin_mode;
              end
        transaction: begin
                     if(Act[4] && !paid_flag) next_state = item_entry;
                     else if(Act[3]) next_state = pay_entry;
                     else if(Act[2]) next_state = finished_trans;
                     else if(Act[1] && !undo_used) next_state = undo;
                     else if(Act[0]) next_state = void_wait;
                     end
        item_entry: next_state = transaction;
        
        pay_entry: next_state = transaction;
        
        finished_trans: begin
                        if(Act[5] || !Key) next_state = idle;
                        end
        
        undo: next_state = transaction;
        
        void_wait: begin
            if(Act[0] == 0)
                next_state = void_confirm;
            end
        
        void_confirm: begin
            if(Act[0]) next_state = idle;
            else if (Act[5:1] != 0) next_state = transaction;
            end
            
        admin_mode: begin
            if(Key)
                next_state = idle;
           end
        endcase
        end
        
    always @(*) begin
        BluLt = 1; WhtLt = 1; RedLt = 1;
        Buzz = 0;
        Display = 0;

        if (state == transaction || state == item_entry || state == undo) begin
            Display = tally;
        end
        else if(state == pay_entry) begin
            Display = balance;
        end
        else if (state == finished_trans) begin
            Display = balance;
            BluLt = 0; 
            if (balance == 0) WhtLt = 0; 
            else if (balance[11] == 1) RedLt = 0;  //NOTE: I had to check online for how to not do balance < 0 https://stackoverflow.com/questions/42545499/comparing-two-numbers-without-comparison-operators-in-verilog
        end
        else if (state == void_confirm || state == void_wait) begin
            Display = tally;
            BluLt = 0; WhtLt = 0; RedLt = 0; 
        end
        else if (state == admin_mode) begin
            if (ShowD) Display = daily_tally; 
            else if (ShowV) Display = void_tally; 

            if (void_tally > 0 && daily_tally <= 0) Buzz = 3;
            else if (void_tally > 0) Buzz = 1;
            else if (daily_tally <= 0) Buzz = 2;
        end
    end
endmodule