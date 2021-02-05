--------------------------------------------------------------------------------
-- Filename     : hex_keypad_driver.vhd
-- Author       :
-- Date Created : 2019-02-26
-- Last Revised : 2019-02-28
-- Project      : lcd_keypad_dev
-- Description  : Driver code to return a binary representation of the output
--                of a 16 button keypad (Sparkfun DD-14881)
--------------------------------------------------------------------------------
--
-- Done:
-- 1. Solve all
-- 2. Add process descriptions
-- 3. Ensure indentation and spacing is clean and consistent.
--
--------------------------------------------------------------------------------

-----------------
--  Libraries  --
-----------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity hex_keypad_driver is
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
end entity hex_keypad_driver;


--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of hex_keypad_driver is
  component debounce is
  port
  (
    I_CLK            : in std_logic;  -- System clk frequency of (C_CLK_FREQ_MHZ)
    I_RESET_N        : in std_logic;  -- System reset (active low)
    I_BUTTON         : in std_logic;  -- Button data to be debounced
    O_BUTTON         : out std_logic  -- Debounced button data
  );
end component;

  -------------
  -- SIGNALS --
  -------------

  -- Keypad counter and enable to account for delay time
  signal s_keypad_enable      : std_logic;
  signal s_keypad_enable_cntr : unsigned(6 downto 0);

  -- key signal data
  signal keys : std_logic_vector(18 downto 0);
  signal keys_previous : std_logic_vector(18 downto 0);
  signal keys_edge : std_logic_vector(18 downto 0);
  signal keys_debounce : std_logic_vector(18 downto 0);


  -- State related signals
  type t_STATE is (IDLE_STATE,
                   COL1_POWER_STATE, COL1_READ_STATE,
                   COL2_POWER_STATE, COL2_READ_STATE,
                   COL3_POWER_STATE, COL3_READ_STATE,
                   COL4_POWER_STATE, COL4_READ_STATE);
  signal s_keypad_state       : t_STATE;

  -- Signals to allow current state of columns to be read as well as written to
  signal s_keypad_col_1       : std_logic;
  signal s_keypad_col_2       : std_logic;
  signal s_keypad_col_3       : std_logic;
  signal s_keypad_col_4       : std_logic;

  -- Signals for additional H and L keys
  signal h_key_pressed        : std_logic;
  signal l_key_pressed        : std_logic;
  signal shift_key_pressed    : std_logic;

  -- Signal to determine if key was pressed
  signal key_pressed_signal          : std_logic := '0';
  signal key_pressed_signal_previous          : std_logic := '0';

  -- 4 bit binary representation of keypad state (output of entity)
  signal s_keypad_binary      : std_logic_vector(3 downto 0);

