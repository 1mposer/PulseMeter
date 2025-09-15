class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :update, :assign_member, :void]

  rescue_from ActionController::ParameterMissing do |e|
    render json: ErrorSerializer.from_messages(e.message), status: :bad_request
  end

  def create
    @session = Session.new(session_params)

    if @session.save
      turn_on_plug
      render json: SessionSerializer.new(@session).as_json, status: :created
    else
      render json: ErrorSerializer.from_active_record(@session), status: :unprocessable_entity
    end
  end

  def update
    @session = Session.find(params[:id])
    
    begin
      Sessions::Complete.call(session: @session, params: session_params)
      turn_off_plug
      render json: ReceiptSerializer.new(@session).as_json, status: :ok
    rescue ArgumentError => e
      render json: ErrorSerializer.from_messages(e.message), status: :unprocessable_entity
    end
  end

  def show
    @session = Session.find(params[:id])
    
    if @session.closed?
      render json: ReceiptSerializer.new(@session).as_json, status: :ok
    else
      render json: SessionSerializer.new(@session).as_json, status: :ok
    end
  end

  def assign_member
    @session = Session.find(params[:id])
    @session.update!(membership_id: params[:membership_id])
    
    render json: SessionSerializer.new(@session).as_json, status: :ok
  end

  def void
    @session = Session.find(params[:id])
    
    unless @session.time_out.nil? && @session.voided_at.nil?
      render json: ErrorSerializer.from_messages("Session is not open"), status: :unprocessable_entity
      return
    end

    @session.update!(
      voided_at: Time.zone.now,
      void_reason: params[:reason].presence || "staff_play"
    )

    render json: VoidSerializer.new(@session).as_json
  end

  def create_drink_purchase
    @session = Session.find(params[:id])
    @item = Item.find(params[:item_id])
    
    unless @session.open?
      render json: ErrorSerializer.from_messages("Session must be open to add purchases"), status: :unprocessable_entity
      return
    end

    unless @item.drink?
      render json: ErrorSerializer.from_messages("Item must be a drink"), status: :unprocessable_entity
      return
    end

    @purchase = @session.drink_purchases.build(
      item: @item,
      member: @session.member,
      quantity: params[:quantity] || 1,
      unit_price_at_sale: @item.current_price
    )

    if @purchase.save
      render json: PurchaseSerializer.new(@purchase).as_json, status: :created
    else
      render json: ErrorSerializer.from_active_record(@purchase), status: :unprocessable_entity
    end
  end

  def create_food_purchase
    @session = Session.find(params[:id])
    @item = Item.find(params[:item_id])
    
    unless @session.open?
      render json: ErrorSerializer.from_messages("Session must be open to add purchases"), status: :unprocessable_entity
      return
    end

    unless @item.food?
      render json: ErrorSerializer.from_messages("Item must be a food item"), status: :unprocessable_entity
      return
    end

    @purchase = @session.food_purchases.build(
      item: @item,
      member: @session.member,
      quantity: params[:quantity] || 1,
      unit_price_at_sale: @item.current_price
    )

    if @purchase.save
      render json: PurchaseSerializer.new(@purchase).as_json, status: :created
    else
      render json: ErrorSerializer.from_active_record(@purchase), status: :unprocessable_entity
    end
  end

  private

  def session_params
    params.require(:session).permit(:time_in, :time_out, :price_per_minute, :membership_id, :table_id, :tag_id, :opened_via)
  end


  def turn_on_plug
    # TODO: Implement actual plug control logic
    Rails.logger.info "Turning on plug for session #{@session.id}"
  end

  def turn_off_plug
    # TODO: Implement actual plug control logic
    Rails.logger.info "Turning off plug for session #{@session.id}"
  end
end
