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
 #include <stdio.h>
 #include <string.h>
 #include "torrents.tab.h"

char * tpb_format_name (char * name);
int tpb_format_leechers (char * name);

char * treactor_format_name (char * name);
char * treactor_format_link (char* link, int len);
int treactor_format_seedsleechers (char * number);

char * tcrazy_format_link (char * link,int len);
char * tcrazy_format_name(char * name,int len);
int tcrazy_format_seedsleechers(char * number,int len);

char * ver_format_name (char * name,int leng);
char * ver_format_link (char * link,int leng);
int ver_format_seeds (char * seeds,int leng);
int ver_format_leechers (char * leechers, int leng);

char * bit_format_name (char * name,int leng);
char * bit_format_link (char * link,int leng);
int bit_format_seeds (char * seeds,int leng);
int bit_format_leechers (char * leechers, int leng);

%}

/*----------------------------------------------------------------------------------------
-------------------------------   Elementos Comunes   ------------------------------------
-----------------------------------------------------------------------------------------*/


ws [\n\t ]*
literal_string \"(\\.|[^\\"])*\"
everything_but_quote [^\"]+
everything_but_gt    [^>]+
everything_but_gt_min [^<>]+
anything .|"\n"
number [0-9]+
everything_but_tab [^"</a>"]+

/*---------------------------------------------------------------------------------------
---------------------------------   The Pirate Bay   -------------------------------------
-----------------------------------------------------------------------------------------*/
%X INI_TPB
%X HEAD_TPB
%X NAME_TPB
%X LINK_TPB
%X SEEDS_TPB
%X LEECHERS_TPB
%X END_TPB

tpb_start_words "<table id=\"searchResult\">"
tpb_end_words "</table>"
tpb_name_begin "<a href="{literal_string}{ws}"class=\"detLink\""{ws}"title="{literal_string}>
tpb_name_end "</a>"
tpb_link "magnet:?xt=urn:btih"{everything_but_quote}
tpb_seedleechers "<td align=\"right\">"{number}"</td>"

/*---------------------------------------------------------------------------------------
---------------------------------   Torrent Reactor   -------------------------------------
-----------------------------------------------------------------------------------------*/
%X INI_TRE
%X HEAD_NAME_TRE
%X BUTTON_VAR_TRE
%X NAME_TRE
%X LINK_TRE
%X SEEDS_TRE
%X LEECHERS_TRE
%X END_TRE

tre_start_words "<div class=\"table-listing\" id=\"torrent-list\">"
tre_end_words "</table>"

tre_name_begin "<td class=\"title\"><a"{everything_but_gt}">"
tre_name_end "</a>"

tre_buttons_begin "<div class=\"btn-group\">"
tre_link "<a class=\"btn btn-mini btn-success\" href="{literal_string}" rel=\"nofollow\" title=\"Download torrent\">"
tre_seed "<td class=\"seeders\">"{number}"</td>"
tre_leecher "<td class=\"leechers\">"{number}"</td>"


/*---------------------------------------------------------------------------------------
---------------------------------   Torrent Crazy   -------------------------------------
-----------------------------------------------------------------------------------------*/

%X INI_CRAZY
%X ELEMENT_CRAZY
%X LINK_CRAZY
%X NAMEDIV_CRAZY
%X NAME_CRAZY
%X SEEDS_CRAZY
%X LEECHERS_CRAZY
%X END_ELEMENT_CRAZY
%X END_CRAZY

crazy_start_words "<table class=\"torrents\">"
crazy_end_words "</table>"

crazy_element_begin "<td class=\"l\">"
crazy_element_end "</tr>"

crazy_link "<a href=\"magnet:"{everything_but_quote}"\">"

crazy_ok_ahref "<a href="{everything_but_gt}">"
crazy_name_end "</a>"

crazy_start_seed "<td class=\"seed\">"
crazy_start_leecher "<td class=\"leech\">"
crazy_end_seed_leecher {number}"</td>"


/*---------------------------------------------------------------------------------------
------------------------------------   VERTOR ------------------------------------------
-----------------------------------------------------------------------------------------*/
%X INI_VER
%X ELEMENT_VER
%X LINKDIV_VER
%X LINK_VER
%X NAME_VER
%X SEEDS_VER
%X LEECHERS_VER
%X END_VER

ver_start_words "<strong>Vertor search results</strong>"
ver_end_words "</table>"

ver_element_begin "<td class=\"first\" >"

ver_link_begin "<a title="{literal_string}
ver_link "href="{literal_string}">"
ver_name_end "</a>"

ver_seed "<td class=\"s\">"{number}"</td>"
ver_leecher "<td class=\"l\">"{number}"</td>"


/*---------------------------------------------------------------------------------------
------------------------------------   BITSNOOP ------------------------------------------
-----------------------------------------------------------------------------------------*/
%X INI_BIT
%X ELEMENT_BIT
%X LINK_BIT
%X NAME_BIT
%X SEEDS_BIT
%X LEECHERS_BIT
%X END_BIT


bit_start_words "<ol id=\"torrents\" start=\"1\">"
bit_end_words "</ol>"

bit_element_begin "<div id=\"sz\">"

bit_link_begin "<a href="{literal_string}">"
bit_name_end "</a>"

bit_seed_bad "<span class=\"health h0\""

bit_seeders "<span class=\"seeders\" title=\"Seeders\">"{everything_but_gt_min}"</span>"
bit_leechers "<span class=\"leechers\" title=\"Leechers\">"{everything_but_gt_min}"</span>"

%%

<INI_TPB>{tpb_start_words} 			  		{/*------- The Pirate Bay --------*/
														BEGIN(HEAD_TPB);}

<HEAD_TPB>{tpb_name_begin} 					{BEGIN(NAME_TPB);}
<HEAD_TPB>{tpb_end_words}						{BEGIN(END_TPB);}

<NAME_TPB>{tpb_name_end} 						{BEGIN(LINK_TPB);			yylval.valString = tpb_format_name(yytext);		return NAME;}
<NAME_TPB>{anything} 							{yymore();}

<LINK_TPB>{tpb_link} 							{BEGIN(SEEDS_TPB);		yylval.valString = strdup(yytext);					return LINK;}
<SEEDS_TPB>{tpb_seedleechers}					{BEGIN(LEECHERS_TPB);	yylval.valInt = tpb_format_leechers(yytext);	return NUM_SEEDS;}
<LEECHERS_TPB>{tpb_seedleechers} 			{BEGIN(HEAD_TPB);			yylval.valInt = tpb_format_leechers(yytext);	return NUM_LEECHERS;}




<INI_TRE>{tre_start_words}						{/*-------- Torrent Reactor --------*/
														BEGIN(HEAD_NAME_TRE);}

<HEAD_NAME_TRE>{tre_name_begin} 			{BEGIN(NAME_TRE);}
<HEAD_NAME_TRE>{tre_end_words}				{BEGIN(END_TRE);}

<NAME_TRE>{tre_name_end}						{BEGIN(BUTTON_VAR_TRE);		yylval.valString = treactor_format_name(yytext);			return NAME;}
<NAME_TRE>{anything}								{yymore();}

<BUTTON_VAR_TRE>{tre_buttons_begin}		{BEGIN(LINK_TRE);}

<LINK_TRE>{tre_link}								{BEGIN(SEEDS_TRE);			yylval.valString = treactor_format_link(yytext,yyleng);	return LINK;}

<SEEDS_TRE>{tre_seed}							{BEGIN(LEECHERS_TRE);		yylval.valInt=treactor_format_seedsleechers(yytext); 	return NUM_SEEDS;}
<LEECHERS_TRE>{tre_leecher} 					{BEGIN(HEAD_NAME_TRE);		yylval.valInt=treactor_format_seedsleechers(yytext);		return NUM_LEECHERS;}




<INI_CRAZY>{crazy_start_words} 				{/*----- Torrent Crazy ------ */
														BEGIN(ELEMENT_CRAZY);}

<ELEMENT_CRAZY>{crazy_element_begin}		{BEGIN(LINK_CRAZY);}
<ELEMENT_CRAZY>{crazy_end_words} 			{BEGIN(END_CRAZY);}
														
<LINK_CRAZY>{crazy_link}						{BEGIN(NAMEDIV_CRAZY);			yylval.valString = tcrazy_format_link(yytext,yyleng);		return LINK;}
<NAMEDIV_CRAZY>{crazy_ok_ahref}				{BEGIN(NAME_CRAZY);}

<NAME_CRAZY>{crazy_name_end} 					{BEGIN(SEEDS_CRAZY);				yylval.valString = tcrazy_format_name(yytext,yyleng);		return NAME;}
<NAME_CRAZY>{anything} 							{yymore();}


<SEEDS_CRAZY>{crazy_start_seed}				{/*DETECTA EL COMIENZO DE ---SEEDERS---*/}
<SEEDS_CRAZY>{crazy_end_seed_leecher}		{BEGIN(LEECHERS_CRAZY);			yylval.valInt = tcrazy_format_seedsleechers(yytext,yyleng);	return NUM_SEEDS;}
<LEECHERS_CRAZY>{crazy_start_leecher}		{/*DETECTA EL COMIENZO DE ---LEECHERS---*/}	
<LEECHERS_CRAZY>{crazy_end_seed_leecher}	{BEGIN(END_ELEMENT_CRAZY);		yylval.valInt = tcrazy_format_seedsleechers(yytext,yyleng); 	return NUM_LEECHERS;}

<END_ELEMENT_CRAZY>{crazy_element_end}	{BEGIN(ELEMENT_CRAZY);}




<INI_VER>{ver_start_words}						{/*-------- Vertor ------- */	
														BEGIN(ELEMENT_VER);}

<ELEMENT_VER>{ver_element_begin}			{BEGIN(LINKDIV_VER);}
<ELEMENT_VER>{ver_end_words}					{BEGIN(END_VER);}

<LINKDIV_VER>{ver_link_begin}					{BEGIN(LINK_VER);}

<LINK_VER>{ver_link}								{BEGIN(NAME_VER);			yylval.valString = ver_format_link(yytext,yyleng);	return LINK;}

<NAME_VER>{ver_name_end} 						{BEGIN(SEEDS_VER);  		yylval.valString = ver_format_name(yytext,yyleng);	return NAME;}
<NAME_VER>{anything} 							{yymore();}

<SEEDS_VER>{ver_seed}							{BEGIN(LEECHERS_VER);	yylval.valInt = ver_format_seeds(yytext,yyleng);		return NUM_SEEDS;}
<LEECHERS_VER>{ver_leecher}					{BEGIN(ELEMENT_VER);		yylval.valInt = ver_format_leechers(yytext,yyleng);	return NUM_LEECHERS;}




<INI_BIT>{bit_start_words}						{/*--------- Bitsnoop ---------*/
														BEGIN(ELEMENT_BIT);}

<ELEMENT_BIT>{bit_element_begin}				{BEGIN(LINK_BIT);}
<ELEMENT_BIT>{bit_end_words}						{BEGIN(END_BIT);}

<LINK_BIT>{bit_link_begin}						{BEGIN(NAME_BIT);			yylval.valString = bit_format_link(yytext,yyleng);	return LINK;}

<NAME_BIT>{bit_name_end} 						{BEGIN(SEEDS_BIT);		yylval.valString = bit_format_name(yytext,yyleng);	return NAME;}
<NAME_BIT>{anything} 							{yymore();}

<SEEDS_BIT>{bit_seed_bad}						{BEGIN(ELEMENT_BIT);		return NO_SEEDS_LEECHERS;}
<SEEDS_BIT>{bit_seeders}						{BEGIN(LEECHERS_BIT);	yylval.valInt = bit_format_seeds(yytext,yyleng);		return NUM_SEEDS;}
<LEECHERS_BIT>{bit_leechers}					{BEGIN(ELEMENT_BIT);		yylval.valInt = bit_format_leechers(yytext,yyleng);	return NUM_LEECHERS;}


<INITIAL,
INI_TPB,
INI_TRE,
INI_CRAZY,
INI_VER,
INI_BIT,
END_TPB,
END_TRE,
END_CRAZY,
END_VER,
END_BIT><<EOF>>									{return END;}


<INI_TPB,HEAD_TPB,
LINK_TPB,SEEDS_TPB,
LEECHERS_TPB,END_TPB>{anything}			 	{}


<INI_TRE,
HEAD_NAME_TRE,
BUTTON_VAR_TRE,
LINK_TRE,
LEECHERS_TRE,
SEEDS_TRE,
END_TRE>{anything}			    				{}


<INI_CRAZY,
ELEMENT_CRAZY,
LINK_CRAZY,
NAMEDIV_CRAZY,
SEEDS_CRAZY,
NAME_CRAZY,
END_ELEMENT_CRAZY,
LEECHERS_CRAZY,
END_CRAZY>{anything}			    				{}

<INI_VER,
ELEMENT_VER,
LINKDIV_VER,
LINK_VER,
NAME_VER,
SEEDS_VER,
LEECHERS_VER,
END_VER>{anything}								{}


<INITIAL,
INI_BIT,
LINK_BIT,
NAME_BIT,
ELEMENT_BIT,
SEEDS_BIT,
LEECHERS_BIT,
END_BIT>{anything}													{}


%%

/*------------------ The Pirate Bay ------------------------*/

char *
tpb_format_name (char * name)
{
	char *ret;
	int i;
	ret = strdup(name);
	for(i=0; ret[i] != '\0'; i++);
	ret[i-4] = '\0';
	return ret;
}

int
tpb_format_leechers (char * name)
{
		char *ret;
		int i;
		ret = name;
		for(;*ret != '>';ret++);
	ret++;
	for(i=0; ret[i] != '\0'; i++);
	ret[i-5] = '\0';
	return atoi(ret);
}

void
begin_tpb(FILE * file)
{
	YY_BUFFER_STATE entrada =  yy_create_buffer(file,  YY_BUF_SIZE);
	yy_switch_to_buffer(entrada);
	BEGIN(INI_TPB);
}

/*------------------ TorrentReactor ------------------------*/

char*
treactor_format_name (char * name)
{
	char * ret;
	int i=0, j, d,t;
	ret = name;

	for(i=0; ret[i] != '\0'; i++)
	{
		if (ret[i] == '<')
		{
			for(j=i; ret[j] != '>'; j++);
			j++;
			d = j - i;
			for(t=i; ret[j] != '\0'; t++){
				ret[t] = ret[j++];
			}
			ret[t] = '\0';
		}
	}
	return strdup(ret);
}

char*
treactor_format_link (char* link,
						int len)
{
	return strndup(link+strlen("<a class=\"btn btn-mini btn-success\" href=\""),len-strlen("\" rel=\"nofollow\" title=\"Download torrent\">")-strlen("<a class=\"btn btn-mini btn-success\" href=\""));
}

int
treactor_format_seedsleechers (char * number)
{
	char *ret;
	int i;
	ret = number;
	for(;*ret != '>';ret++);
	ret++;
	for(i=0; ret[i] != '\0'; i++);
	ret[i-5] = '\0';
	return atoi(ret);
}

void
begin_treactor(FILE * file)
{
	YY_BUFFER_STATE entrada =  yy_create_buffer(file,  YY_BUF_SIZE);
	yy_switch_to_buffer(entrada);
	BEGIN(INI_TRE);
}

/*------------------ Torrent Crazy ------------------------*/

char *
tcrazy_format_link (char * link,
					int len)
{
	return strndup(link+strlen("<a href=\""),len-strlen("\">")-strlen("<a href=\""));
}

char *
tcrazy_format_name (char * name, int len)
{
	return strdup(name);
}


int
tcrazy_format_seedsleechers(char * number,
							int len)
{
	char * temp = strndup(number,len-strlen("</td>"));
	return atoi(temp);
}

void
begin_tcrazy(FILE * file)
{
	YY_BUFFER_STATE entrada =  yy_create_buffer(file,  YY_BUF_SIZE);
	yy_switch_to_buffer(entrada);
	BEGIN(INI_CRAZY);
}



/*------------------ VERTOR ------------------------------*/


char *
ver_format_name (char * name,int leng)
{
	return strndup(name,leng-strlen("</a>"));
}

char *
ver_format_link (char * link,int leng)
{
	char * temp = malloc(sizeof(char)*(leng-(strlen("href=\"")+strlen("\">"))+strlen("http://vertor.com")+1));
	strcpy(temp,"http://vertor.com");
	strncat(temp,link+strlen("href=\""),leng-(strlen("href=\"")+strlen("\">")));
	return temp;
}

int
ver_format_seeds (char * seeds,int leng)
{
	char * temp = strndup(seeds+strlen("<td class=\"s\">"),leng-(strlen("<td class=\"s\">")+strlen("</td>")));
	return atoi(temp);
}

int
ver_format_leechers (char * leechers, int leng)
{
	char * temp = strndup(leechers+strlen("<td class=\"l\">"),leng-(strlen("<td class=\"l\">")+strlen("</td>")));
	return atoi(temp);
}

void
begin_vertor(FILE * file)
{
	YY_BUFFER_STATE entrada =  yy_create_buffer(file,  YY_BUF_SIZE);
	yy_switch_to_buffer(entrada);
	BEGIN(INI_VER);
}



/*------------------ BITSNOOP ------------------------*/


char *
bit_format_name (char * name,int leng)
{
	return strndup(name,leng-strlen("</a>"));
}


char *
bit_format_link (char * link,int leng)
{
	char * temp = malloc(sizeof(char)*(leng-(strlen("<a href=\"")+strlen("\">"))+strlen("http://bitsnoop.com")+1));
	strcpy(temp,"http://bitsnoop.com");
	strncat(temp+strlen("http://bitsnoop.com"),link+strlen("<a href=\""),leng-(strlen("<a href=\"")+strlen("\">")));
	return temp;
}

int
bit_format_seeds (char * seeds,int leng)
{
	char * temp = strndup(seeds+strlen("<span class=\"seeders\" title=\"Seeders\">"),leng-(strlen("<span class=\"seeders\" title=\"Seeders\">")+strlen("</span>")));

	int i=0;
	for(i=0;i<strlen(temp);i++){
		if(temp[i] = ',')
			strcpy(temp+i,temp+i+1);
	}
	return atoi(temp);
}


int
bit_format_leechers (char * leechers, int leng)
{
	char * temp = strndup(leechers+strlen("<span class=\"leechers\" title=\"Leechers\">"),leng-(strlen("<span class=\"leechers\" title=\"Leechers\">")+strlen("</span>")));
	return atoi(temp);
}


void
begin_bit(FILE * file)
{
	YY_BUFFER_STATE entrada =  yy_create_buffer(file,  YY_BUF_SIZE);
	yy_switch_to_buffer(entrada);
	BEGIN(INI_BIT);
}



