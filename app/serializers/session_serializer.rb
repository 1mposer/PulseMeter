class SessionSerializer
  def initialize(session)
    @session = session
  end

  def as_json
    {
      id: @session.id,
      time_in: @session.time_in&.iso8601,
      time_out: @session.time_out&.iso8601,
      duration_minutes: @session.duration_minutes,
      price_per_minute: format_money(@session.price_per_minute),
      estimated_total: format_money(@session.table_total),
      status: @session.status,
      member: member_info,
      table: table_info,
      tag: tag_info,
      opened_via: @session.opened_via,
      purchases_summary: purchases_summary
    }
  end

  private

  def member_info
    return nil unless @session.member
    
    {
      id: @session.member.id,
      name: @session.member.name
    }
  end

  def table_info
    return nil unless @session.table
    
    {
      id: @session.table.id,
      name: @session.table.name
    }
  end

  def tag_info
    return nil unless @session.tag
    
    {
      id: @session.tag.id,
      token: @session.tag.token,
      active: @session.tag.active
    }
  end

  def purchases_summary
    {
      drinks_count: @session.drink_purchases.count,
      drinks_total: format_money(@session.drinks_total),
      food_count: @session.food_purchases.count,
      food_total: format_money(@session.food_total)
    }
  end

  def format_money(amount)
    return "0.00" if amount.nil?
    sprintf("%.2f", amount.to_f)
  end
end
