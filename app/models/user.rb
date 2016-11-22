class User < ApplicationRecord
  devise :ldap_authenticatable, :trackable, :timeoutable
end
