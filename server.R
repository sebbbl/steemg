library(XML)
library(RCurl)
library(rlist)
# library(wordcloud)
# library(tm)
# library(httr)
library(jsonlite)
library(lubridate)
library(VennDiagram)
# library(RODBC)
# library(mongolite)
library(ggplot2)
# library(openair)
library(lattice)
# Sys.setenv(TZ='GMT')

options(shiny.maxRequestSize = 9*1024^2, scipen=999)

server <- function(input, output, session) {
  # observeEvent(input$fr_id, {myid <- input$fr_id})
  zh <- data.frame(matrix(unlist(strsplit(readLines('./www/zh.csv', encoding = 'UTF-8'), ',')), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)
  names(zh) <- c('en', 'zh')
  ###### steemguides ######
  steemguides <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/steemguides.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(steemguides) <- substr(names(steemguides), 3, nchar(names(steemguides))-1)
  steemguides$date <- as.Date(steemguides$date)
  steemguides$author <- gsub('"', '', steemguides$author)
  steemguides$author <- paste0('<a href="https://steemit.com/@', steemguides$author, '">@', steemguides$author , '</a>')
  steemguides$title <- gsub('"', '', steemguides$title)
  steemguides$url <- gsub('"', '', steemguides$url)
  steemguides$github <- gsub('"', '', steemguides$github)
  steemguides$title <- paste0('<a href="https://steemit.com', steemguides$url, '">', steemguides$title , '</a>')
  steemguides$cum_posts <- 1:nrow(steemguides)
  steemguides$cum_payout <- cumsum(steemguides$payout)
  steemguides$cum_votes <- cumsum(steemguides$votes)
  steemguidesslmax <- nrow(steemguides)
  steemguides_author <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/steemguides_author.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(steemguides_author) <- substr(names(steemguides_author), 3, nchar(names(steemguides_author))-1)
  steemguides_author$author <- gsub('"', '', steemguides_author$author)
  steemguides_author$author <- paste0('<a href="https://steemit.com/@', steemguides_author$author, '">@', steemguides_author$author , '</a>')
  steemguidesaslmax <- nrow(steemguides_author)
  output$steemguides_dt1 = renderDataTable({
    mymatsteemguides <- steemguides
    mymatsteemguides <- mymatsteemguides[, c(1:3, 5:7)]
    steemguidesN <- 'payout'
    mymatsteemguides[, 'Rank'] <- floor(rank(-mymatsteemguides[, input$steemguidesN]))
    mymatsteemguides <- mymatsteemguides[rev(order(mymatsteemguides[, 'date'])), ]
    # steemguides_colsel <- c('date', 'author', 'title', 'payout','votes', 'score', 'prize')
    mymatsteemguidesout <- mymatsteemguides[, c('Rank', input$steemguides_colsel)]
    names(mymatsteemguidesout) <- zh$zh[match(names(mymatsteemguidesout), zh$en)]
    mymatsteemguidesout
  },
  options = list(lengthMenu = c(10, 50, 100, steemguidesslmax), pageLength = 10), escape = FALSE
  )
  
  output$steemguides_dt2 = renderDataTable({
    mymatsteemguidesa <- steemguides_author
    # mraN <- 'payout'
    # mymatmra[, 'Rank'] <- floor(rank(-mymatmra[, mraN]))
    mymatsteemguidesa[, 'Rank'] <- floor(rank(-mymatsteemguidesa[, input$steemguidesaN]))
    mymatsteemguidesa <- mymatsteemguidesa[order(mymatsteemguidesa[, 'Rank']), ]
    # mra_colsel <- c('posts', 'payout','votes', 'character')
    # mymatmraout <- mymatmra[, c('Rank', mra_colsel)]
    mymatsteemguidesaout <- mymatsteemguidesa[, c('Rank', input$steemguidesa_colsel)]
    names(mymatsteemguidesaout) <- zh$zh[match(names(mymatsteemguidesaout), zh$en)]
    mymatsteemguidesaout
  },
  options = list(lengthMenu = c(10, 50, 100, steemguidesaslmax), pageLength = 10), escape = FALSE
  )
  steemguidesxlim <- range(steemguides$date)
  output$steemguides_plot1 <- renderPlot({
    plotdate(steemguides$date, steemguides$cum_votes, mylegend = 'Cumulative Votes', myxlim = steemguidesxlim, mycol = 'blue')
  })
  output$steemguides_plot2 <- renderPlot({
    plotdate(steemguides$date, steemguides$cum_payout, mylegend = 'Cumulative Payout (SBD)', myxlim = steemguidesxlim, mycol = 'red')
  })
  output$steemguides_plot3 <- renderPlot({
    plotdate(steemguides$date, steemguides$cum_posts, mylegend = 'Cumulative Posts', myxlim = steemguidesxlim)
  })
  
  ###### Monthly review ######
  mr <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/mr.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(mr) <- substr(names(mr), 3, nchar(names(mr))-1)
  mr$date <- gsub('"', '', mr$date)
  mr$date <- as.Date(mr$date)
  mr$author <- gsub('"', '', mr$author)
  mr$author <- paste0('<a href="https://steemit.com/@', mr$author, '">@', mr$author , '</a>')
  mr$title <- gsub('"', '', mr$title)
  mr$url <- gsub('"', '', mr$url)
  mr$reviewed <- gsub('"', '', mr$reviewed)
  mr$title <- paste0('<a href="https://steemit.com', mr$url, '">', mr$title , '</a>')
  
  mr1 <- mr[mr$author != '<a href="https://steemit.com/@rivalhw">@rivalhw</a>',]
  mr1$prize <- gsub('"', '', mr1$prize)
  mr1$cum_posts <- 1:nrow(mr1)
  mr1$cum_payout <- cumsum(mr1$payout)
  mr1$cum_votes <- cumsum(mr1$votes)
  mr1slmax <- nrow(mr1)
  
  mr3 <- mr[mr$author == '<a href="https://steemit.com/@rivalhw">@rivalhw</a>',]
  mr3slmax <- nrow(mr3)
  
  mr_author <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/mr_author.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(mr_author) <- substr(names(mr_author), 3, nchar(names(mr_author))-1)
  mr_author$author <- gsub('"', '', mr_author$author)
  mr_author$author <- paste0('<a href="https://steemit.com/@', mr_author$author, '">@', mr_author$author , '</a>')
  mr_author$character <- gsub('"', '', mr_author$character)
  mr_author <- mr_author[mr_author$author != '<a href="https://steemit.com/@rivalhw">@rivalhw</a>',]
  mraslmax <- nrow(mr_author)
  
  output$mr_dt1 = renderDataTable({
    mymatmr <- mr1
    mymatmr <- mymatmr[, c(1:3, 5:8, 10)]
    mrN <- 'payout'
    mymatmr[, 'Rank'] <- floor(rank(-mymatmr[, input$mrN]))
    mymatmr <- mymatmr[rev(order(mymatmr[, 'date'])), ]
    mr_colsel <- c('date', 'author', 'title', 'payout','votes', 'score', 'prize', 'reviewed')
    mymatmrout <- mymatmr[, c('Rank', input$mr_colsel)]
    names(mymatmrout) <- zh$zh[match(names(mymatmrout), zh$en)]
    mymatmrout
  },
  options = list(lengthMenu = c(10, 50, 100, mr1slmax), pageLength = 10), escape = FALSE
  )
  
  output$mr_dt3 = renderDataTable({
    mymatmr <- mr3
    mymatmr <- mymatmr[, c(1:3)]
    mr_colsel <- c('date', 'author', 'title')
    mymatmrout <- mymatmr
    names(mymatmrout) <- zh$zh[match(names(mymatmrout), zh$en)]
    mymatmrout
  },
  options = list(lengthMenu = c(10, 50, 100, mr3slmax), pageLength = 10), escape = FALSE
  )
  
  output$mr_dt2 = renderDataTable({
    mymatmra <- mr_author
    # mraN <- 'payout'
    # mymatmra[, 'Rank'] <- floor(rank(-mymatmra[, mraN]))
    mymatmra[, 'Rank'] <- floor(rank(-mymatmra[, input$mraN]))
    mymatmra <- mymatmra[order(mymatmra[, 'Rank']), ]
    # mra_colsel <- c('posts', 'payout','votes', 'character')
    # mymatmraout <- mymatmra[, c('Rank', mra_colsel)]
    mymatmraout <- mymatmra[, c('Rank', input$mra_colsel)]
    names(mymatmraout) <- zh$zh[match(names(mymatmraout), zh$en)]
    mymatmraout
  },
  options = list(lengthMenu = c(10, 50, 100, mraslmax), pageLength = 10), escape = FALSE
  )
  mrxlim <- range(mr$date)
  output$mr_plot1 <- renderPlot({
    plotdate(mr1$date, mr1$cum_votes, mylegend = 'Cumulative Votes', myxlim = mrxlim, mycol = 'blue')
  })
  output$mr_plot2 <- renderPlot({
    plotdate(mr1$date, mr1$cum_payout, mylegend = 'Cumulative Payout (SBD)', myxlim = mrxlim, mycol = 'red')
  })
  output$mr_plot3 <- renderPlot({
    plotdate(mr1$date, mr1$cum_posts, mylegend = 'Cumulative Posts', myxlim = mrxlim)
  })
  
  
  ###### cnkids ######
  cnkids <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cnkids.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cnkids) <- substr(names(cnkids), 3, nchar(names(cnkids))-1)
  cnkids$date <- as.Date(cnkids$date)
  cnkids$author <- gsub('"', '', cnkids$author)
  cnkids$author <- paste0('<a href="https://steemit.com/@', cnkids$author, '">@', cnkids$author , '</a>')
  cnkids$title <- gsub('"', '', cnkids$title)
  cnkids$url <- gsub('"', '', cnkids$url)
  cnkids$title <- paste0('<a href="https://steemit.com', cnkids$url, '">', cnkids$title , '</a>')
  cnkids$cum_posts <- 1:nrow(cnkids)
  cnkids$cum_payout <- cumsum(cnkids$payout)
  cnkids$cum_votes <- cumsum(cnkids$votes)
  cnkidsslmax <- nrow(cnkids)
  cnkids_author <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cnkids_author.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cnkids_author) <- substr(names(cnkids_author), 3, nchar(names(cnkids_author))-1)
  cnkids_author$author <- gsub('"', '', cnkids_author$author)
  cnkids_author$author <- paste0('<a href="https://steemit.com/@', cnkids_author$author, '">@', cnkids_author$author , '</a>')
  cnkidsaslmax <- nrow(cnkids_author)
  output$cnkids_dt1 = renderDataTable({
    mymatcnkids <- cnkids
    mymatcnkids <- mymatcnkids[, c(1:3, 5:6)]
    cnkidsN <- 'payout'
    mymatcnkids[, 'Rank'] <- floor(rank(-mymatcnkids[, input$cnkidsN]))
    mymatcnkids <- mymatcnkids[rev(order(mymatcnkids[, 'date'])), ]
    # cnkids_colsel <- c('date', 'author', 'title', 'payout','votes', 'score', 'prize')
    mymatcnkidsout <- mymatcnkids[, c('Rank', input$cnkids_colsel)]
    names(mymatcnkidsout) <- zh$zh[match(names(mymatcnkidsout), zh$en)]
    mymatcnkidsout
  },
  options = list(lengthMenu = c(10, 50, 100, cnkidsslmax), pageLength = 10), escape = FALSE
  )
  
  output$cnkids_dt2 = renderDataTable({
    mymatcnkidsa <- cnkids_author
    # mraN <- 'payout'
    # mymatmra[, 'Rank'] <- floor(rank(-mymatmra[, mraN]))
    mymatcnkidsa[, 'Rank'] <- floor(rank(-mymatcnkidsa[, input$cnkidsaN]))
    mymatcnkidsa <- mymatcnkidsa[order(mymatcnkidsa[, 'Rank']), ]
    # mra_colsel <- c('posts', 'payout','votes', 'character')
    # mymatmraout <- mymatmra[, c('Rank', mra_colsel)]
    mymatcnkidsaout <- mymatcnkidsa[, c('Rank', input$cnkidsa_colsel)]
    names(mymatcnkidsaout) <- zh$zh[match(names(mymatcnkidsaout), zh$en)]
    mymatcnkidsaout
  },
  options = list(lengthMenu = c(10, 50, 100, cnkidsaslmax), pageLength = 10), escape = FALSE
  )
  cnkidsxlim <- range(cnkids$date)
  output$cnkids_plot1 <- renderPlot({
    plotdate(cnkids$date, cnkids$cum_votes, mylegend = 'Cumulative Votes', myxlim = cnkidsxlim, mycol = 'blue')
  })
  output$cnkids_plot2 <- renderPlot({
    plotdate(cnkids$date, cnkids$cum_payout, mylegend = 'Cumulative Payout (SBD)', myxlim = cnkidsxlim, mycol = 'red')
  })
  output$cnkids_plot3 <- renderPlot({
    plotdate(cnkids$date, cnkids$cum_posts, mylegend = 'Cumulative Posts', myxlim = cnkidsxlim)
  })
  
  ###### cngreen ######
  cngreen <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cngreen.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cngreen) <- substr(names(cngreen), 3, nchar(names(cngreen))-1)
  cngreen$date <- as.Date(cngreen$date)
  cngreen$author <- gsub('"', '', cngreen$author)
  cngreen$author <- paste0('<a href="https://steemit.com/@', cngreen$author, '">@', cngreen$author , '</a>')
  cngreen$title <- gsub('"', '', cngreen$title)
  cngreen$url <- gsub('"', '', cngreen$url)
  cngreen$title <- paste0('<a href="https://steemit.com', cngreen$url, '">', cngreen$title , '</a>')
  cngreen$cum_posts <- 1:nrow(cngreen)
  cngreen$cum_payout <- cumsum(cngreen$payout)
  cngreen$cum_votes <- cumsum(cngreen$votes)
  cngreenslmax <- nrow(cngreen)
  cngreen_author <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cngreen_author.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cngreen_author) <- substr(names(cngreen_author), 3, nchar(names(cngreen_author))-1)
  cngreen_author$author <- gsub('"', '', cngreen_author$author)
  cngreen_author$author <- paste0('<a href="https://steemit.com/@', cngreen_author$author, '">@', cngreen_author$author , '</a>')
  cngreenaslmax <- nrow(cngreen_author)
  output$cngreen_dt1 = renderDataTable({
    mymatcngreen <- cngreen
    mymatcngreen <- mymatcngreen[, c(1:3, 5:6)]
    cngreenN <- 'payout'
    mymatcngreen[, 'Rank'] <- floor(rank(-mymatcngreen[, input$cngreenN]))
    mymatcngreen <- mymatcngreen[rev(order(mymatcngreen[, 'date'])), ]
    # cngreen_colsel <- c('date', 'author', 'title', 'payout','votes', 'score', 'prize')
    mymatcngreenout <- mymatcngreen[, c('Rank', input$cngreen_colsel)]
    names(mymatcngreenout) <- zh$zh[match(names(mymatcngreenout), zh$en)]
    mymatcngreenout
  },
  options = list(lengthMenu = c(10, 50, 100, cngreenslmax), pageLength = 10), escape = FALSE
  )
  
  output$cngreen_dt2 = renderDataTable({
    mymatcngreena <- cngreen_author
    # mraN <- 'payout'
    # mymatmra[, 'Rank'] <- floor(rank(-mymatmra[, mraN]))
    mymatcngreena[, 'Rank'] <- floor(rank(-mymatcngreena[, input$cngreenaN]))
    mymatcngreena <- mymatcngreena[order(mymatcngreena[, 'Rank']), ]
    # mra_colsel <- c('posts', 'payout','votes', 'character')
    # mymatmraout <- mymatmra[, c('Rank', mra_colsel)]
    mymatcngreenaout <- mymatcngreena[, c('Rank', input$cngreena_colsel)]
    names(mymatcngreenaout) <- zh$zh[match(names(mymatcngreenaout), zh$en)]
    mymatcngreenaout
  },
  options = list(lengthMenu = c(10, 50, 100, cngreenaslmax), pageLength = 10), escape = FALSE
  )
  cngreenxlim <- range(cngreen$date)
  output$cngreen_plot1 <- renderPlot({
    plotdate(cngreen$date, cngreen$cum_votes, mylegend = 'Cumulative Votes', myxlim = cngreenxlim, mycol = 'blue')
  })
  output$cngreen_plot2 <- renderPlot({
    plotdate(cngreen$date, cngreen$cum_payout, mylegend = 'Cumulative Payout (SBD)', myxlim = cngreenxlim, mycol = 'red')
  })
  output$cngreen_plot3 <- renderPlot({
    plotdate(cngreen$date, cngreen$cum_posts, mylegend = 'Cumulative Posts', myxlim = cngreenxlim)
  })
  
  
  
  ###### cn31 ######
  cn31 <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cn31.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cn31) <- substr(names(cn31), 3, nchar(names(cn31))-1)
  cn31$date <- as.Date(cn31$date)
  cn31$author <- gsub('"', '', cn31$author)
  cn31$author <- paste0('<a href="https://steemit.com/@', cn31$author, '">@', cn31$author , '</a>')
  cn31$title <- gsub('"', '', cn31$title)
  cn31$url <- gsub('"', '', cn31$url)
  cn31$title <- paste0('<a href="https://steemit.com', cn31$url, '">', cn31$title , '</a>')
  cn31$cum_posts <- 1:nrow(cn31)
  cn31$cum_payout <- cumsum(cn31$payout)
  cn31$cum_votes <- cumsum(cn31$votes)
  cn31slmax <- nrow(cn31)
  cn31_author <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cn31_author.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cn31_author) <- substr(names(cn31_author), 3, nchar(names(cn31_author))-1)
  cn31_author$author <- gsub('"', '', cn31_author$author)
  cn31_author$author <- paste0('<a href="https://steemit.com/@', cn31_author$author, '">@', cn31_author$author , '</a>')
  cn31aslmax <- nrow(cn31_author)
  output$cn31_dt1 = renderDataTable({
    mymatcn31 <- cn31
    mymatcn31 <- mymatcn31[, c(1:3, 5:6)]
    cn31N <- 'payout'
    mymatcn31[, 'Rank'] <- floor(rank(-mymatcn31[, input$cn31N]))
    mymatcn31 <- mymatcn31[rev(order(mymatcn31[, 'date'])), ]
    # cn31_colsel <- c('date', 'author', 'title', 'payout','votes', 'score', 'prize')
    mymatcn31out <- mymatcn31[, c('Rank', input$cn31_colsel)]
    names(mymatcn31out) <- zh$zh[match(names(mymatcn31out), zh$en)]
    mymatcn31out
  },
  options = list(lengthMenu = c(10, 50, 100, cn31slmax), pageLength = 10), escape = FALSE
  )
  
  output$cn31_dt2 = renderDataTable({
    mymatcn31a <- cn31_author
    # mraN <- 'payout'
    # mymatmra[, 'Rank'] <- floor(rank(-mymatmra[, mraN]))
    mymatcn31a[, 'Rank'] <- floor(rank(-mymatcn31a[, input$cn31aN]))
    mymatcn31a <- mymatcn31a[order(mymatcn31a[, 'Rank']), ]
    # mra_colsel <- c('posts', 'payout','votes', 'character')
    # mymatmraout <- mymatmra[, c('Rank', mra_colsel)]
    mymatcn31aout <- mymatcn31a[, c('Rank', input$cn31a_colsel)]
    names(mymatcn31aout) <- zh$zh[match(names(mymatcn31aout), zh$en)]
    mymatcn31aout
  },
  options = list(lengthMenu = c(10, 50, 100, cn31aslmax), pageLength = 10), escape = FALSE
  )
  cn31xlim <- range(cn31$date)
  output$cn31_plot1 <- renderPlot({
    plotdate(cn31$date, cn31$cum_votes, mylegend = 'Cumulative Votes', myxlim = cn31xlim, mycol = 'blue')
  })
  output$cn31_plot2 <- renderPlot({
    plotdate(cn31$date, cn31$cum_payout, mylegend = 'Cumulative Payout (SBD)', myxlim = cn31xlim, mycol = 'red')
  })
  output$cn31_plot3 <- renderPlot({
    plotdate(cn31$date, cn31$cum_posts, mylegend = 'Cumulative Posts', myxlim = cn31xlim)
  })
  
  ###### cnvoice ######
  cnvoice <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cnvoice.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cnvoice) <- substr(names(cnvoice), 3, nchar(names(cnvoice))-1)
  cnvoice$date <- as.Date(cnvoice$date)
  cnvoice$author <- gsub('"', '', cnvoice$author)
  cnvoice$author <- paste0('<a href="https://steemit.com/@', cnvoice$author, '">@', cnvoice$author , '</a>')
  cnvoice$title <- gsub('"', '', cnvoice$title)
  cnvoice$url <- gsub('"', '', cnvoice$url)
  cnvoice$title <- paste0('<a href="https://steemit.com', cnvoice$url, '">', cnvoice$title , '</a>')
  cnvoice$cum_posts <- 1:nrow(cnvoice)
  cnvoice$cum_payout <- cumsum(cnvoice$payout)
  cnvoice$cum_votes <- cumsum(cnvoice$votes)
  cnvoiceslmax <- nrow(cnvoice)
  cnvoice_author <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cnvoice_author.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cnvoice_author) <- substr(names(cnvoice_author), 3, nchar(names(cnvoice_author))-1)
  cnvoice_author$author <- gsub('"', '', cnvoice_author$author)
  cnvoice_author$author <- paste0('<a href="https://steemit.com/@', cnvoice_author$author, '">@', cnvoice_author$author , '</a>')
  cnvoiceaslmax <- nrow(cnvoice_author)
  output$cnvoice_dt1 = renderDataTable({
    mymatcnvoice <- cnvoice
    mymatcnvoice <- mymatcnvoice[, c(1:3, 5:6)]
    cnvoiceN <- 'payout'
    mymatcnvoice[, 'Rank'] <- floor(rank(-mymatcnvoice[, cnvoiceN]))
    # mymatcnvoice[, 'Rank'] <- floor(rank(-mymatcnvoice[, input$cnvoiceN]))
    mymatcnvoice <- mymatcnvoice[rev(order(mymatcnvoice[, 'date'])), ]
    cnvoice_colsel <- c('date', 'author', 'title', 'payout','votes')
    mymatcnvoiceout <- mymatcnvoice[, c('Rank', cnvoice_colsel)]
    # mymatcnvoiceout <- mymatcnvoice[, c('Rank', input$cnvoice_colsel)]
    names(mymatcnvoiceout) <- zh$zh[match(names(mymatcnvoiceout), zh$en)]
    mymatcnvoiceout
  },
  options = list(lengthMenu = c(10, 50, 100, cnvoiceslmax), pageLength = 10), escape = FALSE
  )
  
  output$cnvoice_dt2 = renderDataTable({
    mymatcnvoicea <- cnvoice_author
    cnvoiceaN <- 'payout'
    # mymatcnvoicea[, 'Rank'] <- floor(rank(-mymatcnvoicea[, cnvoiceaN]))
    mymatcnvoicea[, 'Rank'] <- floor(rank(-mymatcnvoicea[, input$cnvoiceaN]))
    mymatcnvoicea <- mymatcnvoicea[order(mymatcnvoicea[, 'Rank']), ]
    # cnvoicea_colsel <- c('posts', 'payout','votes')
    # mymatcnvoiceaout <- mymatcnvoicea[, c('Rank', cnvoicea_colsel)]
    mymatcnvoiceaout <- mymatcnvoicea[, c('Rank', input$cnvoicea_colsel)]
    names(mymatcnvoiceaout) <- zh$zh[match(names(mymatcnvoiceaout), zh$en)]
    mymatcnvoiceaout
  },
  options = list(lengthMenu = c(10, 50, 100, cnvoiceaslmax), pageLength = 10), escape = FALSE
  )
  cnvoicexlim <- range(cnvoice$date)
  output$cnvoice_plot1 <- renderPlot({
    plotdate(cnvoice$date, cnvoice$cum_votes, mylegend = 'Cumulative Votes', myxlim = cnvoicexlim, mycol = 'blue')
  })
  output$cnvoice_plot2 <- renderPlot({
    plotdate(cnvoice$date, cnvoice$cum_payout, mylegend = 'Cumulative Payout (SBD)', myxlim = cnvoicexlim, mycol = 'red')
  })
  output$cnvoice_plot3 <- renderPlot({
    plotdate(cnvoice$date, cnvoice$cum_posts, mylegend = 'Cumulative Posts', myxlim = cnvoicexlim)
  })
  
  ###### cnfunny ######
  cnfunny <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cnfunny.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cnfunny) <- substr(names(cnfunny), 3, nchar(names(cnfunny))-1)
  cnfunny$date <- as.Date(cnfunny$date)
  cnfunny$author <- gsub('"', '', cnfunny$author)
  cnfunny$author <- paste0('<a href="https://steemit.com/@', cnfunny$author, '">@', cnfunny$author , '</a>')
  cnfunny$title <- gsub('"', '', cnfunny$title)
  cnfunny$url <- gsub('"', '', cnfunny$url)
  cnfunny$title <- paste0('<a href="https://steemit.com', cnfunny$url, '">', cnfunny$title , '</a>')
  cnfunny$cum_posts <- 1:nrow(cnfunny)
  cnfunny$cum_payout <- cumsum(cnfunny$payout)
  cnfunny$cum_votes <- cumsum(cnfunny$votes)
  cnfunnyslmax <- nrow(cnfunny)
  cnfunny_author <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cnfunny_author.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cnfunny_author) <- substr(names(cnfunny_author), 3, nchar(names(cnfunny_author))-1)
  cnfunny_author$author <- gsub('"', '', cnfunny_author$author)
  cnfunny_author$author <- paste0('<a href="https://steemit.com/@', cnfunny_author$author, '">@', cnfunny_author$author , '</a>')
  cnfunnyaslmax <- nrow(cnfunny_author)
  output$cnfunny_dt1 = renderDataTable({
    mymatcnfunny <- cnfunny
    mymatcnfunny <- mymatcnfunny[, c(1:3, 5:6)]
    cnfunnyN <- 'payout'
    mymatcnfunny[, 'Rank'] <- floor(rank(-mymatcnfunny[, input$cnfunnyN]))
    mymatcnfunny <- mymatcnfunny[rev(order(mymatcnfunny[, 'date'])), ]
    # cnfunny_colsel <- c('date', 'author', 'title', 'payout','votes', 'score', 'prize')
    mymatcnfunnyout <- mymatcnfunny[, c('Rank', input$cnfunny_colsel)]
    names(mymatcnfunnyout) <- zh$zh[match(names(mymatcnfunnyout), zh$en)]
    mymatcnfunnyout
  },
  options = list(lengthMenu = c(10, 50, 100, cnfunnyslmax), pageLength = 10), escape = FALSE
  )
  
  output$cnfunny_dt2 = renderDataTable({
    mymatcnfunnya <- cnfunny_author
    # mraN <- 'payout'
    # mymatmra[, 'Rank'] <- floor(rank(-mymatmra[, mraN]))
    mymatcnfunnya[, 'Rank'] <- floor(rank(-mymatcnfunnya[, input$cnfunnyaN]))
    mymatcnfunnya <- mymatcnfunnya[order(mymatcnfunnya[, 'Rank']), ]
    # mra_colsel <- c('posts', 'payout','votes', 'character')
    # mymatmraout <- mymatmra[, c('Rank', mra_colsel)]
    mymatcnfunnyaout <- mymatcnfunnya[, c('Rank', input$cnfunnya_colsel)]
    names(mymatcnfunnyaout) <- zh$zh[match(names(mymatcnfunnyaout), zh$en)]
    mymatcnfunnyaout
  },
  options = list(lengthMenu = c(10, 50, 100, cnfunnyaslmax), pageLength = 10), escape = FALSE
  )
  cnfunnyxlim <- range(cnfunny$date)
  output$cnfunny_plot1 <- renderPlot({
    plotdate(cnfunny$date, cnfunny$cum_votes, mylegend = 'Cumulative Votes', myxlim = cnfunnyxlim, mycol = 'blue')
  })
  output$cnfunny_plot2 <- renderPlot({
    plotdate(cnfunny$date, cnfunny$cum_payout, mylegend = 'Cumulative Payout (SBD)', myxlim = cnfunnyxlim, mycol = 'red')
  })
  output$cnfunny_plot3 <- renderPlot({
    plotdate(cnfunny$date, cnfunny$cum_posts, mylegend = 'Cumulative Posts', myxlim = cnfunnyxlim)
  })
  
  ###### cnsport ######
  cnsport <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cnsport.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cnsport) <- substr(names(cnsport), 3, nchar(names(cnsport))-1)
  cnsport$date <- as.Date(cnsport$date)
  cnsport$author <- gsub('"', '', cnsport$author)
  cnsport$author <- paste0('<a href="https://steemit.com/@', cnsport$author, '">@', cnsport$author , '</a>')
  cnsport$title <- gsub('"', '', cnsport$title)
  cnsport$url <- gsub('"', '', cnsport$url)
  cnsport$title <- paste0('<a href="https://steemit.com', cnsport$url, '">', cnsport$title , '</a>')
  cnsport$cum_posts <- 1:nrow(cnsport)
  cnsport$cum_payout <- cumsum(cnsport$payout)
  cnsport$cum_votes <- cumsum(cnsport$votes)
  cnsportslmax <- nrow(cnsport)
  cnsport_author <- read.csv('https://raw.githubusercontent.com/pzhaonet/keller/master/mr/cnsport_author.txt', stringsAsFactors = FALSE, encoding = 'UTF-8', quote = '')
  names(cnsport_author) <- substr(names(cnsport_author), 3, nchar(names(cnsport_author))-1)
  cnsport_author$author <- gsub('"', '', cnsport_author$author)
  cnsport_author$author <- paste0('<a href="https://steemit.com/@', cnsport_author$author, '">@', cnsport_author$author , '</a>')
  cnsportaslmax <- nrow(cnsport_author)
  output$cnsport_dt1 = renderDataTable({
    mymatcnsport <- cnsport
    mymatcnsport <- mymatcnsport[, c(1:3, 5:6)]
    cnsportN <- 'payout'
    mymatcnsport[, 'Rank'] <- floor(rank(-mymatcnsport[, input$cnsportN]))
    mymatcnsport <- mymatcnsport[rev(order(mymatcnsport[, 'date'])), ]
    # cnsport_colsel <- c('date', 'author', 'title', 'payout','votes', 'score', 'prize')
    mymatcnsportout <- mymatcnsport[, c('Rank', input$cnsport_colsel)]
    names(mymatcnsportout) <- zh$zh[match(names(mymatcnsportout), zh$en)]
    mymatcnsportout
  },
  options = list(lengthMenu = c(10, 50, 100, cnsportslmax), pageLength = 10), escape = FALSE
  )
  
  output$cnsport_dt2 = renderDataTable({
    mymatcnsporta <- cnsport_author
    # mraN <- 'payout'
    # mymatmra[, 'Rank'] <- floor(rank(-mymatmra[, mraN]))
    mymatcnsporta[, 'Rank'] <- floor(rank(-mymatcnsporta[, input$cnsportaN]))
    mymatcnsporta <- mymatcnsporta[order(mymatcnsporta[, 'Rank']), ]
    # mra_colsel <- c('posts', 'payout','votes', 'character')
    # mymatmraout <- mymatmra[, c('Rank', mra_colsel)]
    mymatcnsportaout <- mymatcnsporta[, c('Rank', input$cnsporta_colsel)]
    names(mymatcnsportaout) <- zh$zh[match(names(mymatcnsportaout), zh$en)]
    mymatcnsportaout
  },
  options = list(lengthMenu = c(10, 50, 100, cnsportaslmax), pageLength = 10), escape = FALSE
  )
  cnsportxlim <- range(cnsport$date)
  output$cnsport_plot1 <- renderPlot({
    plotdate(cnsport$date, cnsport$cum_votes, mylegend = 'Cumulative Votes', myxlim = cnsportxlim, mycol = 'blue')
  })
  output$cnsport_plot2 <- renderPlot({
    plotdate(cnsport$date, cnsport$cum_payout, mylegend = 'Cumulative Payout (SBD)', myxlim = cnsportxlim, mycol = 'red')
  })
  output$cnsport_plot3 <- renderPlot({
    plotdate(cnsport$date, cnsport$cum_posts, mylegend = 'Cumulative Posts', myxlim = cnsportxlim)
  })
  
  
}
