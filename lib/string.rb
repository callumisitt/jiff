class String
  require 'shellwords'
  
  def to_slug
    value = self.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s
    value.gsub!(/[']+/, '')
    value.gsub!(/\W+/, ' ')
    value.strip!
    value.downcase!
    value.gsub!(' ', '-')
    value
  end
  
  def shell
    string = Shellwords.escape self
    string.gsub!('%', '%%')
    string
  end
end