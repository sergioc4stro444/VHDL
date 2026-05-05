-- ============================================================
-- ARCHIVO     : divisor_frecuencia.vhd
-- PROYECTO    : Microproyecto 2 - Sistema con Memorias
-- DESCRIPCIÓN : Divide el reloj de 50 MHz a frecuencias
--               mucho más bajas para visualización humana.
--
--               MODIFICACIÓN:
--               Se aumentó el tamaño del contador para lograr
--               frecuencias MÁS lentas y facilitar la depuración.
--
-- ENTRADAS    : clk_in   - Reloj de 50 MHz
--               selector - Selección de velocidad (2 bits)
--
-- SALIDAS     : clk_out  - Reloj dividido
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divisor_frecuencia is
    port (
        clk_in   : in  std_logic;
        selector : in  std_logic_vector(1 downto 0);
        clk_out  : out std_logic
    );
end entity;

architecture rtl of divisor_frecuencia is

    -- ----------------------------------------------------------
    -- CONTADOR AMPLIADO
    -- Permite generar frecuencias muy bajas
    -- ----------------------------------------------------------
    signal contador : unsigned(27 downto 0) := (others => '0');

    -- Registro de salida del reloj
    signal clk_reg  : std_logic := '0';

    -- Límite de conteo según velocidad
    signal limite   : unsigned(27 downto 0);

begin

    -- ----------------------------------------------------------
    -- SELECCIÓN DE VELOCIDAD
    -- ----------------------------------------------------------
    with selector select
        limite <=
            to_unsigned(50000000, 28)  when "00", -- Muy lento
            to_unsigned(10000000, 28)  when "01",
            to_unsigned(2000000, 28)   when "10",
            to_unsigned(500000, 28)    when others;

    -- ----------------------------------------------------------
    -- PROCESO DIVISOR
    -- Cuenta ciclos y alterna salida al alcanzar el límite
    -- ----------------------------------------------------------
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if contador >= limite then
                contador <= (others => '0'); -- Reinicia contador
                clk_reg  <= not clk_reg;     -- Invierte señal
            else
                contador <= contador + 1;    -- Incrementa contador
            end if;
        end if;
    end process;

    -- Salida del reloj dividido
    clk_out <= clk_reg;

end architecture;