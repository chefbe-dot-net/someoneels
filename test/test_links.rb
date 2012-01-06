require 'webapp_test'
class LinksTest < WebAppTest

  def setup
    super
    @visited = {}
  end

  def internal?(link)
    link && !(link =~ /^(https?|mailto|ftp):/)
  end

  def test_links
    visit('/sitemap.xml')
    @pages = all("loc").to_a.each do |elm|
      page = (elm.text.match %r{http://www.someoneels.be(/.*)})[1]
      do_visit(page, "sitemap") do 
        all("a").
          select{|elm| internal?(elm["href"])}.
          each do |elm|
            do_visit(elm["href"], elm.text)
          end
      end
    end
  end

  def do_visit(url, from = nil)
    @visited[url] ||= begin
      puts "Visiting #{url} (#{from})"
      visit(url)
      assert_equal 200, page.status_code, "#{url} should respond"
      yield if block_given?
      true
    end
  end

end
