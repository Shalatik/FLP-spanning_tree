# Simona Ceskova xcesko00
# FLP projekt 2
# 27.04.2024
	
NAME = flp23-log 
NAMEPL = flp23-log.pl 

flp23-log : $(NAMEPL)
	swipl -q -g start -o $(NAME) -c $(NAMEPL)
	
clean:
	rm -f $(NAME)/*.o *.hi
