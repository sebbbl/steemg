# steemg: an online collection and analysis tool for steem activities contests

### What is the project about?

There are many long-term activities and contests on steem. For Example, Yuedanping, written as 月旦评 in Chinese and meaning *Monthly Review*, is a long-term literature writing contest in the Chinese steemian community. Since it began in September 2017, it has received more than 2000 submitted articles. The number is growing fast every day. *Steem Handbook*, another long-term activity, aims to helping Steemians to survive on Steem and develop their social communications, and helping the developers to develop new products out of the Steem blockchain or database. The posts submitted to the *Steem Handbook* are more than 200 now, and it is still going on.

Searching steemit.com for an involved article is like looking for a needle in a haystack. The Goolge Custom Search bar often gives unsatifactory results when people want to find a specified artile in these activities. Furthermore, the partipicants and organzers need to know what is really going on with the activities.

This is why I developed steemg (website: <http://steemg.org>). It is an online collection and analysis tool for steem activities and contests. The current version (0.0) provides the information of two activities, which were mentioned before: *Monthly Review* and *Steem Handbook*. Steemg has the following features:


#### Displaying

1. Steemg displays all the related posts in the archieve of an activity with the date, author, title, hyperlink, payout and upvote.

2. Users can sort each column by simply clicking the headers in either ascending order or descending order.

3. The participation frequancy of each author is summarized in a table. Users can rank the authors by the cumulative participation frequency, or the cumulative payout, or the cumulative upvotes.

#### Searching

1. Users can easily search keywords in the post title. 

2. Users can easily pick out the posts with a given author, a given date/month/year, or a give payout/vote.

#### Statistic Analysis

Participants and organizers of the activity can see the statistic analysis figures. Steemg 0.0 provides the time series of cumulative posts, votes and payouts. 


### Technology Stack

This project used R language as well as the shiny package to develop the codes. The website is based on a Ubuntu OS with the shiny-server installed.

### Roadmap

In the future more activities and contests will be displayed on steemg. More statistic analysis will be performed, such as the statistic distribution of the post payout or votes.

Each activity page on steemg will have a notice board, so that users will get the information such as how to participate the activity. The organizers will be able to edit the notice board via github PR.
