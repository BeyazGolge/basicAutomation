class AnimeParser
  require 'selenium-webdriver'
  require 'colorize'
  def get_anime_links
    caps = Selenium::WebDriver::Remote::Capabilities.chrome
    caps.page_load_strategy = 'eager'

    @driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
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

  def go_to_links(window_handles, anime_links)
    handles_with_links = window_handles.zip(anime_links)
    handles_with_links.each do |pairs|
      @driver.switch_to.window(pairs[0])
      @driver.navigate.to pairs[1].to_s
    end
  end

  def window_handles
    @driver.window_handles
  end

  def get_synopsyses(window_handles)
    anime_infos = []
    window_handles.each do |window|
      @driver.switch_to.window(window)
      anime_name = @driver.find_element(:id, 'anime-header-main-title').text
      anime_synopsys = @driver.find_element(:id, 'description').text
      anime_infos.push([anime_name, anime_synopsys])
      @driver.close
    end
    anime_infos
  end

  def print_anime_infos(anime_infos)
    anime_infos.each do |info|
      puts info[0].yellow
      puts info[1]
      puts ('_' * 100).green
    end
  end
end

anime_synopsys_finder = AnimeParser.new

anime_links = anime_synopsys_finder.get_anime_links
original_window_handler = anime_synopsys_finder.window_handles
anime_synopsys_finder.open_new_browsers(anime_links)
new_handles = anime_synopsys_finder.window_handles - original_window_handler
anime_synopsys_finder.go_to_links(new_handles, anime_links)
anime_infos = anime_synopsys_finder.get_synopsyses(new_handles)
anime_synopsys_finder.print_anime_infos(anime_infos)
