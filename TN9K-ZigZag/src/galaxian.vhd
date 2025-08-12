---------------------------------------------------------------------
-- Copyright(c) 2004 Katsumi Degawa , All rights reserved
--
-- Important  not
--
-- This program is freeware for non-commercial use.
-- The author does not guarantee this program.
-- You can use this at your own risk.
--
-- 2004- 4-30  galaxian modify by K.DEGAWA
-- 2004- 5- 6  first release.
-- 2004- 8-23  Improvement with T80-IP.
-- 2004- 9-22  The problem which missile didn't sometimes come out from was improved.
---------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;
---------------------------------------------------------------------
entity galaxian is
	port(
		CLK       : in  std_logic;
		I_RESET   : in std_logic;
		W_R       : out std_logic_vector(2 downto 0);
		W_G       : out std_logic_vector(2 downto 0);
		W_B       : out std_logic_vector(1 downto 0);
		hsync     : out std_logic;
		vsync     : out std_logic;
        O_AUDIO   : out std_logic_vector( 7 downto 0);
		SW_LEFT   : in std_logic;
		SW_RIGHT  : in std_logic;
		SW_UP     : in std_logic;
		SW_DOWN   : in std_logic;
		SW_FIRE   : in std_logic;
        I_COIN1   : in std_logic;
        I_COIN2   : in std_logic;
        I_1P_START : in std_logic;
        I_2P_START : in std_logic;
        AD        : out std_logic_vector(15 downto 0)
	);
end;
----------------------------------------------------------------------
architecture RTL of galaxian is
	--
	-- 	HARDWARE SELECTOR
	--		TRUE = galaxian hardware
	-- 	FALSE = mrdo's nightmare
	--
	constant HWSEL_GALAXIAN : 	boolean := TRUE;

	--    CPU ADDRESS BUS
	signal W_A                : std_logic_vector(15 downto 0) := (others => '0');
	--    CPU IF
	signal W_CPU_CLK          : std_logic := '0';
	signal W_CPU_MREQn        : std_logic := '0';
	signal W_CPU_NMIn         : std_logic := '0';
	signal W_CPU_RDn          : std_logic := '0';
	signal W_CPU_RESETn       : std_logic := '0';
	signal W_CPU_RFSHn        : std_logic := '0';
	signal W_CPU_WAITn        : std_logic := '0';
	signal W_CPU_WRn          : std_logic := '0';
	signal W_RESETn           : std_logic := '0';
	signal W_ROM_SWP          : std_logic := '0';
	-------- CLOCK GEN ---------------------------
	signal W_CLK_12M          : std_logic := '0';
	signal W_CLK_18M          : std_logic := '0';
