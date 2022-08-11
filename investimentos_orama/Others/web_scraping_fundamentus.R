
pegar_tabela_links_rad_cvm <- function(nome_ticket){
  if(!require('XML')) install.packages('XML',repos = "http://cran.us.r-project.org"); library(XML)
  if(!require('httr')) install.packages('httr',repos = "http://cran.us.r-project.org"); library(httr)
  if(!require('rvest')) install.packages('rvest',repos = "http://cran.us.r-project.org"); library(rvest)
 
  
  
  url <-paste0("https://www.fundamentus.com.br/resultados_trimestrais.php?papel=", sub('.SA','',nome_ticket),"&tipo=1")
  html <- read_html(url)
  tabela_html <- XML::htmlParse(html)
  links <- html_attr(html_nodes(html, 'a'), 'href')
  filtro_links<- sapply(links, function(x){
    return(strsplit(x,':')[[1]][[1]]=='https' & strsplit(x,'\\.')[[1]][5]=="br/ENET/frmGerenciaPaginaFRE")
  })
  links <- na.exclude(links[filtro_links])
  datas <- as.Date(html_text(html_nodes(html, 'span'))[-1],'%d/%m/%Y')
  tabela <- data.frame(datas = datas, links = links)
  return(tabela)
}

nome_ticket = 'CEBR5.SA'

tabela <- pegar_tabela_links_rad_cvm(nome_ticket)
#-------------------------------

if(!require('gregexpr')) install.packages('gregexpr',repos = "http://cran.us.r-project.org"); library(gregexpr)
if(!require('libtidy')) install.packages('libtidy',repos = "http://cran.us.r-project.org"); library(libtidy)


nova_url <- tabela$links[1]
novo_html <- read_html(nova_url)
local_tabela <- html_children(html_children(html_children(novo_html)[2])[1])[15]
View(local_tabela)
local_tabela_2<- html_children(html_children(html_children(local_tabela)[1])[3])
local_tabela_3 <- html_children(local_tabela_2)

tabela_html <- XML::htmlParse(nova_html)
root <-  xmlRoot(tabela_html)
dados <-  readHTMLTable(tabela_html, stringsAsFactors = FALSE)

links <- html_attr(html_nodes(novo_html,'a'))

nova_html <- GET(nova_url)
nova_html <- GET(nova_html[['request']][['url']])


