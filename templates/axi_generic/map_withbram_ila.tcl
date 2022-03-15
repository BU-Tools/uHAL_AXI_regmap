set name map_withbram_ila

set output_path ${apollo_root_path}/configs/${build_name}/cores/

file mkdir ${output_path}

####if { [file exists ${output_path}/${name}/${name}.xci] && ([file mtime ${output_path}/${name}/${name}.xci] > [file mtime ${output_path}/${name}.tcl])} {
####    set filename "${output_path}/${name}/${name}.xci"
####    set ip_name [file rootname [file tail $filename]]
####    #normal xci file
####    read_ip $filename
####    set isLocked [get_property IS_LOCKED [get_ips $ip_name]]
####    puts "IP $ip_name : locked = $isLocked"
####    set upgrade  [get_property UPGRADE_VERSIONS [get_ips $ip_name]]
####    if {$isLocked && $upgrade != ""} {
####	puts "Upgrading IP"
####	upgrade_ip [get_ips $ip_name]
####    }    
####} else {
    file delete -force ${apollo_root_path}/configs/${build_name}/cores/${name}

    #create IP
    create_ip -vlnv [get_ipdefs -filter {NAME == ila}] -module_name ${name} -dir ${output_path}

    # type is 0: data & trigger, 1 data only, 2 trigger only
    set_property -dict [list \
			    CONFIG.C_NUM_OF_PROBES {6} \
			    CONFIG.C_PROBE5_TYPE {1} \
			    CONFIG.C_PROBE4_TYPE {1} \
			    CONFIG.C_PROBE3_TYPE {1} \
			    CONFIG.C_PROBE2_TYPE {1} \
			    CONFIG.C_PROBE1_TYPE {1} \
			    CONFIG.C_PROBE0_TYPE {0} \
			    CONFIG.C_PROBE5_WIDTH {32} \
			    CONFIG.C_PROBE4_WIDTH {32} \
			    CONFIG.C_PROBE3_WIDTH {32} \
			    CONFIG.C_PROBE2_WIDTH {32} \
			    CONFIG.C_PROBE1_WIDTH {32} \
			    CONFIG.C_PROBE0_WIDTH {3} \
			    CONFIG.C_EN_STRG_QUAL {1} \
			    CONFIG.C_ADV_TRIGGER {true} \
			    CONFIG.C_PROBE5_MU_CNT {2} \
			    CONFIG.C_PROBE4_MU_CNT {2} \
			    CONFIG.C_PROBE3_MU_CNT {2} \
			    CONFIG.C_PROBE2_MU_CNT {2} \
			    CONFIG.C_PROBE1_MU_CNT {2} \
			    CONFIG.C_PROBE0_MU_CNT {2} \
			    CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
			    CONFIG.C_ENABLE_ILA_AXI_MON {false} \
			    CONFIG.C_MONITOR_TYPE {Native} \
			   ] [get_ips ${name} ]
####}


