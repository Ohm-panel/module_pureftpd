### Ohm PureFTPd module <http://joelcogen.com/projects/ohm/> ###
#
# Accounts controller
#
# Copyright (C) 2010 Joel Cogen <http://joelcogen.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this module. If not, see <http://www.gnu.org/licenses/>.
#
# This program incorporates work covered by the following copyright and
# permission notice:
#
#   Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#
#   - Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   - Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#   - Neither the name of UMONS nor the names of its contributors may be used
#     to endorse or promote products derived from this software without specific
#     prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#   POSSIBILITY OF SUCH DAMAGE.

class PureftpdAccountsController < PureftpdController
  before_filter :authenticate_pureftpd_user

  def controller_name
    "FTP"
  end

  def index
    @accounts = @logged_pureftpd_user.pureftpd_accounts
  end

  def new
    @account = PureftpdAccount.new
  end

  def edit
    @account = PureftpdAccount.find(params[:id])

    unless @account.pureftpd_user == @logged_pureftpd_user
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    end
  end

  def create
    @account = PureftpdAccount.new(params[:pureftpd_account])
    @account.pureftpd_user = @logged_pureftpd_user

    if @account.save
      flash[:notice] = "Account successfully created.#{@@changes}"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def update
    @account = PureftpdAccount.find(params[:id])
    @newatts = params[:pureftpd_account]
    if @newatts[:password] == ''
      @newatts[:password_confirmation] = nil
      @newatts[:password] = @account.password
    end

    if not @account.pureftpd_user == @logged_pureftpd_user
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    elsif @account.update_attributes(params[:pureftpd_account])
      flash[:notice] = @account.username + " was successfully updated.#{@@changes}"
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @account = PureftpdAccount.find(params[:id])

    if @account.pureftpd_user == @logged_pureftpd_user
      @account.destroy

      flash[:notice] = @account.username + " was successfully deleted.#{@@changes}"
      redirect_to :action => 'index'
    else
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    end
  end
end

