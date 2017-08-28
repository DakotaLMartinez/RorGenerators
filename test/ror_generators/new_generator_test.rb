require "test_helper"
require "generators/ror_generators/new_generator"

class RorGenerators::NewGeneratorTest < ::Rails::Generators::TestCase
  include GeneratorTestHelpers

  class_attribute :install_destination

  tests RorGenerators::Generators::NewGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))

  remove_generator_sample_app
  create_generator_sample_app

  Minitest.after_run do 
    remove_generator_sample_app
  end
  
  setup do 
    run_generator %w(product)
    run_generator %w(test)
  end

  test "generates controller" do 
    assert_file "app/controllers/products_controller.rb" do |content| 
      assert_match("class ProductsController < ApplicationController", content)
    end
  end

  test "generates route" do 
    assert_file "config/routes.rb" do |content|
      assert_match("resources :products, only: :index", content)
    end
  end

  test "generates index view" do 
    assert_file "app/views/products/index.html.erb" do |content|
      assert_match('<%= react_component("ProductApp", props: @product_props, prerender: false) %>', content)
    end
  end

  test "generates layout template" do 
    assert_file "app/views/layouts/product.html.erb" do |content|
      assert_match("<%= javascript_pack_tag 'webpack-bundle' %>", content)
      assert_match("<%= yield %>", content)
    end
  end

  test "generates package.json file" do 
    assert_file "client/package.json" do |content|
      assert_match("axios", content)
      assert_match("babel-cli", content)
      assert_match("babel-core", content)
      assert_match("babel-loader", content)
      assert_match("babel-runtime", content)
      assert_match("babel-polyfill", content)
      assert_match("babel-preset-es2015", content)
      assert_match("babel-preset-react", content)
      assert_match("babel-preset-stage-2", content)
      assert_match("es5-shim", content)
      assert_match("expose-loader", content)
      assert_match("immutable", content)
      assert_match("imports-loader", content)
      assert_match("js-yaml", content)
      assert_match("react", content)
      assert_match("react-dom", content)
      assert_match("react-on-rails", content)
      assert_match("react-redux", content)
      assert_match("redux", content)
      assert_match("webpack", content)
      assert_match("webpack-manifest-plugin", content)
    end
  end

  test "generates webpack.config.js" do 
    assert_file "client/webpack.config.js" do |content|
      assert_match("'./app/bundles/product/startup/registration',", content)
    end
  end

  test "adds to webpack.config.js on second run" do 
    assert_file "client/webpack.config.js" do |content|
      assert_match("'./app/bundles/product/startup/registration',\n", content)
      assert_match("'./app/bundles/test/startup/registration',\n", content)
    end
  end

  test "doesn't add file to bundle if it's already there" do 
    run_generator %w(product)
    assert_file "client/webpack.config.js" do |content|
      product_bundles = content.split("\n").select do |line|
        #puts line
        line.include?("'./app/bundles/product/startup/registration',")
      end.length
      assert_equal(1, product_bundles)
    end
    
  end
end