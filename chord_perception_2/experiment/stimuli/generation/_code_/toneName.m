function [out]=toneName(name)
%Takes note name as input and outputs the corresponding frequency in Hz

if strcmp(name,'A0')
    out=27.5000;
elseif strcmp(name,'As0')
    out=29.1352;
elseif strcmp(name,'B0')
    out=30.8677;
elseif strcmp(name,'C1')
    out=32.7032;
elseif strcmp(name,'Cs1')
    out=34.6478;
elseif strcmp(name,'D1')
    out=36.7081;
elseif strcmp(name,'Ds1')
    out=38.8909;
elseif strcmp(name,'E1')
    out=41.2034; 
elseif strcmp(name,'F1')
    out=43.6535; 
elseif strcmp(name,'Fs1')
    out=46.2493;   
elseif strcmp(name,'G1')
    out=48.9994;      
elseif strcmp(name,'Gs1')
    out=51.9131;     
elseif strcmp(name,'A1')
    out=55; 
elseif strcmp(name,'As1')
    out=58.2705;     
elseif strcmp(name,'B1')
    out=61.7354;      
elseif strcmp(name,'C2')
    out=65.4064;
elseif strcmp(name,'Cs2')
    out=69.2957;
elseif strcmp(name,'D2')
    out=73.4162;
elseif strcmp(name,'Ds2')
    out=77.7817;
elseif strcmp(name,'E2')
    out=82.4069; 
elseif strcmp(name,'F2')
    out=87.3071; 
elseif strcmp(name,'Fs2')
    out=92.4986;   
elseif strcmp(name,'G2')
    out=97.9989;      
elseif strcmp(name,'Gs2')
    out=103.8260;     
elseif strcmp(name,'A2')
    out=110; 
elseif strcmp(name,'As2')
    out=116.5410;     
elseif strcmp(name,'B2')
    out=123.4710;          
elseif strcmp(name,'C3')
    out=130.8130;
elseif strcmp(name,'Cs3')
    out=138.5910;
elseif strcmp(name,'D3')
    out=146.8320;
elseif strcmp(name,'Ds3')
    out=155.5630;
elseif strcmp(name,'E3')
    out=164.8140; 
elseif strcmp(name,'F3')
    out=174.6140; 
elseif strcmp(name,'Fs3')
    out=184.9970;   
elseif strcmp(name,'G3')
    out=195.9980;      
elseif strcmp(name,'Gs3')
    out=207.6520;     
elseif strcmp(name,'A3')
    out=220; 
elseif strcmp(name,'As3')
    out=233.0820;     
elseif strcmp(name,'B3')
    out=246.9420;        
elseif strcmp(name,'C4')
    out=261.6260;
elseif strcmp(name,'Cs4')
    out=277.1830;
elseif strcmp(name,'D4')
    out=293.6650;
elseif strcmp(name,'Ds4')
    out=311.1270;
elseif strcmp(name,'E4')
    out=329.6280; 
elseif strcmp(name,'F4')
    out=349.2280; 
elseif strcmp(name,'Fs4')
    out=369.9940;   
elseif strcmp(name,'G4')
    out=391.9950;      
elseif strcmp(name,'Gs4')
    out=415.3050;    
elseif strcmp(name,'A4')
    out=440; 
elseif strcmp(name,'As4')
    out=466.1640;     
elseif strcmp(name,'B4')
    out=493.8830;      
elseif strcmp(name,'C5')
    out=523.2510;
elseif strcmp(name,'Cs5')
    out=554.3650;
elseif strcmp(name,'D5')
    out=587.3300;
elseif strcmp(name,'Ds5')
    out=622.2540;
elseif strcmp(name,'E5')
    out=659.2550; 
elseif strcmp(name,'F5')
    out=698.4560; 
elseif strcmp(name,'Fs5')
    out=739.9890;   
elseif strcmp(name,'G5')
    out=783.9910;      
elseif strcmp(name,'Gs5')
    out=830.6090;     
elseif strcmp(name,'A5')
    out=880; 
elseif strcmp(name,'As5')
    out=932.3280;     
elseif strcmp(name,'B5')
    out=987.7670;      
elseif strcmp(name,'C6')
    out=1.0465e+03;
elseif strcmp(name,'Cs6')
    out=1.1087e+03;
elseif strcmp(name,'D6')
    out=1.1747e+03;
elseif strcmp(name,'Ds6')
    out=1.2445e+03;
elseif strcmp(name,'E6')
    out=1.3185e+03;
elseif strcmp(name,'F6')
    out=1.3969e+03; 
elseif strcmp(name,'Fs6')
    out=1.4800e+03;   
elseif strcmp(name,'G6')
    out=1.5680e+03;      
elseif strcmp(name,'Gs6')
    out=1.6612e+03;     
elseif strcmp(name,'A6')
    out=1760; 
elseif strcmp(name,'As6')
    out=1.8647e+03;     
elseif strcmp(name,'B6')
    out=1.9755e+03;            
elseif strcmp(name,'C7')
    out=2093;
elseif strcmp(name,'Cs7')
    out=2.2175e+03;
elseif strcmp(name,'D7')
    out=2.3493e+03;
elseif strcmp(name,'Ds7')
    out=2.4890e+03;
elseif strcmp(name,'E7')
    out=2.6370e+03; 
elseif strcmp(name,'F7')
    out=2.7938e+03; 
elseif strcmp(name,'Fs7')
    out=2.9600e+03;   
elseif strcmp(name,'G7')
    out=3.1360e+03;      
elseif strcmp(name,'Gs7')
    out=3.3224e+03;     
elseif strcmp(name,'A7')
    out=3520; 
elseif strcmp(name,'As7')
    out=3.7293e+03;     
elseif strcmp(name,'B7')
    out=3.9511e+03;    
else 
    out=4.1860e+03
end    
    
    
    
    
    
    
    
    
    
    
    
    
    
    