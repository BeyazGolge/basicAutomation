require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome
driver.navigate.to 'http://www.lazyautomation.co.uk/lazy1.html'

driver.manage.window.maximize
sleep(3)

title = driver.find_element(:tag_name,'h1')
puts title.text
driver.find_element(:id, 'textfield1').send_keys('OTOMASYONNN') #Send text to a textfield
driver.find_element(:id, 'a').click #Click on a radiobutton
driver.find_element(:name, 'goodbye').click #Click on a checkbox
#driver.find_element(:link_text, 'This is a link to another website').click #Click on a text

###################################################################
#Click on a dropdown button by value
dropdown = driver.find_element(:id, :options1)
option = Selenium::WebDriver::Support::Select.new(dropdown)
option.select_by(:value, 'c')
###################################################################

###################################################################
#Click a button
#driver.find_element(:id, 'hello1').click
#driver.find_element(:name, 'helloworld').click
#driver.find_element(:xpath, '/html/body/center/p[3]/button').click
###################################################################

sleep(5)