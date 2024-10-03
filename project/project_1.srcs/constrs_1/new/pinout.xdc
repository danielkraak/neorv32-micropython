set_property IOSTANDARD LVCMOS33 [get_ports {gpio_o[0]}]
set_property PACKAGE_PIN J19 [get_ports {gpio_o[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {gpio_o[1]}]
set_property PACKAGE_PIN T23 [get_ports {gpio_o[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {gpio_o[2]}]
set_property PACKAGE_PIN E23 [get_ports {gpio_o[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {gpio_o[3]}]
set_property PACKAGE_PIN F22 [get_ports {gpio_o[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
set_property PACKAGE_PIN U22 [get_ports clk_i]

set_property IOSTANDARD LVCMOS33 [get_ports uart_txd_o]
set_property PACKAGE_PIN A5 [get_ports uart_txd_o]

set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd_i]
set_property PACKAGE_PIN A4 [get_ports uart_rxd_i]


set_property IOSTANDARD LVCMOS33 [get_ports spi_csn_o]
set_property PACKAGE_PIN P18 [get_ports spi_csn_o]

#set_property IOSTANDARD LVCMOS33 [get_ports xip_clk_o]
#set_property PACKAGE_PIN H13 [get_ports xip_clk_o]

set_property IOSTANDARD LVCMOS33 [get_ports spi_dat_i]
set_property PACKAGE_PIN R15 [get_ports spi_dat_i]

set_property IOSTANDARD LVCMOS33 [get_ports spi_dat_o]
set_property PACKAGE_PIN R14 [get_ports spi_dat_o]


set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]


