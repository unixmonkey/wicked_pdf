require 'test_helper'
require 'action_view/test_case'

class WickedPdfHelperAssetsTest < ActionView::TestCase

  include WickedPdfHelper::Assets

  if Rails::VERSION::MAJOR == 4

    setup do
      @test_dir   = File.dirname(__FILE__) + '/..'
      @fixtures   = []
      @image      = @test_dir + '/fixtures/spinner.gif'
      @stylesheet = @test_dir + '/fixtures/wicked.css'
      @javascript = @test_dir + '/fixtures/wicked.js'
      FileUtils.cp @image, @test_dir + '/dummy/app/assets/images/asset_spinner.gif'
      FileUtils.cp @stylesheet, @test_dir + '/dummy/app/assets/stylesheets/wicked.css'
    end

    test 'wicked_asset returns a base64 encoded asset for an image in the assets/images dir' do
      assert_match /\Adata:image\/gif;base64,.+\z/, wicked_asset('asset_spinner.gif')
    end

    test 'wicked_asset returns a base64 encoded asset for an image in a subfolder of assets' do
      FileUtils.mkdir_p @test_dir + '/dummy/app/assets/images/spinners/'
      FileUtils.cp @image, @test_dir + '/dummy/app/assets/images/spinners/whirlygig.gif'
      assert_match /\Adata:image\/gif;base64,.+\z/, wicked_asset('spinners/whirlygig.gif')
    end

    test 'wicked_asset returns a base64 encoded asset for a stylesheet in the assets/stylesheets/dir' do
      assert_match /\Adata:text\/css;base64,.+\z/, wicked_asset('wicked.css')
    end

    test 'wicked_asset returns a base64 encoded asset for a javascript in the assets/javascripts/dir' do
      FileUtils.cp @javascript, @test_dir + '/dummy/app/assets/javascripts/wicked.js'
      assert_match /\Adata:application\/javascript;base64,.+\z/, wicked_asset('wicked.js')
    end

    test 'wicked_asset base64 content can be decoded' do
      FileUtils.cp @javascript, @test_dir + '/dummy/app/assets/javascripts/wicked.js'
      js_content = File.open(@javascript){|f| f.read }
      decoded = Base64.decode64(wicked_asset('wicked.js'))
      assert decoded.include? js_content
    end

    test 'wicked_asset returns a base64 encoded asset for an image in the /public dir' do
      FileUtils.cp @image, @test_dir + '/dummy/public/image.gif'
      assert_match /\Adata:image\/gif;base64,.+\z/, wicked_asset('image.gif')
    end

    test 'wicked_asset returns a base64 encoded asset in a in a subdir of the public dir' do
      FileUtils.mkdir_p @test_dir + '/dummy/public/avatars/'
      FileUtils.cp @image, @test_dir + '/dummy/public/avatars/bill.gif'
      assert_match /\Adata:image\/gif;base64,.+\z/, wicked_asset('/avatars/bill.gif')
    end

    test 'wicked_asset with a url returns that url' do
      assert_equal 'http://example.com', wicked_asset('http://example.com')
    end

    test 'wicked_asset adds a protocol to a protocol-relative url' do
      # necessary because wkhtmltopdf does not support them
      assert_equal 'http://example.com', wicked_asset('//example.com')
    end

    test 'wicked_asset respects config:default_protocol' do
      WickedPdf.config[:default_protocol] = 'jim'
      assert_equal 'jim://example.com', wicked_asset('//example.com')
      WickedPdf.config = {}
    end

    test 'wicked_asset returns nil if the asset doesnt exist' do
      assert_nil wicked_asset('nonexistent.png')
    end

    test 'wicked_asset raises an error if config:raise_asset_errors enabled' do
      WickedPdf.config[:raise_asset_errors] = true
      assert_raise(ArgumentError) { wicked_asset('nonexistent.png') }
      WickedPdf.config = {}
    end

  end

end
