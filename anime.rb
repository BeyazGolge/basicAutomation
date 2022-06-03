class AnimeParser
  require 'selenium-webdriver'
  require 'colorize'

  def parse_anime_infos
    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to 'https://animeschedule.net/'
    columns = @driver.find_elements(:class, 'timetable-column')
    animes = []
    columns.each do |column|
      day = column.find_element(:class, 'timetable-column-day').text
      date = column.find_element(:class, 'timetable-column-date-format').text
      shows = column.find_elements(:class, 'timetable-column-show')
      shows.each do |show|
        anime_name = show.find_element(:class, 'show-title-bar').text
        episode = show.find_element(:class, 'show-episode').text
        next if anime_name.empty?

        puts anime_name
        puts "Getting synopsys for #{anime_name}"
        show.find_element(:class, 'show-link').click
        synopsys = @driver.find_element(:id, 'description').text
        @driver.navigate.back
        puts 'Going back to main page'
        animes.push([day, date, anime_name, episode, synopsys])
        sleep(5)
      end
    end
    animes
  rescue StandardError => e
    puts '--------------------------------------------ERROR--------------------------------------------'.red
    puts e.to_s.red
    puts 'Unfortunately an error occured and could not get the full list, here is what i could salvage'.red
    puts '---------------------------------------------------------------------------------------------'.red

    @driver.close if @driver.window_handles.length.positive?
    animes
  end

  def longest_name_length(animes)
    return @longest_name_length unless @longest_name_length.nil?

    @longest_name_length = 0
    animes.each do |anime|
      @longest_name_length = anime[2].length if @longest_name_length < anime[2].length
    end
    @longest_name_length
  end

  def print_anime_infos(animes)
    longest_name_length = longest_name_length(animes)
    animes.each do |anime|
      puts anime[2].yellow + ' ' * (longest_name_length - anime[2].length + 3) + anime[3] + ' < ' + anime[0] + ' ' + anime[1]
      puts anime[4]
      puts ('_' * longest_name_length + '_' * 24).green
    end
  end
end

anime_release_date_finder = AnimeParser.new

x = anime_release_date_finder.parse_anime_infos
anime_release_date_finder.print_anime_infos(x)