--	signal W_CLK_36M          : std_logic := '0';
	signal W_CLK_6M           : std_logic := '0';
	signal W_CLK_6Mn          : std_logic := '0';
	signal WB_CLK_12M         : std_logic := '0';
	signal WB_CLK_6M          : std_logic := '0';
	-------- H and V COUNTER -------------------------
	signal W_C_BLn            : std_logic := '0';
	signal W_C_BLnX           : std_logic := '0';
	signal W_C_BLX            : std_logic := '0';
	signal W_H_BL             : std_logic := '0';
	signal W_H_SYNC           : std_logic := '0';
	signal W_V_BLn            : std_logic := '0';
	signal W_V_BL2n           : std_logic := '0';
	signal W_V_SYNC           : std_logic := '0';
	signal W_H_CNT            : std_logic_vector(8 downto 0) := (others => '0');
	signal W_V_CNT            : std_logic_vector(7 downto 0) := (others => '0');
	-------- CPU RAM  ----------------------------
	signal W_CPU_RAM_DO       : std_logic_vector(7 downto 0) := (others => '0');
	-------- ADDRESS DECDER ----------------------
	signal W_BD_G             : std_logic := '0';
	signal W_CPU_RAM_CSn      : std_logic := '0';
	signal W_CPU_RAM_RDn      : std_logic := '0';
	signal W_CPU_RAM_WRn      : std_logic := '0';
	signal W_CPU_ROM_CSn      : std_logic := '0';
	signal W_DIP_OEn          : std_logic := '0';
	signal W_H_FLIP           : std_logic := '0';
	signal W_LAMP_WEn         : std_logic := '0';
	signal W_OBJ_RAM_RDn      : std_logic := '0';
	signal W_OBJ_RAM_RQn      : std_logic := '0';
	signal W_OBJ_RAM_WRn      : std_logic := '0';
	signal W_PITCHn           : std_logic := '0';
	signal W_SOUND_WEn        : std_logic := '0';
	signal W_STARS_ON         : std_logic := '0';
	signal W_STARS_OFFn       : std_logic := '0';
	signal W_SW0_OEn          : std_logic := '0';
	signal W_SW1_OEn          : std_logic := '0';
	signal W_V_FLIP           : std_logic := '0';
	signal W_VID_RAM_RDn      : std_logic := '0';
	signal W_VID_RAM_WRn      : std_logic := '0';
	signal W_WDR_OEn          : std_logic := '0';
	--------- INPORT -----------------------------
	signal W_SW_DO            : std_logic_vector( 7 downto 0) := (others => '0');
	--------- VIDEO  -----------------------------
	signal W_VID_DO           : std_logic_vector( 7 downto 0) := (others => '0');
	-----  DATA I/F -------------------------------------
	signal W_CPU_ROM_DO       : std_logic_vector( 7 downto 0) := (others => '0');
	signal W_CPU_ROM_DOB      : std_logic_vector( 7 downto 0) := (others => '0');
	signal W_BDO              : std_logic_vector( 7 downto 0) := (others => '0');
	signal W_BDI              : std_logic_vector( 7 downto 0) := (others => '0');
	signal W_CPU_RAM_CLK      : std_logic := '0';
	signal W_VOL1             : std_logic := '0';
	signal W_VOL2             : std_logic := '0';
	signal W_FIRE             : std_logic := '0';
	signal W_HIT              : std_logic := '0';
	--signal W_FS3              : std_logic := '0';
	--signal W_FS2              : std_logic := '0';
	--signal W_FS1              : std_logic := '0';
	signal W_FS               : std_logic_vector( 2 downto 0) := (others => '0');
	-----  BTTONS  -------------------------------------
	--signal C1                 : std_logic := '0';
	--signal C2                 : std_logic := '0';
	--signal D1                 : std_logic := '0';
	--signal D2                 : std_logic := '0';
	--signal J1                 : std_logic := '0';
	--signal J2                 : std_logic := '0';
	--signal L1                 : std_logic := '0';
	--signal L2                 : std_logic := '0';
	--signal R1                 : std_logic := '0';
	--signal R2                 : std_logic := '0';
	--signal S1                 : std_logic := '0';
	--signal S2                 : std_logic := '0';
	--signal U1                 : std_logic := '0';
	--signal U2                 : std_logic := '0';

	signal blx_comb           : std_logic := '0';
	signal W_1VF              : std_logic := '0';
	signal W_256HnX           : std_logic := '0';
	signal W_8HF              : std_logic := '0';
	signal W_DAC              : std_logic := '0';
	signal W_MISSILEn         : std_logic := '0';
	signal W_SHELLn           : std_logic := '0';
	signal ZMWR               : std_logic := '0';

	signal new_sw             : std_logic_vector( 2 downto 0) := (others => '0');
	signal on_game            : std_logic_vector( 1 downto 0) := (others => '0');
	signal rst_count          : std_logic_vector( 3 downto 0) := (others => '0');
	signal W_9L_Q             : std_logic_vector( 7 downto 0) := (others => '0');
	signal W_COL              : std_logic_vector( 2 downto 0) := (others => '0');
--	signal W_B                : std_logic_vector( 1 downto 0) := (others => '0');
--	signal W_G                : std_logic_vector( 2 downto 0) := (others => '0');
--	signal W_R                : std_logic_vector( 2 downto 0) := (others => '0');
--	signal O_AUDIO            : std_logic_vector( 7 downto 0) := (others => '0');
	signal W_STARS_B          : std_logic_vector( 1 downto 0) := (others => '0');
	signal W_STARS_G          : std_logic_vector( 2 downto 0) := (others => '0');
	signal W_STARS_R          : std_logic_vector( 2 downto 0) := (others => '0');
--	signal W_VGA_B            : std_logic_vector( 1 downto 0) := (others => '0');
--	signal W_VGA_G            : std_logic_vector( 2 downto 0) := (others => '0');
--	signal W_VGA_R            : std_logic_vector( 2 downto 0) := (others => '0');
	signal W_VID              : std_logic_vector( 1 downto 0) := (others => '0');
--	signal W_VIDEO_B          : std_logic_vector( 1 downto 0) := (others => '0');
--	signal W_VIDEO_G          : std_logic_vector( 2 downto 0) := (others => '0');
--	signal W_VIDEO_R          : std_logic_vector( 2 downto 0) := (others => '0');
--	signal O_VGA_HSYNC		  : std_logic;
--	signal O_VGA_VSYNC		  : std_logic;
	signal comp_sync_l		  : std_logic;
