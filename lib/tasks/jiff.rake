namespace :jiff do
  
  desc "Create management environment"
  task launch: :environment do
    
    Rake::Task['db:reset'].invoke

    puts '>>>> Creating Users'

    AdminUser.create!(username: 'moggs', first_name: 'Michael', last_name: 'Briggs', email: 'michael@white-agency.co.uk', password: 'cheese', password_confirmation: 'cheese')
    AdminUser.create!(username: 'davey', first_name: 'Dave', last_name: 'Almond', email: 'dave@white-agency.co.uk', password: 'Wh1te69', password_confirmation: 'Wh1te69')
    AdminUser.create!(username: 'callum', first_name: 'Callum', last_name: 'Isitt', email: 'callum@white-agency.co.uk', password: 'cheese', password_confirmation: 'cheese')
    
    puts '>>>> Creating Servers'
    
    @server_test = Server.create! name: 'Test Server', address: 'test.white-agency.co.uk', user: 'rails', password: 'px7mkp6uc224', environment: 'staging', environment_paths: '/home/rails/.rvm/gems/ruby-1.9.3-p125/bin:/home/rails/.rvm/gems/ruby-1.9.3-p125@global/bin:/home/rails/.rvm/rubies/ruby-1.9.3-p125/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/home/rails/.rvm/bin:/home/rails/.rvm/bin'
    
    if Rails.env.development?
      @server_vagrant = Server.create! name: 'Vagrant', address: 'default', user: 'vagrant', environment: 'staging', environment_paths: '/home/vagrant/.rbenv/shims:/home/vagrant/.rbenv/bin:/home/vagrant/.rbenv/shims:/home/vagrant/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games'
    end
    
    puts '>>>> Creating Sites'
    
    Site.create! name: 'Headlands', url: 'http://www.headlandsschool.co.uk', server_ref: 'headlands', server: @server_test, repo: 'headlands'
    Site.create! name: 'Medical Accident Claimline', url: 'http://www.medicalaccidentclaimline.co.uk', server_ref: 'mac', server: @server_test, repo: 'mac'
    Site.create! name: 'Minster Cycles', url: 'http://www.minstercycles.co.uk', server_ref: 'Minster', server: @server_test, repo: 'm-cycles'
    Site.create! name: 'Medical Accident Claimline', url: 'http://www.medicalaccidentclaimline.co.uk', server_ref: 'mac', server: @server_vagrant, repo: 'mac' if Rails.env.development?

  end
end