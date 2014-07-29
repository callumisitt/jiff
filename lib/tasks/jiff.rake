namespace :jiff do
  
  desc "Create default site"
  task launch: :environment do
    
    Rake::Task['db:reset'].invoke

    puts '>>>> Creating Users'

    AdminUser.create!(username: 'moggs', first_name: 'Michael', last_name: 'Briggs', email: 'michael@white-agency.co.uk', password: 'cheese', password_confirmation: 'cheese')
    AdminUser.create!(username: 'davey', first_name: 'Dave', last_name: 'Almond', email: 'dave@white-agency.co.uk', password: 'Wh1te69', password_confirmation: 'Wh1te69')
    AdminUser.create!(username: 'callum', first_name: 'Callum', last_name: 'Isitt', email: 'callum@white-agency.co.uk', password: 'cheese', password_confirmation: 'cheese')
    
    puts '>>>> Creating Servers'
    
    @server_test = Server.create!(name: 'Test Server', address: 'test.white-agency.co.uk', user: 'rails')
    
    puts '>>>> Creating Sites'
    
    Site.create!(name: 'Headlands', url: 'hd.test.white-agency.co.uk', server_ref: 'headlands', server: @server_test)
    Site.create!(name: 'Medical Accident Claimline', url: 'mac.test.white-agency.co.uk', server_ref: 'mac', server: @server_test)
    Site.create!(name: 'Minster Cycles', url: 'mc.test.white-agency.co.uk', server_ref: 'Minster', server: @server_test)

  end
end