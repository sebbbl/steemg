library(shiny)

ui <- fluidPage(
  tags$head(includeScript("google-analytics.js")),
  headerPanel("steemg: a collection of steem contests. Steem 各种活动荟萃。"),
  tabsetPanel(
    ###### steemguides ######
    tabPanel("Steem 指南|Steem Handbook",
             sidebarLayout(
               sidebarPanel(
                 p(),
                 img(src="https://steemitimages.com/DQmc9ka9n5aVok9ShgzmuswUVjMKnJXWkSYfhTyXtKLr41c/banner.jpg", width="300"),
                 h2("《Steem 指南》书稿"),
                 h4("用途: "),
                 "展示《Steem 指南》书稿的相关文章和作者。", 
                 h4("Features: "),
                 "To display the participants in the book Steem Guides.", 
                 p(),
                 hr(),
                 h4('用法: '),
                 p(),
                 "- 单击文章标题或作者会跳转至 steemit。有的浏览器因安全级别高而屏蔽了跳转，改用请用 ctrl + 鼠标左键单击即可;",
                 p(),
                 "- 可以选择第一列“座次”按哪个指标排序;",
                 p(),
                 "- 可以选择第一列“座次”按哪个指标排序;",
                 p(),
                 "- 可以选择显示哪些列;",
                 p(),
                 "- 点击表格顶部标题可以正反排序;",
                 p(),
                 "- 表格右上角搜索栏可以在全表搜索，底部末行可以关键词过滤。",
                 p(),
                 hr(),
                 h4("联系"),
                 '本网站归', a(href = 'https://steemit.com/@dapeng', '@dapeng'), ' 所有。欢迎提供建议。', 
                 p(),
                 img(src="steemit-watermark.png", width="131", height="38"),
                 hr(),
                 wellPanel(
                   h4("累计文章数量"),
                   plotOutput('steemguides_plot3', height = 200),
                   hr(),
                   h4("累计获赞数量"),
                   plotOutput('steemguides_plot1', height = 200),
                   hr(),
                   h4("累计文章收益"),
                   plotOutput('steemguides_plot2', height = 200)
                 )
                 
               ),
               mainPanel(
                 wellPanel(
                   h3("文章榜："),
                   hr(),
                   checkboxGroupInput(
                     inputId = "steemguides_colsel",
                     label   = "选择显示哪些列:",
                     choices = c('date', 'author', 'title', 'payout','votes', 'github'), #'level', 
                     selected = c('date', 'author', 'title', 'payout','votes', 'github'),
                     inline = TRUE
                   ),
                   hr(),
                   radioButtons(
                     inputId = "steemguidesN",
                     label   = "座次依据:",
                     # label   = "Rank in:",
                     choices = c('payout','votes'),
                     selected = 'payout',
                     inline = TRUE
                   ),
                   hr(),
                   
                   dataTableOutput('steemguides_dt1')
                 ),
                 wellPanel(
                   h3("人物榜："),
                   hr(),
                   checkboxGroupInput(
                     inputId = "steemguidesa_colsel",
                     label   = "选择显示哪些列:",
                     choices = c('author', 'posts', 'payout','votes'),
                     selected = c('author', 'posts', 'payout','votes'),
                     inline = TRUE
                   ),
                   hr(),
                   radioButtons(
                     inputId = "steemguidesaN",
                     label   = "座次依据:",
                     choices = c('posts', 'payout','votes'),
                     selected = 'posts',
                     inline = TRUE
                   ),
                   hr(),
                   dataTableOutput('steemguides_dt2')
                 )),
               position = "right"
             )
    ),
    
    
    ###### Monthly Review ######
    tabPanel("月旦评|Monthly Review",
             sidebarLayout(
               sidebarPanel(
                 p(),
                 img(src="https://steemitimages.com/DQmRdNg6SDwvbAXZoyJgyDEZZS29hnenDBPFw68WxWzzMji/monthlyreview.jpg", width="300"),
                 h2("月旦评"),
                 h4("用途: "),
                 "展示月旦评文章和作者。", 
                 h4("Features: "),
                 "To display the participants in the Monthly Review Contest.", 
                 p(),
                 hr(),
                 h4('用法: '),
                 p(),
                 "- 单击文章标题或作者会跳转至 steemit。有的浏览器因安全级别高而屏蔽了跳转，改用请用 ctrl + 鼠标左键单击即可;",
                 p(),
                 "- 可以选择第一列“座次”按哪个指标排序;",
                 p(),
                 "- 可以选择第一列“座次”按哪个指标排序;",
                 p(),
                 "- 可以选择显示哪些列;",
                 p(),
                 "- 点击表格顶部标题可以正反排序;",
                 p(),
                 "- 表格右上角搜索栏可以在全表搜索，底部末行可以关键词过滤。",
                 p(),
                 hr(),
                 h4("联系"),
                 '关于月旦评，请联系活动发起人和主办人', a(href = 'https://steemit.com/@rivalhw', '@rivalhw。'),'本网站归', a(href = 'https://steemit.com/@dapeng', '@dapeng'), ' 所有。欢迎提供建议。', 
                 p(),
                 h4("致谢"),
                 '月旦评 logo 由', a(href = 'https://steemit.com/@lemooljiang', '@lemooljiang'), ' 设计制作。', '琅琊榜的创意来自', a(href = 'https://steemit.com/@angelina6688', '@angelina6688。'), 
                 p(),
                 p(),
                 img(src="steemit-watermark.png", width="131", height="38"),
                 hr(),
                 wellPanel(
                   h4("累计文章数量"),
                   plotOutput('mr_plot3', height = 200),
                   hr(),
                   h4("累计获赞数量"),
                   plotOutput('mr_plot1', height = 200),
                   hr(),
                   h4("累计文章收益"),
                   plotOutput('mr_plot2', height = 200)
                 )
                 
               ),
               mainPanel(
                 wellPanel(
                   h3("文章榜："),
                   hr(),
                   checkboxGroupInput(
                     inputId = "mr_colsel",
                     label   = "选择显示哪些列:",
                     choices = c('date', 'author', 'title', 'payout','votes', 'prize', 'reviewed'), #'score'), #'level', 
                     selected = c('date', 'author', 'title', 'payout','votes', 'prize', 'reviewed'), #'score'),
                     inline = TRUE
                   ),
                   hr(),
                   radioButtons(
                     inputId = "mrN",
                     label   = "座次依据:",
                     # label   = "Rank in:",
                     choices = c('payout','votes'), #'score'),
                     selected = 'payout',
                     inline = TRUE
                   ),
                   hr(),
                   
                   dataTableOutput('mr_dt1')
                 ),
                 wellPanel(
                   h3("档案馆："),
                   hr(),
                   dataTableOutput('mr_dt3')
                 ),
                 wellPanel(
                   h3("人物榜："),
                   hr(),
                   checkboxGroupInput(
                     inputId = "mra_colsel",
                     label   = "选择显示哪些列:",
                     choices = c('author', 'posts', 'payout','votes'), #'character'),
                     selected = c('author', 'posts', 'payout','votes'), #'character'),
                     inline = TRUE
                   ),
                   hr(),
                   radioButtons(
                     inputId = "mraN",
                     label   = "座次依据:",
                     choices = c('posts', 'payout','votes'),
                     selected = 'posts',
                     inline = TRUE
                   ),
                   hr(),
                   dataTableOutput('mr_dt2')
                 )
               ),
               position = "right"
             )
    ),

###### cnkids ######
tabPanel("儿童作品|CN-kids",
         sidebarLayout(
           sidebarPanel(
             p(),
             img(src="https://steemitimages.com/0x0/https://www.seewhatgrows.org/wp-content/uploads/2016/05/Sustainable-Gardening-Tips.jpg", width="300"),
             h2("儿童作品比赛活动"),
             h4("用途: "),
             "展示儿童作品比赛的文章和作者。", 
             h4("Features: "),
             "To display the participants in the CN-kids contest.", 
             p(),
             hr(),
             h4('用法: '),
             p(),
             "- 单击文章标题或作者会跳转至 steemit。有的浏览器因安全级别高而屏蔽了跳转，改用请用 ctrl + 鼠标左键单击即可;",
             p(),
             "- 可以选择第一列“座次”按哪个指标排序;",
             p(),
             "- 可以选择第一列“座次”按哪个指标排序;",
             p(),
             "- 可以选择显示哪些列;",
             p(),
             "- 点击表格顶部标题可以正反排序;",
             p(),
             "- 表格右上角搜索栏可以在全表搜索，底部末行可以关键词过滤。",
             p(),
             hr(),
             h4("联系"),
             '本网站归', a(href = 'https://steemit.com/@dapeng', '@dapeng'), ' 所有。欢迎提供建议。', 
             p(),
             img(src="steemit-watermark.png", width="131", height="38"),
             hr(),
             wellPanel(
               h4("累计文章数量"),
               plotOutput('cnkids_plot3', height = 200),
               hr(),
               h4("累计获赞数量"),
               plotOutput('cnkids_plot1', height = 200),
               hr(),
               h4("累计文章收益"),
               plotOutput('cnkids_plot2', height = 200)
             )
             
           ),
           mainPanel(
             wellPanel(
               h3("文章榜："),
               hr(),
               checkboxGroupInput(
                 inputId = "cnkids_colsel",
                 label   = "选择显示哪些列:",
                 choices = c('date', 'author', 'title', 'payout','votes'), #'level', 
                 selected = c('date', 'author', 'title', 'payout','votes'),
                 inline = TRUE
               ),
               hr(),
               radioButtons(
                 inputId = "cnkidsN",
                 label   = "座次依据:",
                 # label   = "Rank in:",
                 choices = c('payout','votes'),
                 selected = 'payout',
                 inline = TRUE
               ),
               hr(),
               
               dataTableOutput('cnkids_dt1')
             ),
             wellPanel(
               h3("人物榜："),
               hr(),
               checkboxGroupInput(
                 inputId = "cnkidsa_colsel",
                 label   = "选择显示哪些列:",
                 choices = c('author', 'posts', 'payout','votes'),
                 selected = c('author', 'posts', 'payout','votes'),
                 inline = TRUE
               ),
               hr(),
               radioButtons(
                 inputId = "cnkidsaN",
                 label   = "座次依据:",
                 choices = c('posts', 'payout','votes'),
                 selected = 'posts',
                 inline = TRUE
               ),
               hr(),
               dataTableOutput('cnkids_dt2')
             )),
           position = "right"
         )
    )
  )
)