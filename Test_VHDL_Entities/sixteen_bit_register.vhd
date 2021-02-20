----------------------------------------------------------------------------------
-- Engineer: Matthew Thompson
-- 
-- Create Date: 02/17/2021 1:33 PM

-- Module Name: sixteen_bit_register - Behavioral
-- Project Name: EE316 I2c and PWM
-- Description: 
-- Based on: https://stackoverflow.com/a/21581726
-- By: Bill Lynch
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sixteen_bit_register is
    Port ( D : in STD_LOGIC_VECTOR (15 downto 0);
           CLK : in STD_LOGIC;
           Q : out STD_LOGIC_VECTOR (15 downto 0));
end sixteen_bit_register;

architecture description of sixteen_bit_register is
-- this version of a register is cut down from the one referenced in the header comment
-- I have removed the Enable and clear pins. I may add the enable back If I need it
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
             Q <= D;
        end if;
    end process;
end description;