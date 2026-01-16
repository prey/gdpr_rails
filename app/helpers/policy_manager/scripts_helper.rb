module PolicyManager
  module ScriptsHelper
    def render_scripts
      PolicyManager::Script.scripts.map do |c|
        render(partial: c.script) if c.can_render?
      end.compact.join(' ').html_safe
    end
  end
end
