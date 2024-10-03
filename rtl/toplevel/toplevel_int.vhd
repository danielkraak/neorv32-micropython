-- ================================================================================ --
-- NEORV32 - Minimal generic setup with the bootloader enabled                      --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2024 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TODO make this part of work, otherwise Vivado interprets it incorrectly
library neorv32;

entity toplevel_int is
  generic (
    -- General --
    CLOCK_FREQUENCY   : natural := 0;       -- clock frequency of clk_i in Hz
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN   : boolean := true;    -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE : natural := 64*1024; -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN   : boolean := true;    -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE : natural := 64*1024; -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM       : natural := 1;       -- number of GPIO input/output pairs (0..64)
    IO_PWM_NUM_CH     : natural := 3;       -- number of PWM channels to implement (0..12); 0 = disabled
    IO_SPI_EN         : boolean := false;   -- implement serial peripheral interface (SPI)?
    -- Execute in-place module (XIP) --
    XIP_EN                : boolean                        := false;       -- implement execute in-place module (XIP)?
    XIP_CACHE_EN          : boolean                        := false;       -- implement XIP cache?
    XIP_CACHE_NUM_BLOCKS  : natural range 1 to 256         := 8;           -- number of blocks (min 1), has to be a power of 2
    XIP_CACHE_BLOCK_SIZE  : natural range 1 to 2**16       := 256          -- block size in bytes (min 4), has to be a power of 2

  );
  port (
    -- Global control --
    clk_i      : in  std_logic;
    rstn_i     : in  std_logic;
    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_o     : out std_ulogic_vector(3 downto 0);
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart_txd_o : out std_ulogic; -- UART0 send data
    uart_rxd_i : in  std_ulogic := '0'; -- UART0 receive data
    -- PWM (available if IO_PWM_NUM_CH > 0) --
    pwm_o      : out std_ulogic_vector(IO_PWM_NUM_CH-1 downto 0);
    -- XIP
    xip_csn_o  : out std_ulogic;                                        -- chip-select, low-active
    xip_clk_o  : out std_ulogic;                                        -- serial clock
    xip_dat_i  : in  std_ulogic := 'L';                                 -- device data input
    xip_dat_o  : out std_ulogic;                                        -- controller data output
    -- SPI (available if IO_SPI_EN = true) --
    spi_clk_o      : out std_ulogic;                                    -- SPI serial clock
    spi_dat_o      : out std_ulogic;                                    -- controller data out, peripheral data in
    spi_dat_i      : in  std_ulogic := 'L';                             -- controller data in, peripheral data out
    spi_csn_o      : out std_ulogic_vector(7 downto 0)                  -- chip-select, low-active
  );
end entity;

architecture toplevel_int_syn of toplevel_int is

  -- internal IO connection --
  signal con_gpio_o : std_ulogic_vector(63 downto 0);
  signal con_pwm_o  : std_ulogic_vector(11 downto 0);

begin

  -- The core of the problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_inst: entity neorv32.neorv32_top
  generic map (
    -- General --
    CLOCK_FREQUENCY      => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    INT_BOOTLOADER_EN    => true,              -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN      => MEM_INT_IMEM_EN,   -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE    => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN      => MEM_INT_DMEM_EN,   -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE    => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM          => IO_GPIO_NUM,       -- number of GPIO input/output pairs (0..64)
    IO_MTIME_EN          => true,              -- implement machine system timer (MTIME)?
    IO_UART0_EN          => true,              -- implement primary universal asynchronous receiver/transmitter (UART0)?
    IO_PWM_NUM_CH        => IO_PWM_NUM_CH,     -- number of PWM channels to implement (0..12); 0 = disabled
    IO_SPI_EN            => IO_SPI_EN,
    -- XIP
    XIP_EN               => XIP_EN,
    XIP_CACHE_EN         => XIP_CACHE_EN,
    XIP_CACHE_NUM_BLOCKS => XIP_CACHE_NUM_BLOCKS,
    XIP_CACHE_BLOCK_SIZE => XIP_CACHE_BLOCK_SIZE
  )
  port map (
    -- Global control --
    clk_i       => clk_i,                        -- global clock, rising edge
    rstn_i      => rstn_i,                       -- global reset, low-active, async
    -- GPIO (available if IO_GPIO_NUM > 0) --
    gpio_o      => con_gpio_o,                   -- parallel output
    gpio_i      => (others => '0'),              -- parallel input
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => uart_txd_o,                   -- UART0 send data
    uart0_rxd_i => uart_rxd_i,                   -- UART0 receive data
    -- PWM (available if IO_PWM_NUM_CH > 0) --
    pwm_o       => con_pwm_o,                     -- pwm channels
    -- XIP
    xip_csn_o   => xip_csn_o,
    xip_clk_o   => xip_clk_o,
    xip_dat_i   => xip_dat_i,
    xip_dat_o   => xip_dat_o,
    -- SPI
    spi_clk_o   => spi_clk_o,
    spi_dat_o   => spi_dat_o,
    spi_dat_i   => spi_dat_i,
    spi_csn_o   => spi_csn_o
  );

  -- GPIO --
  gpio_o <= con_gpio_o(3 downto 0);
  -- PWM --
  pwm_o <= con_pwm_o(IO_PWM_NUM_CH-1 downto 0);


end architecture;
