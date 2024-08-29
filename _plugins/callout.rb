module Jekyll
  class CalloutTag < Liquid::Block
    # This method is called when the tag is first used.
    def initialize(tag_name, type, tokens)
      super  # Call the parent class's initialize method.
      @type = type.strip  # Save the callout type (e.g., 'info', 'warning') from the tag.
    end

    # This method is called to render the content within the tag.
    def render(context)
      content = super  # This will get the content inside the {% callout %} tag.
      # Return the HTML that will replace the Liquid tag.
      "<div class='callout #{@type}'>#{content}</div>"
    end
  end
end

# Register the tag so that Jekyll recognizes {% callout %}.
Liquid::Template.register_tag('callout', Jekyll::CalloutTag)