--	signal dbl_scan        	  : std_logic;

	signal PSG_EN             : std_logic;
	signal PSG_D              : std_logic_vector(7 downto 0);
	signal PSG_A,PSG_B,PSG_C  : std_logic_vector(7 downto 0);
    --
	signal button_in        : std_logic_vector(15 downto 0);
	signal buttons          : std_logic_vector(15 downto 0);
	signal button_debounced : std_logic_vector(15 downto 0);
	signal joystick_reg     : std_logic_vector(5 downto 0);
	signal joystick2_reg    : std_logic_vector(5 downto 0);
	--
--	signal hsync        	  : std_logic;
--	signal vsync        	  : std_logic;
--------------------------------------------------------------
begin

    AD    <= W_A; -- debug
    hsync <= W_H_SYNC;
    vsync <= W_V_SYNC;
---------------------------------------------------------------
	mc_clocks : entity work.CLOCKGEN
	port map(
		CLK_36M    => CLK,
		RST_IN     => '0',
--		O_CLK_36M  => W_CLK_36M,
		O_CLK_18M  => W_CLK_18M,
		O_CLK_12M  => WB_CLK_12M,
		O_CLK_06M  => WB_CLK_6M,
		O_CLK_06Mn => W_CLK_6Mn
	);
----------------------------------------------------------------
	cpu : entity work.T80as
		port map (
			RESET_n => W_CPU_RESETn,
			CLK_n   => W_CPU_CLK,
			WAIT_n  => W_CPU_WAITn,
			INT_n   => '1',
			NMI_n   => W_CPU_NMIn,
			BUSRQ_n => '1',
			M1_n    => open,
			MREQ_n  => W_CPU_MREQn,
			IORQ_n  => open,
			RD_n    => W_CPU_RDn,
			WR_n    => W_CPU_WRn,
			RFSH_n  => W_CPU_RFSHn,
			HALT_n  => open,
			BUSAK_n => open,
			A       => W_A,
			DI      => W_BDO,
			DO      => W_BDI,
			DOE     => open
		);
-----------------------------------------------------------------
	mc_cpu_ram : entity work.MC_CPU_RAM
	port map (
		I_CLK  => W_CPU_RAM_CLK,
		I_ADDR => W_A(9 downto 0),
		I_D    => W_BDI,
		I_WE   => not W_CPU_WRn,
		I_OE   => not W_CPU_RAM_RDn,
		O_D    => W_CPU_RAM_DO
	);
------------------------------------------------------------------
	mc_adec : entity work.MC_ADEC
	port map(
		I_CLK_12M     => W_CLK_12M,
		I_CLK_6M      => W_CLK_6M,
		I_CPU_CLK     => W_H_CNT(0),
		I_RSTn        => W_RESETn,

		I_CPU_A       => W_A,
		I_CPU_D       => W_BDI(0),
		I_MREQn       => W_CPU_MREQn,
		I_RFSHn       => W_CPU_RFSHn,
		I_RDn         => W_CPU_RDn,
		I_WRn         => W_CPU_WRn,
		I_H_BL        => W_H_BL,
		I_V_BLn       => W_V_BLn,

		O_WAITn       => W_CPU_WAITn,
		O_NMIn        => W_CPU_NMIn,
		O_CPU_ROM_CSn => W_CPU_ROM_CSn,
		O_CPU_RAM_RDn => W_CPU_RAM_RDn,
		O_CPU_RAM_WRn => W_CPU_RAM_WRn,
		O_CPU_RAM_CSn => W_CPU_RAM_CSn,
		O_OBJ_RAM_RDn => W_OBJ_RAM_RDn,
		O_OBJ_RAM_WRn => W_OBJ_RAM_WRn,
		O_OBJ_RAM_RQn => W_OBJ_RAM_RQn,
		O_VID_RAM_RDn => W_VID_RAM_RDn,
		O_VID_RAM_WRn => W_VID_RAM_WRn,
		O_SW0_OEn     => W_SW0_OEn,
		O_SW1_OEn     => W_SW1_OEn,
		O_DIP_OEn     => W_DIP_OEn,
		O_WDR_OEn     => W_WDR_OEn,
		O_LAMP_WEn    => W_LAMP_WEn,
		O_SOUND_WEn   => W_SOUND_WEn,
		O_PITCHn      => W_PITCHn,
		O_H_FLIP      => W_H_FLIP,
		O_V_FLIP      => W_V_FLIP,
		O_BD_G        => W_BD_G,
		O_ROM_SWP     => W_ROM_SWP,
		O_STARS_ON    => W_STARS_ON
	);
