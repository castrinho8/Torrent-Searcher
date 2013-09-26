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

%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include <assert.h>
	#include "html_lib.c"

	#define FICH_DESCARGA "file.html"
	#define FICH_LOG "torrents.log"
	#define MAX_CADENA 100 //Tamaño maximo de la cadena de entrada
	
%}
%error-verbose

%union{
	int 					valInt;
	char* 				valString;
	struct enlace *	listaEnlace;
}

%token <valString> 	NAME
%token <valString> 	LINK
%token <valInt> 		NUM_SEEDS
%token <valInt> 		NUM_LEECHERS
%token <valInt>		END
%token <valInt>		NO_SEEDS_LEECHERS
%start START

%%

START : 					lista_name										
						|	lista_link										
						| 	error												{YYABORT;}
						|	END												{YYACCEPT;} //Se utliliza para detectar cuando no hay resultados.



lista_name :			lista_name elemento_name					
						|	elemento_name									

//Elementos que comienzan con el nombre.
elemento_name : 		NAME LINK NUM_SEEDS NUM_LEECHERS 		{
																					char * stmp = strdup($1);
																					insertar_elemento_lista(stmp,$2,$3,$4);
																				}

						|	NAME LINK NUM_SEEDS NUM_LEECHERS END	{
																					char * stmp = strdup($1);
																					insertar_elemento_lista(stmp,$2,$3,$4);
																					YYACCEPT;
																				}


lista_link : 			lista_link elemento_link
						|	elemento_link

//Elementos que comienzan por el link
elemento_link:			LINK NAME NUM_SEEDS NUM_LEECHERS						{
																									char * stmp = strdup($2);
																									insertar_elemento_lista(stmp,$1,$3,$4);
																								}

						|	LINK NAME NUM_SEEDS NUM_LEECHERS END					{
																									char * stmp = strdup($2);
																									insertar_elemento_lista(stmp,$1,$3,$4);
																									YYACCEPT;
																								}
//Utilizada en bitsnoop para cuando leechers=0 y seeders=0
						|	LINK NAME NO_SEEDS_LEECHERS								{
																									char * stmp = strdup($2);
																									insertar_elemento_lista(stmp,$1,0,0);
																								}

						|	LINK NAME NO_SEEDS_LEECHERS END								{
																									char * stmp = strdup($2);
																									insertar_elemento_lista(stmp,$1,0,0);
																									YYACCEPT;
																								}

%%

void 
yyerror (const char *s)
{
		fprintf (stderr, "%s\n", s);
}

/*
Función que parsea los argumentos indicados por linea de comandos
*/
void 
parsea_argumentos(int argc, char const * argv[]){

	int i=1;
	//Comprueba si no tiene parámetros, en ese caso cogemos todos los buscadores.
	if (argc==1){
		start_pirate = 1;
		start_reactor = 1;
		start_crazy = 1;
		start_vertor = 1;
		start_bit = 1;
	}else{
		while(i<argc){
			if(!strcmp(argv[i],"-r")){
				start_reactor = 1;
			}else if(!strcmp(argv[i],"-c")){
				start_crazy = 1;
			}else if(!strcmp(argv[i],"-p")){
				start_pirate = 1;
			}else if(!strcmp(argv[i],"-v")){
				start_vertor = 1;
			}else if(!strcmp(argv[i],"-b")){
				start_bit = 1;
			}else{
				printf("Argumento no reconocido\n");
				exit(0);
			}
			i++;
		}
	}
}

