class <%= module_name.capitalize.pluralize %>Controller < ApplicationController
    layout "<%= module_name %>"
  
    def index
      @<%= module_name %>_props = {  }
    end
  end
  