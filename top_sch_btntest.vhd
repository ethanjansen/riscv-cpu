library IEEE;
use IEEE.std_logic_1164.all;

entity top_sch_btntest is
    port(
        mclk : in std_logic;
        btn0 : in std_logic;
        extout : out std_logic_vector(4 downto 0) -- mclk, btn, each pulse
    );
end top_sch_btntest;

architecture btntest of top_sch_btntest is
    signal sig_slow, sig_med : std_logic;

    component pulsed_en is
        port
        (
          clk                : in std_logic; --! Clock
          en_slow, en_medium : out std_logic --! Different pulsed enables
        );
    end component;

    component btn_debouncer is
        port
        (
          clk   : in std_logic; --! Clock
          en    : in std_logic; --! Pulsed Enable to slow operation
          btn   : in std_logic; --! Button
          pulse : out std_logic --! One clk pulse from the button
        );
    end component;

begin
    -- outputs
    extout(0) <= mclk;
    extout(1) <= sig_med;
    extout(2) <= sig_slow;
    extout(3) <= btn0;


    -- port maps
    plsen : pulsed_en port map(clk=>mclk, en_slow=>sig_slow, en_medium=>sig_med);
    btndeb : btn_debouncer port map(clk=>mclk, en=>sig_slow, btn=>btn0, pulse=> extout(4));
end btntest;