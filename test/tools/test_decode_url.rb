require 'webapp_test'
class DecodeUrlTest < Test::Unit::TestCase
  include WebApp::Tools

  def _(path)
    Path.dir.dir.dir/:public/:pages/path
  end

  def test_decode_url
    assert_equal [_("index.md"), "fr"], decode_url('')
    assert_equal [_("fr/index.md"), "fr"], decode_url('fr')
    assert_equal [_("fr/index.md"), "fr"], decode_url('fr/index')
    assert_equal [_("fr/maison/index.md"), "fr"], decode_url('fr/maison')
    assert_equal [_("fr/maison/index.md"), "fr"], decode_url('fr/maison/')
    assert_equal [_("fr/maison/index.md"), "fr"], decode_url('fr/maison/index')
  end

  def not_found
    :not_found
  end

  def settings
    Object.new.extend(Module.new{ def default_lang; "fr"; end })
  end

end
