# TODO: Do we need the require here at all? Or put it somewhere else for autoload?
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'securerandom'

class UpdatesController < ApplicationController
  def index
    @move = current_user.moves.last # We select the last created move as current
    @updates = policy_scope(Update).where(move: @move)
  end

  # This method creates all updates for the current move
  def create_updates
    @move = current_move
    if @move.present?
      # Checking if user is allowed to start the move
      authorize @move
      @move.updates.destroy_all # if updates_new?
      @my_providers = current_user.my_providers
      @my_providers.each do |my_provider|
        Update.create(move: @move, provider: my_provider.provider, id_sent: my_provider.identifier_value, update_status: Update::STATUS[0])
      end
      redirect_to move_updates_path(@move)
    else
      skip_authorization
      flash[:alert] = "Please make sure your new address and move date are set."
      redirect_to my_providers_path
    end
  end

  # This method sends out updates
  def send_updates
    @move = current_user.moves.last
    authorize @move
    updates = @move.updates.includes(:provider)

    # Here we should actually do some sending; for now just changing the status
    updates.each do |update|
      update.update(update_status: Update::STATUS[1]) # Muahaha
      if update.provider.update_method == "api" && update.provider.api_endpoint.present?
        ApiSendJob.perform_later(update)
        next
      end
      if update.provider.update_method.blank?
        PDF.create(parent: update, uuid: SecureRandom.uuid)
      end
    end

    flash[:notice] = "Hooray! We're informing your providers, please come back later to check the updates."
    redirect_to my_providers_path
  end

  def updates_new?
    @move.updates.all? { |update| update.update_status == Update::STATUS[0] }
  end
end
