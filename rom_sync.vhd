-- ============================================================
-- ARCHIVO     : rom_sync.vhd
-- PROYECTO    : Microproyecto 2 - Sistema con Memorias ROM y RAM
-- DESCRIPCIÓN : Memoria ROM (Read Only Memory) sincrónica.
--               Contiene 16 posiciones de 8 bits cada una con
--               datos predefinidos que no pueden modificarse.
--               PATRÓN: dirección = dato (posición 0 → 0x00,
--               posición 1 → 0x01, ... posición F → 0x0F)
--               Esto hace muy fácil verificar el funcionamiento:
--               el display de dirección y el dato siempre iguales.
--               La lectura es sincrónica: el dato aparece en
--               la salida UN ciclo de reloj después de presentar
--               la dirección (latencia de 1 ciclo).
-- ENTRADAS    : clk      - Reloj del sistema
--               addr     - Dirección de lectura (4 bits, 0-15)
-- SALIDAS     : data_out - Dato leído de la ROM (8 bits)
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mem_pkg.all;

entity rom_sync is
    port (
        clk      : in  std_logic;
        addr     : in  addr_t;
        data_out : out word_t
    );
end entity rom_sync;

architecture rtl of rom_sync is

    -- ----------------------------------------------------------
    -- CONTENIDO DE LA ROM
    -- Patrón simple: dirección = dato
    -- Posición 0 → 0x00, posición 1 → 0x01, ... posición F → 0x0F
    -- En los displays siempre verás el mismo número en dirección y dato
    -- ----------------------------------------------------------
    constant mem : mem_t := (
        0  => x"00", 1  => x"01", 2  => x"02", 3  => x"03",
        4  => x"04", 5  => x"05", 6  => x"06", 7  => x"07",
        8  => x"08", 9  => x"09", 10 => x"0A", 11 => x"0B",
        12 => x"0C", 13 => x"0D", 14 => x"0E", 15 => x"0F"
    );

    signal q_reg  : word_t := (others => '0');
    signal addr_i : integer range 0 to 2**ADDR_WIDTH-1;

begin

    addr_i <= to_integer(unsigned(addr));

    -- Lectura sincrónica: dato disponible un ciclo después de addr
    process(clk)
    begin
        if rising_edge(clk) then
            q_reg <= mem(addr_i);
        end if;
    end process;

    data_out <= q_reg;

end architecture rtl;