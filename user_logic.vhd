LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity usr_logic is
port( clk : 	in std_logic;
			reset_n: out std_logic;
			i2c_ena: out std_logic;
			i2c_addr: out std_logic_vector(6 downto 0);

			i2c_rw:	out std_logic;
			i2c_data_wr: out std_logic_vector(7 downto 0);
			data_rd: out std_logic_vector(7 downto 0);
			ack_error: buffer std_logic;
			busy: out std_logic);

end usr_logic;

architecture behavior of usr_logic is
signal Cont 		: unsigned(19 downto 0) := X"03FFF";
type state_type is (start, write_data, repeat);
signal slave_addr : std_logic_vector(6 downto 0);
signal state : state_type := start;
signal data_wr: std_logic_vector(7 downto 0);
signal byteSel : integer := 0;

begin
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
		when write_data => --WORKING ON THIS NOW
			if byteSel /= 12 then

			else
      end if;
    when repeat => --WORKING ON THIS NOW

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
