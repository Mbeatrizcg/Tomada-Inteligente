library ieee;
use ieee.std_logic_1164.all;

entity tomada_top is -- entidade topo
    port (
        clk_50mhz  : in std_logic; -- clock
        botao_rst  : in std_logic; -- reset 
        chaves_set : in std_logic_vector(7 downto 0); -- setpoint através de chaves
        pinos_adc  : in std_logic_vector(7 downto 0); -- leitura do conversor A/D
        
        sinal_rele : out std_logic; -- pino do rele
        led_trip   : out std_logic; -- LED vermelho pra alarme
        buzzer     : out std_logic); -- pino do buzzer - pisca na frequencia
end entity;


architecture Estrutural of tomada_top is
	
    component registrador port (clk, reset, en: in std_logic; D: in std_logic_vector(7 downto 0); Q: out std_logic_vector(7 downto 0)); end component;
    component comparador port (adc_val, setpoint: in std_logic_vector(7 downto 0); alta: out std_logic); end component;
    component divisor_clock port (clk_50mhz, reset: in std_logic; clk_1hz, clk_pisca: out std_logic); end component;
    component temporizador port (clk_base, reset, en: in std_logic; timeout: out std_logic); end component;
    component fsm port (clk, reset_geral, corrente_alta, timeout: in std_logic; rele_on, alarme_on, timer_en: out std_logic); end component;

	 -- sinais internos (fios)
    signal fio_clk_1hz, fio_clk_pisca : std_logic;
    signal val_setpoint, val_adc      : std_logic_vector(7 downto 0);
    signal flag_alta, flag_timeout    : std_logic;
    signal cmd_rele, cmd_alarme       : std_logic;
    signal en_timer                   : std_logic;
    signal rst_ativo_alto             : std_logic;

begin
    -- adequando botão da Cyclone II (ativo em baixo)
    rst_ativo_alto <= not botao_rst;

    -------------------- CAMINHO DE DADOS --------------------
	 -- liga o gerador de frequências
    U_DIV: divisor_clock port map (clk_50mhz, rst_ativo_alto, fio_clk_1hz, fio_clk_pisca);
    
    -- registra o setpoint das chaves continuamente (en=1) 
    U_REG_SET: registrador port map (clk_50mhz, rst_ativo_alto, '1', chaves_set, val_setpoint);
    
    -- registra a entrada ADC continuamente pra sinc com clock (en = '1')
    U_REG_ADC: registrador port map (clk_50mhz, rst_ativo_alto, '1', pinos_adc, val_adc);
    
	 -- conecta os valores guardados nos registradores
    U_COMP: comparador port map (val_adc, val_setpoint, flag_alta);
    
	 -- conecta o temporizador ao clock de 1Hz, só conta quando en_timer=1
    U_TEMP: temporizador port map (fio_clk_1hz, rst_ativo_alto, en_timer, flag_timeout);

    -------------------- UNIDADE DE CONTROLE --------------------
    U_FSM: fsm port map (
        clk           => clk_50mhz, 		-- clock rápido pra transições imediatas
        reset_geral   => rst_ativo_alto,	-- botão de reset
        corrente_alta => flag_alta,			-- flag do comparador
        timeout       => flag_timeout,		-- flag do temporizador
        rele_on       => cmd_rele,			-- fio do relé
        alarme_on     => cmd_alarme,		-- fio de alerta
        timer_en      => en_timer			-- enable do contador
    );

    -------------------- SAÍDAS --------------------
    sinal_rele <= cmd_rele; -- pino do relé vai direto para fora da placa
    
	 -- o LED e o buzzer só vão ligar/piscar se alarme_on=1 & clk_pisca=1
    led_trip <= cmd_alarme and fio_clk_pisca;
    buzzer   <= cmd_alarme and fio_clk_pisca;

end architecture;