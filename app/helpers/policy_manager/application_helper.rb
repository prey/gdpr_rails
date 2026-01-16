module PolicyManager
  module ApplicationHelper
    def bootstrap_class_for(flash_type)
      { success: 'alert-success', error: 'alert-danger', alert: 'alert-warning',
        notice: 'alert-info' }[flash_type.to_sym] || flash_type.to_s
    end

    def flash_messages(_opts = {})
      flash.each do |msg_type, message|
        flash.delete(msg_type)
        concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)}") do
          concat content_tag(:button, "<i class='fa fa-times-circle'></i>".html_safe, class: 'close',
                                                                                      data: { dismiss: 'alert' })
          concat message
        end)
      end

      session.delete(:flash)
      nil
    end

    def state_color(state)
      case state
      when 'pending', 'draft'
        'tag-yellow'
      when 'progress'
        'tag-azure'
      when 'completed', 'published'
        'tag-green'
      end
    end

    def gravatar_url(user, size)
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    end

    def chart(data)
      column_chart(data.call)
    rescue Groupdate::Error
      content_tag(:p,
                  'chart not displayed, Be sure to install time zone support - https://github.com/ankane/groupdate#for-mysql', class: 'alert alert-danger')
    end
  end
end
