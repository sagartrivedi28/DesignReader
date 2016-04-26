function DECIMAL = Integer_2Byte(Data)

if Data(1) < 128
    DECIMAL = Data(1)*256+Data(2);
else
    DECIMAL = -((255-Data(1))*256+(255-Data(2)));
    DECIMAL = DECIMAL - 1;
end
