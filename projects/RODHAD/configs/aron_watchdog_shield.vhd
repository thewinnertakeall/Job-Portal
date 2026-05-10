-- ==============================================================================
-- 🔒 HARDWARE BLOCK ARCHITECTURE: ARON WATCHDOG AND DTO VALIDATOR
-- Designed by Mateo Gallego for RISC-V Custom Coprocessor Implementation
-- ==============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity aron_watchdog_shield is
    Port (
        clk               : in  STD_LOGIC;
        reset             : in  STD_LOGIC;
        data_in_bus       : in  STD_LOGIC_VECTOR(31 downto 0); -- Bus de datos de la Capa 7
        data_valid        : in  STD_LOGIC;
        heart_rate_value  : in  UNSIGNED(15 downto 0);
        quarantine_trigger: out STD_LOGIC;                    -- Alerta Física de Reingreso
        motor_relay_power : out STD_LOGIC                     -- Corte de energía Fail-Safe
    );
end aron_watchdog_shield;

architecture Behavioral of aron_watchdog_shield is
    signal internal_quarantine : STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            internal_quarantine <= '0';
            motor_relay_power   <= '1'; -- Motores encendidos por defecto
        elsif rising_edge(clk) then
            if data_valid = '1' then
                -- DTO de Capa Física: Si los datos de pulso superan los 300 BPM (Fuzzing/Desborde)
                -- O si el bus detecta la firma de caracteres de inyección ">>>" (0x3E3E3E en ASCII)
                if (heart_rate_value > 300) or (data_in_bus = x"003E3E3E") then
                    internal_quarantine <= '1';
                    motor_relay_power   <= '0'; -- CORTE FÍSICO INMEDIATO DE ENERGÍA (Doctrina Fail-Safe)
                end if;
            end if;
        end if;
    end process;

    quarantine_trigger <= internal_quarantine;
end Behavioral;
