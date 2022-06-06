class AnimeParser
  require 'selenium-webdriver'
  require 'colorize'
  def get_anime_links
    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to 'https://animeschedule.net/'

    columns = @driver.find_elements(:class, 'timetable-column')
    anime_links = []
    columns.each do |column|
      shows = column.find_elements(:class, 'timetable-column-show')
      shows.each do |show|
        anime_name = show.find_element(:class, 'show-title-bar').text
        next if anime_name.empty?

        link = show.find_element(:class, 'show-link').attribute('href')
        anime_links.push(link)
      end
    end
    anime_links
  rescue StandardError => e
    puts '----------------------------------------------ERROR----------------------------------------------'.red
    puts e.to_s.red
    puts 'Unfortunately an error occured and could not get the full list, returning what could be salvaged'.red
    puts '-------------------------------------------------------------------------------------------------'.red

    @driver.close if @driver.window_handles.length.positive?
    anime_links
  end

  def open_new_browsers(anime_links)
    anime_links.each do |_link|
      @driver.execute_script('window.open()')
    end
  end

  def window_handles
    @driver.window_handles
  end

  def switch_tabs(window_handles, original_handler, anime_links)
    window_handles -= original_handler
    handles_with_links = window_handles.zip(anime_links)
    puts handles_with_links[0][0]
    handles_with_links.each do |pairs|
      @driver.switch_to.window(pairs[0])
      @driver.navigate.to pairs[1].to_s

      puts "Switched to window #{pairs[0]}"
      puts "Switched to anime #{pairs[1]}"
    end
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

anime_synopsys_finder = AnimeParser.new

anime_links = anime_synopsys_finder.get_anime_links
original_window_handler = anime_synopsys_finder.window_handles

anime_synopsys_finder.open_new_browsers(anime_links)
sleep(5)
new_handles = anime_synopsys_finder.window_handles

anime_synopsys_finder.switch_tabs(new_handles, original_window_handler, anime_links)
sleep(5)
# anime_release_date_finder.print_anime_infos(animes)
