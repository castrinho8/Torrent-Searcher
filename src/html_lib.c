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

/*-------------------Libreria HTML--------------------------*/

#include <stdio.h>
#include <string.h>
#include "lists_lib.c"

#define OUTPUT_FILE "./salida.html"
	
FILE * htmlfile;

/*
Inicializa el fichero HTML de salida
*/
void
inicializar_html()
{
	htmlfile = fopen(OUTPUT_FILE, "w+");
	fprintf (htmlfile,"%s", "<html><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><head><title>Tracker</title></head><body><p align=\"center\" style=\" font-size:25px;\"><b>Buscador de Torrents</b></p><div align=\"right\"><b>Autores</b><p>Marcos Chavarría Teijeiro (marcos.chavarria@udc.es)</p><p>Pablo Castro Valiño (pablo.castro1@udc.es)</p></div><table width=\"100%\" border=\"0.5\" rules=\"rows\">");  
}


/*
Añade una barra que indica la búsqueda que se ha realizado
*/
void
anhade_cadena(char * cadena)
{
	char * temp = malloc(sizeof(char)*(strlen(cadena)+strlen("<p style=\" font-size:25px;\"><u>Resultados de busqueda para:</u><strong> \"\"</strong></p>")+1));
	strcpy(temp,"<p style=\" font-size:25px;\"><u>Resultados de busqueda para:</u><strong> \"");
	strcat(temp,cadena);
	strcat(temp,"\"</strong></p>");
	fprintf(htmlfile,"%s",temp);
}


/*
Inserta el nombre de un nuevo tracker
*/
void 
insertar_nombre_tracker(char * tracker_name)
{ 	
	fprintf(htmlfile,"%s","<tr><u><td><p align=\"left\" style=\"margin-top: 2em;\"><b>");
	fprintf(htmlfile,"%s",tracker_name);
	fprintf(htmlfile,"%s","</b></u></p></td></tr>");
	fprintf(htmlfile,"%s","<tr><td width=\"60%\" height =\"50\">NOMBRE/LINK</td><td width=\"20%\">SEEDS</td><td width=\"20%\">LEECHERS<br/></td></tr>");  
}


/*
Añade un elemento resultado de la búsqueda al fichero HTML
*/
void
insertar_elemento(int number,struct enlace * elemento)
{
	fprintf (htmlfile,"%s","<td width=\"60%\" height =\"50\"><a href=");  
	fprintf (htmlfile,"%s",elemento->link);
	fprintf (htmlfile,"%s",">");  
	fprintf (htmlfile,"%s",elemento->name);  
	fprintf (htmlfile,"%s","</a></td><td width=\"20%\"><b>");  
	fprintf (htmlfile,"%i",elemento->seeds);
	fprintf (htmlfile,"%s","</b></td><td width=\"20%\"><b>");
	fprintf (htmlfile,"%i",elemento->leechers);
	fprintf (htmlfile,"%s","</b><br/></td><td>");
	fprintf (htmlfile,"%i",number);
	fprintf (htmlfile,"%s","</td></tr>");
}


/*
Inserta un tag comienzo de linea
*/
void
insertar_comienzo_linea()
{
	fprintf (htmlfile,"%s","<tr>");  
}


/*
Inserta un tag fin de linea
*/
void
insertar_fin_linea()
{
	fprintf (htmlfile,"%s","</tr>");  
}


/*
Inserta los tags correspondientes al fin del fichero HTML
*/
void
termina_html()
{	
	fprintf (htmlfile,"%s","</table></body></html>");  
	fclose(htmlfile);
}
