module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.permit(:sort, :direction, :search, :status, :fulfillment_status).merge({ sort: column, direction: direction }), { class: css_class }
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
    current_page?(url_parameters) ? css_class : ''
  end

  def checked?(param_value, value, default)
    if param_value.nil? && default
      true
    else
      param_value == value
    end
  end
end