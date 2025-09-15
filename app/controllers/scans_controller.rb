class ScansController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:open]

  def open
    tag = Tag.find_by(token: params[:tag_token])
    
    unless tag
      render json: ErrorSerializer.from_messages("Tag not found"), status: :not_found
      return
    end

    unless tag.active?
      render json: ErrorSerializer.from_messages("Tag is inactive"), status: :unprocessable_entity
      return
    end

    table = tag.table
    existing_session = Session.open_only.where(table_id: table.id).first

    if existing_session
      Rails.logger.info "ScanOpen: tag=#{tag.token} table_id=#{table.id} applied_price=N/A existing_session=true"
      render json: SessionSerializer.new(existing_session).as_json, status: :ok
    else
      # Determine price_per_minute: use param if provided, otherwise table default
      price_per_minute = params[:price_per_minute].presence || table.default_price_per_minute
      
      session_params = {
        table_id: table.id,
        tag_id: tag.id,
        time_in: Time.zone.now,
        price_per_minute: price_per_minute,
        opened_via: "scan"
      }

      Rails.logger.info "ScanOpen: tag=#{tag.token} table_id=#{table.id} applied_price=#{price_per_minute} existing_session=false"
      session = Session.create!(session_params)

      render json: SessionSerializer.new(session).as_json, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: ErrorSerializer.from_messages(e.message), status: :unprocessable_entity
  end
end


