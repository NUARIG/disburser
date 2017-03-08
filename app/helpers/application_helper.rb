module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.permit(:sort, :direction, :search, :status, :data_status, :specimen_status, :vote_status, :feasibility, :repository_id).merge({ sort: column, direction: direction }), { class: css_class }
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

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def user_signed_in?
    northwestern_user_signed_in? || external_user_signed_in?
  end

  def user_type?(resource, user_class)
    resource.class == user_class
  end
end