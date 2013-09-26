/***************************************************************************
 *	Torrents searcher for the command line												*
 *	Copyright (C) 2013 by Pablo Castro and Marcos Chavarria 						*
 * <pablo.castro1@udc.es>, <marcos.chavarria@udc.es> 								*
 * 																								*
 * This program is free software; you can redistribute it and/or modify 	*
 * it under the terms of the GNU General Public License as published by 	*
 * the Free Software Foundation; either version 2 of the License, or 		*
 * (at your option) any later version. 												*
 ***************************************************************************/

/*-------------------Libreria LISTAS----------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>


/*
Estructura con la lista de los links resultado
*/
typedef struct enlace * t_lista_links;
struct enlace{
	char* tracker_name;
	char* name;
	char* link;
	int seeds;
	int leechers;
	t_lista_links next;
};


/*
Estructura con la lista de sitios web donde se buscarán los torrents
*/
typedef struct sitio * t_lista_sitios;
struct sitio{
	char* name;
	char* format;
	void (*init_func)(FILE*);
	struct sitio * next;
};

t_lista_sitios sitios;
t_lista_links lista;
int start_crazy = 0;
int start_pirate = 0;
int start_reactor = 0;
int start_vertor = 0;
int start_bit = 0;

//Funciones a las que se llama para iniciar la start condition correspondiente.
void begin_tpb		(FILE * file);
void begin_treactor	(FILE * file);
void begin_tcrazy	(FILE * file);
void begin_vertor (FILE * file);
void begin_bit (FILE * file);

void yyerror (const char *s);


/*
Función que inserta un nuevo elemento en la lista de links
*/
void insertar_elemento_lista(char * name,char * link,int seeds,int leechers){
	
	struct enlace * element = malloc(sizeof(struct enlace));
	
	element->name = name;
	element->link = link;
	
	element->seeds = seeds;
	element->leechers = leechers;
	element->next = NULL;
	
	if(lista==NULL){
		lista = element;
	}else{
		
		t_lista_links l;
		for(l=lista;l->next != NULL;l=l->next);
		l->next = element;
	}
	
}
	
	
	
	

	
	
	
	
	
	
