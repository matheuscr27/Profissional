#setwd('/home/matheus/Documentos/Programas/investimentos_orama')

stock_portfolio_stats <- function(stock_portfolio, dates, my_table){
  
  dates <- dates[names(stock_portfolio[['stock']])]
  names_filter <- my_table$names %in% names(stock_portfolio[['stock']])
  stand_desviation <- (sapply(dates, function(x){return(x[['price']]$adjusted[nrow(x[['price']])])}) - my_table$media[names_filter])/my_table$sd[names_filter]
  
  return(stand_desviation)
}

risk <- function(stock_portfolio, price_dividends_data){
  
  test <-sapply(names(stock_portfolio$stock), function(x){
    my_lines <- price_dividends_data[[x]]$price$adjusted
    return(my_lines)
  })
  my_lengths <-  sapply(test, length)
  if(!all(my_lengths == my_lengths[1])){
    test <- sapply(test, tail, n = min(my_lengths))# deixar todos com o mesmo tamanho
  }
  test <- na.exclude(test)
  
  percent_concentration <- percent_stock_concentration(stock_portfolio = stock_portfolio, look = 'owned value')
  
  relative_percent <- sapply(names(stock_portfolio$stock), function(x){# relative percent line name in relation of col name
    return(percent_concentration/ (percent_concentration + percent_concentration[x]))
  })
  
  
  stock_change <- (test[nrow(test),] - test[1,])/test[1,]
  
  dual_stock_return <- sapply(names(stock_portfolio$stock), function(x){   
    dual_stock_return <- sapply(names(stock_portfolio$stock), function(y){
      if(length(names(stock_portfolio$stock))>1){
      
        return(stock_change[x]*relative_percent[x,y] +stock_change[y]*relative_percent[y,x])
      
      }else{
        
        return(stock_change[x]*relative_percent +stock_change[y]*relative_percent)
        
      }
    })
    return(dual_stock_return)
  })
  row.names(dual_stock_return) <- names(stock_portfolio$stock)
  variation <- apply(test, MARGIN = 2, var)
  cov_table <- sapply(names(stock_portfolio$stock), function(x){
    my_lines <- sapply(names(stock_portfolio$stock), function(y){
      #return(cov(test[,x], test[,y]))
      return(var(test[,x], test[,y]))
    })
    return(my_lines)
  })
  rownames(cov_table) <- names(stock_portfolio$stock)
  colnames(cov_table) <- names(stock_portfolio$stock)
  #  ((relative_percent['CGRA4.SA', 'TRPL4.SA'])**2)*variation['CGRA4.SA'] + ((relative_percent['TRPL4.SA','CGRA4.SA'])**2)*variation['TRPL4.SA'] + 2*(relative_percent['CGRA4.SA', 'TRPL4.SA']*relative_percent['TRPL4.SA','CGRA4.SA']*cov_table['TRPL4.SA','CGRA4.SA'])
  
  risk <-  sapply(names(stock_portfolio$stock), function(x){
    my_lines <- sapply(names(stock_portfolio$stock), function(y){
    
      if(length(names(stock_portfolio$stock))>1){
        
        return((((relative_percent[x, y])**2)*variation[x] + ((relative_percent[y,x])**2)*variation[y] + 2*(relative_percent[x, y]*relative_percent[y,x]*cov_table[y,x])))
      
      }else{
        
        return((((relative_percent)**2)*variation[x] + ((relative_percent)**2)*variation[y] + 2*(relative_percent*relative_percent*cov_table)))
      }
    })
    return(my_lines)
  })
  row.names(risk) <- names(stock_portfolio$stock)
  
  risk <- sqrt(abs(risk))
  
  best_percent <- sapply(names(stock_portfolio$stock), function(x){
    my_lines <- sapply(names(stock_portfolio$stock), function(y){
      my_percent <- (variation[y] - cov_table[x,y])/(variation[x] + variation[y] -2*cov_table[x,y] )
      if(!is.na(my_percent)){
        if(my_percent > 1){
          my_percent = 1
        }else if(my_percent < 0){
          my_percent = 0
        }
      }
      return(my_percent)
    })
    return(my_lines)
  })
  
                         
  row.names(best_percent) <- names(stock_portfolio$stock)
  high_below_ideal_percent <-best_percent - relative_percent 
  high_below_ideal_percent <- round(high_below_ideal_percent, 2)

  return(list(cov_table = cov_table,
              test = test,
            risk = risk,
            relative_percent =relative_percent ,
            best_percent = best_percent, 
            high_below_ideal_percent = high_below_ideal_percent))
}
#my_risk<- risk(stock_portfolio = stock_portfolio, price_dividends_data = price_dividends_data) 
#View(my_risk$high_below_ideal_percent)
