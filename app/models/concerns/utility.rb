module Utility
  extend ActiveSupport::Concern
  
  module ClassMethods
    def hide_commands(*commands)
      hidden_commands = []
      commands.each do |command|
        hidden_commands << command
      end
      define_method(:hidden_commands) { hidden_commands }
    end
  end
end