# _plugins/markdown_callouts.rb
Jekyll::Hooks.register :documents, :pre_render do |document|
  # Duplicate the content to make it mutable
  mutable_content = document.content.dup
  
  # Replace callout markdown syntax with corresponding HTML
  mutable_content.gsub!(/\[!(note|warning|info|success|danger)\](.*)/) do |match|
    type, content = $1, $2
    "<div class=\"callout #{type}\">#{content.strip}</div>"
  end
  
  # Assign the modified content back to the document
  document.content = mutable_content
end

