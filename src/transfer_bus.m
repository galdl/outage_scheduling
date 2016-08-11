function ordinal_bus_num = transfer_bus(bus_num)

area = floor(bus_num/100);
ordinal_bus_num = (area-1)*24 + mod(bus_num,100);