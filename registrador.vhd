library ieee;
use ieee.std_logic_1164.all;

entity registrador is
    port (
        clk   : in std_logic; -- clock
        reset : in std_logic; -- reset
        en    : in std_logic; -- enable
        D     : in std_logic_vector(7 downto 0); -- entrada
        Q     : out std_logic_vector(7 downto 0); -- saida
    );
end entity;

architecture Comportamental of registrador is
begin
    process(clk, reset) -- ativa quando 'clk' ou 'reset' for alterado
    begin 
		-- verifica o reset assíncrono
        if reset = '1' then -- se reset=1
            Q <= (others => '0'); -- limpa saída
		-- se reset não ativo
        elsif rising_edge(clk) then -- verifica borda de subida do clock
            if en = '1' then -- verifica enable
                Q <= D; -- 'memorização' - copia o valor de D para Q 
            end if; -- se en=0 o registrador mantém o valor inalterado
        end if;
    end process;
end architecture;