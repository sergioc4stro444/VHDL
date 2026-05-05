-- ============================================================
-- ARCHIVO     : mem_pkg.vhd
-- PROYECTO    : Microproyecto 2 - Sistema con Memorias ROM y RAM
-- DESCRIPCIÓN : Paquete (package) compartido por todos los módulos
--               del sistema. Define las constantes globales de
--               ancho de datos y dirección, los tipos de datos
--               personalizados usados en ROM y RAM, y declara
--               los componentes rom_sync y ram_sincrona para
--               que puedan ser instanciados desde el top level.
-- AUTOR       : Ingeniería Electrónica y Telecomunicaciones
--               Universidad del Cauca
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package mem_pkg is

    -- ----------------------------------------------------------
    -- CONSTANTES GLOBALES DEL SISTEMA
    -- DATA_WIDTH : número de bits por palabra (8 bits = 1 byte)
    -- ADDR_WIDTH : número de bits de dirección
    --             Con 4 bits se pueden direccionar 2^4 = 16
    --             posiciones de memoria (0x0 hasta 0xF)
    -- ----------------------------------------------------------
    constant DATA_WIDTH : integer := 8;
    constant ADDR_WIDTH : integer := 4;

    -- ----------------------------------------------------------
    -- TIPOS PERSONALIZADOS
    -- word_t : tipo para representar una palabra de datos (8 bits)
    --          Usado en las entradas y salidas de datos de ROM/RAM
    -- addr_t : tipo para representar una dirección (4 bits)
    --          Usado para seleccionar la posición de memoria
    -- mem_t  : tipo array que representa la memoria completa
    --          Es un arreglo de 16 posiciones, cada una de 8 bits
    -- ----------------------------------------------------------
    subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
    subtype addr_t is std_logic_vector(ADDR_WIDTH-1 downto 0);
    type mem_t is array (0 to (2**ADDR_WIDTH)-1) of word_t;

    -- ----------------------------------------------------------
    -- DECLARACIÓN DEL COMPONENTE: rom_sync
    -- Memoria ROM sincrónica de solo lectura.
    -- El dato de salida se registra en el flanco de subida
    -- del reloj, por lo que hay una latencia de 1 ciclo.
    -- Puertos:
    --   clk      : reloj del sistema
    --   addr     : dirección de lectura (4 bits)
    --   data_out : dato leído de la ROM (8 bits)
    -- ----------------------------------------------------------
    component rom_sync
        port (
            clk      : in  std_logic;
            addr     : in  addr_t;
            data_out : out word_t
        );
    end component;

    -- ----------------------------------------------------------
    -- DECLARACIÓN DEL COMPONENTE: ram_sincrona
    -- Memoria RAM sincrónica de lectura y escritura.
    -- Permite escribir un dato con we=1 y leerlo con re=1.
    -- Puertos:
    --   clk      : reloj del sistema
    --   we       : write enable - habilita escritura (activo alto)
    --   re       : read enable  - habilita lectura   (activo alto)
    --   addr     : dirección de lectura/escritura (4 bits)
    --   data_in  : dato a escribir en la RAM (8 bits)
    --   data_out : dato leído de la RAM (8 bits)
    -- ----------------------------------------------------------
    component ram_sincrona
        port (
            clk      : in  std_logic;
            we       : in  std_logic;
            re       : in  std_logic;
            addr     : in  addr_t;
            data_in  : in  word_t;
            data_out : out word_t
        );
    end component;

end package mem_pkg;

-- ============================================================
-- CUERPO DEL PAQUETE
-- No requiere implementación ya que solo contiene declaraciones
-- de tipos, constantes y componentes.
-- ============================================================
package body mem_pkg is
end package body mem_pkg;