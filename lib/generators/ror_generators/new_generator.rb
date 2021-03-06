require "rails/generators"

module RorGenerators
  module Generators
    class NewGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
    
      def module_name 
        @module_name ||= "#{file_name}"
      end
    
      def client_dest_prefix 
        "client/app/bundles/#{module_name}/"
      end
    
      def create_react_directories
        dirs = %w[components containers startup]
        dirs.each { |name| empty_directory("#{client_dest_prefix}/#{name}") }
      end
    
      def create_redux_directories
        dirs = %w[actions constants reducers store]
        dirs.each { |name| empty_directory("#{client_dest_prefix}/#{name}") }
      end
    
      def copy_template_files 
        client_template_files.each do |file|
          file_name = file[2] ? module_name.capitalize : module_name
          template "client/#{file[0]}/#{file[1]}", 
            "#{client_dest_prefix}/#{file[0]}/#{file_name}#{file[1].gsub('.erb', '')}"
        end
      end
    
      def add_route 
        route "resources :#{module_name.downcase.pluralize}, only: :index"
      end
    
      def copy_server_files
        empty_directory("app/views/#{module_name}")
        template "server/controller.rb", "app/controllers/#{module_name.pluralize}_controller.rb"
        template "server/index.html.erb", "app/views/#{module_name.pluralize}/index.html.erb"
        template "server/layout.html.erb", "app/views/layouts/#{module_name}.html.erb"
      end
      
      def copy_config_files 
        template "client/startup/registration.jsx.erb", "#{client_dest_prefix}/startup/registration.jsx"
      end

      def copy_webpack_config
        if !dest_file_exists?("client/webpack.config.js")
          template "client/webpack.config.js.erb", "client/webpack.config.js"
        end
      end

      def add_file_to_bundle
        if dest_file_exists?("client/webpack.config.js")
          if not_in_bundle?
            puts "not in bundle"
            inject_into_file "client/webpack.config.js", after: "'babel-polyfill',\n" do
              "\t\t\t'./app/bundles/#{module_name}/startup/registration',\n"
            end
          end
        end
      end

      def copy_package_json 
        template "client/package.json.tt", "client/package.json" unless dest_file_exists?("client/package.json")
      end
    
      # def template_package_json
      #   if dest_file_exists?("package.json")
      #     add_yarn_postinstall_script_in_package_json
      #   else
      #     template("base/base/package.json", "package.json")
      #   end
      # end
    
      private
    
      def client_template_files 
        [
          ["actions", "ActionCreators.jsx.erb", false],
          ["components", ".jsx.erb", true],
          ["constants", "Constants.jsx.erb", false],
          ["containers", "Container.jsx.erb", true],
          ["reducers", "Reducer.jsx.erb", false],
          ["startup", "App.jsx.erb", true],
          ["store", "Store.jsx.erb", false]
        ]
      end
    
      # From https://github.com/rails/rails/blob/4c940b2dbfb457f67c6250b720f63501d74a45fd/railties/lib/rails/generators/rails/app/app_generator.rb
      def app_name
        @app_name ||= (defined_app_const_base? ? defined_app_name : File.basename(destination_root))
                      .tr('\\', "").tr(". ", "_")
      end
    
      def defined_app_name
        defined_app_const_base.underscore
      end
    
      def defined_app_const_base
        Rails.respond_to?(:application) && defined?(Rails::Application) &&
          Rails.application.is_a?(Rails::Application) && Rails.application.class.name.sub(/::Application$/, "")
      end
    
      alias defined_app_const_base? defined_app_const_base
    
      def app_const_base
        @app_const_base ||= defined_app_const_base || app_name.gsub(/\W/, "_").squeeze("_").camelize
      end
    
      def dest_file_exists?(file)
        dest_file = File.join(destination_root, file)
        File.exist?(dest_file) ? dest_file : nil
      end
    
      def add_yarn_postinstall_script_in_package_json
        client_package_json = File.join(destination_root, "package.json")
        contents = File.read(client_package_json)
        postinstall = %("postinstall": "cd client && yarn install")
        if contents =~ /"scripts" *:/
          replacement = <<-STRING
    "scripts": {
    #{postinstall},
    STRING
          regexp = / {2}"scripts": {/
        else
          regexp = /^{/
          replacement = <<-STRING.strip_heredoc
            {
              "scripts": {
                #{postinstall}
              },
          STRING
        end
    
        contents.gsub!(regexp, replacement)
        File.open(client_package_json, "w+") { |f| f.puts contents }
      end

      def not_in_bundle?
        if Pathname.new('client/webpack.config.js').file? 
          match = File.readlines('client/webpack.config.js').find do |line|
            line.include?("#{module_name}/startup/registration")
          end
        end
        match.nil?
      end
    
    end
  end
end