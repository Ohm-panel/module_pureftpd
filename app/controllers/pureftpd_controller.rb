class PureftpdController < ApplicationController
  unloadable
  before_filter :authenticate

  def controller_name
    "FTP"
  end

  def index
    redirect_to :controller => 'pureftpd_accounts'
  end

  def addtodomain
    # This service is not "per domain"
    @domain = Domain.find(params[:domain_id])
    @service = Service.find(params[:service_id])
    @domain.services.delete @service

    flash[:error] = "This is a global service, you cannot add it to a domain"
    redirect_to @domain
  end

  def addtouser
    redirect_to :controller => 'pureftpd_users', :action => 'new', :user_id => params[:user_id]
  end

  def removefromuser
    usertodel = PureftpdUser.find(:first, :conditions => { :user_id => params[:user_id] })
    usertodel.destroy unless usertodel.nil?

    flash[:notice] = "Service removed"
    redirect_to User.find(params[:user_id])
  end

  def showuser
    redirect_to :controller => 'pureftpd_users', :action => 'show', :user_id => params[:user_id]
  end

private

  def authenticate_pureftpd_user
    @logged_pureftpd_user = PureftpdUser.find(:first, :conditions => { :user_id => @logged_user })
    if @logged_pureftpd_user
      true
    elsif @logged_user.root?
      # Create an unlimited account for root and return it
      @logged_pureftpd_user = PureftpdUser.new(:user_id       => @logged_user.id,
                                               :max_accounts  => -1)
      @logged_pureftpd_user.save
      true
    else
      flash[:error] = "You don't have access to this service. If you think you should, please contact your administrator."
      redirect_to :controller => 'dashboard'
      false
    end
  end
end

