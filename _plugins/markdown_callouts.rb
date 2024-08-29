module Jekyll
  module CustomFilters
    def callout(content)
      # Update regex to stop at a blank line
      content.gsub(/\[!(note|warning|info)\](.+?)(?=\n\n|\z)/m) do |match|
        type = $1
        text = $2.strip
        "<div class=\"callout #{type}\">#{text}</div>"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::CustomFilters)

