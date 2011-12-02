require 'wlang'
require 'wlang/dialects/xhtml_dialect'
WLang::dialect('whtml', '.whtml') do
  encoders WLang::EncoderSet::XHtml
  rules    WLang::RuleSet::Basic
  rules    WLang::RuleSet::Imperative
  rules    WLang::RuleSet::Encoding
  rules    WLang::RuleSet::Buffering

  rule '#' do |parser,offset|
    yaml, reached = parser.parse(offset, "wlang/dummy")
    YAML::load(yaml).each_pair do |k,v|
      parser.scope_define(k,v)
    end
    ["", reached]
  end

  rule '@' do |parser, offset|
    link, reached = parser.parse(offset)
    link = parser.evaluate(link)
    [link, reached]
  end

end
