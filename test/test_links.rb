require 'webapp_test'
class LinksTest < WebAppTest

  def setup
    visit('/sitemap.xml')
    @pages = all("loc").map do |elm|
      elm.text =~ %r{http://www.someoneels.be(/.*)}
      $1
    end
  end

  def test_links
    @pages.each do |p|
      puts "Visiting #{p}"
      visit(p)
      assert_equal 200, page.status_code

      # img tags
      all("img").select{|elm| elm["src"]}.to_a.each do |elm|
        visit(elm["src"])
        assert_equal 200, page.status_code, "<img #{elm['src']}> is reachable"
      end

      # a tags
      all("a").select{|elm| elm["href"] && (elm["href"] != '#')}.to_a.each do |elm|
        visit(elm["href"])
        assert_equal 200, page.status_code, "<a #{elm['href']}> is reachable"
      end
    end
  end

end
