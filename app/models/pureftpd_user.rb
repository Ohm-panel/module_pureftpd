class PureftpdUser < ActiveRecord::Base
  belongs_to :user
  has_many :pureftpd_accounts

  validates_presence_of :user_id
  validates_uniqueness_of :user_id

  def user
    User.find_by_id user_id
  end

  def used_accounts_total
    # What user uses
    used = pureftpd_accounts.count
    # What's given to sub-users
    user.users.each do |u|
      ftpuser = PureftpdUser.find(:first, :conditions => { :user_id => u.id })
      used += ftpuser ? ftpuser.max_accounts : 0
    end
    used
  end

  def free_accounts
    return -1 if max_accounts == -1
    max_accounts - used_accounts_total
  end

  validate :check_quota

  def check_quota
    return if user.nil? # Rejected anyway, don't need to crash here

    # Fill blank quotas
    self.max_accounts = -1 if max_accounts.blank? || max_accounts < 0

    # Root can do anything
    return if user.root?
    return if user.parent.root?

    # Compute quotas to take from parent
    oldme = id ? PureftpdUser.find(id) : nil
    accounts_to_take = max_accounts - ((oldme && max_accounts!=-1) ? oldme.max_accounts : 0)

    # See if we can take that much
    parent = PureftpdUser.find(:first, :conditions => { :user_id => user.parent.id })
    errors.add(:max_accounts, "is more than you can give") unless User.quota_ok parent.free_accounts, accounts_to_take
  end
end

