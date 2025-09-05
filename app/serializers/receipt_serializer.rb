class ReceiptSerializer
  def initialize(session)
    @session = session
  end

  def as_json
    {
      session_id: @session.id,
      started_at: @session.time_in&.iso8601,
      ended_at: @session.time_out&.iso8601,
      duration_minutes: @session.duration_minutes,
      price_per_minute: format_money(@session.price_per_minute),
      table: table_info,
      member: member_info,
      charges: {
        table_time_total: format_money(@session.table_total),
        drinks: drinks_charges,
        food: food_charges
      },
      sub_total: format_money(@session.subtotal),
      tax_amount: format_money(0), # Tax calculation can be added later
      grand_total: format_money(@session.grand_total),
      voided: @session.voided?
    }
  end

  private

  def table_info
    return nil unless @session.table
    
    {
      id: @session.table.id,
      name: @session.table.name
    }
  end

  def member_info
    return nil unless @session.member
    
    {
      id: @session.member.id,
      name: @session.member.name
    }
  end

  def drinks_charges
    @session.drink_purchases.includes(:item).map do |purchase|
      {
        item_id: purchase.item.id,
        name: purchase.item.name,
        qty: purchase.quantity,
        unit_price: format_money(purchase.unit_price_at_sale),
        total: format_money(purchase.total_price)
      }
    end
  end

  def food_charges
    @session.food_purchases.includes(:item).map do |purchase|
      {
        item_id: purchase.item.id,
        name: purchase.item.name,
        qty: purchase.quantity,
        unit_price: format_money(purchase.unit_price_at_sale),
        total: format_money(purchase.total_price)
      }
    end
  end

  def format_money(amount)
    return "0.00" if amount.nil?
    sprintf("%.2f", amount.to_f)
  end
end
