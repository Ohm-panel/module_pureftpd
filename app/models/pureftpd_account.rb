require 'digest/sha2'

class PureftpdAccount < ActiveRecord::Base
  belongs_to :pureftpd_user
  belongs_to :domain

  def domain
    Domain.find_by_id domain_id
  end

  def full_username
    username + '@' + domain.domain
  end

  validates_presence_of :pureftpd_user_id, :password, :username, :domain_id
  validates_format_of :username, :with => /\A[a-z][a-z0-9_-]*\Z/
  validates_format_of :root, :with => /\A[a-zA-Z0-9_\-\/.\s]*\Z/
  validates_uniqueness_of :username, :scope => :domain_id
  validate :passwords_match, :legal_domain, :legal_root

  attr_accessor :password_confirmation

  def passwords_match
    errors.add(:password_confirmation, "doesn't match password") if password_confirmation && password_confirmation != password
  end

  def legal_domain
    errors.add(:domain, "is not yours") unless pureftpd_user && pureftpd_user.user.domains.include?(domain)
  end

  def legal_root
    errors.add(:root, "cannot contain '..'") if root.present? && root.include?("..")
  end

  def before_save
    self.password = User.shadow_password(password) if password_confirmation
  end
end

