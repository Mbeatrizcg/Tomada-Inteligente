library ieee;
use ieee.std_logic_1164.all;

entity fsm is
    port (
        clk           : in std_logic; -- clock
        reset_geral   : in std_logic; -- botão físico de reset
        corrente_alta : in std_logic; -- flag do comparador - 1 se houver sovrecarca
        timeout       : in std_logic; -- flag do temporizador - 1 se o tempo estourar 
        
        rele_on       : out std_logic; -- atuador (liga e desliga a tomada)
        alarme_on     : out std_logic; -- aciona LED/Buzzer 
        timer_en      : out std_logic); -- enable temporizador
end entity;

architecture RTL of fsm is
    type state_type is (S_INIT, S_MONITOR, S_TEMP, S_TRIP);
    signal estado_atual, estado_prox : state_type;
begin

    -- REGISTRADOR DE ESTADO 
    process(clk, reset_geral)
    begin
        if reset_geral = '1' then
            estado_atual <= S_INIT; -- reset assíncrono - força o estado inicial
        elsif rising_edge(clk) then
            estado_atual <= estado_prox; -- atualiza estado na subida do clock
        end if;
    end process;

    -- LÓGICA DE PRÓXIMO ESTADO
    estado_prox <= 
        S_MONITOR when (estado_atual = S_INIT) else -- Transição de saída do reset
        
		  -- Transições a partir do estado de Monitoramento - Normal
        S_TEMP    when (estado_atual = S_MONITOR and corrente_alta = '1') else 
        S_MONITOR when (estado_atual = S_MONITOR and corrente_alta = '0') else
        
		  -- Transições a partir do estado de Temporização - Pico detectado 
        S_TRIP    when (estado_atual = S_TEMP and timeout = '1') else -- Tempo esgotado
        S_MONITOR when (estado_atual = S_TEMP and corrente_alta = '0') else -- Alarme falso, volta ao normal
        S_TEMP    when (estado_atual = S_TEMP) else -- mantém aguardando o tempo passar
        
        S_INIT    when (estado_atual = S_TRIP and reset_geral = '1') else -- Usuário apertou reset
        S_TRIP; -- Se não ocorrer reset, trava o sistema no estado de falha por segurança

    -- LÓGICA DE SAÍDA
    rele_on   <= '1' when (estado_atual = S_MONITOR or estado_atual = S_TEMP) else '0'; -- em MONITOR e TEMP o relé fica ligado dando energia a tomada
    alarme_on <= '1' when (estado_atual = S_TRIP) else '0'; -- alarme toca se a máquina entrar no estado de falha
    timer_en  <= '1' when (estado_atual = S_TEMP) else '0'; -- temporizador só conta enquanto estiver no estado TEMP

end architecture;