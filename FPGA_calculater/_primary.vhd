library verilog;
use verilog.vl_types.all;
entity display is
    generic(
        CLK_DIV_PERIOD  : integer := 600
    );
    port(
        clk_in          : in     vl_logic;
        rst_n_in        : in     vl_logic;
        seg_data_1      : in     vl_logic_vector(3 downto 0);
        seg_data_2      : in     vl_logic_vector(3 downto 0);
        seg_data_3      : in     vl_logic_vector(3 downto 0);
        seg_data_4      : in     vl_logic_vector(3 downto 0);
        seg_data_5      : in     vl_logic_vector(3 downto 0);
        seg_data_6      : in     vl_logic_vector(3 downto 0);
        seg_data_7      : in     vl_logic_vector(3 downto 0);
        seg_data_8      : in     vl_logic_vector(3 downto 0);
        seg_data_en     : in     vl_logic_vector(7 downto 0);
        seg_dot_en      : in     vl_logic_vector(7 downto 0);
        rclk_out        : out    vl_logic;
        sclk_out        : out    vl_logic;
        sdio_out        : out    vl_logic
    );
end display;
