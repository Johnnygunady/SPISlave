library ieee;
use ieee.std_logic_1164.all;

entity main is
    port(o_busy : out std_logic;
        i_sclk : in std_logic;
        i_ss : in std_logic;
        i_mosi : in std_logic;
        o_miso : out std_logic := '0';
        o_sclk_test : out std_logic;
        o_ss_test : out std_logic;
        o_mosi_test : out std_logic);
end entity main;

architecture rtl of main is

    constant N : integer := 64;
    constant CPOL : std_logic := '0'; 

    -- signal  o_busy,
    --         i_sclk,
    --         i_ss,
    --         i_mosi,
    --         o_miso : std_logic;
                    
    signal  o_data_parallel : std_logic_vector(N-1 downto 0);

    --signal  i_data_parallel : std_logic_vector(N-1 downto 0) := x"ABCDEFAB";

    --signal buf : std_logic_vector(N-1 downto 0) := x"ABCDEFAB"; 
    signal buf1 : std_logic_vector(N-1 downto 0);
    signal slave_rx : std_logic_vector(N-1 downto 0);
    -- signal master_rx : std_logic_vector(N-1 downto 0);


    component spi_slave
        generic(
            N                     : integer := 2;      -- number of bit to serialize
            CPOL                  : std_logic := '0' );  -- clock polarity
        port (
            o_busy                      : out std_logic;  -- receiving data if '1'
            i_data_parallel             : in  std_logic_vector(N-1 downto 0);  -- data to sent
            o_data_parallel             : out std_logic_vector(N-1 downto 0);  -- received data
            i_sclk                      : in  std_logic;
            i_ss                        : in  std_logic;
            i_mosi                      : in  std_logic;
            o_miso                      : out std_logic);
    end component spi_slave;

begin
    
    U1 : spi_slave
    generic map (
      N  => N,
      CPOL => CPOL)
    port map (
        o_busy => o_busy,
        i_sclk => i_sclk,
        i_ss => i_ss,
        i_mosi => i_mosi,
        o_miso => o_miso,
        i_data_parallel => o_data_parallel,
        o_data_parallel => o_data_parallel
    ); 

    
    o_sclk_test <= i_sclk;
    o_ss_test <= i_ss;
    o_mosi_test <= i_mosi;
    -- process
    -- begin
    --     wait until rising_edge(i_sclk);
    --     i_ss <= '0';    
    --     for i in N-1 downto 0 loop
    --         wait until rising_edge(i_sclk);
    --         i_mosi <= buf(N-1);
    --         buf <= buf(N-2 downto 0) & '0';
    --     end loop;
    --     wait until rising_edge(i_sclk);
    --     i_ss <= '1';   
    -- end process;

    process
    begin
        wait until falling_edge(o_busy);
        slave_rx(N-1 downto 0) <= o_data_parallel(N-1 downto 0);
    end process;

    -- process
    -- begin
    --     wait until rising_edge(o_busy);
    --     wait until falling_edge(i_sclk);
    --     for i in N-1 downto 0 loop
    --         buf1(i) <= o_miso;
    --         wait until falling_edge(i_sclk);
    --     end loop;
    --     master_rx <= buf1;
    -- end process;

end architecture rtl;