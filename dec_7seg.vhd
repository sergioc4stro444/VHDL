-- ============================================================
-- ARCHIVO     : dec_7seg.vhd
-- PROYECTO    : Microproyecto 2 - Sistema con Memorias ROM y RAM
-- DESCRIPCIÓN : Decodificador de BCD (4 bits) a display de
--               7 segmentos. Convierte un valor hexadecimal
--               de 0x0 a 0xF en las señales de control de los
--               7 segmentos del display de la tarjeta DE0.
--               IMPORTANTE: Los displays de la DE0 son de
--               CÁTODO COMÚN con lógica ACTIVO BAJO, es decir:
--               0 = segmento ENCENDIDO
--               1 = segmento APAGADO
-- ENTRADAS    : bcd_in  - Valor hex de 4 bits (0x0 a 0xF)
-- SALIDAS     : seg_out - 7 bits de control {g,f,e,d,c,b,a}
--
--               Disposición de segmentos:
--                  aaa
--                 f   b
--                 f   b
--                  ggg
--                 e   c
--                 e   c
--                  ddd
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec_7seg is
    port (
        bcd_in  : in  std_logic_vector(3 downto 0);  -- Valor 0x0-0xF
        seg_out : out std_logic_vector(6 downto 0)   -- {g,f,e,d,c,b,a}
    );
end entity dec_7seg;

architecture rtl of dec_7seg is
begin

    -- ----------------------------------------------------------
    -- TABLA DE DECODIFICACIÓN
    -- Activo bajo: '0' enciende el segmento, '1' lo apaga
    -- seg_out = "gfedcba"
    -- ----------------------------------------------------------
    with bcd_in select
        seg_out <=
            "1000000" when x"0",  -- Muestra: 0
            "1111001" when x"1",  -- Muestra: 1
            "0100100" when x"2",  -- Muestra: 2
            "0110000" when x"3",  -- Muestra: 3
            "0011001" when x"4",  -- Muestra: 4
            "0010010" when x"5",  -- Muestra: 5
            "0000010" when x"6",  -- Muestra: 6
            "1111000" when x"7",  -- Muestra: 7
            "0000000" when x"8",  -- Muestra: 8
            "0010000" when x"9",  -- Muestra: 9
            "0001000" when x"A",  -- Muestra: A
            "0000011" when x"B",  -- Muestra: b
            "1000110" when x"C",  -- Muestra: C
            "0100001" when x"D",  -- Muestra: d
            "0000110" when x"E",  -- Muestra: E
            "0001110" when x"F",  -- Muestra: F
            "1111111" when others; -- Display apagado

end architecture rtl;