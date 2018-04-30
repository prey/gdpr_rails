require "will_paginate"
require 'will_paginate/view_helpers/action_view'

module PolicyManager
  class PaginatorRenderer < WillPaginate::ActionView::LinkRenderer
    ELLIPSIS = '&hellip;'

    def to_html
      list_items = pagination.map do |item|
        case item
          when (1.class == Integer ? Integer : Fixnum)
            page_number(item)
          else
            send(item)
        end
      end.join(@options[:link_separator])

      list_wrapper = tag :nav, list_items, class: "pagination button-group"
      tag :nav, list_wrapper
    end

    def container_attributes
      super.except(*[:link_options])
    end

    protected

    def page_number(page)
      link_options = @options[:link_options] || {}

      if page == current_page
        tag(:a, page, class: 'btn page-item active', href: '')
      else
        tag(:a, page, href: page_path(page), class: 'page-link btn', rel: rel_value(page))
      end
    end

    def page_path(page)
      return "../index.html" if page == 1
      if @collection.current_page == 1
        return "./#{page}/index.html" if @collection.current_page < page
        return "../#{page}/index.html" if @collection.current_page > page
      else
        return "../#{page}/index.html"
      end
    end

    def previous_or_next_page(page, text, classname)
      link_options = @options[:link_options] || {}
      if page
        link_wrapper = tag(:a, text || page, href: page_path(page), class: "page-link btn" + classname.to_s)
        # link_wrapper, class: 'page-item '
      else
        tag(:a, text, href:'', class: 'page-link btn')
        # span_wrapper, class: 'page-item disabled'
      end
    end

    def gap
      tag :p, tag(:i, ELLIPSIS, class: 'page-link'), class: 'page-item disabled btn'
    end

    def previous_page
      num = @collection.current_page > 1 && @collection.current_page - 1
      previous_or_next_page num, @options[:previous_label], 'previous btn'
    end

    def next_page
      num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
      previous_or_next_page num, @options[:next_label], 'next btn'
    end

  end
end
