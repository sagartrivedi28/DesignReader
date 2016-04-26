function HEADER = HEADER_TYPE(Data)

switch Data
    case 0
        HEADER = 'HEADER';
    case 1
        HEADER = 'BGNLIB';
    case 2
        HEADER = 'LIBNAME';
    case 3
        HEADER = 'UNITS';
    case 4
        HEADER = 'ENDLIB';
    case 5
        HEADER = 'BGNSTR';
    case 6
        HEADER = 'STRNAME';
    case 7
        HEADER = 'ENDSTR';
    case 8
        HEADER = 'BOUNDARY';
    case 9
        HEADER = 'PATH';
    case 10
        HEADER = 'SREF';
    case 11
        HEADER = 'AREF';
    case 12
        HEADER = 'TEXT';
    case 13
        HEADER = 'LAYER';
    case 14
        HEADER = 'DATATYPE';
    case 15
        HEADER = 'WIDTH';
    case 16
        HEADER = 'XY';
    case 17
        HEADER = 'ENDEL';    
    case 18
        HEADER = 'SNAME';
    case 19
        HEADER = 'COLROW';
        
    case 21
        HEADER = 'NODE';
    case 22
        HEADER = 'TEXTTYPE';
    case 23
        HEADER = 'PRESENTATION';
        
    case 25
        HEADER = 'ASCII STRING';
    case 26
        HEADER = 'STRANS';
    case 27
        HEADER = 'MAG';
    case 28
        HEADER = 'ANGLE';
        
    case 31
        HEADER = 'PEFLIBS';
    case 32
        HEADER = 'FONTS';
    case 33
        HEADER = 'PATHTYPE';
    case 34
        HEADER = 'GENERATIONS';
    case 35
        HEADER = 'ATTRTABLE';
        
    case 38
        HEADER = 'ELFLAGS';
        
    case 42
        HEADER = 'NODETYPE';
        
    case 45
        HEADER = 'BOX';
    case 46
        HEADER = 'BOXTYPE';
    case 47
        HEADER = 'PLEX';
        
    case 54
        HEADER = 'FORMAT';
    case 55
        HEADER = 'MASK';
    case 56
        HEADER = 'ENDMASKS';
        
    otherwise
        HEADER = [num2str(Data) ' UNKOWN'];     
        
end
