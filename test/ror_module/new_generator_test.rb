require "test_helper"
require "generators/ror_module/new_generator"

class RorModule::NewGeneratorTest < ::Rails::Generators::TestCase
  include GeneratorTestHelpers

  class_attribute :install_destination

  tests RorModule::Generators::NewGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))

  remove_generator_sample_app
  create_generator_sample_app

  Minitest.after_run do 
    remove_generator_sample_app
  end
  
  setup do 
    run_generator %w(test)
  end

  test "generates controller" do 
    assert_file "app/controllers/test_controller.rb" do |content| 
      assert_match("class TestController < ApplicationController", content)
    end
  end

  test "generates route" do 
    assert_file "config/routes.rb" do |content|
      assert_match("resources :test, only: :index", content)
    end
  end
end