class HomeController < ApplicationController
  helper_method :sort_column, :sort_direction
  def index
    params[:page]||= 1
    options = {}
    options[:sort_column] = sort_column
    options[:sort_direction] = sort_direction

    @repositories = Repository.search_across_fields(params[:search], options).paginate(per_page: 10, page: params[:page])
  end

  private
    def sort_column
      ['name', 'data', 'specimens'].include?(params[:sort]) ? params[:sort] : 'name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end
end