--------------------------------------------------------------------
-- active high buttons
	mc_inport : entity work.MC_INPORT
	port map (
		I_COIN1       => I_COIN1,
		I_COIN2       => I_COIN2,
		I_1P_START    => I_1P_START,
		I_2P_START    => I_2P_START,
		I_LEFT        => SW_LEFT,
		I_RIGHT       => SW_RIGHT,
		I_UP          => SW_UP,
		I_DOWN        => SW_DOWN,
		I_FIRE        => SW_FIRE,

		I_SW0_OE      => W_SW0_OEn,
		I_SW1_OE      => W_SW1_OEn,
		I_DIP_OE      => W_DIP_OEn,
		O_D           => W_SW_DO
	);
------------------------------------------------------------------
-- prog rom

	u_rom : entity work.rom0
	port map (
		CLK  => W_CLK_12M,
		ADDR => W_A(13) & (W_A(12) xor (W_ROM_SWP and W_A(13))) & W_A(11 downto 0),
		DATA => W_CPU_ROM_DO --,
--		ENA  => '1'
	);
-------------------------------------------------------------------
	mc_hv : entity work.MC_HV_COUNT
	port map(
		I_CLK    => WB_CLK_6M,
		I_RSTn   => W_RESETn,
		O_H_CNT  => W_H_CNT,
		O_H_SYNC => W_H_SYNC,
		O_H_BL   => W_H_BL,
		O_V_CNT  => W_V_CNT,
		O_V_SYNC => W_V_SYNC,
		O_V_BL2n => W_V_BL2n,
		O_V_BLn  => W_V_BLn,
		O_C_BLn  => W_C_BLn
	);
-------------------------------------------------------------------
	mc_vid : entity work.MC_VIDEO
	port map(
		I_CLK_18M     => W_CLK_18M,
		I_CLK_12M     => W_CLK_12M,
		I_CLK_6M      => W_CLK_6M,
		I_CLK_6Mn     => W_CLK_6Mn,
		I_H_CNT       => W_H_CNT,
		I_V_CNT       => W_V_CNT,
		I_H_FLIP      => W_H_FLIP,
		I_V_FLIP      => W_V_FLIP,
		I_V_BLn       => W_V_BLn,
		I_C_BLn       => W_C_BLn,
		I_A           => W_A(9 downto 0),
		I_BD          => W_BDI,
		I_OBJ_RAM_RQn => W_OBJ_RAM_RQn,
		I_OBJ_RAM_RDn => W_OBJ_RAM_RDn,
		I_OBJ_RAM_WRn => W_OBJ_RAM_WRn,
		I_VID_RAM_RDn => W_VID_RAM_RDn,
		I_VID_RAM_WRn => W_VID_RAM_WRn,
		O_C_BLnX      => W_C_BLnX,
		O_BD          => W_VID_DO,
		O_VID         => W_VID,
		O_COL         => W_COL
	);
--------------------------------------------------------------------
	mc_col_pal : entity work.MC_COL_PAL
	port map(
		I_CLK_12M    => W_CLK_12M,
		I_CLK_6M     => W_CLK_6M,
		I_VID        => W_VID,
		I_COL        => W_COL,
		I_C_BLnX     => W_C_BLnX,
		O_C_BLX      => W_C_BLX,
		O_STARS_OFFn => W_STARS_OFFn,
		O_R          => W_R,
		O_G          => W_G,
		O_B          => W_B
	);
---------------------------------------------------------------------
--  u_dblscan : entity work.scandoubler
--    port map (
--		clk_sys => W_CLK_36M,
--		r_in => W_R & W_R,
--		g_in => W_G & W_G,
--		b_in => W_B & W_B,
--		hs_in => W_H_SYNC,
--		vs_in => W_V_SYNC,
--		r_out => W_VGA_R,
--		g_out => W_VGA_G,
--		b_out => W_VGA_B,
--		hs_out => O_HSYNC,
--		vs_out => O_VSYNC,
--		scanlines => "00"
--	);
-------------------------------------------------------------------------
--      O_VIDEO_R <= W_VGA_R(5 downto 2);
 --     O_VIDEO_G <= W_VGA_G(5 downto 2);
 --     O_VIDEO_B <= W_VGA_B(5 downto 2);
-------------------------------------------------------------------------
	-- VGA scan doubler
