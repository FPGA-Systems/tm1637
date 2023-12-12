----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2022 09:45:18 PM
-- Design Name: 
-- Module Name: top - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
 Port ( 
    iclk : in std_logic;
    oclk    : out std_logic;
    odio    : out std_logic
 );
end top;

architecture rtl of top is
    
    component clk_wiz_0
    port
     (-- Clock in ports
      -- Clock out ports
      clk_out1          : out    std_logic;
      -- Status and control signals
      locked            : out    std_logic;
      clk_in1           : in     std_logic
     );
    end component;
    
    signal clk : std_logic;
    
    signal ascii_char_1 : std_logic_vector(7 downto 0) := (others => '0');
    signal ascii_char_2 : std_logic_vector(7 downto 0) := (others => '0');
    signal ascii_char_3 : std_logic_vector(7 downto 0) := (others => '0');
    signal ascii_char_4 : std_logic_vector(7 downto 0) := (others => '0');
    
    signal o7seg_1 : std_logic_vector(7 downto 0) := (others => '0');
    signal o7seg_2 : std_logic_vector(7 downto 0) := (others => '0');
    signal o7seg_3 : std_logic_vector(7 downto 0) := (others => '0');
    signal o7seg_4 : std_logic_vector(7 downto 0) := (others => '0');
    
    signal wr : std_logic := '0';
    signal cnt : natural range 0 to 50_000_000 := 0;
    
    signal dis : natural range 0 to 3 := 2;
    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            wr <= '0';
            cnt <= cnt + 1;
            
            if (cnt = 25_000_000) then
                wr <= '1';
                cnt <= 0;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if (wr = '1') then
                dis <= dis + 1 ;
                if (dis = 2) then
                    dis <= 0;
                end if;
            end if;
        end if;
    end process;

    process(dis)
    begin
        case (dis) is
            when 0 => ascii_char_1 <= x"48"; ascii_char_2 <= x"45"; ascii_char_3 <= x"59"; ascii_char_4 <= x"00"; --HEY
            when 1 => ascii_char_1 <= x"46"; ascii_char_2 <= x"50"; ascii_char_3 <= x"47"; ascii_char_4 <= x"41"; --FPGA
            when others =>  ascii_char_1 <= x"00"; ascii_char_2 <= x"00"; ascii_char_3 <= x"00"; ascii_char_4 <= x"00"; 
        end case;
    end process;

    clk_wiz : clk_wiz_0
       port map ( 
       clk_out1 => clk,               
       locked => open,
       clk_in1 => iclk
    );
    
    inst_decoder_1: entity work.ascii_to_gfedcba(rtl)
    port map(
        iascii   => ascii_char_1,
        ogfedcba => o7seg_1
    );
    
    inst_decoder_2: entity work.ascii_to_gfedcba(rtl)
    port map(
        iascii   => ascii_char_2,
        ogfedcba => o7seg_2
    );
    
    inst_decoder_3: entity work.ascii_to_gfedcba(rtl)
    port map(
        iascii   => ascii_char_3,
        ogfedcba => o7seg_3
    );
    
    inst_decoder_4: entity work.ascii_to_gfedcba(rtl)
    port map(
        iascii   => ascii_char_4,
        ogfedcba => o7seg_4
    );
    
    inst_tm1637 : entity work.tm1637(rtl)
    Port  map(
        iclk    => clk,
        ichar_1 => o7seg_1,
        ichar_2 => o7seg_2,
        ichar_3 => o7seg_3,
        ichar_4 => o7seg_4,
        iwr     => wr,
        odone   => open,
        oclk    => oclk,
        odio    => odio
  );
    
    
end rtl;