begin
  keypad_debounce: for i in 0 to 18 generate
    debounce_keys: debounce
      port map
      (
        I_CLK            => I_CLK_50MHZ,
        I_RESET_N        => I_SYSTEM_RST,
        I_BUTTON         => keys(i),
        O_BUTTON         => keys_debounce(i)
      );
  end generate keypad_debounce;

  ------------------------------------------------------------------------------
  -- Process Name     : KEYPAD_EN_CNTR
  -- Sensitivity List : I_CLK_50MHZ    : 100 MHz global clock
  --                    I_SYSTEM_RST    : Global Reset line
  -- Useful Outputs   : s_keypad_enable : Enable line to allow state to change
  --                    in KEYPAD_STATE_MACHINE process
  --                    (active high enable logic)
  -- Description      : Counter to delay the powering of the columns to negate
  --                    the delay of the Hardware. Every 1111111b (127) clock
  --                    ticks (1.27 us), s_keypad_enable gets driven high to
  --                    allow for state change in KEYPAD_STATE_MACHINE process.
  ------------------------------------------------------------------------------
  KEYPAD_EN_CNTR: process (I_CLK_50MHZ, I_SYSTEM_RST)
  begin
    if (I_SYSTEM_RST = '1') then
      s_keypad_enable_cntr  <= (others => '0');
      s_keypad_enable       <= '0';

    elsif (rising_edge(I_CLK_50MHZ)) then
      s_keypad_enable_cntr  <= s_keypad_enable_cntr + 1;

      if (s_keypad_enable_cntr = "1100100") then  -- Max count 127 (1.27 us)
        s_keypad_enable     <= '1';
      else
        s_keypad_enable     <= '0';
      end if;
    end if;
  end process KEYPAD_EN_CNTR;
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Process Name     : KEYPAD_STATE_MACHINE
  -- Sensitivity List : I_CLK_50MHZ    : 100 MHz global clock
  --                    I_SYSTEM_RST    : Global Reset line
  -- Useful Outputs   : s_keypad_state  : Current state of keypad state machine.
  --                                      Used to control read and write of row
  --                                      and cols in KEYPAD_TO_BINARY process.
  -- Description      : State machine to control different states for power and
  --                    and read of rows and cols. Always a power state then a
  --                    read state.
  ------------------------------------------------------------------------------
  KEYPAD_STATE_MACHINE: process (I_CLK_50MHZ, I_SYSTEM_RST)
  begin
    if (I_SYSTEM_RST = '1') then  -- Upon reset, set the state to IDLE_STATE
      s_keypad_state          <= IDLE_STATE;

    elsif (rising_edge(I_CLK_50MHZ)) then
      if (s_keypad_enable = '1') then
        case s_keypad_state is
          when IDLE_STATE =>
              s_keypad_state  <= COL2_POWER_STATE;

          when COL1_POWER_STATE =>
              s_keypad_state  <= COL1_READ_STATE;
          when COL1_READ_STATE =>
              s_keypad_state  <= COL2_POWER_STATE;

          when COL2_POWER_STATE =>
              s_keypad_state  <= COL2_READ_STATE;
          when COL2_READ_STATE =>
              s_keypad_state  <= COL3_POWER_STATE;

          when COL3_POWER_STATE =>
              s_keypad_state  <= COL3_READ_STATE;
          when COL3_READ_STATE =>
              s_keypad_state  <= COL4_POWER_STATE;

          when COL4_POWER_STATE =>
              s_keypad_state  <= COL4_READ_STATE;
          when COL4_READ_STATE =>
              s_keypad_state  <= COL1_POWER_STATE;

          -- Error condition, should never occur
          when others =>
            s_keypad_state    <= IDLE_STATE;
        end case;
      else
        s_keypad_state        <= s_keypad_state;
      end if;
    end if;
  end process KEYPAD_STATE_MACHINE;
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Process Name     : KEYPAD_TO_BINARY
  -- Sensitivity List : I_CLK_50MHZ    : 100 MHz global clock
  --                    I_SYSTEM_RST    : Global Reset line
  -- Useful Outputs   : s_keypad_binary : 4 bit binary representation of keypad
  --                                      state (output of entity).
  -- Description      : Entity to control the powering and reading of the
  --                    keypad rows and columns based on the current s_keypad_state.
  --                    Outputs the current binary number of keypad (0-15)
  ------------------------------------------------------------------------------
  KEYPAD_TO_BINARY: process (I_CLK_50MHZ, I_SYSTEM_RST)
  begin
    if (I_SYSTEM_RST = '1') then
      s_keypad_col_1      <= '0';
      s_keypad_col_2      <= '0';
      s_keypad_col_3      <= '0';
      s_keypad_col_4      <= '0';
      -- s_keypad_binary     <= (others => '0');

    elsif ((rising_edge(I_CLK_50MHZ))) then
      keys_previous <= keys_debounce;
      -- Power the Column 1
      if (s_keypad_state = COL1_POWER_STATE) then
        s_keypad_col_1    <= '1';
        s_keypad_col_2    <= '0';
        s_keypad_col_3    <= '0';
        s_keypad_col_4    <= '0';

      -- Power the Column 2
      elsif (s_keypad_state = COL2_POWER_STATE) then
        s_keypad_col_1    <= '0';
        s_keypad_col_2    <= '1';
        s_keypad_col_3    <= '0';
        s_keypad_col_4    <= '0';

      -- Power the Column 3
      elsif (s_keypad_state = COL3_POWER_STATE) then
        s_keypad_col_1    <= '0';
        s_keypad_col_2    <= '0';
        s_keypad_col_3    <= '1';
        s_keypad_col_4    <= '0';

      -- Power the Column 4
      elsif (s_keypad_state = COL4_POWER_STATE) then
        s_keypad_col_1    <= '0';
        s_keypad_col_2    <= '0';
        s_keypad_col_3    <= '0';
        s_keypad_col_4    <= '1';

      else
        s_keypad_col_1    <= s_keypad_col_1;
        s_keypad_col_2    <= s_keypad_col_2;
        s_keypad_col_3    <= s_keypad_col_3;
        s_keypad_col_4    <= s_keypad_col_4;
      end if;

      -- Col 1
      if (s_keypad_state = COL1_READ_STATE) then
         keys(0) <= I_KEYPAD_ROW_1;
         keys(1) <= I_KEYPAD_ROW_2;
         keys(2) <= I_KEYPAD_ROW_3;
         keys(3) <= I_KEYPAD_ROW_4;
         keys(4) <= I_KEYPAD_ROW_5;

        -- key_pressed_signal <= '0';
        -- if    (I_KEYPAD_ROW_1 = '1') then
        --    keys(0) <= '1';
        --   -- current_key_pressed <= A_KEY;
        --   -- key_pressed_signal <= '1';
        --   -- s_keypad_binary <= "1010";             -- A key pressed
        -- elsif (I_KEYPAD_ROW_2 = '1') then
        --   current_key_pressed <= ONE_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "0001";             -- 1 key pressed
        -- elsif (I_KEYPAD_ROW_3 = '1') then
        --   current_key_pressed <= FOUR_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "0100";             -- 4 key pressed
        -- elsif (I_KEYPAD_ROW_4 = '1') then
        --   current_key_pressed <= FIVE_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "0111";             -- 7 key pressed
        -- elsif (I_KEYPAD_ROW_5 = '1') then
        --   current_key_pressed <= ZERO_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "0000";             -- 0 key pressed
        -- else
        --   s_keypad_binary <= s_keypad_binary;
        --   key_pressed_signal <= '0';
        --
        -- end if;

      -- Col 2
      elsif (s_keypad_state = COL2_READ_STATE) then
         keys(5) <= I_KEYPAD_ROW_1;
         keys(6) <= I_KEYPAD_ROW_2;
         keys(7) <= I_KEYPAD_ROW_3;
         keys(8) <= I_KEYPAD_ROW_4;
        -- if    (I_KEYPAD_ROW_1 = '1') then
        --   current_key_pressed <= EIGHT_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "1011";             -- B key pressed
        -- elsif (I_KEYPAD_ROW_2 = '1') then
        --   current_key_pressed <= TWO_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "0010";             -- 2 key pressed
        -- elsif (I_KEYPAD_ROW_3 = '1') then
        --   current_key_pressed <= FIVE_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "0101";             -- 5 key pressed
        -- elsif (I_KEYPAD_ROW_4 = '1') then
        --   current_key_pressed <= EIGHT_KEY
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "1000";             -- 8 key pressed
        -- else
        --   s_keypad_binary <= s_keypad_binary;
        -- end if;

      -- Col 3
      elsif (s_keypad_state = COL3_READ_STATE) then
         keys(9) <= I_KEYPAD_ROW_1;
         keys(10) <= I_KEYPAD_ROW_2;
         keys(11) <= I_KEYPAD_ROW_3;
         keys(12) <= I_KEYPAD_ROW_4;
         keys(13) <= I_KEYPAD_ROW_5;
        -- if    (I_KEYPAD_ROW_1 = '1') then
        --   current_key_pressed <= C_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "1100";             -- C key pressed
        -- elsif (I_KEYPAD_ROW_2 = '1') then
        --   current_key_pressed <= THREE_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "0011";             -- 3 key pressed
        -- elsif (I_KEYPAD_ROW_3 = '1') then
        --   current_key_pressed <= SIX_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "0110";             -- 6 key pressed
        -- elsif (I_KEYPAD_ROW_4 = '1') then
        --   current_key_pressed <= NINE_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "1001";             -- 9 key pressed
        -- elsif (I_KEYPAD_ROW_5 = '1') then
        --   key_pressed_signal <= '1';
        --   h_key_pressed <= '1';                  -- H key pressed
        -- else
        --   s_keypad_binary <= s_keypad_binary;
        -- end if;

      -- Col 4
      elsif (s_keypad_state = COL4_READ_STATE) then
         keys(14) <= I_KEYPAD_ROW_1;
         keys(15) <= I_KEYPAD_ROW_2;
         keys(16) <= I_KEYPAD_ROW_3;
         keys(17) <= I_KEYPAD_ROW_4;
         keys(18) <= I_KEYPAD_ROW_5;
        -- if    (I_KEYPAD_ROW_1 = '1') then
        --   current_key_pressed <= D_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "1101";
        -- elsif (I_KEYPAD_ROW_2 = '1') then
        --   current_key_pressed <= E_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "1110";
        -- elsif (I_KEYPAD_ROW_3 = '1') then
        --   current_key_pressed <= F_KEY;
        --   key_pressed_signal <= '1';
        --   s_keypad_binary <= "1111";
        -- elsif (I_KEYPAD_ROW_4 = '1') then
        --   key_pressed_signal <= '1';
        --   shift_key_pressed <= '1';
        -- elsif (I_KEYPAD_ROW_5 = '1') then
        --   key_pressed_signal <= '1';
        --   l_key_pressed <= '1';
        -- else
        --   if (key_pressed_signal = '1') then
        --     KEY_PRESSED <= key_pressed_signal;
        --   else
        --     KEY_PRESSED <= '0';
        --   end if;
        --   s_keypad_binary <= s_keypad_binary;
        -- end if;
      -- else

        --
        -- s_keypad_binary   <= s_keypad_binary;
      end if;
    end if;
  end process KEYPAD_TO_BINARY;

  KEY_PROCESS : process(I_CLK_50MHZ)
     begin
       if(rising_edge(I_CLK_50MHZ)) then
        for indx in 0 to 18 loop
          if (keys_debounce(indx) = '1' and keys_previous(indx) = '0') then
            keys_edge(indx) <= '1';
          else
            keys_edge(indx) <= '0';
          end if;
      end loop;
    end if;
  end process;


  final_data : process(I_CLK_50MHZ)
  begin
    if(rising_edge(I_CLK_50MHZ)) then
     if (to_integer(unsigned(keys_edge)) = 0 or
      keys_edge(13) = '1' or
       keys_edge(17) = '1' or
        keys_edge(18) = '1') then
         KEY_PRESSED <= '0';
     else
       KEY_PRESSED <= '1';
     end if;

     if    (keys_edge(0) = '1') then
       s_keypad_binary <= "1010";
     elsif (keys_edge(1) = '1') then
       s_keypad_binary <= "0001";
     elsif (keys_edge(2) = '1') then
       s_keypad_binary <= "0100";
     elsif (keys_edge(3) = '1') then
       s_keypad_binary <= "0111";
     elsif (keys_edge(4) = '1') then
       s_keypad_binary <= "0000";
     elsif (keys_edge(5) = '1') then
       s_keypad_binary <= "1011";
     elsif (keys_edge(6) = '1') then
       s_keypad_binary <= "0010";
     elsif (keys_edge(7) = '1') then
       s_keypad_binary <= "0101";
     elsif (keys_edge(8) = '1') then
       s_keypad_binary <= "1000";
     elsif (keys_edge(9) = '1') then
       s_keypad_binary <= "1100";
     elsif (keys_edge(10) = '1') then
       s_keypad_binary <= "0011";
     elsif (keys_edge(11) = '1') then
       s_keypad_binary <= "0110";
     elsif (keys_edge(12) = '1') then
       s_keypad_binary <= "1001";
     elsif (keys_edge(14) = '1') then
       s_keypad_binary <= "1101";
     elsif (keys_edge(15) = '1') then
       s_keypad_binary <= "1110";
     elsif (keys_edge(16) = '1') then
       s_keypad_binary <= "1111";
     end if;

     if (keys_edge(18) = '1') then
       l_key_pressed <= '1';
     else
        l_key_pressed <= '0';
   end if;

     if (keys_edge(17) = '1') then
       shift_key_pressed <= '1';
     else
        shift_key_pressed <= '0';
   end if;

     if (keys_edge(13) = '1') then
       h_key_pressed <= '1';
     else
        h_key_pressed <= '0';
   end if;
   end if;

  end process;

  O_KEYPAD_COL_1          <= s_keypad_col_1;
  O_KEYPAD_COL_2          <= s_keypad_col_2;
  O_KEYPAD_COL_3          <= s_keypad_col_3;
  O_KEYPAD_COL_4          <= s_keypad_col_4;
  O_KEYPAD_BINARY         <= s_keypad_binary;

  SHIFT_PRESSED           <= shift_key_pressed;
  ------------------------------------------------------------------------------
end architecture rtl;
