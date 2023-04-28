

 
set_attribute hdl_search_path {/DIG_DESIGN/INTERNS/dic_lab_03/piyush/merge/} 
set_attribute lib_search_path {/DIG_DESIGN/INTERNS/PDK_DIC/}



set_attribute library {slow_vdd1v0_basicCells.lib}


 

set myFiles [list rotating_and_vectoring.v]
set_attribute information_level 7




set basename ROTATING_VECTORING;
set myClk clk;

set myPeriod_ps 1000;
set myInDelay_ns 0.5;
set myOutDelay_ns 0.5;
set runname report;




read_hdl ${myFiles}
elaborate ${basename}

set_top_module  ${basename}



set clock [define_clock -period ${myPeriod_ps} -name ${myClk} [clock_ports]]	
external_delay -input $myInDelay_ns -clock ${myClk} [find / -port ports_in/*]
external_delay -output $myOutDelay_ns -clock ${myClk} [find / -port ports_out/*]


check_design -unresolved
report timing -lint

synthesize -to_mapped -effort medium


report timing > genus_reports/${basename}_${runname}_timing.rep
report gates  > genus_reports/${basename}_${runname}_cell.rep
report power  > genus_reports/${basename}_${runname}_power.rep


write_hdl -mapped >  netlist/${basename}_${runname}.v
write_sdc >  sdc/${basename}_${runname}.sdc


gui_raise
