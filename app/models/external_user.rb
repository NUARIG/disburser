class ExternalUser < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  after_initialize :set_defaults

  validates_presence_of :first_name, :last_name

  #Class Methods
  def self.search(search_token, repository = nil)
    all_users = []
    search_tokens = search_token.split(' ')
    where_condition = "(lower(first_name) like ? OR lower(last_name) like ?)"
    where_condition = Array.new(search_tokens.size, where_condition)
    where_condition = where_condition.join(' AND ')
    search_tokens = search_tokens.map { |search_token| ["%#{search_token.downcase}%", "%#{search_token.downcase}%"] }
    search_tokens.flatten
    where_condition = [where_condition, search_tokens].flatten
    all_users =  ExternalUser.where(where_condition).map { |user| { username: user.username, first_name: user.first_name, last_name: user.last_name, email: user.email } }

    if repository
      existing_users = repository.repository_users.map { |repository_user| { username: repository_user.user.username, first_name: repository_user.user.first_name, last_name: repository_user.user.last_name, email: repository_user.user.email } }
      all_users = all_users - existing_users
    end

    all_users
  end

  private
    def set_defaults
      if self.new_record?
        self.username = self.email
      end
    end
end