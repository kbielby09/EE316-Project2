-----------------
--  Libraries  --
-----------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity digit_write is
  port (
    -- Clock and reset Signals
    I_RESET_N   : in std_logic;
    I_CLK_50MHZ : in std_logic;

    CURRENT_MODE : in  std_logic_vector(1 downto 0);
    FREQUENCY    : in std_logic_vector(1 downto 0);

    LCD_RW      : out std_logic;
    LCD_EN      : out std_logic;
    LCD_RS      : out std_logic;
    LCD_DATA    : out std_logic_vector(7 downto 0);
    LCD_ON      : out std_logic;
    LCD_BLON    : out std_logic;

    -- Address and data
    INPUT_ADDR :  in std_logic_vector(7 downto 0);
    INPUT_DATA :  in std_logic_vector(15 downto 0)

  );
end entity;

architecture arch of digit_write is

  component lcd_driver is
      port(
          I_RESET_N   : in std_logic;
          I_CLK_50MHZ : in std_logic;
          INPUT_DATA   : in std_logic_vector(31 downto 0);
          INPUT_ADDR   : in std_logic_vector(15 downto 0);
          CURRENT_MODE : in  std_logic_vector(1 downto 0);
          FREQUENCY    : in std_logic_vector(1 downto 0);
          DATA_CHANGE  : in std_logic;
          LCD_RW      : out std_logic;
          LCD_EN      : out std_logic;
          LCD_RS      : out std_logic;
          LCD_DATA    : out std_logic_vector(7 downto 0);
          LCD_ON      : out std_logic;
          LCD_BLON    : out std_logic
      );
  end component lcd_driver;

  component input_to_ascii is
    port (
      I_RESET_N   : in std_logic;
      I_CLK_50MHZ : in std_logic;
      data_ascii_out : out std_logic_vector(31 downto 0);
      addr_ascii_out : out std_logic_vector(15 downto 0);
      INPUT_ADDR     : in std_logic_vector(7 downto 0);
      INPUT_DATA     : in std_logic_vector(15 downto 0)
    );
  end component;

  signal converted_data : std_logic_vector(31 downto 0);
  signal converted_addr : std_logic_vector(15 downto 0);

  signal previous_mode : std_logic_vector(1 downto 0);
  signal previous_data : std_logic_vector(15 downto 0);
  signal previous_frequency : std_logic_vector(1 downto 0);

  signal s_data_change : std_logic := '0';

begin

  CONVERT : input_to_ascii
  port map(
    I_RESET_N      => I_RESET_N,
    I_CLK_50MHZ    => I_CLK_50MHZ,
    data_ascii_out => converted_data,
    addr_ascii_out => converted_addr,
    INPUT_ADDR     => INPUT_ADDR,
    INPUT_DATA     => INPUT_DATA
  );

  LCD : lcd_driver
  port map(
    I_RESET_N    => I_RESET_N,
    I_CLK_50MHZ  => I_CLK_50MHZ,
    INPUT_DATA   => converted_data,
    INPUT_ADDR   => converted_addr,
    CURRENT_MODE => CURRENT_MODE,
    FREQUENCY    => FREQUENCY,
    DATA_CHANGE  => s_data_change,
    LCD_RW       => LCD_RW,
    LCD_EN       => LCD_EN,
    LCD_RS       => LCD_RS,
    LCD_DATA     => LCD_DATA,
    LCD_ON       => LCD_ON,
    LCD_BLON     => LCD_BLON
  );

  DIGIT_COUNT : process(I_CLK_50MHZ, I_RESET_N)
  begin
    if (I_RESET_N = '0') then
      previous_mode <= (others => '0');
      previous_data <= (others => '0');
    elsif (rising_edge(I_CLK_50MHZ)) then
      previous_mode <= CURRENT_MODE;
      previous_data <= INPUT_DATA;
      previous_frequency <= FREQUENCY;
      if (previous_mode /= CURRENT_MODE
          or previous_data /= INPUT_DATA
          or previous_frequency /= FREQUENCY) then
        s_data_change <= '1';
      else
        s_data_change <= '0';
      end if;
    end if;
  end process;

end architecture;
