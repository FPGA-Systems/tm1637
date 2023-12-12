----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2022 08:56:27 PM
-- Design Name: 
-- Module Name: tm1637 - rtl
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
entity tm1637 is
    generic( 
        C_ICLK_IN_HZ : natural := 25_000_000
    );
  Port (
        iclk    : in std_logic;
        ichar_1 : in std_logic_vector(7 downto 0);
        ichar_2 : in std_logic_vector(7 downto 0);
        ichar_3 : in std_logic_vector(7 downto 0);
        ichar_4 : in std_logic_vector(7 downto 0);
        iwr     : in std_logic;
        odone   : out std_logic;
        oclk    : out std_logic;
        odio    : out std_logic
  );
end tm1637;

architecture rtl of tm1637 is
--                                                     idle command 1        ack/stop command 2         data 1              data 2              data 3              data 4           ack/stop command 3
    signal sreg_oclk : std_logic_vector(0 to 148) := b"1111_0101010101010101_0101110_101010101010101_01_0101010101010101_01_0101010101010101_01_0101010101010101_01_0101010101010101_010111_0101010101010101_010_1111111111";
    signal sreg_odio : std_logic_vector(0 to 148) := b"1110_0000000000001100_0000100_000000000001111_00_0000000000000000_00_0000000000000000_00_0000000000000000_00_0000000000000000_000010_1111001100000011_000_0111111111";
    
    signal ce : std_logic := '0';
    signal cnt : natural range 0 to C_ICLK_IN_HZ := 0;
    
    type state_type is (s0, s1, s2);
    signal state : state_type := s0;
    signal sreg_en : std_logic := '0';
    signal wr : std_logic := '0';
    signal cnt_2 : natural range 0 to 255 := 0;
    
begin

    process(iclk)
    begin
        if rising_edge(iclk) then
            cnt <= cnt +1;
            ce <= '0';
            
            if (cnt = C_ICLK_IN_HZ / 250) then
                cnt <= 0;
                ce <= '1';
            end if;
        end if;
    end process;
    
    process(iclk)
    begin
        if rising_edge(iclk) then
            
            wr <= '0';
            sreg_en <= '0';
            odone <= '0';
            
            case state is
                when s0 => if (iwr = '1') then
                                wr <= '1';
                                state <= s1;
                            end if;
                            
                when s1 => if (ce = '1') then
                                state <= s2;
                            end if;
                
                when s2 => sreg_en <= '1';
                            if (ce = '1') then
                                cnt_2 <= cnt_2 + 1;
                                
                                if (cnt_2 = sreg_oclk'right - 1) then
                                    sreg_en <= '0';
                                    cnt_2 <= 0;
                                    odone <= '1';
                                    state <= s0;
                                end if;
                            end if;
                
                when others => state <= s0;
            end case;
            
        end if;
    end process;
    
    process(iclk) 
    
        variable V_DATA1_1st_bit_pos : natural := 44;
        variable V_DATA2_1st_bit_pos : natural := 62;
        variable V_DATA3_1st_bit_pos : natural := 80;
        variable V_DATA4_1st_bit_pos : natural := 98;
        
    begin
        if rising_edge(iclk) then
            
            if(wr = '1') then
                for i in 0 to 7 loop
                    sreg_odio(2*i + V_DATA1_1st_bit_pos)    <= ichar_1(i);
                    sreg_odio(2*i + V_DATA1_1st_bit_pos +1) <= ichar_1(i);
                    
                    sreg_odio(2*i + V_DATA2_1st_bit_pos)    <= ichar_2(i);
                    sreg_odio(2*i + V_DATA2_1st_bit_pos +1) <= ichar_2(i);
                    
                    sreg_odio(2*i + V_DATA3_1st_bit_pos)    <= ichar_3(i);
                    sreg_odio(2*i + V_DATA3_1st_bit_pos +1) <= ichar_3(i);
                    
                    sreg_odio(2*i + V_DATA4_1st_bit_pos)    <= ichar_4(i);
                    sreg_odio(2*i + V_DATA4_1st_bit_pos +1) <= ichar_4(i);
                end loop;
            end if;
            
            
            if (ce = '1' and sreg_en = '1') then
                for i in 0 to sreg_oclk'right - 1 loop
                    sreg_oclk(i) <= sreg_oclk(i+1) ;
                end loop;
                
                for i in 0 to sreg_odio'right - 1 loop
                    sreg_odio(i) <= sreg_odio(i+1) ;
                end loop;
            end if;
            
            sreg_oclk(sreg_oclk'right) <= sreg_oclk(0);
            sreg_odio(sreg_odio'right) <= sreg_odio(0);
            
        end if;
    end process;
    
    oclk <= sreg_oclk(0);
    odio <= sreg_odio(0);
    
end rtl;
