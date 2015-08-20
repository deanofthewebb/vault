class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
  :rememberable, :trackable,
  :authentication_keys => [ :login ]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable
  has_many :secret_file, :foreign_key => 'login'

  def email_required?
  	false
  end

  def email_changed?
  	false
  end
end
