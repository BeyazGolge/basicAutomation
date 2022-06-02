require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome
driver.navigate.to 'https://animeschedule.net/'

#sleep(2)

columns = driver.find_elements(:class,'timetable-column')
longestName = 0
columns.each do |column|
    day = column.find_element(:class,'timetable-column-day').text
    date = column.find_element(:class,'timetable-column-date-format').text
    shows = column.find_elements(:class, 'timetable-column-show')
    puts '_________________________________________________________________________________'
    puts day + ' ' + date
    animes = []
    shows.each do |show|
        animeName = show.find_element(:class, 'show-title-bar').text
        if animeName.length>longestName
            longestName = animeName.length
        end
        episode = show.find_element(:class,'show-episode').text
        if !animeName.empty?
            animes.push([animeName, episode])
        end
    end

    animes.each do |anime|
        puts  + anime[0] + ' '*(longestName-(anime[0].length)+3) + anime[1] 
    end
end
