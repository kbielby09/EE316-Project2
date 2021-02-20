-----------------
--  Libraries  --
-----------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity test_entity is
  port (
    -- Clock and reset Signals
    I_RESET_N   : in std_logic;
    I_CLK_50MHZ : in std_logic;

    -- Outputs to LCD display
    LCD_RW      : out std_logic;
    LCD_EN      : out std_logic;
    LCD_RS      : out std_logic;
    LCD_DATA    : out std_logic_vector(7 downto 0);
    LCD_ON      : out std_logic;
    LCD_BLON    : out std_logic
  );
end entity test_entity;

architecture rtl of test_entity is

  component lcd_driver is
      port(
          -- Clock and reset Signals
          I_RESET_N   : in std_logic;
          I_CLK_50MHZ : in std_logic;

          -- Address and data
          INPUT_ADDR :  in std_logic_vector(7 downto 0);
          INPUT_DATA :  in std_logic_vector(15 downto 0);
          NEW_INPUT  :  in std_logic;

          -- Control Inputs
          SYS_PAUSE    : in  std_logic;
          PWM_GEN_MODE : in  std_logic;
          -- DATA_READY   : out std_logic;

          -- Outputs to LCD display
          LCD_RW      : out std_logic;
          LCD_EN      : out std_logic;
          LCD_RS      : out std_logic;
          LCD_DATA    : out std_logic_vector(7 downto 0);
          LCD_ON      : out std_logic;
          LCD_BLON    : out std_logic;

          -- Output to top entity
          LCD_INITIALIZED : out std_logic
      );
  end component lcd_driver;

  signal new_input_data        : std_logic;
  signal lcd_ready             : std_logic := '0';
  signal lcd_data_in           : unsigned(15 downto 0) := (others  => '0');
  signal lcd_addr_in           : unsigned(7 downto 0)  := (others => '0');
  signal one_hz_counter_signal : unsigned(25 downto 0) := (others => '0');
  signal lcd_init              : std_logic;
  signal pause                 : std_logic;
  signal pwm                   : std_logic;
  signal count_enable          : std_logic;

begin

  LCD_ENTITY : lcd_driver
  port map(
    I_RESET_N       => I_RESET_N,
    I_CLK_50MHZ     => I_CLK_50MHZ,
    INPUT_ADDR      => std_logic_vector(lcd_addr_in),
    INPUT_DATA      => std_logic_vector(lcd_data_in),
    SYS_PAUSE       => pause,
    NEW_INPUT       => new_input_data,
    PWM_GEN_MODE    => pwm,
    LCD_RW          => LCD_RW,
    LCD_EN          => LCD_EN,
    LCD_RS          => LCD_RS,
    LCD_DATA        => LCD_DATA,
    LCD_ON          => LCD_ON,
    LCD_BLON        => LCD_BLON,
    LCD_INITIALIZED => lcd_init
  );


  ONE_HZ_CLOCK : process (I_CLK_50MHZ, I_RESET_N)
   begin
     if(I_RESET_N = '0') then
         one_hz_counter_signal <= (others => '0');
         count_enable          <= '0';
     elsif (rising_edge(I_CLK_50MHZ)) then
          one_hz_counter_signal <= one_hz_counter_signal + 1;
          if (one_hz_counter_signal = "10111110101111000001111111") then
              count_enable <= '1';
              one_hz_counter_signal <= (others => '0');
          else
              count_enable <= '0';
          end if;
     end if;
  end process ONE_HZ_CLOCK;

  TEST_SIGNAL : process(I_CLK_50MHZ, I_RESET_N)
    begin
      if (I_RESET_N = '0') then
      elsif (rising_edge(I_CLK_50MHZ)) then
        if (count_enable = '1' and lcd_ready = '1') then
          lcd_data_in <= lcd_data_in + 1;
          lcd_addr_in <= lcd_addr_in + 1;
          new_input_data <= '1';
        else
          new_input_data <= '0';
        end if;
      end if;
  end process TEST_SIGNAL;

end architecture rtl;
