library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisor_clock is
    port (
        clk_50mhz : in std_logic; -- clock
        reset     : in std_logic; -- reset
        clk_1hz   : out std_logic; -- clock lento 1hz
        clk_pisca : out std_logic); -- saída de clock (pra fazer o LED piscar)
end entity;

architecture Comportamental of divisor_clock is
	 -- cria sinal interno - contador
    signal count : unsigned(25 downto 0);
begin
    process(clk_50mhz, reset)
    begin
	 -- reset assíncrono
        if reset = '1' then
            count <= (others => '0'); -- zera os bits do contador
        elsif rising_edge(clk_50mhz) then -- Se não há reset, avalia a borda de subida do clock_50MHz
            if count = 49_999_999 then -- se contador=49.999.999 passou 1s
                count <= (others => '0'); -- estoura o contador e volta a zero
            else
                count <= count + 1; -- caso contrário continua incrementando o contador
            end if;
        end if;
    end process;

    -- Extraindo frequências (MSBs do contador atuam como divisores naturais)
    clk_1hz   <= std_logic(count(25)); -- Aprox 1.5Hz a 0.7Hz dependendo do corte
    clk_pisca <= std_logic(count(23)); -- oscila 4 vezes mais rápido
end architecture;