/*
Función que inicializa la lista de sitios web en donde se realizará la búsqueda
*/
void
init_sitios()
{
	t_lista_sitios sitio;
	sitios = NULL;
	
	if(start_reactor){
		/****************** Torrent Reactor ******************/
		sitio = malloc(sizeof(struct sitio));
		sitio->name = strdup("Torrent Reactor");
		sitio->format = strdup("http://www.torrentreactor.net/torrent-search/%s");
		sitio->init_func = begin_treactor;
		sitio->next = sitios;
		sitios = sitio;
	}

	if(start_vertor){
		/****************** Vertor *******************/
		sitio = malloc(sizeof(struct sitio));
		sitio->name = strdup("Vertor");
		sitio->format = strdup(	"http://www.vertor.com/index.php\\?mod\\=search\\&search\\=\\&words\\=%s\\&cid\\=0"
								"\\&type\\=1\\&exclude\\=\\&hash\\=\\&new\\=0\\&orderby\\=a.seeds\\&asc\\=0");
		sitio->init_func = begin_vertor;
		sitio->next = sitios;	
		sitios = sitio;
	}
	
	if(start_bit){
		/****************** Bitsnoop *******************/
		sitio = malloc(sizeof(struct sitio));
		sitio->name = strdup("Bitsnoop");
		sitio->format = strdup("http://bitsnoop.com/search/all/%s/c/d/1/");
		sitio->init_func = begin_bit;
		sitio->next = sitios;
		sitios = sitio;
	}
	
	if(start_crazy){
		/****************** Torrent Crazy *******************/
		sitio = malloc(sizeof(struct sitio));
		sitio->name = strdup("Torrent Crazy");
		sitio->format = strdup("http://torrentcrazy.com/s/%s");
		sitio->init_func = begin_tcrazy;
		sitio->next = sitios;
		sitios = sitio;
	}
	
	if(start_pirate){
		/****************** The Pirate Bay *******************/
		sitio = malloc(sizeof(struct sitio));
		sitio->name = strdup("The Pirate Bay");
		sitio->format = strdup("http://thepiratebay.is/search/%s/0/7/0");
		sitio->init_func = begin_tpb;
		sitio->next = sitios;
		sitios = sitio;
	}
}

/*
Función que descarga el fichero HTML de la URL indicada
*/
void
descargar_archivo (	char* format,
					char* cadena)
{
	char url[2048];
	char cmd[2148];

	assert(strlen(format) + strlen(cadena) < 2048);
	sprintf(url,format,cadena);
	sprintf(cmd,"wget -O "
			 FICH_DESCARGA
			 " %s -o torrents.log "
			 "--timeout=10 -t 1",url);
	system(cmd);

}

/*
Elimina el fichero descargado
*/
void
eliminar_archivo ()
{
	system("rm -f " FICH_DESCARGA);
}

/*
Abre firefox y muestra el fichero HTML generado
*/
void
muestra_html ()
{
	system("firefox " OUTPUT_FILE " & 2> /dev/null > /dev/null");
}


/*
Obtiene una cadena de búsqueda
*/
char *
obtener_cadena()
{
	//Pide la cadena por pantalla
	char * cadena = malloc(sizeof(char)*MAX_CADENA);
	printf("Indroduzca la búsqueda que desee realizar\n");
	fgets(cadena,MAX_CADENA,stdin);

	//Eliminamos el espacio que fgets introduce al final
	char * cadena_res = strndup(cadena,sizeof(char)*(strlen(cadena)-1));

	//Añade al HTML la cadena que se ha buscado.
	anhade_cadena(cadena_res);
	
	//En caso de que haya espacios en blanco, los cambia por '+'
	int c=0;
	int espaces=0;
	for(c=0;c <= strlen(cadena_res);c++){
		if(isspace(cadena_res[c])){
			espaces++;
			cadena_res[c] ='+';
		}
	}

	return cadena_res;
}


int
main(int argc, char const *argv[])
{
	//Comprueba los argumentos
	parsea_argumentos(argc, argv);

	int i = 1,j,k=0;
	t_lista_links l;
	lista = NULL;
	t_lista_sitios sit;
	FILE * fil;

	//Inicializa el fichero html de salida
	inicializar_html();
	
	//Obtiene la cadena a buscar correctamente formateada
	char * cadena = obtener_cadena();
	
	//Inicializa los sitios para los argumentos introducidos
	init_sitios(argc,argv);

	struct enlace * last = malloc(sizeof(struct enlace));

	for(sit = sitios; sit; sit = sit->next)
	{	
		//Descarga y parsea los diferentes sitios
		lista = NULL;
		printf("DESCARGANDO:%s\n",sit->name);
		descargar_archivo(sit->format,cadena);
		fil = fopen(FICH_DESCARGA, "r");
		sit->init_func(fil);	
		yyparse();
		fclose(fil);
		eliminar_archivo();
		
		//Asigna a cada elemento el nombre de su tracker correspondiente
		j=0;
		for(l=lista; l; l = l->next) {
			j++;
			l->tracker_name = sit->name;
		}

		//Escribe el fichero HTML
		k=1;
		insertar_nombre_tracker(sit->name);
		insertar_comienzo_linea();
		
		for(l=lista; l != NULL; l = l->next){
			insertar_comienzo_linea();
			insertar_elemento(k,l);
			insertar_fin_linea();
			last = l;
			k++;
		}
	}
	termina_html();
	
	muestra_html();
}






