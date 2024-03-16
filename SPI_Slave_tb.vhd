library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity SPI_Slave_tb is
end entity SPI_Slave_tb;

architecture TB of SPI_Slave_tb is

    constant N : integer := 64;
    constant CPOL : std_logic := '0'; 
    --constant T : std_logic := 5;

    signal CLK : std_logic := '0';
    signal i_sclk : std_logic := '0';
    signal  o_busy : std_logic;
    signal i_mosi : std_logic := '0';
    signal  i_ss   : std_logic := '1';
    signal  o_miso : std_logic := '0';
    signal data : std_logic_vector(N-1 downto 0) := x"AB0000000000000A";
                    
    signal  i_data_parallel,
            o_data_parallel : std_logic_vector(N-1 downto 0);

    --signal buf : std_logic_vector(N-1 downto 0) := x"ABCDEFAB"; 
    signal buf1 : std_logic_vector(N-1 downto 0);
    -- signal slave_rx : std_logic_vector(N-1 downto 0);
    signal master_rx : std_logic_vector(N-1 downto 0) := (others => '0');

    procedure SendPacket
    (
        signal data   : std_logic_vector(63 downto 0);
        signal o_cs     : out std_logic;
        signal i_sclk   : out std_logic;
        signal o_line   : out std_logic
    )  is
    begin 
        --signal buf : std_logic_vector(63 downto 0) := data;
        o_cs <= '1';
        wait for 5 ns;
        o_cs <= '0';
        o_line <= data(63);
        wait for 10 ns;
        for i in 62 downto 0 loop
            i_sclk <= not CPOL;
            wait for 5 ns;
            i_sclk <= CPOL;
            o_line <= data(i);
            wait for 5 ns;
        end loop;
        i_sclk <= not CPOL;
        wait for 5 ns;
        i_sclk <= CPOL;
        wait for 5 ns;
        wait for 10 ns;
        o_cs <= '1';
    end procedure SendPacket;

    procedure RecvPacket
    (   
        signal o_cs     : out std_logic;
        signal i_sclk   : out std_logic
    ) is
    begin
        o_cs <= '1';
        wait for 5 ns;
        o_cs <= '0';
        wait for 10 ns;
        for i in 62 downto 0 loop
            i_sclk <= not CPOL;
            wait for 5 ns;
            i_sclk <= CPOL;
            wait for 5 ns;
        end loop;
        i_sclk <= not CPOL;
        wait for 5 ns;
        i_sclk <= CPOL;
        wait for 5 ns;
        wait for 10 ns;
        o_cs <= '1';
    end procedure RecvPacket;

    component main
        port (
            o_busy                      : out std_logic;  -- receiving data if '1'
            i_sclk                      : in  std_logic;
            i_ss                        : in  std_logic;
            i_mosi                      : in  std_logic;
            o_miso                      : out std_logic);
    end component main;

begin
    
    U1 : main
    port map (
        o_busy => o_busy,
        i_sclk => i_sclk,
        i_ss => i_ss,
        i_mosi => i_mosi,
        o_miso => o_miso
    ); 
    
    -- main_clk : process 
    -- begin
    --     CLK <= not CLK; 
    --     wait for 5 ns;    
    -- end process main_clk;

    -- process(i_ss)
    -- begin 
    --     if (i_ss = '0') then
    --         if (rising_edge(CLK)) then
    --             i_sclk <= '1';
    --         elsif (falling_edge(CLK)) then
    --             i_sclk <= '0';
    --         end if;
    --     end if;
    -- end process;

    testing : process 
    begin
        SendPacket(data, i_ss, i_sclk, i_mosi);
        RecvPacket(i_ss, i_sclk);
        wait;
    end process testing;


    -- process
    -- begin
    --     i_ss <= '1';
    --     wait until falling_edge(i_sclk);
    --     i_ss <= '0';
    --     for i in N-1 downto 0 loop
    --         wait until falling_edge(i_sclk);
    --         i_mosi <= buf(N-1);
    --         buf <= buf(N-2 downto 0) & '0';
    --     end loop;
    --     wait until falling_edge(i_sclk);
    --     i_ss <= '1';   
    --     wait for 10 ns;
    --     --buf (N-1 downto 0) <= x"55";
    -- end process;

    process(i_ss, i_sclk)
    begin
        if (i_ss = '0' and rising_edge(i_sclk))  then 
            buf1(N-1 downto 0) <= buf1(N-2 downto 0) & o_miso;
        end if;
        master_rx <= buf1;
    end process;

end architecture TB;