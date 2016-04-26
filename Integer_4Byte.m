function DECIMAL = Integer_4Byte(Data)

if Data(1) < 128
    DECIMAL = Data(1)*256^3+Data(2)*256^2+Data(3)*256+Data(4);
else
    DECIMAL = -((255-Data(1))*256^3+(255-Data(2))*256^2+(255-Data(3))*256+(255-Data(4)));
    DECIMAL = DECIMAL - 1;
end
