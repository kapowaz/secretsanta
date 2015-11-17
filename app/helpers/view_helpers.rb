require 'tilt/erb'

class SecretSanta
  class ViewHelpers
    def self.erb(template, locals={})
      Tilt::ERBTemplate.new("app/views/#{template}.erb").render(nil, locals)
    end
  end
end
