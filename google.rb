require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome
driver.navigate.to 'https://google.com/'

driver.find_element(:xpath,'/html/body/div[1]/div[3]/form/div[1]/div[1]/div[1]/div/div[2]/input').send_keys('anime')
driver.find_element(:xpath,'/html/body/div[1]/div[3]/form/div[1]/div[1]/div[3]/center/input[1]').click
sleep(2)
driver.navigate().back()
sleep(2)