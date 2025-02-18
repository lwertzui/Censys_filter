# Censys_filter
takes a html of a censys search, dumped with the dev cosole or a browser extension and finds all ip adresses and ports in the entire File.  
you can get a lot of data from censys without a premium account by using tor, so the rate limiter is reset everytime you disconnect and   
reconnect from tor, also put results per page up to the max and do multiple runs with different sorting, if you know a bit about linux,  
i trust you are smart enough to add the outputs of multiple html scans into one file and then rerun the main script so you get a complete  
list and also it filters out the duplicates. 
  
This definitely wasnt made to exploit ICSA-24-165-19 or anything, also ignore the naming history, that definitely hasn't got anything to do with it.
