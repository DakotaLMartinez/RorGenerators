class <%= module_name.capitalize %>Controller < ApplicationController
    layout "<%= module_name %>"
  
    def index
      @<%= module_name %>_props = {  }
    end
  end
  