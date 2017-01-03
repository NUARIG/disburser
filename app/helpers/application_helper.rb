module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.permit(:sort, :direction).merge({ sort: column, direction: direction }), { class: css_class }
  end

  def validation_errors?(object, field_name)
    object.errors.messages[field_name].any?
  end

  def format_validation_errors(object, field_name)
    if object.errors.any?
      if !object.errors.messages[field_name].blank?
        object.errors.messages[field_name].join(", ")
      end
    end
  end

  def active?(css_class, url_parameters)
    current_request?(url_parameters) ? css_class : ''
  end

  def current_request?(*requests)
    requests.each do |request|
      if request[:controller] == controller.controller_name
        return true if request[:action].is_a?(Array) && request[:action].include?(controller.action_name) && request
        return true if request[:action] == controller.action_name
      end
    end
    false
  end
end