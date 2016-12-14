# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


require './lib/ldap'

if !params[:first_name].blank? && !params[:last_name].blank?
  @ldap_entries = Ldap.instance.find_entries_by_full_name("#{params[:first_name]}*", "#{params[:last_name]}*")
end
if !params[:email].blank?
  @ldap_entries = Ldap.instance.find_entries_by_email("#{params[:email]}*")
end

params = {}
params[:first_name] = 'Jalpa'
params[:last_name] = 'Patel'
@ldap_entries = Ldap.instance.find_entries_by_full_name("#{params[:first_name]}*", "#{params[:last_name]}*")

User.search_ldap('marvin bloom')
# all_users = Ldap.instance.find_entries_by_name("marvin*").map(&:uid).flatten
# users = Ldap.instance.find_entries_by_name("bloom*").map(&:uid).flatten

mail
givenname
sn

User.search_ldap('marvin bloom')
Ldap.instance.find_entries_by_name("jones*")

r = Repository.first
ru = r.repository_users.new(username: 'mjg994')
u = User.where(username: 'mjg994').first
ru.user = u

r = Repository.first
ru = r.repository_users.new(username: 'mjg994')
ru.save


r = Repository.first
ru = RepositoryUser.new(repository: r, username: 'mjg994')
ru.save