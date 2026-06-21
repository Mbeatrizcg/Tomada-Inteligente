library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador is
    port (
        adc_val  : in std_logic_vector(7 downto 0); -- leitura atual simulada da corrente
        setpoint : in std_logic_vector(7 downto 0); -- limite máximo configurado nas chaves
        alta     : out std_logic -- vai para '1' se houver sobrecarga, caso contrário '0'
    );
end entity;

architecture Combinacional of comparador is
begin  -- avaliada continuamente, sem depender do clock
    alta <= '1' when unsigned(adc_val) > unsigned(setpoint) else '0'; -- se corrente > que setpoint saída alta=1, senão alta=0
end architecture;