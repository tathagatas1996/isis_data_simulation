%testing erosita data quality
require("isisscripts");

variable i,N = 20; 
variable ph_idx = Double_Type[N], err_idx = Double_Type[N,2];
variable eneflux = Double_Type[N], err_eneflux = Double_Type[N,2];
variable red_chi2 = Double_Type[N];
variable info3;

for(i=0;i<N;i++)
{
delete_data(all_data);
variable file_arf_a = "arf01_100nmAl_200nmPI_sdtq.fits"; 
variable file_arf_b = "arf01_200nmAl_200nmPI_sdtq.fits";
variable file_rmf = "rmf01_sdtq.fits";

%exposure in seconds
variable ex_a = 2.0*400.0;
variable ex_b = 5.0*400.0;

%load parameters based on which the data will be generated
load_par("BL12_3m.par");

variable rmf = load_rmf(file_rmf);
variable arf_a = load_arf(file_arf_a);
variable arf_b = load_arf(file_arf_b);

variable seta = 1;
variable setb = 2;

Remove_Spectrum_Gaps = 1;

assign_rmf(rmf,seta);
assign_rmf(rmf,setb);

assign_arf(arf_a,seta);
assign_arf(arf_b,setb);

set_arf_exposure (arf_a,ex_a);
set_arf_exposure (arf_b,ex_b);
set_data_exposure (seta,ex_a);
set_data_exposure (setb,ex_b);

fakeit();
set_fake(seta,0);
set_fake(setb,0);

fits_write_pha_file("a_BL12_3m.fak", seta);
fits_write_pha_file("b_BL12_3m.fak", setb);

group([seta,setb]; bounds=[0.2,12], unit="keV", min_sn=6, min_chan=7);
xnotice_en([seta,setb],0.21,7.);

%plot_counts({seta,setb};dsym=[4,17],dcol=[11,12]);

fit_counts;
list_par;

%the error calculation for the count rate;

()=fit_counts(&info3);
red_chi2[i] = (info3.statistic) / (info3.num_bins - info3.num_variable_params );


% I want to save the plots that is giving a bad value of red_chi^2 to analyse it for later. you might not want this.
if(red_chi2[i] <= 0.8 || red_chi2[i] >= 1.2)
{	 
	variable id1;
	variable id2;
	variable j = String_Type(char(i));
	variable image_name1 = strcat("plot_data",string(i),".ps/CPS");
	variable image_name2 = strcat("plot_cnts",string(i),".ps/CPS");

	id1 = open_plot(image_name1);
	xlog;
        ylog;
	plot_data({seta,setb};res=2,dsym=[4,17],dcol=[4,5]);
	close_plot(id1);

	id2 = open_plot(image_name2);
	xlog;
        ylog;
	plot_counts({seta,setb};res=2,dsym=[4,17],dcol=[4,5]);
	close_plot(id2);
};


ph_idx[i] = get_par(3);
%to calculate the error bounds:
(err_idx[i,0],err_idx[i,1]) = conf(3); 

eneflux[i] = get_par(4);
(err_eneflux[i,0],err_eneflux[i,1]) = conf(4);

%xlog;
%ylog;
%plot_data({seta,setb};res=2;dsym=[4,17],dcol=[4,5]);
};




%print( ph_idx, "filea" );
%print( err_idx, "fileb" );

%print( eneflux ,"filec" );
%print( err_eneflux, "filed" );

print( red_chi2 , "reduced_chi2" );

%!paste filea fileb > photon_index ---> this is a command to be run outside this script, so it is commented.
%!paste filec filed > eneflux --------->  ""                ""                   ""                   ""


