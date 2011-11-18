#encoding: utf-8
class UsersController < ApplicationController
  inherit_resources
  actions :show
  can_edit_on_the_spot
  before_filter :can_update_on_the_spot?, :only => :update_attribute_on_the_spot
  def show
    show!{
      return redirect_to(user_path(@user.primary)) if @user.primary
      @title = "#{@user.display_name}"
      @backs = @user.backs.project_visible(current_site).confirmed.order(:confirmed_at)
      @backs = @backs.not_anonymous unless @user == current_user or (current_user and current_user.admin)
      @backs = @backs.all
      @projects = current_site.present_projects.where(:user_id => @user.id).order("updated_at DESC")
      @projects = @projects.visible unless @user == current_user
      @projects = @projects.all
    }
  end

  def update_attribute_on_the_spot
    klass, field, id = params[:id].split('__')
    select_data = params[:select_array]
    object = klass.camelize.constantize.find(id)
    local_user_fields = ["bio"]
    if klass == 'user' and not local_user_fields.include?(field)
      updated = object.sn_update_attribute(field, params[:value])
    else
      updated = object.update_attribute(field, params[:value])
    end

    if updated
      if select_data.nil?
        render :text => CGI::escapeHTML(object.send(field).to_s)
      else
        parsed_data = JSON.parse(select_data.gsub("'", '"'))
        render :text => parsed_data[object.send(field).to_s]
      end
    else
      render :text => object.errors.full_messages.join("\n"), :status => 422
    end
  end

  private
  def can_update_on_the_spot?
    user_fields = ["email", "name", "bio", "newsletter", "project_updates"]
    notification_fields = ["dismissed"]
    def render_error; render :text => t('require_permission'), :status => 422; end
    return render_error unless current_user
    klass, field, id = params[:id].split('__')
    return render_error unless klass == 'user' or klass == 'notification'
    if klass == 'user'
      return render_error unless user_fields.include? field
      user = User.find id
      return render_error unless current_user.id == user.id or current_user.admin
    elsif klass == 'notification'
      return render_error unless notification_fields.include? field
      notification = Notification.find id
      return render_error unless current_user.id == notification.user.id
    end
  end
end
