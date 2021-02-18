-----------------
--  Libraries  --
-----------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity pwm_control is
  port (
    -- Clock and reset Signals
    I_RESET_N   : in std_logic;
    I_CLK_50MHZ : in std_logic;

    FREQ_SEL    : in std_logic;
    PWM_OUT     : out std_logic
  );
end entity;

architecture rtl of pwm_control is

  component ROM is
  	port
  	(
  		address : in STD_LOGIC_VECTOR (7 DOWNTO 0);
  		clock		: in STD_LOGIC;
  		q		    : out STD_LOGIC_VECTOR (15 DOWNTO 0)
  	);
  end component ROM;

  -- Signals to
  type FREQ_STATE is
  (
    SIXTY_HZ,
    ONE_HUNDRED_TWENTY_HZ,
    ONE_KHZ
  );

  signal frequency_state : FREQ_STATE := SIXTY_HZ;

  -- Signals to get rom data
  signal i_rom_addr : unsigned(7 downto 0) := (others => '0');
  signal rom_data   : std_logic_vector(15 downto 0);
  signal addr_change : std_logic := '0';

  -- Signals for frequency counter
  signal sixty_hz_counter : unsigned(11 downto 0);
  signal one_twenty_hz_counter : unsigned(21 downto 0);
  signal one_khz_counter : unsigned(21 downto 0);
  signal count_once : std_logic := '0';

  signal pwm_count : unsigned(15 downto 0);
  signal pwm_sig_val : std_logic := '0';
  signal PWM_MODE : std_logic := '1'; -- TODO remove and implement with signal

begin

  ROM_INST : ROM
  port map
  (
    address => std_logic_vector(i_rom_addr),
    clock	  => I_CLK_50MHZ,
    q		    => rom_data
  );

  FREQ_CHANGE : process(I_CLK_50MHZ, I_RESET_N)
  begin
    if (I_RESET_N = '0') then
      frequency_state <= SIXTY_HZ;
    elsif (rising_edge(I_CLK_50MHZ)) then
      if (FREQ_SEL = '0') then
        case( frequency_state ) is
          when SIXTY_HZ =>
            frequency_state <= ONE_HUNDRED_TWENTY_HZ;
          when ONE_HUNDRED_TWENTY_HZ =>
            frequency_state <= ONE_KHZ;
            -- frequency_state <= SIXTY_HZ;
          when ONE_KHZ =>
            frequency_state <= SIXTY_HZ;
        end case;
      end if;
    end if;
  end process FREQ_CHANGE;

  FREQ_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
  begin
    if (I_RESET_N = '0') then
      sixty_hz_counter <= (others => '0');
      one_twenty_hz_counter <= (others => '0');
      i_rom_addr <= (others => '0');
    elsif (rising_edge(I_CLK_50MHZ)) then
      sixty_hz_counter <= sixty_hz_counter + 1;
      one_twenty_hz_counter <= one_twenty_hz_counter + 1;
      addr_change <= '0';
      case(frequency_state) is
        when SIXTY_HZ =>
          if (pwm_count(10 downto 0) = "11111111111") then
            count_once <= '1';
          end if;

          if (sixty_hz_counter = "110010110111") then
            i_rom_addr <= i_rom_addr + 1;
            addr_change <= '1';
            count_once <= '0';
            sixty_hz_counter <= (others => '0');
          end if;

        when ONE_HUNDRED_TWENTY_HZ =>
          if (one_twenty_hz_counter = "11001011100") then
          -- if (one_twenty_hz_counter =‬ "110010110111") then
            i_rom_addr <= i_rom_addr + 1;
            addr_change <= '1';
            count_once <= '0';
            one_twenty_hz_counter <= (others => '0');
          end if;
        when ONE_KHZ =>
          -- TODO add counter for 1KHz
      end case;
    end if;
  end process FREQ_COUNTER;

  PWM_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
  begin
    if (I_RESET_N = '0') then
      pwm_count <= (others => '0');
      pwm_sig_val <= '0';
    elsif (rising_edge(I_CLK_50MHZ)) then
      if (PWM_MODE = '1') then
        pwm_count <= pwm_count + 1;
        case(frequency_state) is
          when SIXTY_HZ =>
            if (pwm_count(10 downto 0) = unsigned(rom_data(15 downto 5))) then
              pwm_sig_val <= '1';
            elsif (pwm_count(10 downto 0) = "11111111111" or addr_change = '1') then
              pwm_count <= (others => '0');  -- Reset counter
              pwm_sig_val <= '0';

            end if;
          when ONE_HUNDRED_TWENTY_HZ =>
            if (pwm_count(8 downto 0) = unsigned(rom_data(15 downto 7))) then
              pwm_sig_val <= '1';
            elsif (pwm_count(8 downto 0) = "111111111" or addr_change = '1') then
              pwm_count <= (others => '0');  -- Reset counter
              pwm_sig_val <= '0';
            end if;
          when ONE_KHZ =>
            -- if (pwm_count(5 downto 0) = unsigned(rom_data(5 downto 0))) then
            --   pwm_sig_val <= '1';
            -- elsif (pwm_count(5 downto 0) = "111111") then
            --   pwm_count <= (others => '0');  -- Reset counter
            --   pwm_sig_val <= '0';
            -- end if;
        end case;
      end if;
    end if;
  end process PWM_COUNTER;

  PWM_OUT <= pwm_sig_val; -- TODO not sure about this
end architecture;
