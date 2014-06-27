%bandpass_filter (input_4D_epi_nii_file, low_freq, high_freq,  TR, output_4D_epi_nii_file, show_amplitude_frequency_response)
% made by Dr. Zhishun Wang on June 25-27
% input_4D_epi_nii_file:  an input 4D nii EPI image file name to be band-pass filtered
% low_freq, high_freq:  low and high cutoff frequencies, typicall 0.008 to 0.1Hz for resting-state EPI 
% TR: seconds
% output_4D_epi_nii_file: optional, if not given, the program will use the input file name adding a prefix "f"
% show_amplitude_frequency_response: 1 or 0,  optional, if not given, set to 0, if setting  to 1, the program will display amplitude -frequency response graphics to show how the filter looks like     
% example:
% bandpass_filter ('myEPI_4D.nii', 0.008, 0.1,  2, [], 1);

function bandpass_filter (input_4D_epi_nii_file, low_freq, high_freq,  TR, output_4D_epi_nii_file, show_amplitude_frequency_response)

if nargin<5
    output_4D_epi_nii_file=[];
    show_amplitude_frequency_response=0;
end
if nargin<6
    show_amplitude_frequency_response=0;
end
LP_Freq = low_freq;
HP_Freq = high_freq;

 [Bf,Af] = butter(8, [2*LP_Freq*TR 2*HP_Freq*TR], 'bandpass'); 
 
 if show_amplitude_frequency_response
    [H,F] = freqz(Bf,Af,1024,1/TR);
    figure
    plot(F,abs(H));
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
 end
 
 %% perform forward and backward filtering with 0 phase distortion 
%  filtfilt(Bhf,Ahf,Ktmp);
  
  nii=load_nii(input_4D_epi_nii_file);
  if isempty(output_4D_epi_nii_file)
      [pathStr,fname,ext] = fileparts(input_4D_epi_nii_file);
      if ~isempty(pathStr)
          output_nii_file = [pathStr filesep 'f' fname ext];
      else
          output_nii_file = ['f' fname ext];
      end
  else
      output_nii_file = output_4D_epi_nii_file;
  end
  
  [x,y,z,t]=size(nii.img);
  I0 = reshape(nii.img,x*y*z,t);
  I = double(I0');
  fJ =  filtfilt(Bf,Af,I);
  J = reshape(fJ', x,y,z,t);
  
  fnii=nii;
  class_str = class(nii.img);
  com_str = ['fnii.img=' class_str '(J)'];
  eval(com_str);
  [pathStr1,fname1,ext1] = fileparts(output_nii_file);
  fnii.fileprefix = fname1;
  save_nii(fnii, output_nii_file);
  
  
 
 