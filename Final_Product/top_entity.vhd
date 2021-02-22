-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_entity is
    port(
        -- Clocks and base signals
        I_RESET_N : in std_logic;
        I_CLK_50MHZ : in std_logic;

        -- On board key inputs
        KEY1 : in std_logic;
        KEY2 : in std_logic;
        KEY3 : in std_logic;

        -- PWM output
        PWM_OUT : out std_logic;

        -- SRAM outputs
        SRAM_DATA_ADR : out std_logic_vector(17 downto 0);
        DIO : inout std_logic_vector(15 downto 0);
        CE_N : out std_logic;
        WE_N    : out std_logic;     -- signal for writing to SRAM
        OE    : out std_logic;     -- Input signal for enabling output
        UB    : out std_logic;
        LB    : out std_logic;

        LCD_RW      : out std_logic;
        LCD_EN      : out std_logic;
        LCD_RS      : out std_logic;
        LCD_DATA    : out std_logic_vector(7 downto 0);
        LCD_ON      : out std_logic;
        LCD_BLON    : out std_logic

    );
  end top_entity;

architecture rtl of top_entity is

  -- SRAM controlller
  component SRAM_controller is
  port
  (
    I_CLK_50MHZ     : in std_logic;
    I_SYSTEM_RST_N  : in std_logic;
    COUNT_EN : in std_logic;
    RW         : in std_logic;
    DIO : inout std_logic_vector(15 downto 0);
    CE_N : out std_logic;
    WE_N    : out std_logic;
    OE    : out std_logic;
    UB    : out std_logic;
    LB    : out std_logic;
    IN_DATA      : in std_logic_vector(15 downto 0);
    IN_DATA_ADDR : in std_logic_vector(17 downto 0);
    OUT_DATA    : out std_logic_vector(15 downto 0);
    OUT_DATA_ADR : out std_logic_vector(17 downto 0)
  );
  end component SRAM_controller;

  -- ROM driver (auto generated signature)
  component ROM is
  	port
  	(
  		address		: in std_logic_vector (7 downto 0);
  		clock		  : in std_logic  := '1';
  		q		      : out std_logic_vector (15 downto 0)
  	);
  end component ROM;

  -- TODO implement
  -- component i2c_master IS
  --   generic(
  --     input_clk : integer := 100_000_000; --input clock speed from user logic in Hz
  --     bus_clk   : integer := 400_000);   --speed the i2c bus (scl) will run at in Hz
  --   port(
  --     clk       : in     std_logic;                    --system clock
  --     reset_n   : in     std_logic;                    --active low reset
  --     ena       : in     std_logic;                    --latch in command
  --     addr      : in     std_logic_vector(6 DOWNTO 0); --address of target slave
  --     rw        : in     std_logic;                    --'0' is write, '1' is read
  --     data_wr   : in     std_logic_vector(7 DOWNTO 0); --data to write to slave
  --     busy      : out    std_logic;                    --indicates transaction in progress
  --     data_rd   : out    std_logic_vector(7 DOWNTO 0); --data read from slave
  --     ack_error : buffer std_logic;                    --flag if improper acknowledge from slave
  --     sda       : inout  std_logic;                    --serial data output of i2c bus
  --     scl       : inout  std_logic);                   --serial clock output of i2c bus
  -- end component i2c_master;

  component digit_write is
    port (
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
      INPUT_ADDR :  in std_logic_vector(7 downto 0);
      INPUT_DATA :  in std_logic_vector(15 downto 0)
    );
  end component;

  component pwm_control is
    port (
    I_RESET_N   : in std_logic;
    I_CLK_50MHZ : in std_logic;
    frequency : std_logic_vector(1 downto 0);
    addr_change : in std_logic;
    i_rom_data  : in std_logic_vector (15 DOWNTO 0);
    PWM_OUT     : out std_logic
    );
  end component pwm_control;

  -- ROM initialization signal
  signal rom_initialize     : std_logic := '0';
  signal rom_data           : std_logic_vector(15 downto 0);
  signal init_data_addr     : unsigned(17 downto 0) := (others => '1');
  signal rom_write          : unsigned(17 downto 0) := (others => '0');

  -- data signals
  signal sram_data_address : unsigned(17 downto 0);
  signal sram_data         : std_logic_vector(15 downto 0);
  signal sram_addr_change  : std_logic;

  -- sram Signals
  signal out_data_signal       : std_logic_vector(15 downto 0);
  signal count_enable          : std_logic;
  signal count_enable_1        : std_logic;
  signal one_hz_counter_signal : unsigned(25 downto 0) := (others => '0');
  signal RW                    : std_logic;

  -- Previous key signals
  signal previous_key0 : std_logic;
  signal previous_key1 : std_logic;
  signal previous_key2 : std_logic;
  signal previous_key3 : std_logic;


  type TYPE_FSTATE is
  (
    INIT,
    TEST,
    PAUSE,
    GEN
  );

  signal controller_state : TYPE_FSTATE := INIT;
  -- signal controller_state : TYPE_FSTATE := GEN;

  -- Signals to control frequency
  type FREQ_STATE is
  (
    SIXTY_HZ,
    ONE_HUNDRED_TWENTY_HZ,
    ONE_KHZ
  );

  signal frequency_state : FREQ_STATE := SIXTY_HZ;
  signal frequency_val   : std_logic_vector(1 downto 0) := "00";

  -- Signals for frequency counter
  signal sixty_hz_counter : unsigned(11 downto 0);
  signal one_twenty_hz_counter : unsigned(21 downto 0);
  signal one_khz_counter : unsigned(21 downto 0);

  -- Signals for LCD display
  signal lcd_state : std_logic_vector(1 downto 0) := "00";
  signal lcd_in_data : std_logic_vector(15 downto 0);

  begin

    -- ROM driver port map
    ROM_UNIT : ROM
    port map(
        address	=> std_logic_vector(init_data_addr(7 downto 0)),
        clock	  => I_CLK_50MHZ,
        q	      => rom_data
    );

    -- SRAM  controller port map
    SRAM : SRAM_controller
    port map(
        I_CLK_50MHZ    => I_CLK_50MHZ,
        I_SYSTEM_RST_N => I_RESET_N,
        COUNT_EN       => count_enable_1,
        RW             => RW,
        DIO            => DIO,
        CE_N           => CE_N,
        WE_N           => WE_N,
        OE             => OE,
        UB             => UB,
        LB             => LB,
        IN_DATA        => sram_data,
        IN_DATA_ADDR   => std_logic_vector(sram_data_address),
        OUT_DATA       => out_data_signal,
        OUT_DATA_ADR   => SRAM_DATA_ADR
    );

    PWM : pwm_control
    port map(
      I_RESET_N   => I_RESET_N,
      I_CLK_50MHZ => I_CLK_50MHZ,
      frequency   => frequency_val,
      addr_change => sram_addr_change,
      i_rom_data  => out_data_signal,
      PWM_OUT     => PWM_OUT
    );

    LCD : digit_write
    port map(
      I_RESET_N   => I_RESET_N,
      I_CLK_50MHZ => I_CLK_50MHZ,
      CURRENT_MODE => lcd_state,
      FREQUENCY    => frequency_val,
      LCD_RW      => LCD_RW,
      LCD_EN      => LCD_EN,
      LCD_RS      => LCD_RS,
      LCD_DATA    => LCD_DATA,
      LCD_ON      => LCD_ON,
      LCD_BLON    => LCD_BLON,
      INPUT_ADDR => std_logic_vector(sram_data_address(7 downto 0)),
      INPUT_DATA => lcd_in_data
    );


    ONE_HZ_CLOCK : process (I_CLK_50MHZ, I_RESET_N)
     begin
       if(I_RESET_N = '0') then
           one_hz_counter_signal <= (others => '0');
           count_enable          <= '0';
           sixty_hz_counter <= (others => '0');
           one_twenty_hz_counter <= (others => '0');
           one_khz_counter <= (others => '0');
       elsif (rising_edge(I_CLK_50MHZ)) then

         if (controller_state = INIT) then
             count_enable_1 <= count_enable;
             if (rom_write = "110000110101000000") then
               count_enable <= '1';
             else
               count_enable <= '0';
             end if;
         end if;

         if (controller_state = GEN) then
           sixty_hz_counter <= sixty_hz_counter + 1;
           one_twenty_hz_counter <= one_twenty_hz_counter + 1;
           one_khz_counter <= one_khz_counter + 1;
           count_enable_1 <= '0';
           sram_addr_change <= '0';
           case(frequency_state) is
             when SIXTY_HZ =>
               if (sixty_hz_counter = "110010110111") then
                 sixty_hz_counter <= (others => '0');
               elsif (sixty_hz_counter = "110010110100") then
                 count_enable_1 <= '1';
               elsif (sixty_hz_counter = "110010110110") then
                 sram_addr_change <= '1';
               end if;
             when ONE_HUNDRED_TWENTY_HZ =>
               if (one_twenty_hz_counter = "11001011100") then
                 one_twenty_hz_counter <= (others => '0');
               elsif (one_twenty_hz_counter = X"659") then
                 count_enable_1 <= '1';
               elsif (one_twenty_hz_counter = X"65B") then
                 sram_addr_change <= '1';
               end if;
             when ONE_KHZ =>
               if (one_khz_counter = "11000011") then
                 one_khz_counter <= (others => '0');
               elsif (one_khz_counter = "11000001") then
                 count_enable_1 <= '1';
               elsif (one_khz_counter = X"C2") then
                 sram_addr_change <= '1';
               end if;
           end case;
         end if;

        if (controller_state = TEST) then
            count_enable_1 <= count_enable;
            one_hz_counter_signal <= one_hz_counter_signal + 1;
            if (one_hz_counter_signal = "10111110101111000001111111") then
                count_enable <= '1';
                one_hz_counter_signal <= (others => '0');
            else
                count_enable <= '0';
            end if;
        end if;

     end if;
    end process ONE_HZ_CLOCK;

    KEY0_STATE : process(I_CLK_50MHZ)
    begin
      if (rising_edge(I_CLK_50MHZ)) then
        previous_key0 <= I_RESET_N;
      end if;
    end process;

    CONTROL_STATE : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (I_RESET_N = '0') then
            controller_state <= INIT;
            frequency_state <= SIXTY_HZ;
          elsif (rising_edge(I_CLK_50MHZ)) then
            previous_key1 <= KEY1;
            previous_key2 <= KEY2;
            previous_key3 <= KEY3;
              case( controller_state ) is
                when INIT =>
                  -- if (rom_initialize = '1' and I_RESET_N = '1' and previous_key0 = '0') then
                  if (rom_initialize = '1' and I_RESET_N = '1') then
                      controller_state <= TEST;
                  end if;
                when TEST =>
                  if (KEY1 = '0' and previous_key1 = '1') then
                    controller_state <= PAUSE;
                  elsif (KEY2 = '0' and previous_key2 = '1') then
                    controller_state <= GEN;
                  end if;
                when PAUSE =>
                  if (KEY1 = '0' and previous_key1 = '1') then
                    controller_state <= TEST;
                  elsif (KEY2 = '0' and previous_key2 = '1') then
                    controller_state <= GEN;
                  end if;
                when GEN =>
                  if (KEY2 = '0' and previous_key2 = '1') then
                    controller_state <= TEST;
                  end if;
                  if (KEY3 = '0' and previous_key3 = '1') then
                    case( frequency_state ) is
                      when SIXTY_HZ =>
                        frequency_state <= ONE_HUNDRED_TWENTY_HZ;
                        frequency_val <= "01";
                      when ONE_HUNDRED_TWENTY_HZ =>
                        frequency_state <= ONE_KHZ;
                        frequency_val <= "10";
                      when ONE_KHZ =>
                        frequency_state <= SIXTY_HZ;
                        frequency_val <= "00";
                    end case;
                  end if;
              end case;
            end if;
    end process CONTROL_STATE;

    STATE_FUNCTION : process(I_CLK_50MHZ, I_RESET_N)
        begin
          if (I_RESET_N = '0') then
            sram_data         <= (others  => '0');
            rom_write         <= (others  => '0');
            init_data_addr    <= (others  => '1');
            sram_data_address <= (others  => '0');
            rom_initialize <= '0';
            if (I_RESET_N = '0' and previous_key0 = '1') then
              lcd_state <= "00";
            end if;

          elsif (rising_edge(I_CLK_50MHZ)) then
          -- if (rising_edge(I_CLK_50MHZ)) then
          --   if (I_RESET_N = '0' and previous_key0 = '1') then
          --     sram_data         <= (others  => '0');
          --     rom_write         <= (others  => '0');
          --     init_data_addr    <= (others  => '1');
          --     sram_data_address <= (others  => '0');
          --     rom_initialize <= '0';
          --     lcd_state <= "00";
          --   end if;

            case controller_state is
              when INIT => -- Initialize SRAM
                lcd_state <= "00";
                -- lcd_in_data <= (others => '0');
                RW <= '0';
                if (init_data_addr /= "000000000100000000") then
                  sram_data_address <= init_data_addr;
                  sram_data         <= rom_data;
                end if;
                rom_write <= rom_write + 1;
                if (rom_write = "110000110101000000") then
                  rom_write <= (others => '0');
                  init_data_addr <= init_data_addr + 1;
                  if (init_data_addr = "000000000011111111") then
                    sram_data <= (others => '0');
                    sram_data_address <= (others => '0');
                    rom_initialize <= '1';
                  end if;
                end if;
              when TEST =>
                lcd_state <= "01";
                lcd_in_data <= out_data_signal;
                -- display data on i2c

                -- increment sram address
                RW <= '1';
                if (count_enable = '1') then
                  sram_data_address <= sram_data_address + 1;
                  if (sram_data_address(7 downto 0) = "11111111" ) then
                    sram_data_address <= (others  => '0');
                  end if;
                end if;
              when PAUSE =>
                lcd_state <= "10";
                -- lcd_in_data <= (others => '0');
                -- pause i2c
                -- pause LCD
                -- pause sram counter
              when GEN =>
                lcd_state <= "11";
                lcd_in_data <= (others => '0');
                RW <= '1';
                if (sram_data_address(7 downto 0) = "11111111" ) then
                  sram_data_address <= (others  => '0');
                end if;

                case( frequency_state ) is
                  when SIXTY_HZ =>
                    if (sixty_hz_counter = "110010110100") then
                      sram_data_address <= sram_data_address + 1;
                    end if;
                  when ONE_HUNDRED_TWENTY_HZ =>
                    if (one_twenty_hz_counter = "1100101010") then
                      sram_data_address <= sram_data_address + 1;
                    end if;
                  when ONE_KHZ =>
                    if (one_khz_counter = "11000001") then
                      sram_data_address <= sram_data_address + 1;
                    end if;
                end case;
          end case;
        end if;
    end process STATE_FUNCTION;


  end rtl;
