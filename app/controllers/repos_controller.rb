class ReposController < ApplicationController
  def toggle_need_help
    @repo_name = params[:repo]
    @repo = Repo.init_and_toggle_repo(current_user, @repo_name)
    @user_need_help = current_user.need_help_counter
    respond_to do |format|
      format.js
    end
  end

  def update_user_description
    @repo_name = params[:repo]
    @desc = params[:user_description]
    @repo = Repo.init_and_description(current_user, @repo_name, @desc)

    respond_to do |format|
      format.js
    end
  end
end
