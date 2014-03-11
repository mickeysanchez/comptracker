module AccountsHelper
  def total_rewards_browser
    # set up and initialize Watir and Phantomjs in a way that works for the Total Rewards Page.
    
    capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs(
    "phantomjs.page.settings.userAgent" => "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36")
    driver = Selenium::WebDriver.for :phantomjs, :desired_capabilities => capabilities
    switches = ['--ignore-ssl-errors=yes']
    
    ::Watir::Browser.new driver 
  end
  
  def navigate_to_total_rewards_offers(browser, total_rewards_account)
    # get to offers page
    browser.goto  "http://www.totalrewards.com/e-totalrewards/?"
    browser.input(:id => "username").to_subtype.set(total_rewards_account.username)
    browser.input(:id => "pin").to_subtype.set(total_rewards_account.password_digest)
    browser.button(:value => "Sign In").click
    browser.link(:href => "/TotalRewards/Offers.do?", :text => "Your Offers").click
  end
  
  def scrape_total_rewards(browser)
    browser.frame(:id => "offerDisplayMod_iframe").wait_until_present
    offers = browser.frame(:id => "offerDisplayMod_iframe").divs(:class => "pItem")
   
    total_rewards_comps = {}
    
    offers.each do |offer|
      if offer.span(:class => "lblSubjectOld").exists?
        name = offer.span(:class => "lblSubjectOld").text
      else
        name = offer.span(:class => "lblSub").text
      end
      date = offer.div(:class => "expwidth").text
      expiration = date.chomp[-10..-1]
      date = DateTime.strptime(expiration, "%m/%d/%Y")
      
      total_rewards_comps[name] = date
    end
    
    total_rewards_comps
  end
  
  def prepare_total_rewards_comps(total_rewards_comps)
    total_rewards_comps.each do |name, date|
      c = Comp.new
      c.description = name
      c.expiration = date
      
      today = Date.today
      
      c.days_until_expiration = date.mjd - today.mjd
      
      c.save
    end
    
    total_rewards_comps.each do |key, value|
      value.chomp!
      expiration = value[-10..-1]
      expiration = DateTime.strptime(expiration, '%m/%d/%Y')
      today = Date.today
      total_rewards_comps[key] = expiration.mjd - today.mjd
    end
  end
end
