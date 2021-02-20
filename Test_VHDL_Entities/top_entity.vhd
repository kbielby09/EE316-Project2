-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

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
        OUT_DATA_ADR : out std_logic_vector(17 downto 0);      -- segments that are to be illuminated for the seven segment hex
        DIO : inout std_logic_vector(15 downto 0);
        CE_N : out std_logic;
        WE_N    : out std_logic;     -- signal for writing to SRAM
        OE    : out std_logic;     -- Input signal for enabling output
        UB    : out std_logic;
        LB    : out std_logic

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

  -- ROM driver port map
  ROM_UNIT : ROM
  port map(
      address	=> std_logic_vector(init_data_addr(7 downto 0)),
      clock	  => I_CLK_50MHZ,
      q	      => rom_data
  );

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

  -- component pwm_control is
  --   port (
  --     I_RESET_N   : in std_logic;
  --     I_CLK_50MHZ : in std_logic;
  --     addr_change : in std_logic;
  --     rom_data     : in std_logic_vector (15 DOWNTO 0);
  --     PWM_OUT     : out std_logic
  --   );
  -- end component pwm_control;

  -- ROM initialization signal
  signal rom_initialize     : std_logic := '0';
  signal rom_data           : std_logic_vector(15 downto 0);

  -- data signals
  signal sram_data_address : unsigned(17 downto 0);
  signal sram_data         : std_logic_vector(15 downto 0);

  -- sram Signals
  signal out_data_signal       : std_logic_vector(15 downto 0);
  signal count_enable          : std_logic;
  signal count_enable_1        : std_logic;
  signal counter_paused        : std_logic := '1';
  signal one_hz_counter_signal : unsigned(25 downto 0) := (others => '0');
  signal RW                    : std_logic;

  -- data signals
  signal sram_data_address : std_logic_vector(17 downto 0);
  signal sram_data         : std_logic_vector(15 downto 0);

  -- sram Signalssignal trigger_signal : std_logic;
  signal in_data_signal  : std_logic_vector(15 downto 0);
  signal address_signal : std_logic_vector(7 downto 0);
  signal count_enable : std_logic;
  signal one_hz_counter_signal : unsigned(25 downto 0) := "00000000000000000000000000";
  signal input_data_addr : unsigned(7 downto 0) := (others => '0');
  signal input_data      : unsigned(15 downto 0);
  signal RW : std_logic;
  signal dio_data : std_logic_vector(15 downto 0);
  signal  : std_logic;

  type TYPE_FSTATE is
  (
    INIT,
    TEST,
    PAUSE,
    GEN
  );

  signal controller_state : TYPE_FSTATE := INIT;

  -- Signals to control frequency
  type FREQ_STATE is
  (
    SIXTY_HZ,
    ONE_HUNDRED_TWENTY_HZ,
    ONE_KHZ
  );

  signal frequency_state : FREQ_STATE := SIXTY_HZ;

  -- Signals for frequency counter
  signal sixty_hz_counter : unsigned(11 downto 0);
  signal one_twenty_hz_counter : unsigned(21 downto 0);
  signal one_khz_counter : unsigned(21 downto 0);

  -- signal fstate : type_fstate;
  -- signal reg_fstate : type_fstate;

  begin

    ROM_UNIT : ROM
    port map(
        address	=> input_data_addr,
        clock	=> I_CLK_50MHZ,
        q	=> rom_data
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

    -- PWM : pwm_control
    -- port map(
    --   I_RESET_N   => I_RESET_N,
    --   I_CLK_50MHZ => I_CLK_50MHZ,
    --   addr_change => ,
    --   rom_data    => ,
    --   PWM_OUT     => PWM_OUT
    -- );

    ONE_HZ_CLOCK : process (I_CLK_50MHZ, I_SYSTEM_RST_N)
     begin
      if(I_SYSTEM_RST_N = '1') then
         one_hz_counter_signal <= (others => '0');
      end if;

     if (rising_edge(I_CLK_50MHZ)) then
         one_hz_counter_signal <= one_hz_counter_signal + 1;
         if (one_hz_counter_signal = "10111110101111000001111111") then  -- check for 1 Hz clock (count to 50 million)
             count_enable <= '1';
             RW <= not(RW);
             one_hz_counter_signal <= (others => '0');
         else
             count_enable <= '0';
         end if;
     end if;

 end process ONE_HZ_CLOCK;

 -- TODO add functionality for LCD display data
 -- DISPLAY_LCD : process(I_CLK_50MHZ, I_RESET_N)
 --     begin
 --        if (I_RESET_N = '1') then
 --            -- Reset signal and LCD display
 --        elsif (rising_edge(I_CLK_50MHZ)) then
 --            -- Write data to LCD display
 --        end if;
 -- end process DISPLAY_LCD;

 -- SRAM_COUNTER : process (I_CLK_50MHZ, I_RESET_N)
 --      begin
 --          if (I_RESET_N = '1') then
 --               input_data_addr <= (others => '0');
 --          end if;
 --
 --          if(rising_edge(I_CLK_50MHZ)) then
 --              if(count_enable = '1') then
 --                if(input_data_addr = "00001111") then
 --                    input_data_addr <= (others => '0');
 --                    RW <= not(RW);
 --                else
 --                  if (l_key_pressed = '1') then
 --                      input_data_addr <= input_data_addr - 1;
 --                  else
 --                      input_data_addr <= input_data_addr + 1;
 --                  end if;
 --                end if;
 --              end if;
 --          end if;
 --  end process SRAM_COUNTER;

    CONTROL_STATE : process(I_CLK_50MHZ, I_RESET_N)
        begin
            if (rising_edge(I_CLK_50MHZ)) then
              case( controller_state ) is
                when INIT =>
                  if (rom_initialize = '1' and I_RESET_N = '1') then
                      controller_state <= TEST;
                  end if;
                when TEST =>
                  if (I_RESET_N = '0') then
                    controller_state <= INIT;
                  elsif (KEY1 = '0') then
                    controller_state <= PAUSE;
                  elsif (KEY2 = '0') then
                    controller_state <= GEN;
                  end if;
                when PAUSE =>
                  if (I_RESET_N = '0') then
                    controller_state <= INIT;
                  elsif (KEY1 = '0') then
                    controller_state <= TEST;
                  elsif (KEY2 = '0') then
                    controller_state <= GEN;
                  end if;
                when GEN =>
                  if (I_RESET_N = '0') then
                    controller_state <= INIT;
                    frequency_state <= SIXTY_HZ;
                  elsif (KEY3 = '0') then
                    case( frequency_state ) is
                      when SIXTY_HZ =>
                        frequency_state <= ONE_HUNDRED_TWENTY_HZ;
                      when ONE_HUNDRED_TWENTY_HZ =>
                        frequency_state <= ONE_KHZ;
                      when ONE_KHZ =>
                        frequency_state <= SIXTY_HZ;
                    end case;
                  end if;
              end case;
            end if;
    end process CONTROL_STATE;

    FREQ_COUNTER : process(I_CLK_50MHZ, I_RESET_N)
    begin
      if (I_RESET_N = '0') then
        sixty_hz_counter <= (others => '0');
        one_twenty_hz_counter <= (others => '0');
        one_khz_counter <= (others => '0');
        addr_change <= '0';
        i_rom_addr <= (others => '0');
      elsif (rising_edge(I_CLK_50MHZ)) then
        sixty_hz_counter <= sixty_hz_counter + 1;
        one_twenty_hz_counter <= one_twenty_hz_counter + 1;
        one_khz_counter <= one_khz_counter + 1;
        addr_change <= '0';
        case(frequency_state) is
          when SIXTY_HZ =>
            if (sixty_hz_counter = "110010110111") then
              i_rom_addr <= i_rom_addr + 1;
              addr_change <= '1';
              sixty_hz_counter <= (others => '0');
            end if;

          when ONE_HUNDRED_TWENTY_HZ =>
            if (one_twenty_hz_counter = "11001011100") then
              i_rom_addr <= i_rom_addr + 1;
              addr_change <= '1';
              one_twenty_hz_counter <= (others => '0');
            end if;
          when ONE_KHZ =>
            if (one_khz_counter = "11000011") then
              i_rom_addr <= i_rom_addr + 1;
              addr_change <= '1';
              one_khz_counter <= (others => '0');
            end if;
        end case;
      end if;
    end process FREQ_COUNTER;

    STATE_FUNCTION : process(I_CLK_50MHZ, I_RESET_N)
        begin
            if (I_RESET_N = '0') then
                sram_data         <= (others  => '0');
                rom_write         <= (others  => '0');
                init_data_addr    <= (others  => '1');
            elsif (rising_edge(I_CLK_50MHZ)) then
                case controller_state is
                    when INIT =>
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

                    when OPERATION =>
                        RW <= '1';
                        if (count_enable = '1') then
                          case( count_direction ) is
                              when COUNT_UP =>
                                  if (sram_data_address(7 downto 0) = "11111111" and counter_paused = '0') then
                                      sram_data_address <= (others  => '0');
                                  elsif (counter_paused = '0') then
                                      sram_data_address <= sram_data_address + 1;
                                  end if;

                          end case;
                      end if;

                end case;
            end if;
    end process STATE_FUNCTION;


  end rtl;
