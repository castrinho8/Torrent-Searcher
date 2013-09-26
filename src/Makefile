#/***************************************************************************
# *	Torrents searcher for the command line											*
# *	Copyright (C) 2013 by Pablo Castro and Marcos Chavarria 					*
# * <pablo.castro1@udc.es>, <marcos.chavarria@udc.es> 							*
# * 																								*
# * This program is free software; you can redistribute it and/or modify 	*
# * it under the terms of the GNU General Public License as published by 	*
# * the Free Software Foundation; either version 2 of the License, or 		*
# * (at your option) any later version. 												*
# ***************************************************************************/

FUENTE = torrents

default:
	@echo " "
	@echo " ------------------------------------------------------------ "
	@echo "Usage:"
	@echo "	compile:	Compila la práctica"
	@echo "	run:		Ejecuta la práctica realizando la búsqueda en todos los trackers."
	@echo "	clean:		Borrar ficheros ejecutables y temporales"
	@echo " ------------------------------------------------------------ "
	@echo "	Ejecución normal: ./torrents [opciones]"
	@echo "	Opciones de ejecucion:"
	@echo "	-p : Buscar en The Pirate Bay"
	@echo "	-r : Buscar en Torrent Reactor"
	@echo "	-c : Buscar en Torrent Crazy"
	@echo "	-v : Buscar en Vertor"
	@echo "	-b : Buscar en Bitsnoop"


all: compile

# Compila el proyecto
compile: html_lib.o
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd
	gcc -o $(FUENTE) lex.yy.c $(FUENTE).tab.c -lfl -ly

# Ejecuta el programa
run: 
	./$(FUENTE)

# Compila en modo debug
debug:
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd 
	gcc -o $(FUENTE) lex.yy.c $(FUENTE).tab.c -lfl -ly -g -DDEBUG=1

# Compila la librería de HTML
html_lib.o: lists_lib.o
	gcc -c html_lib.c

# Compila la librería de listas
lists_lib.o:
	gcc -c lists_lib.c

# Elimina ficheros generados y ejecutables
clean:
	rm -rf $(FUENTE) lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h torrents.log file.html salida.html html_lib.o lists_lib.o


