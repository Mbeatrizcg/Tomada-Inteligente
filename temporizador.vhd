library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity temporizador is
    port (
        clk_base : in std_logic; -- clock lento
        reset    : in std_logic; -- reset
        en       : in std_logic; -- enable 
        timeout  : out std_logic); -- flag pra cortar energia
end entity;

architecture Comportamental of temporizador is
	 -- sinal interno do contador, conta de 0 a 2
    signal count : unsigned(1 downto 0);
begin
    process(clk_base, reset)
    begin
		-- reset assíncrono
        if reset = '1' then
            count <= "00";
        elsif rising_edge(clk_base) then -- na borda de subida do clock(cada 1 segundo)
            if en = '1' then -- o contador só avança se a FSM mandar (en=1 - há sobrecarga)
                if count < 2 then -- ao chegar em 2, trava
                    count <= count + 1; 
                end if;
            else
                count <= "00"; -- Auto-reset se o enable cair (corrente normalizou)
            end if;
        end if;
    end process;

    -- ativa timeout quando count chega a 2
    timeout <= '1' when count = 2 else '0';
end architecture;