class AnimeParser
  require 'selenium-webdriver'
  require 'colorize'

  def parse_anime_infos
    @driver = Selenium::WebDriver.for :chrome

    # options = Selenium::WebDriver::Chrome::Options.new
    # options.add_argument('--headless')
    # options.add_argument('--disable-gpu')
    # options.add_argument('--disable-extensions')

    # @driver = Selenium::WebDriver.for(:chrome, capabilities: options)

    @driver.navigate.to 'https://animeschedule.net/'
    # @wait = Selenium::WebDriver::Wait.new(:timeout => 10)

    puts @driver.window_handles
    columns = @driver.find_elements(:class, 'timetable-column')
    animes = []
    columns.each do |column|
      day = column.find_element(:class, 'timetable-column-day').text
      date = column.find_element(:class, 'timetable-column-date-format').text
      shows = column.find_elements(:class, 'timetable-column-show')
      shows.each do |show|
        wait = Selenium::WebDriver::Wait.new(timeout: 3)
        puts 'Finding anime name'
        anime_name_element = show.find_element(:class, 'show-title-bar')
        anime_name = anime_name_element.text
        puts 'Finding episode'
        episode = show.find_element(:class, 'show-episode').text
        next if anime_name.empty?

        puts anime_name
        puts "Getting synopsys for #{anime_name}"
        show.find_element(:class, 'show-link').click
        sleep(4)
        synopsys_element = @driver.find_element(:id, 'description')
        synopsys = synopsys_element.text
        @driver.navigate.back
        puts 'Going back to main page'
        sleep(4)
        wait.until { @driver.find_element(id: 'footer-copyright').displayed? }
        animes.push([day, date, anime_name, episode, synopsys])
      end
    end
    animes
  rescue StandardError => e
    puts '----------------------------------------------ERROR----------------------------------------------'.red
    puts e.to_s.red
    puts 'Unfortunately an error occured and could not get the full list, returning what could be salvaged'.red
    puts '-------------------------------------------------------------------------------------------------'.red

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

animes = anime_release_date_finder.parse_anime_infos
anime_release_date_finder.print_anime_infos(animes)
