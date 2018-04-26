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
  
  
  
}
