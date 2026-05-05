-- ============================================================
-- ARCHIVO     : top_mem_system.vhd
-- PROYECTO    : Microproyecto 2 - Sistema con Memorias ROM y RAM
-- DESCRIPCIÓN : Módulo top level del sistema. Integra ROM, RAM,
--               divisor de frecuencia y displays 7 segmentos.
--               
--               MODIFICACIÓN:
--               Se agregó un retardo en el estado S_SHOW para
--               permitir visualizar correctamente los datos en
--               los displays. Sin este retardo, el sistema es
--               demasiado rápido para el ojo humano.
--
--               FSM de 7 estados:
--               S_READ_ROM      → Presenta dirección
--               S_WAIT_ROM      → Espera latencia ROM (1)
--               S_WAIT_ROM2     → Captura dato ROM
--               S_WRITE_RAM     → Escribe en RAM
--               S_READ_RAM      → Activa lectura RAM
--               S_READ_RAM_WAIT → Espera latencia RAM
--               S_SHOW          → Muestra dato y pausa visual
--
-- TARJETA     : Altera DE0 (EP3C16F484C6)
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mem_pkg.all;

entity top_mem_system is
    port (
        clk      : in  std_logic;                     -- Reloj 50 MHz
        rst_n    : in  std_logic;                     -- Reset activo bajo
        selector : in  std_logic_vector(1 downto 0);  -- Selección velocidad
        HEX0     : out std_logic_vector(6 downto 0);  -- Display bajo
        HEX1     : out std_logic_vector(6 downto 0);  -- Display alto
        HEX2     : out std_logic_vector(6 downto 0);  -- Apagado
        HEX3     : out std_logic_vector(6 downto 0);  -- Apagado
        LEDG     : out std_logic_vector(7 downto 0);  -- Datos en binario
        LEDR     : out std_logic_vector(2 downto 0)   -- Señales de control
    );
end entity;

architecture Behavioral of top_mem_system is

    -- ----------------------------------------------------------
    -- DEFINICIÓN DE ESTADOS DE LA FSM
    -- ----------------------------------------------------------
    type state_t is (
        S_READ_ROM,
        S_WAIT_ROM,
        S_WAIT_ROM2,
        S_WRITE_RAM,
        S_READ_RAM,
        S_READ_RAM_WAIT,
        S_SHOW
    );

    signal state : state_t := S_READ_ROM;

    -- ----------------------------------------------------------
    -- SEÑALES INTERNAS
    -- ----------------------------------------------------------
    signal rst          : std_logic;                 -- Reset activo alto
    signal clk_lento    : std_logic;                 -- Reloj dividido
    signal addr_cnt     : addr_t := (others => '0'); -- Contador de dirección
    signal rom_data     : word_t;                    -- Salida ROM
    signal rom_data_reg : word_t := (others => '0'); -- Registro intermedio
    signal ram_dout     : word_t;                    -- Salida RAM
    signal display_reg  : word_t := (others => '0'); -- Registro para display

    signal we_sig     : std_logic := '0'; -- Write Enable RAM
    signal re_sig     : std_logic := '0'; -- Read Enable RAM
    signal done_reg   : std_logic := '0'; -- Indicador de ciclo completo

    -- 🔥 Contador de retardo para visualización
    signal delay_cnt : integer range 0 to 50 := 0;

begin

    -- Conversión de reset (activo bajo → activo alto)
    rst <= not rst_n;

    -- ----------------------------------------------------------
    -- INSTANCIA DEL DIVISOR DE FRECUENCIA
    -- Genera un reloj lento visible
    -- ----------------------------------------------------------
    U_DIV : entity work.divisor_frecuencia
        port map (
            clk_in   => clk,
            selector => selector,
            clk_out  => clk_lento
        );

    -- ----------------------------------------------------------
    -- INSTANCIA DE LA ROM
    -- ----------------------------------------------------------
    U_ROM : entity work.rom_sync
        port map (
            clk      => clk_lento,
            addr     => addr_cnt,
            data_out => rom_data
        );

    -- ----------------------------------------------------------
    -- INSTANCIA DE LA RAM
    -- ----------------------------------------------------------
    U_RAM : entity work.ram_sincrona
        port map (
            clk      => clk_lento,
            we       => we_sig,
            re       => re_sig,
            addr     => addr_cnt,
            data_in  => rom_data_reg,
            data_out => ram_dout
        );

    -- ----------------------------------------------------------
    -- FSM PRINCIPAL
    -- Maneja lectura ROM, escritura RAM y visualización
    -- ----------------------------------------------------------
    process(clk_lento)
    begin
        if rising_edge(clk_lento) then
            if rst = '1' then
                -- Reset del sistema
                state        <= S_READ_ROM;
                addr_cnt     <= (others => '0');
                we_sig       <= '0';
                re_sig       <= '0';
                done_reg     <= '0';
                rom_data_reg <= (others => '0');
                display_reg  <= (others => '0');
                delay_cnt    <= 0;

            else
                case state is

                    -- Presenta dirección a la ROM
                    when S_READ_ROM =>
                        state <= S_WAIT_ROM;

                    -- Espera ciclo 1 de ROM
                    when S_WAIT_ROM =>
                        state <= S_WAIT_ROM2;

                    -- Captura dato válido de ROM
                    when S_WAIT_ROM2 =>
                        rom_data_reg <= rom_data;
                        state        <= S_WRITE_RAM;

                    -- Escribe dato en RAM
                    when S_WRITE_RAM =>
                        we_sig <= '1';
                        re_sig <= '0';
                        state  <= S_READ_RAM;

                    -- Activa lectura RAM
                    when S_READ_RAM =>
                        we_sig <= '0';
                        re_sig <= '1';
                        state  <= S_READ_RAM_WAIT;

                    -- Espera latencia RAM
                    when S_READ_RAM_WAIT =>
                        state <= S_SHOW;

                    -- 🔥 Muestra dato y genera retardo visual
                    when S_SHOW =>
                        display_reg <= ram_dout;

                        -- Mantiene el estado varios ciclos
                        if delay_cnt < 40 then
                            delay_cnt <= delay_cnt + 1;
                            state <= S_SHOW;
                        else
                            delay_cnt <= 0;

                            -- Avanza dirección
                            if addr_cnt = "1111" then
                                addr_cnt <= (others => '0');
                                done_reg <= '1';
                            else
                                addr_cnt <= std_logic_vector(unsigned(addr_cnt) + 1);
                                done_reg <= '0';
                            end if;

                            state <= S_READ_ROM;
                        end if;

                end case;
            end if;
        end if;
    end process;

    -- ----------------------------------------------------------
    -- DISPLAYS 7 SEGMENTOS
    -- ----------------------------------------------------------
    U_HEX0 : entity work.dec_7seg
        port map (bcd_in => display_reg(3 downto 0), seg_out => HEX0);

    U_HEX1 : entity work.dec_7seg
        port map (bcd_in => display_reg(7 downto 4), seg_out => HEX1);

    -- Displays apagados
    HEX2 <= "1111111";
    HEX3 <= "1111111";

    -- LEDs de salida
    LEDG    <= display_reg;
    LEDR(0) <= we_sig;
    LEDR(1) <= re_sig;
    LEDR(2) <= done_reg;

end architecture;