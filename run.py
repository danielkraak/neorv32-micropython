from vunit import VUnit
from pathlib import Path

# Create VUnit instance by providing the name of the VUnit project
vu = VUnit.from_argv()

# Set the path to your VHDL source files
src_path = Path("rtl/**/")
neorv32_path = Path("common/neorv32/rtl/**/")

# Create a library where you will store your design units
lib_rv32 = vu.add_library("neorv32")
lib = vu.add_library("lib")

# Add your VHDL files to the library
lib_rv32.add_source_files(neorv32_path / "*.vhd")
lib.add_source_files(src_path / "*.vhd")

# Set any VHDL simulator options, if needed
vu.set_sim_option("modelsim.vcom_flags", ["-2008"], allow_empty=True)

# Run VUnit - this will compile the source files, analyze them, and run the tests
vu.main()
