Throughput mapping
++++++++++++++++++

+ snr-peak-rate
http://www.etsi.org/deliver/etsi_tr/136900_136999/136942/08.01.00_60/tr_136942v080100p.pdf

+ SNR_to_throughput_mapping_lte_sim
output of Vienna LTE simulator for different spatial multiplexing

+ SNR_to_throughput_mod_mapping_siso
extract from output of Vienna LTE simulator (SISO)

+ SNR_to_throughput_mod_mimo_mapping_ERROR
Strange multiplication for high throughput based on SISO

+ SNR_to_throughput_mod_mimo_44_mapping
extract from output of Vienna LTE simulator (MIMO44)

+ SNR_to_throughput_mod_mimo_88_mapping
Starting from SISO we multiply the peak rate x8 only for SINR values larger then 24 dB
(this is a conservative value for multiplying the peak rate, in fact mimo88 starts to provide more throughout at lower SINR, typically 15 dB)
 
+ SNR_to_throughput_mod_mimo_1616_mapping
Starting from MIMO44 we multiply the peak rate x4 for all values