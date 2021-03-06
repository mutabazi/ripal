#' server.R
#' 
#' ripal Shiny server-side main handler (Does all the heavy lifting) 
#' 
#' this is the initial version and needs some code cleanup and
#' definitely some user interface care & feeding
#' 

shinyServer(function(input, output) {
    
  results <- reactive({
        
    useLocal <- input$useLocal
    
    dumpfile <- NULL 
    
    if (is.null(input$dumpfile)) {
      if (is.null(input$localDumpFile)) {
        return(NULL)
      } else {        
        pw.info <- file.info(sprintf("www/data/%s",input$localDumpFile))
        print(str(pw.info))
        dumpfile <- list(datapath=sprintf("www/data/%s", input$localDumpFile),
                         name=input$localDumpFile, 
                         size=pw.info$size)
        print(str(dumpfile))
      }
    } else {      
      dumpfile <- input$dumpfile      
    }
    
		passwords <- readPass(dumpfile$datapath)

    tot <- nrow(passwords) 

    return(list(filename=dumpfile$name, bytes=dumpfile$size, passwords=passwords, tot=tot))
    
  })
  
  #' helper function to display tabular data
  
  printCounts <- function(ct) {
    p <- results()$passwords
    tmp <- data.frame(Term=names(ct), Count=as.numeric(unlist(ct)))
    tmp$Percent <- sprintf("%3.2f%%", ((tmp$Count / results()$tot) * 100))
    print(tmp[order(-tmp$Count),])
  }
  
  countsDF <- function(ct) {
    p <- results()$passwords
    tmp <- data.frame(Term=names(ct), Count=as.numeric(unlist(ct)))
    tmp$Percent <- sprintf("%3.2f%%", ((tmp$Count / results()$tot) * 100))
    return(tmp[order(-tmp$Count),])
  }
  
  #' each "output" function follows the Shiny pattern, rendering
  #' whatever the element is on the ui.R side. Most of these
  #' key off of changes to the dumpfile, but some reference the
  #' input$topN variable from ui.R and will re-render when that
  #' reactive value changes. 
    
  output$overview1 <- renderText({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return("No file selected") }
    return(sprintf("File: %s (%s lines/%s bytes)",
                   results()$filename, 
                   format(results()$tot, big.mark=",", scientific=FALSE), 
                   format(results()$bytes, big.mark=",", scientific=FALSE)))
  })
  
  output$top1 <- renderTable({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords
    top.n <- as.data.frame(head(sort(table(p$orig), decreasing=TRUE), input$topN))
    top.n$Password <- rownames(top.n)
    rownames(top.n) <- NULL
    top.n <- top.n[,c(2,1)]
    colnames(top.n) <- c("Password","Count")
    top.n$Percent <- sprintf("%3.2f%%", ((top.n$Count / results()$tot) * 100))
    print(top.n)
  }, include.rownames=FALSE)
  
  output$topBasewords <- renderTable({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords
    basewords <- as.data.frame(head(sort(table(p[nchar(p$basewords)>3,]$basewords), decreasing=TRUE), input$topN))
    basewords$Password <- rownames(basewords)
    rownames(basewords) <- NULL
    basewords <- basewords[,c(2,1)]
    colnames(basewords) <- c("Password","Count")
    basewords$Percent <- sprintf("%3.2f%%", ((basewords$Count / results()$tot) * 100))
    print(basewords)
  }, include.rownames=FALSE)
  
  output$top1Chart <- renderPlot({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords
    top.n <- as.data.frame(head(sort(table(p$orig), decreasing=TRUE), input$topN))
    top.n$Password <- rownames(top.n)
    rownames(top.n) <- NULL
    top.n <- top.n[,c(2,1)]
    colnames(top.n) <- c("Password","Count")
    top.n$Percent <- sprintf("%3.2f%%", ((top.n$Count / results()$tot) * 100))
    gg <- ggplot(data=top.n, aes(x=reorder(Password, Count), y=Count))
    gg <- gg + geom_bar(stat="identity", fill="steelblue")
    gg <- gg + labs(x="Password", y="Count", title=sprintf("Top %d Passwords", input$topN))
    gg <- gg + coord_flip()
    gg <- gg + theme_bw()
    print(gg)
  })
  
  output$topBasewordsChart <- renderPlot({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords
    basewords <- as.data.frame(head(sort(table(p[nchar(p$basewords)>3,]$basewords), decreasing=TRUE), input$topN))
    basewords$Password <- rownames(basewords)
    rownames(basewords) <- NULL
    basewords <- basewords[,c(2,1)]
    colnames(basewords) <- c("Password","Count")
    basewords$Percent <- sprintf("%3.2f%%", ((basewords$Count / results()$tot) * 100))
    gg <- ggplot(data=basewords, aes(x=reorder(Password, Count), y=Count))
    gg <- gg + geom_bar(stat="identity", fill="steelblue")
    gg <- gg + labs(x="Password", y="Count", title=sprintf("Top %d Basewords", input$topN))
    gg <- gg + coord_flip()
    gg <- gg + theme_bw()
    print(gg)
  })
  
  output$topLen <- renderTable({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords
    by.length <- as.data.frame(table(p$len))
    colnames(by.length) <- c("Password","Count")
    by.length$Percent <- sprintf("%3.2f%%", ((by.length$Count / results()$tot) * 100))
    print(by.length)
  }, include.rownames=FALSE)
  
  output$topFreq <- renderTable({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords
    length.tab <- table(p$len)
    by.freq <- as.data.frame(table(factor(p$len, 
                                          levels = names(length.tab[order(length.tab, decreasing = TRUE)]))))
    colnames(by.freq) <- c("Password","Count")
    by.freq$Percent <- sprintf("%3.2f%%", ((by.freq$Count / results()$tot) * 100))
    print(by.freq)
  }, include.rownames=FALSE)
  
  output$pwLenFreq <- renderPlot({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords
    length.tab <- table(p$len)
    plot(length.tab, col="steelblue", main="Password Length Frequency",
         xlab="Password Length", ylab="Count")    
  })

  output$pwCompStats <- renderText({
    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    
    p <- results()$passwords
    
    one.to.six <- nrow(p[p$len>=1 & p$len<=6,])
    one.to.eight <- nrow(p[p$len>=1 & p$len<=8,])
    nine.plus <- nrow(p[p$len>8,])
    
    only.lower.alpha <- sum(grepl("^[a-z]+$",p$orig))
    only.upper.alpha <- sum(grepl("^[A-Z]+$",p$orig))
    only.alpha <- only.lower.alpha + only.upper.alpha
    
    only.numeric <- sum(grepl("^[0-9]+$",p$orig))
    
    first.cap.last.sym <- sum(grepl("^[A-Z].*[[:punct:]]$",p$orig))
    first.cap.last.num <- sum(grepl("^[A-Z].*[0-9]$",p$orig))
    
    singles.on.end <- sum(grepl("[^0-9]+([0-9]{1})$", p$orig))
    doubles.on.end <- sum(grepl("[^0-9]+([0-9]{2})$", p$orig))
    triples.on.end <- sum(grepl("[^0-9]+([0-9]{3})$", p$orig))
		
		tot <- nrow(p)
    
    o <- c(sprintf("One to six characters = %d, (%3.3f%%)", one.to.six, 100*(one.to.six/tot)),
    sprintf("One to eight characters = %d, (%3.3f%%)", one.to.eight, 100*(one.to.eight/tot)),
    sprintf("More than eight characters = %d, (%3.3f%%)", nine.plus, 100*(nine.plus/tot)),
    sprintf("Only lowercase alpha = %d, (%3.3f%%)", only.lower.alpha, 100*(only.lower.alpha/tot)),
    sprintf("Only uppercase alpha = %d, (%3.3f%%)", only.upper.alpha, 100*(only.upper.alpha/tot)),
    sprintf("Only alpha = %d, (%3.3f%%)", only.alpha, 100*(only.alpha/tot)),
    sprintf("Only numeric = %d, (%3.3f%%)", only.numeric, 100*(only.numeric/tot)),
    sprintf("First capital last symbol = %d, (%3.3f%%)", first.cap.last.sym, 100*(first.cap.last.sym/tot)),
    sprintf("First capital last number = %d, (%3.3f%%)", first.cap.last.num, 100*(first.cap.last.num/tot)),
    sprintf("Single digit on the end = %d, (%3.3f%%)", singles.on.end, 100*(singles.on.end/tot)),
    sprintf("Two digits on the end = %d, (%3.3f%%)", doubles.on.end, 100*(doubles.on.end/tot)),
    sprintf("Three digits on the end = %d, (%3.3f%%)", doubles.on.end, 100*(doubles.on.end/tot)))
    
    print(sprintf("%s<br/>",o))
    
  })  
  
  output$worst25 <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    worst.ct <- sapply(worst.pass, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE)
    countsDF(worst.ct)    
  }, options=list(iDisplayLength=10))
  
  output$weekdaysFullDT <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    countsDF(sapply(weekdays.full, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE))    
  }, options=list(iDisplayLength=10))
  
  output$weekdaysAbbrevDT <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    countsDF(sapply(weekdays.abbrev, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE))    
  }, options=list(iDisplayLength=10))
  
  output$monthsFullDT <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    countsDF(sapply(months.full, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE))    
  }, options=list(iDisplayLength=10))
  
  output$monthsAbbrevDT <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    countsDF(sapply(months.abbrev, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE))    
  }, options=list(iDisplayLength=10))
  
  output$yearsDT <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    d <- input$dateRange
    yrs <- as.character(d[1]:d[2])
    countsDF(sapply(yrs, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE))    
  }, options=list(iDisplayLength=10))
  
  output$yearRangeTitle <- renderText({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    d <- input$dateRange
    return(sprintf("Years [%d-%d] Corpus Counts", d[1], d[2]))
  })
  
  output$colorsDT <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    countsDF(sapply(common.colors, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE))    
  }, options=list(iDisplayLength=10))
  
  output$seasonsDT <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    countsDF(sapply(seasons, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE))    
  }, options=list(iDisplayLength=10))
  
  output$planetsDT <- renderDataTable({    
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    countsDF(sapply(planets, function(x) { return(x=list("count"=sum(grepl(x, results()$p$orig, ignore.case=TRUE))))}, simplify=FALSE))    
  }, options=list(iDisplayLength=10))
  
  output$pwLastDigit <- renderPlot({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    last.num.factor <- factor(na.omit(p$last.num))
    plot(last.num.factor, col="steelblue", main="Count By Last digit")    
  })
  
  output$last2 <- renderTable({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    last.df <- as.data.frame(tail(sort(table(na.omit(p$last.2))), input$topN))
    last.df$Digits <- rownames(last.df)
    rownames(last.df) <- NULL
    last.df <- last.df[,c(2,1)]
    colnames(last.df) <- c("Last 2 Digits","Count")
    print(last.df)
  }, include.rownames=FALSE)
  
  output$last3 <- renderTable({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    last.df <- as.data.frame(tail(sort(table(na.omit(p$last.3))), input$topN))
    last.df$Digits <- rownames(last.df)
    rownames(last.df) <- NULL
    last.df <- last.df[,c(2,1)]
    colnames(last.df) <- c("Last 3 Digits","Count")
    print(last.df)
  }, include.rownames=FALSE)
  
  output$last4 <- renderTable({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    last.df <- as.data.frame(tail(sort(table(na.omit(p$last.4))), input$topN))
    last.df$Digits <- rownames(last.df)
    rownames(last.df) <- NULL
    last.df <- last.df[,c(2,1)]
    colnames(last.df) <- c("Last 4 Digits","Count")
    print(last.df)
  }, include.rownames=FALSE)
  
  output$last5 <- renderTable({
    if (is.null(input$dumpfile) & is.null(input$localDumpFile)) { return(NULL) }
    p <- results()$passwords    
    last.df <- as.data.frame(tail(sort(table(na.omit(p$last.5))), input$topN))
    last.df$Digits <- rownames(last.df)
    rownames(last.df) <- NULL
    last.df <- last.df[,c(2,1)]
    colnames(last.df) <- c("Last 5 Digits","Count")
    print(last.df)
  }, include.rownames=FALSE)
  
})

