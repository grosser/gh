module GH
  class Pagination < Wrapper
    class Paginated
      include Enumerable

      def initialize(page, url, gh)
        @page, @next_url, @gh = page, url, gh
      end

      def each(&block)
        return enum_for(:each) unless block
        @page.each(&block)
        next_page.each(&block)
      end

      def inspect
        "[#{first.inspect}, ...]"
      end

      def [](value)
        return @page[value] if value < @page.size
        next_page[value - @page.size]
      end

      private

      def next_page
        @next_page ||= @gh[@next_url]
      end
    end

    wraps GH::Normalizer
    double_dispatch

    def modify_response(response)
      return response unless response.headers['link'] =~ /<([^>]+)>;\s*rel=\"next\"/
      Paginated.new(response, $1, self)
    end
  end
end
