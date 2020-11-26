class ProvidersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    skip_policy_scope
    @providers = Provider.all

    if user_signed_in?
      @selected_ids = current_user.my_providers.pluck(:provider_id)
    else
      redirect_to user_session_path, notice: "Please log in first"
    end

    @icons = { plus: ActionController::Base.helpers.image_url("icons/plus.svg"),
               check: ActionController::Base.helpers.image_url("icons/checked.svg") }
               
  end

  def show
    @provider = Provider.find(params[:id])
    authorize @provider
  end

  def edit
    authorize @provider
  end

  def update
    authorize @provider
  end

  def destroy
    authorize @provider
  end
end
