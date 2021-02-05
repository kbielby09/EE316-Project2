-----------------
--  Libraries  --
-----------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity key_counter is
    port(
    -- Clocks & Resets
    I_CLK_50MHZ    : in  std_logic;
    I_SYSTEM_RST    : in  std_logic;

    -- Keypad Inputs (rows)
    I_KEYPAD_ROW_1  : in  std_logic;
    I_KEYPAD_ROW_2  : in  std_logic;
    I_KEYPAD_ROW_3  : in  std_logic;
    I_KEYPAD_ROW_4  : in  std_logic;
    I_KEYPAD_ROW_5  : in  std_logic;

    -- Keypad Outputs (cols)
    O_KEYPAD_COL_1  : out std_logic;
    O_KEYPAD_COL_2  : out std_logic;
    O_KEYPAD_COL_3  : out std_logic;
    O_KEYPAD_COL_4  : out std_logic;

    OP_MODE         : out std_logic;

    -- Function key output
    H_KEY_OUT  : out std_logic;
    L_KEY_OUT  : out std_logic;

    O_KEY_ADDR : out std_logic_vector(17 downto 0);

    KEY_DATA_OUT : out std_logic_vector(15 downto 0));

end key_counter;

architecture rtl of key_counter is

  component hex_keypad_driver is
  port
  (
    -- Clocks & Resets
    I_CLK_50MHZ    : in  std_logic;
    I_SYSTEM_RST    : in  std_logic;

    -- Keypad Inputs (rows)
    I_KEYPAD_ROW_1  : in  std_logic;
    I_KEYPAD_ROW_2  : in  std_logic;
    I_KEYPAD_ROW_3  : in  std_logic;
    I_KEYPAD_ROW_4  : in  std_logic;
    I_KEYPAD_ROW_5  : in  std_logic;

    -- Keypad Outputs (cols)
    O_KEYPAD_COL_1  : out std_logic;
    O_KEYPAD_COL_2  : out std_logic;
    O_KEYPAD_COL_3  : out std_logic;
    O_KEYPAD_COL_4  : out std_logic;

    -- Function key output
    H_KEY_OUT  : out std_logic;
    L_KEY_OUT  : out std_logic;
    SHIFT_PRESSED : out std_logic;

    -- Output trigger for key pressed
    KEY_PRESSED : out std_logic;

    -- 4 bit binary representation of keypad state (output of entity)
    O_KEYPAD_BINARY : out std_logic_vector(3 downto 0)

  );
end component hex_keypad_driver;

    signal data_in : std_logic_vector(15 downto 0);
    signal addr_in : std_logic_vector(17 downto 0);

    signal key_pressed_signal : std_logic;

    signal shift_pressed_signal : std_logic;
    signal h_key_pressed_signal : std_logic;
    signal l_key_pressed_signal : std_logic;

    signal address_input        : std_logic := '0';

    signal key_value : std_logic_vector(3 downto 0);

begin
    KEY_DRIVER : hex_keypad_driver
        port map(
            I_CLK_50MHZ => I_CLK_50MHZ,
            I_SYSTEM_RST => I_SYSTEM_RST,
            I_KEYPAD_ROW_1 => I_KEYPAD_ROW_1,
            I_KEYPAD_ROW_2 => I_KEYPAD_ROW_2,
            I_KEYPAD_ROW_3 => I_KEYPAD_ROW_3,
            I_KEYPAD_ROW_4 => I_KEYPAD_ROW_4,
            I_KEYPAD_ROW_5 => I_KEYPAD_ROW_5,

            O_KEYPAD_COL_1 => O_KEYPAD_COL_1,
            O_KEYPAD_COL_2 => O_KEYPAD_COL_2,
            O_KEYPAD_COL_3 => O_KEYPAD_COL_3,
            O_KEYPAD_COL_4 => O_KEYPAD_COL_4,

            H_KEY_OUT => H_KEY_OUT,
            L_KEY_OUT => L_KEY_OUT,
            SHIFT_PRESSED => shift_pressed_signal,

            KEY_PRESSED => key_pressed_signal,

            O_KEYPAD_BINARY => key_value
        );

    SHIFT_KEYS : process(I_CLK_50MHZ)
        begin
            if (rising_edge(I_CLK_50MHZ) and key_pressed_signal = '1') then
                if (address_input = '1') then

                elsif (address_input = '0') then
                  data_in(3 downto 0) <= key_value;
                  data_in(7 downto 4) <= data_in(3 downto 0);
                  data_in(11 downto 8) <= data_in(7 downto 4);
                  data_in(15 downto 12) <= data_in(11 downto 8);
                  -- data_in(15 downto 4) <= data_in(11 downto 0);
                end if;

            end if;
    end process SHIFT_KEYS;

    OP_MODE <= shift_pressed_signal;
    O_KEY_ADDR <= addr_in;
    KEY_DATA_OUT <= data_in;

end architecture rtl;
