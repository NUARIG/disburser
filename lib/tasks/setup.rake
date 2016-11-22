namespace :setup do
  desc "Users"
  task(users: :environment) do |t, args|
    user = User.where(username: 'moomin')
    if user.blank?
      user = User.new(email: 'moomin@moomin.com', password: 'password', username: 'moomin')
      user.save!
    end
  end
end