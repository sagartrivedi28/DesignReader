function DECIMAL = Float_8Byte(Data)

if Data(1) < 128
    exponent= Data(1)-64;   
    significant = 0;
    for i = 2:8
        significant = significant*256+Data(i);
    end
    significant = significant/2^56;
    
    DECIMAL = 16^(exponent)*significant;
else
    exponent= Data(1)-192;   
    significant = 0;
    for i = 2:8
        significant = significant*256+Data(i);
    end
    significant = significant/2^56;
    
    DECIMAL = -16^(exponent)*significant;    
end
   
