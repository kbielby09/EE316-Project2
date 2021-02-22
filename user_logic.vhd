LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity usr_logic is
port( clk : 	in std_logic;
		iData:   in std_logic_vector(15 downto 0) := X"abcd";
		
		oSDA: 	inout Std_logic;
		oSCL:		inout std_logic);

end usr_logic;

architecture behavior of usr_logic is

signal Cont 		: unsigned(19 downto 0) := X"03FFF";
type state_type is (start, write_data, repeat);
signal slave_addr : std_logic_vector(6 downto 0) := "1110001";
signal i2c_addr : std_logic_vector(6 downto 0);
signal state : state_type := start;
signal regBusy, sigBusy, reset_n, i2c_ena, i2c_rw, ack_err : std_logic;
signal data_wr: std_logic_vector(7 downto 0);
signal i2c_data_wr : std_logic_vector(7 downto 0);
signal byteSel : integer := 0;
signal regData: std_logic_vector(15 downto 0);
signal busy_prev : std_logic;

component i2c_master is
GENERIC(
    input_clk : INTEGER := 100_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END component i2c_master;


begin


inst_master : i2c_master
port map(
	clk => clk,
	reset_n => reset_n,
	ena => i2c_ena,
	addr => i2c_addr,
	rw => i2c_rw,
	data_wr => data_wr,
	busy => sigBusy,
	data_rd => OPEN,
	ack_error => ack_err,
	sda => oSDA,
	scl => oSCL);

process(clk)
begin 
if(clk'EVENT and clk = '1') then
	case state is
		when start =>
			if Cont /= X"00000" then
				Cont <= Cont -1;
				reset_n <= '0';
				state <= start;
				i2c_ena <= '0';
			else
				reset_n <= '1';
				i2c_ena <= '1';
				i2c_addr <= slave_addr;
				i2c_rw <= '0';
				i2c_data_wr <= data_wr;
				state <= write_data;
			end if;
		when write_data =>
		regBusy <= sigBusy;
		regData<=iData;
		if regBusy/=sigBusy and sigBusy='0' then
			if byteSel /= 12 then
				byteSel <= byteSel + 1;
				state <= write_data;
				
			else 
				byteSel<= 8;
				i2c_ena <= '0';
				state <= repeat;
			end if;
		end if;
			
		when repeat =>
			i2c_ena <= '0';
			if regData /= iData then
				Cont <= X"03FFF";
				state <= start;
			else	
				state <= repeat;
	
			end if;
		end case;
end if;
end process;

process(byteSel)
begin
	case byteSel is
		when 0 => data_wr <= X"76";
		when 1 => data_wr <= X"76";
		when 2 => data_wr <= X"76";
		when 3 => data_wr <= X"7A";
		when 4 => data_wr <= X"FF";
		when 5 => data_wr <= X"77";
		when 6 => data_wr <= X"00";
		when 7 => data_wr <= X"79";
		when 8 => data_wr <= X"00";
		when 9 => data_wr <= X"0"&iData(15 downto 12);
		when 10 => data_wr <= X"0"&iData(11 downto 8);
		when 11 => data_wr <= X"0"&iData(7 downto 4);
		when 12 => data_wr <= X"0"&iData(3 downto 0);
		when others => data_wr <= X"76";
	end case;
end process;


end behavior;
