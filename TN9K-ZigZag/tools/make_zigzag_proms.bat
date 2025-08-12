copy /b/y zz_d1.7l + zz_d2.7k + zz_d4.7f + zz_d3.7h main.bin

make_vhdl_prom main.bin rom0.vhd
make_vhdl_prom zz_6.1h galaxian_1h.vhd
make_vhdl_prom zz_5.1k galaxian_1k.vhd
make_vhdl_prom zzbpr_e9.bin galaxian_6l.vhd

pause