--	vga_scandbl : entity work.VGA_SCANDBL
--	port map(
		-- input
--		CLK     => W_CLK_6M,
--		CLK_X2  => W_CLK_12M,
--		I_R     => W_R,
--		I_G     => W_G,
--		I_B     => W_B,
--		I_HSYNC => not W_H_SYNC,
--		I_VSYNC => W_V_SYNC,
		-- output
--		O_R     => W_VGA_R,
--		O_G     => W_VGA_G,
--		O_B     => W_VGA_B,
--		O_HSYNC => hsync,
--		O_VSYNC => vsync,
 --     scanlines    =>  '0'		
--	);

--	O_VIDEO_R(3 downto 0) <= W_VGA_R(0) & W_VGA_R(1) & W_VGA_R(2) & "0";
--	O_VIDEO_G(3 downto 0) <= W_VGA_G(0) & W_VGA_G(1) & W_VGA_G(2) & "0";
--	O_VIDEO_B(3 downto 0) <= W_VGA_B(0) & W_VGA_B(1) & "00";
	
--	O_HSYNC <= hsync;
--	O_VSYNC <= vsync;
------------------------------------------------------------------------
--	wav_dac_a : entity work.dac
--	port map(
--		clk_i   => W_CLK_18M,
--		res_n_i => W_RESETn,
--		dac_i   => O_AUDIO,
--		dac_o   => W_DAC
--	);
-------- VIDEO  -----------------------------
--  dbl_scan <=  '1'; -- 1 = VGAS  0 = RGB

	blx_comb <= W_C_BLX or (not W_V_BL2n);

  p_comp_sync : process(W_H_SYNC, W_V_SYNC)
   begin
    comp_sync_l <= (not W_V_SYNC) and (not W_H_SYNC);
   end process;
-----  CPU I/F  -------------------------------------

	W_CPU_RESETn  <= W_RESETn;
	W_CPU_CLK     <= W_H_CNT(0);
	W_CPU_RAM_CLK <= W_CLK_12M and (not W_CPU_RAM_CSn);

	W_CPU_ROM_DOB <= x"00" when W_CPU_ROM_CSn = '1' else W_CPU_ROM_DO ;

	W_CLK_12M <= WB_CLK_12M;
	W_CLK_6M  <= WB_CLK_6M;
--	W_RESETn  <= I_SW(8) or I_SW(7) or I_SW(6)     or I_SW(5);
--	W_RESETn  <= '1';
	W_RESETn  <= not I_RESET;
	W_BDO     <= W_SW_DO  or W_VID_DO or W_CPU_RAM_DO or W_CPU_ROM_DOB ;


---------- SOUND I/F -----------------------------
--	O_AUDIO_L <= W_DAC;
--	O_AUDIO_R <= W_DAC;
-------------------------------------------------------------------------------

	PSG_EN <= '1' when W_A(15 downto 11) = "01001" and W_A(9) = '0' and W_CPU_MREQn = '0' and W_CPU_WRn = '0' else '0';
	
	process(W_CPU_CLK)
	begin
		if rising_edge(W_CPU_CLK) then
			if PSG_EN = '1' and W_A(8) = '1' then
				PSG_D <= W_A(7 downto 0);
			end if;
		end if;
	end process;

	--O_AUDIO <= ("00" & PSG_A) + ("00" & PSG_B) + ("00" & PSG_C);
	-- O_AUDIO <= PSG_A + PSG_B + PSG_C;
	
	--psg : entity ym2149
	--port map
	--(
	--	CLK       => W_CPU_CLK,
	--	CE        => '1',
	--	RESET     => not W_RESETn,

	--	BDIR      => PSG_EN and W_A(0) and not W_A(8),
	--	BC        => W_A(1),
	--	DI        => PSG_D,

	--	CHANNEL_A => PSG_A,
	--	CHANNEL_B => PSG_B,
	--	CHANNEL_C => PSG_C
	--);
----------------------------------------------------------------------
ym2149 : entity work.ym2149
port map (
-- data bus
	I_DA            => PSG_D,
	O_DA            => open,
	O_DA_OE_L       => open, 
-- control
	I_A9_L          => '0',
	I_A8            => '1',
	I_BDIR          => PSG_EN and W_A(0) and not W_A(8),
	I_BC            => W_A(1),
	I_SEL_L         => '1', 
-- audio
	O_AUDIO         => O_AUDIO,
-- port a
	I_IOA           => "11111111",
	O_IOA           => open,
	O_IOA_OE_L      => open,
-- port b
	I_IOB           => "11111111",
	O_IOB           => open,
	O_IOB_OE_L      => open,

	ENA             => '1',     
	RESET_L         => W_RESETn,--'1',
	CLK             => W_CPU_CLK
);
-------------------------------------------------------------------------------
end RTL;