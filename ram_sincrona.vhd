-- ============================================================
-- ARCHIVO     : ram_sincrona.vhd
-- PROYECTO    : Microproyecto 2 - Sistema con Memorias ROM y RAM
-- DESCRIPCIÓN : Memoria RAM (Random Access Memory) sincrónica.
--               Permite leer y escribir datos en cualquier
--               posición. Tiene 16 posiciones de 8 bits.
--               Inicia con todos los valores en cero.
--               Modo READ_FIRST: en escritura, la salida refleja
--               el dato que había ANTES de escribir.
--               La escritura se activa con we=1.
--               La lectura  se activa con re=1.
-- ENTRADAS    : clk      - Reloj del sistema
--               we       - Write Enable: 1=escribir, 0=no escribir
--               re       - Read Enable:  1=leer,     0=no leer
--               addr     - Dirección (4 bits, posiciones 0-15)
--               data_in  - Dato a escribir (8 bits)
-- SALIDAS     : data_out - Dato leído de la RAM (8 bits)
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mem_pkg.all;  -- Importa tipos word_t, addr_t y constantes

entity ram_sincrona is
    port (
        clk      : in  std_logic;  -- Reloj principal del sistema
        we       : in  std_logic;  -- Write Enable (activo alto)
        re       : in  std_logic;  -- Read Enable  (activo alto)
        addr     : in  addr_t;     -- Dirección de 4 bits (0x0 a 0xF)
        data_in  : in  word_t;     -- Dato de entrada para escritura
        data_out : out word_t      -- Dato de salida para lectura
    );
end entity ram_sincrona;

architecture rtl of ram_sincrona is

    -- ----------------------------------------------------------
    -- DEFINICIÓN DEL ARRAY DE MEMORIA RAM
    -- 16 posiciones de 8 bits cada una
    -- Se inicializa en ceros al arrancar el sistema
    -- ----------------------------------------------------------
    type ram_type is array (0 to 2**ADDR_WIDTH-1) of word_t;
    signal mem    : ram_type := (others => (others => '0'));

    -- Registro de salida: guarda el dato leído en cada ciclo
    signal q_reg  : word_t := (others => '0');

    -- Conversión de dirección a entero para indexar el array
    signal addr_i : integer range 0 to 2**ADDR_WIDTH-1;

begin

    -- Convierte addr (std_logic_vector) a entero para indexar la RAM
    addr_i <= to_integer(unsigned(addr));

    -- ----------------------------------------------------------
    -- PROCESO DE LECTURA Y ESCRITURA SINCRÓNICA
    -- Se ejecuta en cada flanco de subida del reloj.
    --
    -- Si we=1 (escritura habilitada):
    --   - Se guarda data_in en la posición addr_i de la RAM
    --   - La salida q_reg toma el valor ANTERIOR (READ_FIRST)
    --     esto evita conflictos de lectura/escritura simultánea
    --
    -- Si re=1 (lectura habilitada) y we=0:
    --   - Se lee el dato de la posición addr_i
    --   - Se guarda en q_reg para enviarlo a la salida
    -- ----------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                -- ESCRITURA: guardar dato en la RAM
                mem(addr_i) <= data_in;
                -- Modo READ_FIRST: salida refleja valor anterior
                q_reg <= mem(addr_i);
            elsif re = '1' then
                -- LECTURA: leer dato de la RAM
                q_reg <= mem(addr_i);
            end if;
            -- Si we=0 y re=0: la salida mantiene su valor anterior
        end if;
    end process;

    -- Asignar el registro de salida al puerto data_out
    data_out <= q_reg;

end architecture rtl;