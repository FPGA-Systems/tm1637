----------------------------------------------------------------------------------
-- Company:  
-- Engineer: 
-- 
-- Create Date: 04/30/2022 08:42:23 PM
-- Design Name: 
-- Module Name: ascii_to_gfedcba - rtl
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

entity ascii_to_gfedcba is
 Port (
    iascii      : in  std_logic_vector(7 downto 0);
    ogfedcba    : out std_logic_vector(7 downto 0)
 );
end ascii_to_gfedcba;

architecture rtl of ascii_to_gfedcba is
    
    --ASCII table https://en.wikipedia.org/wiki/ASCII
    --ASCII char to 7 seg (gfedcba) https://en.wikichip.org/wiki/seven-segment_display/representing_letters
    
    function f_ascii_to_gfedcba(iascii: in std_logic_vector(7 downto 0))
    return std_logic_vector is
    
    variable o7seg : std_logic_vector(7 downto 0);
    
    begin
        case iascii is
            when x"00" => o7seg := x"00"; -- empty
            when x"48" => o7seg := x"76"; -- H
            when x"45" => o7seg := x"79"; -- E
            when x"59" => o7seg := x"6e"; -- Y
            when x"46" => o7seg := x"71"; -- F
            when x"50" => o7seg := x"73"; -- P
            when x"47" => o7seg := x"3D"; -- G
            when x"41" => o7seg := x"77"; -- A
            when others => o7seg := x"00";
        end case;
        return o7seg;
    end function;
    
begin

    ogfedcba <= f_ascii_to_gfedcba(iascii);

end rtl;
