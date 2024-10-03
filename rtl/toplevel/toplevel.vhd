-- Toplevel containing clock mmcm and toplevel_int

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity toplevel is
  generic (
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN   : boolean := true;    -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE : natural := 256*1024; -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN   : boolean := true;    -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE : natural := 128*1024; -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM       : natural := 1;       -- number of GPIO input/output pairs (0..64)
    IO_PWM_NUM_CH     : natural := 3        -- number of PWM channels to implement (0..12); 0 = disabled
  );
  port (
    clk_i      : in  std_logic; -- Oscillator clock

    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_o     : out std_ulogic_vector(3 downto 0);

    -- primary UART0 (available if IO_UART0_EN = true) --
    uart_txd_o : out std_ulogic; -- UART0 send data
    uart_rxd_i : in  std_ulogic := '0'; -- UART0 receive data

    -- XIP currently not broken out, as spi controller is already connected to our single spi flash
    -- xip_csn_o  : out std_ulogic;      -- chip-select, low-active
    -- -- xip_clk_o  : out std_ulogic;      -- serial clock
    -- xip_dat_i  : in  std_ulogic;      -- device data input
    -- xip_dat_o  : out std_ulogic;       -- controller data output

    -- SPI (available if IO_SPI_EN = true) --
    -- spi_clk_o  : out std_ulogic;                                 -- SPI serial clock (controlled through STARTUPE2 primitive)
    spi_dat_o  : out std_ulogic;                                    -- controller data out, peripheral data in
    spi_dat_i  : in  std_ulogic := 'L';                             -- controller data in, peripheral data out
    spi_csn_o  : out std_ulogic                                     -- chip-select, low-active

  );

end entity;

architecture toplevel_syn of toplevel is

  component clk_wiz_0
    port (
      clk_out1 : out STD_LOGIC;
      reset    : in STD_LOGIC;
      locked   : out STD_LOGIC;
      clk_in   : in STD_LOGIC
    );
  end component;

  -- MMCM output clock frequency in Hz
  constant CLOCK_FREQUENCY_MMCM : natural := 100_000_000;

  signal sys_clk : std_logic;
  signal clock_locked : std_logic;

  signal spi_clk_int : std_logic;

begin

clk_wiz_0_inst : clk_wiz_0
  port map (
    clk_out1 => sys_clk,
    reset    => '0',
    locked   => clock_locked,
    clk_in   => clk_i
  );

toplevel_int_inst : entity work.toplevel_int
  generic map (
    CLOCK_FREQUENCY   => CLOCK_FREQUENCY_MMCM,
    MEM_INT_IMEM_EN   => MEM_INT_IMEM_EN,
    MEM_INT_IMEM_SIZE => MEM_INT_IMEM_SIZE,
    MEM_INT_DMEM_EN   => MEM_INT_DMEM_EN,
    MEM_INT_DMEM_SIZE => MEM_INT_DMEM_SIZE,
    IO_GPIO_NUM       => IO_GPIO_NUM,
    IO_PWM_NUM_CH     => IO_PWM_NUM_CH,
    IO_SPI_EN         => TRUE,
    XIP_EN            => TRUE,
    XIP_CACHE_EN      => TRUE
  )
  port map (
    clk_i      => sys_clk,
    rstn_i     => clock_locked,
    gpio_o     => gpio_o,
    uart_txd_o => uart_txd_o,
    uart_rxd_i => uart_rxd_i,
    pwm_o      => open,
    -- xip_csn_o  => xip_csn_o,
    -- xip_clk_o  => xip_clk_int,
    -- xip_dat_i  => xip_dat_i,
    -- xip_dat_o  => xip_dat_o
    spi_clk_o    => spi_clk_int,
    spi_dat_o    => spi_dat_o,
    spi_dat_i    => spi_dat_i,
    spi_csn_o(0) => spi_csn_o,
    spi_csn_o(1) => open,
    spi_csn_o(2) => open,
    spi_csn_o(3) => open,
    spi_csn_o(4) => open,
    spi_csn_o(5) => open,
    spi_csn_o(6) => open,
    spi_csn_o(7) => open
  );


  STARTUPE2_inst : STARTUPE2
  generic map (
     PROG_USR => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
     SIM_CCLK_FREQ => 0.0  -- Set the Configuration Clock Frequency(ns) for simulation.
  )
  port map (
     CFGCLK => open,       -- 1-bit output: Configuration main clock output
     CFGMCLK => open,     -- 1-bit output: Configuration internal oscillator clock output
     EOS => open,             -- 1-bit output: Active high output signal indicating the End Of Startup.
     PREQ => open,           -- 1-bit output: PROGRAM request to fabric output
     CLK => '0',             -- 1-bit input: User start-up clock input
     GSR => '0',             -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
     GTS => '0',             -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
     KEYCLEARB => '0', -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
     PACK => '0',           -- 1-bit input: PROGRAM acknowledge input
     USRCCLKO => spi_clk_int,   -- 1-bit input: User CCLK input
                             -- For Zynq-7000 devices, this input must be tied to GND
     USRCCLKTS => '0', -- 1-bit input: User CCLK 3-state enable input
                             -- For Zynq-7000 devices, this input must be tied to VCC
     USRDONEO => '0',   -- 1-bit input: User DONE pin output control
     USRDONETS => '1' -- 1-bit input: User DONE 3-state enable output
  );

end architecture;
