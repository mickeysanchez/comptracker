module UsersHelper
  def get_borgata_comps
    # set up and initialize Watir and Phantomjs in a way that works for the Borgata page.
    switches = ['--ignore-ssl-errors=yes']
    browser = Watir::Browser.new :phantomjs, :args => switches
    
    # get to offers page
    borgata_account = @accounts.find_by(:type_of_account => "Borgata Rewards")
    browser.goto "https://www.theborgata.com/casino/mbr"
    browser.input(:id => "borgataMainContentWrapped_content_0_ctlLoginForm_txtEmailAddressOrAccountNumber").to_subtype.set(borgata_account.username)
    browser.input(:id => "borgataMainContentWrapped_content_0_ctlLoginForm_txtPassword").to_subtype.set(borgata_account.password_digest)
    browser.link(:id => "borgataMainContentWrapped_content_0_ctlLoginForm_btnLogin").click
    
    # scrape comps
    comps = browser.table(:class => "data-list-table offers").tbody.trs
    @borgata_comps = {}
    
    comps.each do |comp|
      name = comp.td(:class => "offer-name").text
      date = comp.td(:class => "offer-date").text
      
      date.chomp!
      expiration = date[-8..-1]
      expiration.lstrip!
      expiration = Date.strptime(expiration, '%m.%d.%y')
      
      today = Date.today
      
      @borgata_comps[name] = expiration.mjd - today.mjd
    end
  
    browser.close 
  end
  
 
  
end
