module Utility
  extend ActiveSupport::Concern
  
  module ClassMethods
    def hide_commands(*commands)
      puts 'HIYA'
      hidden_commands = []
      commands.each do |command|
        hidden_commands << command
      end
      define_method :hidden_commands do
        hidden_commands
      end
    end
  end
end